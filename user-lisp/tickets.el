;;; tickets.el --- Org ticket workflow -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/<tickets-dir>/<feature>.org: the PRD and each
;; issue are top-level headings.
;; The "w" and "f" agenda views roll up across all live sessions' tickets.
;;; Code:

(declare-function my/sessions "sessions")
(declare-function my/session-ticket-file "sessions")
(defvar my/session-tickets-subdir)

(defun my/session-ticket-org-files ()
  "Ticket file of every live session."
  (seq-uniq (delq nil (mapcar #'my/session-ticket-file (my/sessions)))))

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
      ((org-agenda-files (my/session-ticket-org-files))))
     ("f" "Tracker frontier"
      ((tags-todo "KIND={.}+TYPE=\"HITL\"/NEXT"
                  ((org-agenda-overriding-header "Mine")))
       (tags-todo "KIND={.}+TYPE=\"AFK\"/NEXT"
                  ((org-agenda-overriding-header "Agent"))))
      ;; Frontier means startable, so blocked entries drop out rather than dim.
      ((org-agenda-files (my/session-ticket-org-files))
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
