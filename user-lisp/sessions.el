;;; sessions.el --- Feature-in-flight session layer -*- lexical-binding: t; -*-
;;; Commentary:
;; A session = (worktree, tickets/<feature>/, agent buffer, tab), derived
;; from disk and live buffers on every access — never persisted.  A linked
;; git worktree of the repo in hand is a session; an agent-shell buffer
;; outside any worktree is a bare session.
;;
;; A session has two layouts, each in its own tab: the work tab (ticket +
;; agent) and the browse tab (dirvish sidebar + code).
;;
;; Lifecycle: `my/session-spawn' -> work -> `my/session-teardown'.
;; Mission control: `my/session-dashboard'.
;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'subr-x)
(require 'project)
(require 'recentf)
(require 'tab-bar)
(require 'tabulated-list)

(declare-function agent-shell-status "agent-shell")
(declare-function agent-shell "agent-shell")
(declare-function dirvish-side "dirvish-side")

(defgroup my/sessions nil
  "Feature-in-flight sessions over git worktrees."
  :group 'convenience)

(defcustom my/session-tickets-subdir "tickets"
  "Directory under a root holding <feature>.org ticket files."
  :type 'string)

(defcustom my/session-ticket-template
  "#+title: %s\n\n* %s\n:PROPERTIES:\n:FEATURE: %s\n:KIND: prd\n:END:\n\n** Problem Statement\n\n** Solution\n"
  "Template for a new feature ticket file; %s is the feature name."
  :type 'string)

(defcustom my/session-browse-tab-suffix " code"
  "Suffix distinguishing a session's browse tab from its work tab."
  :type 'string)

(defcustom my/session-worktree-directory-function
  #'my/session-default-worktree-directory
  "Function from (REPO-ROOT FEATURE) to the worktree path to create."
  :type 'function)

(defun my/session-default-worktree-directory (repo-root feature)
  "Directory worktrees/<repo>/<FEATURE> beside REPO-ROOT."
  (let ((repo (directory-file-name (expand-file-name repo-root))))
    (expand-file-name (format "worktrees/%s/%s" (file-name-nondirectory repo) feature)
                      (file-name-directory repo))))

(cl-defstruct my/session name root branch agent-buffer)

;;; Git plumbing

(defun my/session--git (dir &rest args)
  "Run git ARGS in DIR, returning trimmed stdout or signaling an error."
  (with-temp-buffer
    (let ((status (apply #'call-process "git" nil t nil
                         "-C" (expand-file-name dir) args)))
      (unless (zerop status)
        (error "git %s: %s" (string-join args " ")
               (string-trim (buffer-string))))
      (string-trim (buffer-string)))))

(defun my/session--linked-worktree-p (root)
  "Non-nil when ROOT is a linked git worktree (not the main checkout)."
  (and (file-directory-p root)
       (condition-case nil
           (not (file-equal-p
                 (my/session--git root "rev-parse" "--path-format=absolute" "--git-dir")
                 (my/session--git root "rev-parse" "--path-format=absolute" "--git-common-dir")))
         (error nil))))

(defun my/session--main-root (root)
  "Main checkout root for the worktree at ROOT."
  (file-name-directory
   (directory-file-name
    (my/session--git root "rev-parse" "--path-format=absolute" "--git-common-dir"))))

(defun my/session--branch (root)
  (condition-case nil
      (my/session--git root "rev-parse" "--abbrev-ref" "HEAD")
    (error nil)))

(defun my/session--worktrees (root)
  "Alist of (BRANCH . WORKTREE) for every worktree of the repo at ROOT.
Includes the main checkout; a detached worktree has no branch and is omitted."
  (let (out worktree)
    (dolist (line (split-string
                   (my/session--git root "worktree" "list" "--porcelain") "\n")
                  (nreverse out))
      (cond ((string-prefix-p "worktree " line)
             (setq worktree (substring line 9)))
            ((string-prefix-p "branch " line)
             (push (cons (substring line 7) worktree) out))))))

(defun my/session--repo-root ()
  "Main checkout of the repo at point, prompting when there is none."
  (or (and (not (file-remote-p default-directory))
           (ignore-errors (my/session--main-root default-directory)))
      (funcall project-prompter)))

;;; Derivation

(defun my/session--agent-buffer (root)
  "Live agent-shell buffer rooted under ROOT, if any."
  (seq-find (lambda (buffer)
              (with-current-buffer buffer
                (and (derived-mode-p 'agent-shell-mode)
                     (file-in-directory-p default-directory root))))
            (buffer-list)))

(defun my/sessions (&optional repo)
  "Derive the list of live sessions from disk and buffers.
With REPO, consider only that repo's worktrees, which `git worktree list'
answers in one call.  Without it every known project root is stat'd —
including remote ones, where that alone opens a Tramp connection.
Bare sessions belong to no repo, so they are listed either way."
  (let (sessions roots)
    (dolist (root (if repo
                      (mapcar #'cdr (my/session--worktrees repo))
                    (seq-remove #'file-remote-p (project-known-project-roots))))
      (when (my/session--linked-worktree-p root)
        (push root roots)
        (let ((branch (my/session--branch root)))
          (push (make-my/session
                 :name (or branch (file-name-nondirectory (directory-file-name root)))
                 :root (expand-file-name root)
                 :branch branch
                 :agent-buffer (my/session--agent-buffer root))
                sessions))))
    ;; Bare sessions: agents running outside any known worktree.
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (and (derived-mode-p 'agent-shell-mode)
                   (not (seq-some (lambda (root)
                                    (file-in-directory-p default-directory root))
                                  roots)))
          (push (make-my/session
                 :name (format "adhoc: %s" (abbreviate-file-name default-directory))
                 :root default-directory
                 :agent-buffer buffer)
                sessions))))
    (nreverse sessions)))

(defun my/session-status (session)
  "Agent status of SESSION: `busy', `blocked', `ready', or `none'."
  (if-let* ((buffer (my/session-agent-buffer session))
            ((buffer-live-p buffer)))
      (agent-shell-status :shell-buffer buffer)
    'none))

(defun my/session--features (root)
  "Feature names having a ticket file under ROOT."
  (let ((base (expand-file-name my/session-tickets-subdir root)))
    (when (file-directory-p base)
      (mapcar #'file-name-base
              (directory-files base nil "\\`[^.].*\\.org\\'")))))

(defun my/session-ticket-file (session)
  "Ticket file tickets/<feature>.org for SESSION, when it exists."
  (when-let* ((feature (my/session-branch session))
              (file (expand-file-name
                     (concat my/session-tickets-subdir "/"
                             (file-name-nondirectory feature) ".org")
                     (my/session-root session)))
              ((file-exists-p file)))
    file))

(defun my/session--read (prompt)
  "Read a session of the repo at point by name with PROMPT."
  (let* ((sessions (my/sessions (my/session--repo-root)))
         (name (completing-read prompt (mapcar #'my/session-name sessions) nil t)))
    (seq-find (lambda (s) (equal (my/session-name s) name)) sessions)))

;;; Layout and navigation

(defun my/session--start-agent (session)
  "Start an agent shell in SESSION's root and return its buffer."
  (require 'agent-shell)
  (let ((default-directory (my/session-root session)))
    (save-window-excursion (call-interactively #'agent-shell))
    (my/session--agent-buffer (my/session-root session))))

(defun my/session-layout (session)
  "Apply the standard layout: tickets left, agent right."
  (delete-other-windows)
  (if-let* ((ticket (my/session-ticket-file session)))
      (find-file ticket)
    (dired (my/session-root session)))
  (when-let* ((agent (or (and (buffer-live-p (my/session-agent-buffer session))
                              (my/session-agent-buffer session))
                         (my/session--start-agent session))))
    (display-buffer agent '((display-buffer-in-direction)
                            (direction . right)
                            (window-width . 0.5)))))

(defun my/session--recent-file (root)
  "Most recently visited file under ROOT, if any."
  (seq-find (lambda (file)
              (and (file-in-directory-p file root) (file-exists-p file)))
            (mapcar #'expand-file-name recentf-list)))

(defun my/session-browse-layout (session)
  "Apply the browse layout: dirvish sidebar left, code right."
  (require 'dirvish-side)
  (delete-other-windows)
  (let ((root (my/session-root session)))
    (if-let* ((file (my/session--recent-file root)))
        (find-file file)
      (let ((default-directory root))
        (switch-to-buffer "*scratch*")))
    ;; `dirvish-side--new' lays out from `with-selected-window', so point
    ;; stays in the code window.
    (dirvish-side root)))

(defun my/session-browse-tab-name (session)
  "Name of SESSION's browse tab."
  (concat (my/session-name session) my/session-browse-tab-suffix))

(defun my/session--tab-p (name)
  (seq-some (lambda (tab) (equal name (alist-get 'name tab)))
            (funcall tab-bar-tabs-function)))

(defun my/session--open-tab (name layout)
  "Switch to tab NAME, calling LAYOUT on it only when newly created."
  (let ((existing (my/session--tab-p name)))
    (tab-bar-switch-to-tab name)
    (unless existing (funcall layout))))

(defun my/session-open (session)
  "Jump to SESSION's work tab, creating tab and layout when missing."
  (interactive (list (my/session--read "Session: ")))
  (my/session--open-tab (my/session-name session)
                        (lambda () (my/session-layout session))))

(defun my/session-browse (session)
  "Jump to SESSION's browse tab, creating tab and layout when missing."
  (interactive (list (my/session--read "Browse session: ")))
  (my/session--open-tab (my/session-browse-tab-name session)
                        (lambda () (my/session-browse-layout session))))

;;; Lifecycle

(defun my/session-spawn (repo-root feature)
  "Create worktree, branch, and ticket scaffold for FEATURE off REPO-ROOT."
  (interactive
   (let ((root (funcall project-prompter)))
     (list root (completing-read "Feature: " (my/session--features root)))))
  (let ((worktree (funcall my/session-worktree-directory-function repo-root feature)))
    (unless (file-directory-p worktree)
      (condition-case nil
          (my/session--git repo-root "worktree" "add" "-b" feature worktree)
        ;; Branch already exists: check it out instead.
        (error (my/session--git repo-root "worktree" "add" worktree feature))))
    (project-remember-project (project-current nil worktree))
    (let* ((source (expand-file-name my/session-tickets-subdir repo-root))
           (external (and (file-symlink-p source) (file-truename source)))
           (base (expand-file-name my/session-tickets-subdir worktree))
           (file (expand-file-name (concat feature ".org") base)))
      ;; A tracker the repo does not version is one directory shared by every
      ;; worktree, reached by a symlink the main checkout already carries.
      ;; Replicate that link; a fresh worktree would otherwise start empty,
      ;; since git checks out tracked files only.
      (cond ((null external) (make-directory base t))
            ((not (file-symlink-p base)) (make-symbolic-link external base)))
      (unless (file-exists-p file)
        (write-region (format my/session-ticket-template feature feature feature)
                      nil file)))
    (my/session-open
     (make-my/session :name feature :root worktree :branch feature))))

(defun my/session-teardown (session)
  "Kill SESSION's buffers, close its tab, and remove its worktree."
  (interactive (list (my/session--read "Tear down session: ")))
  (let ((name (my/session-name session))
        (root (my/session-root session)))
    (when (yes-or-no-p (format "Tear down %s (removes worktree %s)? " name root))
      (when (my/session--linked-worktree-p root)
        (let ((main (my/session--main-root root))
              (dirty (not (string-empty-p
                           (my/session--git root "status" "--porcelain")))))
          (when (and dirty
                     (not (yes-or-no-p
                           (format "%s has uncommitted changes; remove anyway? " name))))
            (user-error "Teardown of %s aborted" name))
          (let ((default-directory root))
            (project-kill-buffers t))
          (apply #'my/session--git main "worktree" "remove"
                 (append (and dirty '("--force")) (list root)))
          (project-forget-project root)))
      (when-let* ((buffer (my/session-agent-buffer session)))
        (kill-buffer buffer))
      (dolist (tab (list name (my/session-browse-tab-name session)))
        (when (my/session--tab-p tab)
          (tab-bar-close-tab-by-name tab)))
      (message "Session %s torn down (branch kept)" name))))

;;; Mission control

(defvar my/session-dashboard-buffer "*Sessions*")

(defun my/session--status-label (status)
  (pcase status
    ('busy (propertize "● busy" 'face 'warning))
    ('blocked (propertize "✋ blocked" 'face 'error))
    ('ready (propertize "● ready" 'face 'success))
    (_ (propertize "– none" 'face 'shadow))))

(defvar-local my/session-dashboard--repo nil
  "Repo whose sessions this dashboard lists, resolved when it was opened.
Held so reverting does not re-prompt from the dashboard's own buffer.")

(defun my/session-dashboard--entries ()
  (mapcar (lambda (session)
            (list session
                  (vector (my/session-name session)
                          (my/session--status-label (my/session-status session))
                          (if-let* ((buffer (my/session-agent-buffer session)))
                              (buffer-name buffer)
                            "")
                          (abbreviate-file-name (my/session-root session)))))
          (my/sessions my/session-dashboard--repo)))

(defun my/session-dashboard-open ()
  "Open the session at point."
  (interactive)
  (when-let* ((session (tabulated-list-get-id)))
    (my/session-open session)))

(defun my/session-dashboard-browse ()
  "Open the browse tab of the session at point."
  (interactive)
  (when-let* ((session (tabulated-list-get-id)))
    (my/session-browse session)))

(defun my/session-dashboard-teardown ()
  "Tear down the session at point."
  (interactive)
  (when-let* ((session (tabulated-list-get-id)))
    (my/session-teardown session)
    (revert-buffer)))

(defvar-keymap my/session-dashboard-mode-map
  :parent tabulated-list-mode-map
  "RET" #'my/session-dashboard-open
  "b" #'my/session-dashboard-browse
  "n" #'my/session-spawn
  "k" #'my/session-dashboard-teardown)

(define-derived-mode my/session-dashboard-mode tabulated-list-mode "Sessions"
  "Mission control for feature-in-flight sessions."
  (setq tabulated-list-format
        [("Feature" 28 t) ("Status" 12 t) ("Agent" 30 t) ("Root" 40 t)])
  (setq tabulated-list-padding 1)
  (add-hook 'tabulated-list-revert-hook
            (lambda () (setq tabulated-list-entries (my/session-dashboard--entries)))
            nil t)
  (tabulated-list-init-header))

(defun my/session-dashboard (repo)
  "Show mission control: REPO's sessions with agent status.
REPO is the repo at point, prompted for when there is none.  It is read
before the dashboard buffer is current, whose own `default-directory'
would otherwise decide it."
  (interactive (list (my/session--repo-root)))
  (with-current-buffer (get-buffer-create my/session-dashboard-buffer)
    (unless (derived-mode-p 'my/session-dashboard-mode)
      (my/session-dashboard-mode))
    ;; After the mode, which kills buffer-local variables.
    (setq my/session-dashboard--repo repo)
    (setq tabulated-list-entries (my/session-dashboard--entries))
    (tabulated-list-print t)
    (pop-to-buffer (current-buffer))))

;;; Keys

(keymap-global-set "<f6>" #'my/session-dashboard)
(keymap-global-set "C-c s d" #'my/session-dashboard)
(keymap-global-set "C-c s n" #'my/session-spawn)
(keymap-global-set "C-c s j" #'my/session-open)
(keymap-global-set "C-c s b" #'my/session-browse)
(keymap-global-set "C-c s k" #'my/session-teardown)

(provide 'sessions)
;;; sessions.el ends here
