;;; tickets.el --- Which org files make up a repo's tracker -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/<tickets-dir>/<feature>.org: the PRD and each
;; issue are top-level headings.  Which files those are, and the setup a
;; ticket buffer needs.  config/org-tracker.el builds the agenda views.
;;; Code:
(require 'seq)
(require 'subr-x)
(require 'project)

(declare-function my/session--repo-root "sessions")
(declare-function my/session--worktrees "sessions")
(declare-function my/session--repos "sessions")
(defvar my/session-tickets-subdir)

;; Scope is one repo, derived from `git worktree list', not from
;; `project-known-project-roots'. Walking known roots would stat every project
;; Emacs has ever seen — including remote ones, where `file-directory-p' opens
;; a Tramp connection just to build an agenda for an unrelated repo.
(defun my/tracker-org-files (&optional repo)
  "Ticket file of every feature in REPO, the repo at point by default.
A feature checked out in a worktree resolves to that worktree's copy, so
in-flight state wins; every other feature resolves to the main checkout."
  (let* ((root (or repo (my/session--repo-root)))
         (base (expand-file-name my/session-tickets-subdir root))
         (files (make-hash-table :test 'equal)))
    (when (file-directory-p base)
      (dolist (file (directory-files base t "\\`[^.].*\\.org\\'"))
        (puthash (file-name-base file) file files)))
    (pcase-dolist (`(,branch . ,worktree) (my/session--worktrees root))
      (let* ((feature (file-name-nondirectory branch))
             (file (expand-file-name
                    (concat my/session-tickets-subdir "/" feature ".org")
                    worktree)))
        (when (file-exists-p file)
          (puthash feature file files))))
    (sort (hash-table-values files) #'string<)))

(defvar my/tracker--warned-repos nil
  "Roots `my/tracker-all-org-files' has already warned about.")

(defun my/tracker--warn-unreadable (root err)
  "Warn that ROOT was left out of the tracker sweep because of ERR.
Once per root per session: the sweep runs on every agenda and dashboard
build, and a root stays dead until someone forgets the project."
  (unless (member root my/tracker--warned-repos)
    (push root my/tracker--warned-repos)
    (display-warning
     'my/tracker
     (format "%s is a known project but not a readable checkout, so its \
tickets are missing from the frontier.  Drop it with \
`M-x project-forget-project'.\n%s"
             (abbreviate-file-name root) (error-message-string err)))))

(defun my/tracker-all-org-files ()
  "Ticket file of every feature in every known repo.
What one repo's agenda is to `my/tracker-org-files', this is to the
machine: the frontier the dashboard opens on spans repos, since which
one is at point says nothing about what is waiting.

A root that git cannot read is skipped, with a warning naming it.
`my/session--repos' keeps a known project root that is no longer a checkout
— a worktree directory left behind without its `.git' file — and one of
those would otherwise abort the sweep and blank the dashboard's frontier
for every repo."
  (seq-uniq (seq-mapcat (lambda (repo)
                          (condition-case err
                              (my/tracker-org-files repo)
                            (error (my/tracker--warn-unreadable repo err) nil)))
                        (my/session--repos))))

(defconst my/tracker-columns-format
  "%30ITEM(Title) %10TODO(State) %10KIND(Kind) %6TYPE(Type) %20FEATURE(Feature) %20TRACKER_CATEGORY(Category) %10PRIORITY(Priority) %24BRANCH(Branch)"
  "Column view over the tracker's properties.")

(defun my/tracker-columns-setup ()
  "Use `my/tracker-columns-format' in ticket files.
The format names tracker properties, so it stays out of other Org buffers.
Every tracker heading carries FEATURE, and the file is reached through a
symlink whose path says nothing reliable about what it holds."
  (when (save-excursion
          (goto-char (point-min))
          (re-search-forward "^:FEATURE:" nil t))
    (setq-local org-columns-default-format my/tracker-columns-format)))

(defun my/tracker-anchor-directory ()
  "Anchor `default-directory' at the project the visited path names.
A tracker file is visited through <repo>/tickets, a symlink into the
tracker repo: Emacs walks the visited path and answers <repo>, while a
subprocess resolves the link and answers the tracker repo.  Anchoring the
buffer at its project root leaves both answering <repo>.  A tickets
directory belonging to its own repo is left alone."
  (when-let* ((file buffer-file-name)
              ((not (equal (file-truename file) (expand-file-name file))))
              (project (project-current nil (file-name-directory file))))
    (setq-local default-directory (expand-file-name (project-root project)))))

(defconst my/tracker-frontier-blocks
  '((tags-todo "KIND={.}+TYPE=\"HITL\"/NEXT"
               ((org-agenda-overriding-header "Mine")))
    (tags-todo "KIND={.}+TYPE=\"AFK\"/NEXT"
               ((org-agenda-overriding-header "Agent"))))
  "Blocks of the frontier view, over one repo (\"f\") or every repo (\"F\").")

(provide 'tickets)
;;; tickets.el ends here
