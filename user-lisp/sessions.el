;;; sessions.el --- Feature-in-flight session layer -*- lexical-binding: t; -*-
;;; Commentary:
;; A session = (worktree, tickets/<feature>/, agent buffer, tab), derived
;; from disk and live buffers on every access — never persisted.  Every
;; worktree of the repo in hand is a session, the main checkout included —
;; it is where the branch work lands, so it is worth a tab like any other.
;; An agent-shell buffer outside any worktree is a bare session.
;;
;; A session has three layouts, each in its own tab: the work tab (ticket +
;; agent), the browse tab (dirvish sidebar + code), and the review tab (the
;; branch diffed against its merge base + agent).
;;
;; Spawning is not the only way in: `my/session-review' takes any branch the
;; repo knows, someone else's included, and makes the worktree it needs.
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
(declare-function my/agent-attention-jump "agent-attention")
(declare-function agent-shell "agent-shell")
(declare-function dirvish-side "dirvish-side")
(declare-function vc-responsible-backend "vc")
(declare-function vc-call-backend "vc-hooks")
(declare-function vc-diff-internal "vc")
(declare-function outline-hide-subtree "outline")
(declare-function outline-show-subtree "outline")

;; Let-bound in `my/session--review-diff' before vc has necessarily loaded;
;; the declaration is what keeps that binding dynamic rather than lexical.
(defvar vc-allow-async-diff)

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

