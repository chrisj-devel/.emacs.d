;;; tickets.el --- Org ticket workflow -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/<tickets-dir>/<feature>.org: the PRD and each
;; issue are top-level headings.
;; The "s" agenda view rolls up TODOs across all live sessions' tickets.
;;; Code:

(declare-function my/sessions "sessions")
(declare-function my/session-ticket-file "sessions")

(defun my/session-ticket-org-files ()
  "Ticket file of every live session."
  (seq-uniq (delq nil (mapcar #'my/session-ticket-file (my/sessions)))))

(use-package org
  :ensure nil
  :bind ("C-c a" . org-agenda)
  :custom
  (org-todo-keywords
   '((sequence "TODO(t)" "DOING(d)" "BLOCKED(b)" "|" "DONE(x)" "DROP(q)")))
  (org-log-done 'time)
  (org-agenda-custom-commands
   '(("s" "In-flight session tickets" alltodo ""
      ((org-agenda-files (my/session-ticket-org-files)))))))

(provide 'tickets)
;;; tickets.el ends here
