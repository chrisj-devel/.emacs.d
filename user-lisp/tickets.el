;;; tickets.el --- Org ticket workflow -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/<tickets-dir>/<feature>.org: the PRD and each
;; issue are top-level headings.
;; The "w" and "f" agenda views cover one repo's whole tracker: every feature
;; in the main checkout, each shown in its worktree's copy when one exists.
;;; Code:

(require 'subr-x)

(declare-function my/session--repo-root "sessions")
(declare-function my/session--worktrees "sessions")
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

(defconst my/tracker-columns-format
  "%30ITEM(Title) %10TODO(State) %10KIND(Kind) %6TYPE(Type) %20FEATURE(Feature) %20TRACKER_CATEGORY(Category) %10PRIORITY(Priority) %24BRANCH(Branch)"
  "Column view over the tracker's properties.")

(defun my/tracker-columns-setup ()
  "Use `my/tracker-columns-format' in ticket files.
The format names tracker properties, so it stays out of other Org buffers."
  (when (and buffer-file-name
             (equal (file-name-nondirectory
                     (directory-file-name
                      (file-name-directory buffer-file-name)))
                    my/session-tickets-subdir))
    (setq-local org-columns-default-format my/tracker-columns-format)))

(use-package org
  :ensure nil
  :bind ("C-c a" . org-agenda)
  ;; Ticket files carry one logical line per paragraph and list item, so the
  ;; wrapping is visual-line-mode's job.
  :hook ((org-mode . my/tracker-columns-setup)
         (org-mode . visual-line-mode))
  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "NEXT(n)" "DOING(p)" "WAIT(w@/!)"
               "|" "DONE(d)" "CANCELED(c@)")))
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-use-fast-todo-selection t)
  ;; Edna-blocked tickets dim, so the frontier reads at a glance.
  (org-agenda-dim-blocked-tasks t)
  (org-src-preserve-indentation t)
  (org-src-tab-acts-natively t)
  (org-edit-src-content-indentation 0)
  ;; KIND is what distinguishes a tracker heading from any other Org heading,
  ;; so both views work across sessions without naming a repo.
  (org-agenda-custom-commands
   '(("w" "Tracker workboard"
      ((todo "DOING") (todo "NEXT") (todo "WAIT") (todo "TODO"))
      ((org-agenda-files (my/tracker-org-files))))
     ("f" "Tracker frontier"
      ((tags-todo "KIND={.}+TYPE=\"HITL\"/NEXT"
                  ((org-agenda-overriding-header "Mine")))
       (tags-todo "KIND={.}+TYPE=\"AFK\"/NEXT"
                  ((org-agenda-overriding-header "Agent"))))
      ;; Frontier means startable, so blocked entries drop out rather than dim.
      ((org-agenda-files (my/tracker-org-files))
       (org-agenda-dim-blocked-tasks 'invisible)))))
  :config
  (require 'org-tempo)                  ; <s TAB
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t))))

;; Built-in dependency enforcement is ORDERED plus parent/child only; the
;; tracker's edges are cross-file, so Edna's BLOCKER property is the gap.
(use-package org-edna
  :after org
  :config (org-edna-mode))

(provide 'tickets)
;;; tickets.el ends here
