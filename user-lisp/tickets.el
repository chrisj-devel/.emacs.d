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
   '((sequence "TODO(t)" "NEXT(n)" "DOING(p)" "WAIT(w@/!)"
               "|" "DONE(d)" "CANCELED(c@)")))
  (org-log-done 'time)
  (org-agenda-custom-commands
   '(("s" "In-flight session tickets" alltodo ""
      ((org-agenda-files (my/session-ticket-org-files)))))))

;; Built-in dependency enforcement is ORDERED plus parent/child only; the
;; tracker's edges are cross-file, so Edna's BLOCKER property is the gap.
(use-package org-edna
  :after org
  :config (org-edna-mode))

;; org-agenda matches on tags and keywords; the tracker's views need queries
;; over arbitrary properties. Pulls in org-super-agenda for :super-groups.
(use-package org-ql
  :after org)

(provide 'tickets)
;;; tickets.el ends here