(defcustom my/session-review-tab-suffix " review"
  "Suffix distinguishing a session's review tab from its work tab."
  :type 'string)

(defcustom my/review-collapsed-files
  '("\\.spec\\." "\\.test\\." "/__tests__/" "_test\\.")
  "Regexps of repo-relative paths whose diff starts folded in a review."
  :type '(repeat regexp))

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

(defun my/session--divergence (root base)
  "Cons of (BEHIND . AHEAD) between BASE and the checkout at ROOT.
BEHIND counts commits on BASE that ROOT lacks, AHEAD the ones ROOT has
that BASE lacks.  Answers nil when the two cannot be compared.  One
rev-list rather than two: the dashboard asks per session."
  (when-let* ((out (ignore-errors
                     (my/session--git root "rev-list" "--left-right" "--count"
                                      (concat base "...HEAD"))))
              (counts (split-string out))
              ((= (length counts) 2)))
    (cons (string-to-number (nth 0 counts))
          (string-to-number (nth 1 counts)))))

(defun my/session-divergence (session &optional base)
  "Cons of (BEHIND . AHEAD) between BASE and SESSION, nil when uncountable.
BASE defaults to the one `my/session--base-ref' derives for SESSION's own
root, read without fetching."
  (when-let* ((root (my/session-root session))
              (base (or base (ignore-errors (my/session--base-ref root)))))
    (my/session--divergence root base)))

(defun my/session-drift-report (root)
  "One line on how far the checkout at ROOT trails its base.
For a caller outside Emacs: the agent working a session reads staleness
through `emacsclient --eval' rather than running the comparison itself,
so which side of the default branch leads is decided here only and a
second copy of the rule cannot drift from this one.  Fetches, being run
once at the start of a run."
  (let ((root (expand-file-name root)))
    (if-let* ((base (my/session--base-ref root t)))
        (if-let* ((behind (car (my/session--divergence root base))))
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

(defvar-local my/session-dashboard--repo nil
  "Repo whose sessions this dashboard lists, resolved when it was opened.
Held so reverting does not re-prompt from the dashboard's own buffer, and
so a session command run inside it is scoped by what it shows rather than
by the directory the buffer happens to carry.  Declared here, far above
the dashboard, because the scoping is what reads it first.")

(defun my/session--repo-root (&optional prompt)
  "Main checkout of the repo at point, read when there is none or with PROMPT.
A dashboard's own `default-directory' is no answer — the buffer outlives
the directory it was opened from — so the repo it lists stands in, and
the dashboard listing every repo names none, which reads one."
  (or (and (not prompt)
           (if (derived-mode-p 'my/session-dashboard-mode)
               my/session-dashboard--repo
             (and (not (file-remote-p default-directory))
                  (ignore-errors (my/session--main-root default-directory)))))
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

(defun my/session--at (root)
  "The session whose worktree is ROOT, or nil when ROOT is not one.
Matched with `file-equal-p\=': a caller from outside Emacs names the
worktree by whatever path reaches it, which need not be the one git
answers with."
  (seq-find (lambda (session) (file-equal-p (my/session-root session) root))
            (my/sessions (my/session--main-root root))))

(defun my/session--read (prompt &optional pick-repo)
  "Read a session of the repo at point by name with PROMPT.
In a dashboard the candidates are the sessions it lists, which for the
dashboard scoped to no repo is every one it derived.  PICK-REPO, the
prefix argument, reads the repo to offer instead."
  (let* ((sessions (my/sessions (if (and (not pick-repo)
                                         (derived-mode-p 'my/session-dashboard-mode))
                                    my/session-dashboard--repo
                                  (my/session--repo-root pick-repo))))
         (name (completing-read prompt (mapcar #'my/session-name sessions) nil t)))
    (seq-find (lambda (s) (equal (my/session-name s) name)) sessions)))

(defun my/session--read-here (prompt arg)
  "The current tab's session, or one read with PROMPT.
ARG is the raw prefix argument: one prefix reads a session of the repo
in scope, two read the repo too.  A dashboard, or a tab no session
opened, reads as with one prefix."
  (or (and (not arg)
           (not (derived-mode-p 'my/session-dashboard-mode))
           (when-let* ((root (my/session-tab-worktree)))
             (and (file-directory-p root) (my/session--at root))))
      (my/session--read prompt (equal arg '(16)))))

;;; Layout and navigation

(defun my/session--start-agent (session)
  "Start an agent shell in SESSION's root and return its buffer."
  (require 'agent-shell)
  (let ((default-directory (my/session-root session)))
    (save-window-excursion (call-interactively #'agent-shell))
    (my/session--agent-buffer (my/session-root session))))

(defun my/session--show-agent (session)
  "Show SESSION's agent shell to the right, starting one when there is none."
  (when-let* ((agent (or (and (buffer-live-p (my/session-agent-buffer session))
                              (my/session-agent-buffer session))
                         (my/session--start-agent session))))
    (display-buffer agent '((display-buffer-in-direction)
                            (direction . right)
                            (window-width . 0.5)))))

(defun my/session-layout (session)
  "Apply the standard layout: tickets left, agent right."
  (delete-other-windows)
  (if-let* ((ticket (my/session-ticket-file session)))
      (find-file ticket)
    (dired (my/session-root session)))
  (my/session--show-agent session))

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

(defun my/session-review-tab-name (session)
  "Name of SESSION's review tab."
  (concat (my/session-tab-name session) my/session-review-tab-suffix))

(defun my/session--tab-p (name)
  (seq-some (lambda (tab) (equal name (alist-get 'name tab)))
            (funcall tab-bar-tabs-function)))

(defun my/session--open-tab (name root layout)
  "Switch to the tab NAME standing for the worktree ROOT.
LAYOUT is called on it only when the tab is newly created."
  (let ((existing (my/session--tab-p name)))
    (tab-bar-switch-to-tab name)
    ;; `tab-bar--current-tab-make' copies parameters it does not recognise,
    ;; which is what carries this across a tab switch.
    (setf (alist-get 'my/session-worktree
                     (cdr (assq 'current-tab (funcall tab-bar-tabs-function))))
          (file-name-as-directory (expand-file-name root)))
    (unless existing (funcall layout))))

(defun my/session-open (session)
  "Jump to SESSION's work tab, creating tab and layout when missing.
Interactively the session is read from the repo in scope; a prefix
argument reads the repo too."
  (interactive (list (my/session--read "Session: " current-prefix-arg)))
  (my/session--open-tab (my/session-tab-name session)
                        (my/session-root session)
                        (lambda () (my/session-layout session))))

(defun my/session-browse (session)
  "Jump to SESSION's browse tab, creating tab and layout when missing.
Interactively it is the current tab's session; a prefix argument reads
one from the repo in scope, and two read the repo too."
  (interactive (list (my/session--read-here "Browse session: " current-prefix-arg)))
  (my/session--open-tab (my/session-browse-tab-name session)
                        (my/session-root session)
                        (lambda () (my/session-browse-layout session))))

;;; Review

(defun my/session--review-buffer-name (session)
  "Name of the buffer holding SESSION's diff against its merge base."
  (format "*review: %s*" (my/session-tab-name session)))

(defun my/session--review-diff (session)
  "Fill and answer SESSION's review buffer: merge base against the worktree.
Uncommitted changes are in it, so a branch is reviewed as it stands
rather than as it was last committed.  Its own buffer per session, since
two reviews run side by side as readily as two sessions do."
  (require 'vc)
  (let* ((root (my/session-root session))
         (default-directory root)
         (base (or (my/session--base-ref root t)
                   (user-error "No base to review %s against" (my/session-name session))))
         (backend (vc-responsible-backend root))
         (buffer (get-buffer-create (my/session--review-buffer-name session)))
         ;; `vc-diff-internal' displays the buffer itself, at the end; the
         ;; layout has already settled which window it belongs in.
         (display-buffer-overriding-action '((display-buffer-same-window)))
         ;; Synchronous: the notes below are placed against the finished text.
         (vc-allow-async-diff nil))
    (vc-diff-internal nil (list backend (list root))
                      (vc-call-backend backend 'mergebase base "HEAD")
                      nil nil buffer)
    (with-current-buffer buffer
      ;; `erase-buffer' leaves overlays behind, collapsed onto one position.
      (remove-overlays (point-min) (point-max) 'my/review-note t)
      (my/review--collapse-files)
      ;; vc's own revert function drops the buffer it was given and rebuilds
      ;; into *vc-diff*.
      (setq-local revert-buffer-function
                  (lambda (&rest _) (my/session--review-diff session))))
    buffer))

(defun my/review--collapse-files ()
  "Fold each file in the diff matching `my/review-collapsed-files'."
  (outline-minor-mode 1)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\+\\+\\+ \\(?:b/\\)?\\([^\t\n]+\\)" nil t)
      (when (seq-some (lambda (re) (string-match-p re (match-string 1)))
                      my/review-collapsed-files)
        (outline-hide-subtree)))))

(defun my/session-review-layout (session)
  "Apply the review layout: the branch diff left, agent right."
  (delete-other-windows)
  (switch-to-buffer (my/session--review-diff session))
  (my/session--show-agent session))

(defun my/session--review-branches (root)
  "Alist of (BRANCH . BASE) for the repo at ROOT, in the order worth offering.
Every local head first, with a nil BASE since the branch is already
there.  Then every remote branch no local head stands for, BASE being the
remote ref to make it from.  Fetches, so a branch pushed since the last
review is among them."
  (when-let* ((remote (my/session--remote root)))
    ;; Offline, or a remote that has gone: the refs simply stay as last seen.
    (my/session--git-succeeds-p root "fetch" remote))
  (let* ((locals (split-string
                  (my/session--git root "for-each-ref" "--format=%(refname:short)"
                                   "refs/heads")
                  "\n" t))
         (remotes (split-string
                   (my/session--git root "for-each-ref"
                                    ;; lstrip=3 drops refs/remotes/<remote>/, so a
                                    ;; namespaced branch keeps the rest of its name.
                                    "--format=%(refname:short)\t%(refname:lstrip=3)"
                                    "refs/remotes")
                   "\n" t)))
    (append (mapcar #'list locals)
            (delq nil
                  (mapcar (lambda (line)
                            (pcase-let ((`(,ref ,branch) (split-string line "\t")))
                              (unless (or (equal branch "HEAD") (member branch locals))
                                (cons branch ref))))
                          remotes)))))

(defun my/session--review-open (session)
  "Jump to SESSION's review tab, creating tab and layout when missing."
  (my/session--open-tab (my/session-review-tab-name session)
                        (my/session-root session)
                        (lambda () (my/session-review-layout session))))

(defun my/session-review (repo-root branch &optional base)
  "Review BRANCH of REPO-ROOT against its merge base, in a tab of its own.
Any branch the repo knows is reviewable, whether or not it is one you
opened: BRANCH gets a worktree when it has none, made from BASE — the
remote ref behind it — when no local head stands for it yet.
Interactively the repo is the one at point; a prefix argument reads it."
  (interactive
   (let* ((root (my/session--repo-root current-prefix-arg))
          (branches (my/session--review-branches root))
          (choice (assoc (completing-read "Review branch: " branches nil t) branches)))
     (list root (car choice) (cdr choice))))
  (let ((worktree (my/session--materialise repo-root branch base)))
    (my/session--review-open
     (make-my/session :name branch :root worktree :branch branch))))

(defun my/review--position (file line)
  "Position in the current diff buffer of LINE of FILE, nil when it has none.
FILE is repo-relative and LINE numbers it as the branch leaves it, so a
line only the base has is nowhere to put anything."
  (save-excursion
    (goto-char (point-min))
    (let (current new pos)
      (while (and (not pos) (not (eobp)))
        (cond
         ((looking-at "^\\+\\+\\+ \\(?:b/\\)?\\([^\t\n]+\\)")
          (setq current (match-string-no-properties 1) new nil))
         ((and (equal current file) (looking-at "^@@ -[0-9,]+ \\+\\([0-9]+\\)"))
          (setq new (string-to-number (match-string 1))))
         ((null new))
         ((looking-at "^[+ ]")
          (if (= new line) (setq pos (point)) (setq new (1+ new))))
         ((looking-at "^-"))
         (t (setq new nil)))
        (forward-line 1))
      pos)))

;;;###autoload
(defun my/review-note (root file line text)
  "Write TEXT against LINE of FILE in the review diff of the worktree at ROOT.
FILE is relative to ROOT and LINE numbers it as the branch leaves it.
This is how the agent reviewing a session reports a finding:

    emacsclient --eval \='(my/review-note \"ROOT\" \"FILE\" LINE \"TEXT\")\='

Answers nil when the review tab is not open or the line is not in the
diff, which tells the agent a note that landed from one that did not.
Notes last until the diff is rebuilt, `g' being what clears them."
  (when-let* ((session (my/session--at root))
              (buffer (get-buffer (my/session--review-buffer-name session))))
    (with-current-buffer buffer
      (when-let* ((pos (my/review--position file line)))
        (save-excursion
          (goto-char pos)
          (when (re-search-backward "^\\+\\+\\+ " nil t)
            (outline-show-subtree)))
        (let ((overlay (make-overlay pos pos)))
          (overlay-put overlay 'my/review-note t)
          (overlay-put overlay 'before-string
                       (propertize (concat "\u258f " text "\n")
                                   'face 'font-lock-warning-face)))
        t))))

;;; Mode line

(defvar-local my/session--buffer-place nil
  "Cached (DIRECTORY ROOT . MAIN-CHECKOUT-P) for this buffer.
Keyed on `default-directory' because a dired, dirvish-side or shell
buffer moves and a file buffer does not.")

(defun my/session--buffer-place ()
  "Project root of the current buffer and whether it is a main checkout."
  (unless (equal (car my/session--buffer-place) default-directory)
    (setq my/session--buffer-place
          (cons default-directory
                (and (not (file-remote-p default-directory))
                     (when-let* ((project (project-current))
                                 (root (file-name-as-directory
                                        (expand-file-name (project-root project)))))
                       ;; One stat, where `my/session--linked-worktree-p' is
                       ;; two git subprocesses.
                       (cons root
                             (file-directory-p
                              (expand-file-name ".git" root))))))))
  (cdr my/session--buffer-place))

(defun my/session-tab-worktree ()
  "Worktree the current tab was opened for, or nil for a tab no session opened."
  (alist-get 'my/session-worktree
             (cdr (assq 'current-tab (funcall tab-bar-tabs-function)))))

(defun my/session-mode-line ()
  "Mode-line element for a buffer the current tab's name does not account for.
The tab bar names the session a tab stands for, but buffers are not
tab-scoped (rule 4) and the main checkout's branch moves under a tab
named when it opened.  Nil in every other case."
  (when-let* ((tab (my/session-tab-worktree))
              (place (my/session--buffer-place)))
    (cond
     ((not (string-equal tab (car place)))
      (propertize
       (format " %s " (file-name-nondirectory (directory-file-name (car place))))
       'face 'mode-line-emphasis
       'help-echo (format "Buffer is in %s, not this tab's session"
                          (abbreviate-file-name (car place)))))
     ((and (cdr place) vc-mode) vc-mode))))

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

(defun my/session--materialise (repo-root branch &optional base)
  "Worktree of REPO-ROOT holding BRANCH, created when it has none, and answered.
BASE is the ref BRANCH forks from when it does not exist yet; a branch
that does exist is checked out wherever it left off.  A branch already in
a worktree is answered where git has it, which need not be where
`my/session-worktree-directory-function' would put a new one."
  (let ((worktree (or (cdr (assoc branch (my/session--worktrees repo-root)))
                      (funcall my/session-worktree-directory-function repo-root branch))))
    (unless (file-directory-p worktree)
      (condition-case nil
          (apply #'my/session--git repo-root "worktree" "add" "-b" branch worktree
                 (and base (list base)))
        ;; Branch already exists: check it out instead, at wherever it left off.
        (error (my/session--git repo-root "worktree" "add" worktree branch))))
    (project-remember-project (project-current nil worktree))
    (dolist (path (my/session--linked-paths repo-root))
      (my/session--link repo-root worktree path))
    worktree))

(defun my/session-spawn (repo-root feature)
  "Create worktree, branch, and ticket scaffold for FEATURE off REPO-ROOT.
Interactively the repo is the one at point; a prefix argument reads it."
  (interactive
   (let ((root (my/session--repo-root current-prefix-arg)))
     (list root (completing-read "Feature: " (my/session--features root)))))
  (let ((worktree (my/session--materialise
                   repo-root feature (my/session--spawn-base repo-root))))
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

(defun my/session--close-tabs (root)
  "Close every tab opened for the worktree ROOT.
Matched by the tab's worktree, not its name: a name is fixed when the tab
opens, and the branch it was named for can move."
  (let ((root (file-name-as-directory (expand-file-name root)))
        (tabs (funcall tab-bar-tabs-function)))
    ;; Highest first, so each close leaves the lower positions standing.
    (dolist (index (reverse (number-sequence 1 (length tabs))))
      (when (equal (alist-get 'my/session-worktree (cdr (nth (1- index) tabs)))
                   root)
        (tab-bar-close-tab index)))))

(defun my/session-teardown (session)
  "Kill SESSION's buffers, close its tab, and remove its worktree.
The main checkout is a session too and is never removed; tearing it down
closes its tabs and kills its agent, and it is derived again next time.
Interactively it is the current tab's session; a prefix argument reads
one from the repo in scope, and two read the repo too."
  (interactive (list (my/session--read-here "Tear down session: " current-prefix-arg)))
  (let* ((name (or (my/session-feature session) (my/session-name session)))
         (root (my/session-root session))
         ;; Resolved before the worktree goes: the ticket is visited through
         ;; the tracker symlink, under the tracker's own path, which is
         ;; outside the project `project-kill-buffers' kills.
         (ticket (when-let* ((file (my/session-ticket-file session)))
                   (find-buffer-visiting file)))
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
        (when ticket (kill-buffer ticket))
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
      (my/session--close-tabs root)
      (message "Session %s torn down (branch kept)" name))))

;;; Mission control

(defvar my/session-dashboard-buffer "*Sessions*")

(defun my/session--status-label (status)
  (pcase status
    ('busy (propertize "● busy" 'face 'warning))
    ('blocked (propertize "✋ blocked" 'face 'error))
    ('ready (propertize "● ready" 'face 'success))
    (_ (propertize "– none" 'face 'shadow))))

(defun my/session--drift-label (divergence)
  "DIVERGENCE, a (BEHIND . AHEAD) cons, as one column of arrows."
  (pcase divergence
    ('nil (propertize "–" 'face 'shadow))
    ('(0 . 0) (propertize "current" 'face 'shadow))
    (`(,behind . ,ahead)
     (string-join
      (delq nil
            (list (unless (zerop ahead)
                    (propertize (format "↑%d" ahead) 'face 'success))
                  (unless (zerop behind)
                    (propertize (format "↓%d" behind) 'face
                                (if (>= behind my/session-stale-threshold)
                                    'error
                                  'shadow)))))
      " "))))

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
                                (my/session--drift-label
                                 (my/session-divergence session (base root)))
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

(defun my/session-dashboard-review ()
  "Open the review tab of the session at point."
  (interactive)
  (when-let* ((session (tabulated-list-get-id)))
    (my/session--review-open session)))

(defun my/session-dashboard-spawn ()
  "Spawn a session off the repo this dashboard lists.
The dashboard buffer outlives the directory it was opened from, so its
own `default-directory' is no answer; `my/session--repo-root' reads the
repo out of the dashboard, and asks when it lists every repo and so
names none to spawn off."
  (interactive)
  (let ((repo (my/session--repo-root)))
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
  "r" #'my/session-dashboard-review
  "n" #'my/session-dashboard-spawn
  "k" #'my/session-dashboard-teardown)

(define-derived-mode my/session-dashboard-mode tabulated-list-mode "Sessions"
  "Mission control for feature-in-flight sessions."
  (setq tabulated-list-format
        [("Feature" 28 t) ("Status" 12 t) ("Drift" 12 t) ("Agent" 30 t) ("Root" 40 t)])
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
REPO is the repo at point, prompted for when there is none and by a
prefix argument.  It is read before the dashboard buffer is current,
whose own `default-directory' would otherwise decide it."
  (interactive (list (my/session--repo-root current-prefix-arg)))
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
  "a" #'my/agent-attention-jump
  "b" #'my/session-browse
  "r" #'my/session-review
  "k" #'my/session-teardown)

(fset 'my/session-map my/session-map)

(keymap-global-set "C-c s" 'my/session-map)
(keymap-global-set "<f6>" #'my/session-dashboard)

(provide 'sessions)
;;; sessions.el ends here
