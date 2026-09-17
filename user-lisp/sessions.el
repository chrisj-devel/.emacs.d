;;; sessions.el --- Feature-in-flight session layer -*- lexical-binding: t; -*-
;;; Commentary:
;; A session = (worktree, tickets/<feature>/, agent buffer, tab), derived
;; from disk and live buffers on every access — never persisted.  Every
;; worktree of the repo in hand is a session, the main checkout included —
;; it is where the branch work lands, so it is worth a tab like any other.
;; An agent-shell buffer outside any worktree is a bare session.
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

(defcustom my/session-stale-threshold 25
  "Commits behind base at which the dashboard calls a session stale.
Being a little behind is the normal state of an active repo; the number
worth reacting to is repo-specific, so set this per repo in its
.dir-locals.el where the default does not fit."
  :type 'natnum
  :safe #'natnump)

(defcustom my/session-linked-paths nil
  "Repo-relative paths to symlink from the main checkout into a new worktree.
For what a worktree needs in order to run but git does not carry:
gitignored configuration, credentials, and installed dependencies.  An
entry the main checkout lacks is skipped.

Set this per repo in its .dir-locals.el.  It is read from the root the
session is spawned off, not from the buffer in hand."
  :type '(repeat string)
  :safe (lambda (v) (and (listp v) (seq-every-p #'stringp v))))

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

(defun my/session--git-succeeds-p (dir &rest args)
  "Non-nil when git ARGS exits zero in DIR.
For the plumbing that answers by exit status — `merge-base --is-ancestor',
`rev-parse --verify' — where `my/session--git' would signal instead."
  (zerop (apply #'call-process "git" nil nil nil
                "-C" (expand-file-name dir) args)))

(defun my/session--linked-worktree-p (root)
  "Non-nil when ROOT is a linked git worktree (not the main checkout)."
  (and (file-directory-p root)
       (condition-case nil
           (not (file-equal-p
                 (my/session--git root "rev-parse" "--path-format=absolute" "--git-dir")
                 (my/session--git root "rev-parse" "--path-format=absolute" "--git-common-dir")))
         (error nil))))

(defun my/session--main-root (root)
  "Main checkout root for ROOT.
A linked worktree resolves to the checkout it was created from.  Anything
else resolves to its own toplevel — notably a submodule, whose common dir
lives under its superproject and so names no checkout at all."
  (file-name-as-directory
   (if (my/session--linked-worktree-p root)
       (directory-file-name
        (file-name-directory
         (directory-file-name
          (my/session--git root "rev-parse" "--path-format=absolute" "--git-common-dir"))))
     (my/session--git root "rev-parse" "--show-toplevel"))))

(defun my/session--branch (root)
  (condition-case nil
      (my/session--git root "rev-parse" "--abbrev-ref" "HEAD")
    (error nil)))

(defun my/session--remote (root)
  "Remote of the repo at ROOT: origin when it has one, else the first named."
  (let ((remotes (split-string (my/session--git root "remote") "\n" t)))
    (cond ((member "origin" remotes) "origin")
          (remotes (car remotes)))))

(defun my/session--default-branch (root)
  "Name of ROOT's default branch, unqualified by any remote.
`<remote>/HEAD' names it.  A repo whose remote HEAD was never probed, or
which has no remote at all, falls back to the branch its main checkout is
on — the base spawning has always used."
  (or (when-let* ((remote (my/session--remote root)))
        (ignore-errors
          (string-remove-prefix
           (concat remote "/")
           (my/session--git root "symbolic-ref" "--short"
                            (format "refs/remotes/%s/HEAD" remote)))))
      (my/session--branch (my/session--main-root root))))

(defun my/session--base-ref (root &optional fetch)
  "Ref new work off ROOT forks from, or nil when it cannot be settled.
The default branch exists twice — locally and on the remote — and which
one leads depends on how the repo is worked: a repo whose main lands
through PRs has <remote>/main running ahead of the checkout, while one
merged locally and pushed later has it the other way round.  Whichever
contains the other is the base.  Neither containing the other means the
two have diverged, which is a thing to look at rather than guess past,
and answers nil.

With FETCH, refresh the remote branch first.  Without it the remote ref
is read as last fetched, so a caller that runs often — the dashboard —
costs no network."
  (when-let* ((branch (my/session--default-branch root)))
    (let* ((remote (my/session--remote root))
           (tracking (and remote (concat remote "/" branch))))
      (when (and fetch tracking)
        ;; Offline, or a branch the remote dropped: the ref simply stays as
        ;; last seen, which is still a better base than HEAD in hand.
        (my/session--git-succeeds-p root "fetch" remote branch))
      (cl-flet ((exists-p (ref)
                  (and ref (my/session--git-succeeds-p
                            root "rev-parse" "--verify" "--quiet" ref)))
                (contains-p (a b)
                  (my/session--git-succeeds-p root "merge-base" "--is-ancestor" a b)))
        (cond ((not (exists-p tracking)) branch)
              ((not (exists-p branch)) tracking)
              ((contains-p branch tracking) tracking)
              ((contains-p tracking branch) branch))))))

(defun my/session--behind (root base)
  "Commits on BASE that the checkout at ROOT lacks, nil when uncountable."
  (ignore-errors
    (string-to-number
     (my/session--git root "rev-list" "--count" (concat "HEAD.." base)))))

(defun my/session-behind (session &optional base)
  "Commits on BASE that SESSION lacks, nil when there is no base to count from.
BASE defaults to the one `my/session--base-ref' derives for SESSION's own
root, read without fetching."
  (when-let* ((root (my/session-root session))
              (base (or base (ignore-errors (my/session--base-ref root)))))
    (my/session--behind root base)))

(defun my/session-drift-report (root)
  "One line on how far the checkout at ROOT trails its base.
For a caller outside Emacs: the agent working a session reads staleness
through `emacsclient --eval\=' rather than running the comparison itself,
so which side of the default branch leads is decided here only and a
second copy of the rule cannot drift from this one.  Fetches, being run
once at the start of a run."
  (let ((root (expand-file-name root)))
    (if-let* ((base (my/session--base-ref root t)))
        (if-let* ((behind (my/session--behind root base)))
            (if (zerop behind)
                (format "current with %s" base)
              (format "%d commit%s behind %s" behind (if (= behind 1) "" "s") base))
          (format "cannot count against %s" base))
      (format "%s has diverged from its remote"
              (or (ignore-errors (my/session--default-branch root)) root)))))

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

(defun my/session--repos ()
  "Known main checkouts, each linked worktree folded into the one it came from.
`project-known-project-roots' also holds every worktree `my/session-spawn'
remembered, and a session command always means the checkout behind one."
  (seq-uniq
   (mapcar (lambda (root)
             (or (ignore-errors (my/session--main-root root))
                 (expand-file-name root)))
           (seq-filter #'file-directory-p
                       (seq-remove #'file-remote-p (project-known-project-roots))))
   #'file-equal-p))

(defun my/session--read-repo ()
  "Read a main checkout, completing over the known ones.
Not `project-prompter': its candidates are every known root, worktrees
included.  A path outside the list is still accepted."
  (expand-file-name
   (completing-read "Repo: " (mapcar #'abbreviate-file-name (my/session--repos)))))

(defun my/session--repo-root (&optional prompt)
  "Main checkout of the repo at point, read when there is none or with PROMPT."
  (or (and (not prompt)
           (not (file-remote-p default-directory))
           (ignore-errors (my/session--main-root default-directory)))
      (my/session--read-repo)))

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
answers in one call, and take them all: the main checkout is a worktree
git names like the rest, and a repo's own state is a thing to sit in.
Without REPO every known project root is stat'd — including remote ones,
where that alone opens a Tramp connection — and only linked worktrees
count, since a project root is not a session merely by being known.
An agent sitting outside those roots is listed either way: as the
worktree it runs in, or bare when it runs in no repo at all."
  (let (sessions roots)
    (dolist (root (if repo
                      (mapcar #'cdr (my/session--worktrees repo))
                    (seq-remove #'file-remote-p (project-known-project-roots))))
      (when (or repo (my/session--linked-worktree-p root))
        (push root roots)
        (let ((branch (my/session--branch root)))
          (push (make-my/session
                 :name (or branch (file-name-nondirectory (directory-file-name root)))
                 :root (expand-file-name root)
                 :branch branch
                 :agent-buffer (my/session--agent-buffer root))
                sessions))))
    ;; Agents running outside those roots.  Each is rooted at the worktree it
    ;; sits in, so its name, tab and worktree removal match the session the
    ;; worktree's own repo derives; only an agent in no repo at all is bare.
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (and (derived-mode-p 'agent-shell-mode)
                   (not (seq-some (lambda (root)
                                    (file-in-directory-p default-directory root))
                                  roots)))
          (let* ((top (ignore-errors
                        (my/session--git default-directory "rev-parse" "--show-toplevel")))
                 (root (expand-file-name (or top default-directory)))
                 (branch (and top (my/session--branch root))))
            (push root roots)
            (push (make-my/session
                   :name (cond (branch branch)
                               (top (file-name-nondirectory (directory-file-name root)))
                               (t (format "adhoc: %s" (abbreviate-file-name root))))
                   :root root
                   :branch branch
                   :agent-buffer buffer)
                  sessions)))))
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

(defun my/session-feature (session)
  "Feature SESSION is in flight on: the last component of its branch.
A branch is often namespaced — feature/foo, chris/foo — while the ticket
it works through is tickets/foo.org.  A session on no branch has none."
  (when-let* ((branch (my/session-branch session)))
    (file-name-nondirectory branch)))

(defun my/session-ticket-file (session)
  "Ticket file tickets/<feature>.org for SESSION, when it exists."
  (when-let* ((feature (my/session-feature session))
              (file (expand-file-name
                     (concat my/session-tickets-subdir "/" feature ".org")
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

(defun my/session-tab-name (session)
  "Name of SESSION's work tab, qualified by repo.
Tabs share one namespace across the frame while session names are unique
only within a repo: every main checkout is a session named for its
default branch.  A session outside any repo keeps its own name, already
a path."
  (if-let* ((main (ignore-errors (my/session--main-root (my/session-root session)))))
      (format "%s/%s"
              (file-name-nondirectory (directory-file-name main))
              (my/session-name session))
    (my/session-name session)))

(defun my/session-browse-tab-name (session)
  "Name of SESSION's browse tab."
  (concat (my/session-tab-name session) my/session-browse-tab-suffix))

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
  (my/session--open-tab (my/session-tab-name session)
                        (lambda () (my/session-layout session))))

(defun my/session-browse (session)
  "Jump to SESSION's browse tab, creating tab and layout when missing."
  (interactive (list (my/session--read "Browse session: ")))
  (my/session--open-tab (my/session-browse-tab-name session)
                        (lambda () (my/session-browse-layout session))))

;;; Lifecycle

(defun my/session--linked-paths (root)
  "Value of `my/session-linked-paths' for the repo at ROOT.
Read from ROOT's directory-local variables rather than from the current
buffer: the session being spawned need not belong to the project in hand."
  (with-temp-buffer
    (setq default-directory (file-name-as-directory (expand-file-name root)))
    (hack-dir-local-variables)
    (alist-get 'my/session-linked-paths file-local-variables-alist
               my/session-linked-paths)))

(defun my/session--link (main worktree path)
  "Symlink PATH under WORKTREE to its counterpart under MAIN.
Skips PATH when MAIN does not have it or WORKTREE already does.  The link
points at the truename, so a MAIN that reaches PATH through a symlink of
its own is replicated rather than chained through."
  (let ((source (expand-file-name path main))
        (target (expand-file-name path worktree)))
    (when (and (file-exists-p source)
               (not (or (file-exists-p target) (file-symlink-p target))))
      (make-directory (file-name-directory (directory-file-name target)) t)
      (make-symbolic-link (file-truename source) target))))

(defun my/session--spawn-base (root)
  "Ref to branch a new session off ROOT from, nil to leave the choice to git.
Nil when ROOT has no default branch to speak of — a detached main
checkout — where git's own answer, HEAD in hand, is the base spawning has
always used.  A default branch that has diverged from its remote is read
from the user: the two are equally defensible bases and only one of them
is the one meant."
  (when-let* ((branch (my/session--default-branch root)))
    (or (my/session--base-ref root t)
        (completing-read
         (format "%s has diverged from its remote; branch off: " branch)
         (list branch (concat (my/session--remote root) "/" branch))
         nil t))))

(defun my/session-spawn (repo-root feature)
  "Create worktree, branch, and ticket scaffold for FEATURE off REPO-ROOT.
Interactively the repo is the one at point; a prefix argument reads it."
  (interactive
   (let ((root (my/session--repo-root current-prefix-arg)))
     (list root (completing-read "Feature: " (my/session--features root)))))
  (let ((worktree (funcall my/session-worktree-directory-function repo-root feature))
        (base (my/session--spawn-base repo-root)))
    (unless (file-directory-p worktree)
      (condition-case nil
          (apply #'my/session--git repo-root "worktree" "add" "-b" feature worktree
                 (and base (list base)))
        ;; Branch already exists: check it out instead, at wherever it left off.
        (error (my/session--git repo-root "worktree" "add" worktree feature))))
    (project-remember-project (project-current nil worktree))
    (dolist (path (my/session--linked-paths repo-root))
      (my/session--link repo-root worktree path))
    (let* ((source (expand-file-name my/session-tickets-subdir repo-root))
           (external (and (file-symlink-p source) (file-truename source)))
           (base (expand-file-name my/session-tickets-subdir worktree))
           (feature (file-name-nondirectory feature))
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
  "Kill SESSION's buffers, close its tab, and remove its worktree.
The main checkout is a session too and is never removed; tearing it down
closes its tabs and kills its agent, and it is derived again next time."
  (interactive (list (my/session--read "Tear down session: ")))
  (let* ((name (or (my/session-feature session) (my/session-name session)))
         (root (my/session-root session))
         ;; Read before the worktree goes: a tab name is qualified by the repo
         ;; behind the root, which removal takes away.
         (tabs (list (my/session-tab-name session)
                     (my/session-browse-tab-name session)))
         (linked (my/session--linked-worktree-p root)))
    (when (yes-or-no-p
           (if linked
               (format "Tear down %s (removes worktree %s)? " name root)
             (format "Tear down %s (keeps the checkout %s)? " name root)))
      (let ((dirty (and linked
                        (not (string-empty-p
                              (my/session--git root "status" "--porcelain"))))))
        (when (and dirty
                   (not (yes-or-no-p
                         (format "%s has uncommitted changes; remove anyway? " name))))
          (user-error "Teardown of %s aborted" name))
        ;; Named rather than taken from `default-directory', which for a root
        ;; outside every known project would otherwise prompt.
        (when-let* ((project (project-current nil root)))
          (project-kill-buffers t project))
        (when linked
          (let ((main (my/session--main-root root)))
            (apply #'my/session--git main "worktree" "remove"
                   (append (and dirty '("--force")) (list root)))
            ;; `project-forget-project' matches with `assoc', against a list
            ;; project.el stores abbreviated and as directory names; `git
            ;; worktree list' answers neither.
            (project-forget-project
             (abbreviate-file-name (file-name-as-directory root))))))
      (when-let* ((buffer (my/session-agent-buffer session)))
        (kill-buffer buffer))
      (dolist (tab tabs)
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

(defun my/session--behind-label (behind)
  (cond ((null behind) (propertize "–" 'face 'shadow))
        ((zerop behind) (propertize "current" 'face 'shadow))
        ((>= behind my/session-stale-threshold)
         (propertize (format "↓%d" behind) 'face 'error))
        (t (propertize (format "↓%d" behind) 'face 'shadow))))

(defun my/session-dashboard--entries ()
  ;; One base per repo rather than one per session: deriving it shells out,
  ;; and every session of a repo forks from the same answer.
  (let ((bases (make-hash-table :test #'equal)))
    (cl-flet ((base (root)
                (let ((main (or (ignore-errors (my/session--main-root root)) root)))
                  (with-memoization (gethash main bases)
                    (ignore-errors (my/session--base-ref main))))))
      (mapcar (lambda (session)
                (let ((root (my/session-root session)))
                  (list session
                        (vector (my/session-name session)
                                (my/session--status-label (my/session-status session))
                                (my/session--behind-label
                                 (my/session-behind session (base root)))
                                (if-let* ((buffer (my/session-agent-buffer session)))
                                    (buffer-name buffer)
                                  "")
                                (abbreviate-file-name root)))))
              (my/sessions my/session-dashboard--repo)))))

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

(defun my/session-dashboard-spawn ()
  "Spawn a session off the repo this dashboard lists.
The dashboard buffer outlives the directory it was opened from, so its
own `default-directory' is no answer; `my/session-dashboard--repo' is."
  (interactive)
  (let ((repo my/session-dashboard--repo))
    (my/session-spawn repo (completing-read "Feature: " (my/session--features repo)))))

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
  "n" #'my/session-dashboard-spawn
  "k" #'my/session-dashboard-teardown)

(define-derived-mode my/session-dashboard-mode tabulated-list-mode "Sessions"
  "Mission control for feature-in-flight sessions."
  (setq tabulated-list-format
        [("Feature" 28 t) ("Status" 12 t) ("Base" 9 t) ("Agent" 30 t) ("Root" 40 t)])
  (setq tabulated-list-padding 1)
  (add-hook 'tabulated-list-revert-hook
            (lambda () (setq tabulated-list-entries (my/session-dashboard--entries)))
            nil t)
  (tabulated-list-init-header))

(defun my/session-dashboard--buffer (repo)
  "The dashboard buffer, printed with REPO's sessions.
A nil REPO lists what `my/sessions' derives without one: every linked
worktree of every known project, plus any agent outside them."
  (with-current-buffer (get-buffer-create my/session-dashboard-buffer)
    (unless (derived-mode-p 'my/session-dashboard-mode)
      (my/session-dashboard-mode))
    ;; After the mode, which kills buffer-local variables.
    (setq my/session-dashboard--repo repo)
    (setq tabulated-list-entries (my/session-dashboard--entries))
    (tabulated-list-print t)
    (current-buffer)))

(defun my/session-dashboard (repo)
  "Show mission control: REPO's sessions with agent status.
REPO is the repo at point, prompted for when there is none.  It is read
before the dashboard buffer is current, whose own `default-directory'
would otherwise decide it."
  (interactive (list (my/session--repo-root)))
  (pop-to-buffer (my/session-dashboard--buffer repo)))

;;; Keys

;; A real prefix map rather than six global bindings: which-key then has a
;; name for the prefix, and dashboard.el reads the pane it renders out of the
;; map itself, so the two cannot drift apart.
(defvar-keymap my/session-map
  :doc "Session lifecycle and navigation."
  "d" #'my/session-dashboard
  "n" #'my/session-spawn
  "j" #'my/session-open
  "b" #'my/session-browse
  "k" #'my/session-teardown)

(fset 'my/session-map my/session-map)

(keymap-global-set "C-c s" 'my/session-map)
(keymap-global-set "<f6>" #'my/session-dashboard)

(provide 'sessions)
;;; sessions.el ends here
