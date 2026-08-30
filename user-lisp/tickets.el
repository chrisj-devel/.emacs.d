;;; tickets.el --- Org ticket workflow -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/tickets/<feature>/ as prd.org + issues.org.
;; The "s" agenda view rolls up TODOs across all live sessions' tickets.
;;; Code:

(declare-function my/sessions "sessions")
(declare-function my/session-tickets-dir "sessions")

(defun my/session-ticket-org-files ()
  "All org files under the tickets directory of every live session."
  (seq-uniq
   (seq-mapcat (lambda (session)
                 (when-let* ((dir (my/session-tickets-dir session))
                             ((file-directory-p dir)))
                   (directory-files-recursively dir "\\.org\\'")))
               (my/sessions))))

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
