;;; tickets.el --- Org ticket workflow -*- lexical-binding: t; -*-
;;; Commentary:
;; Tickets live in <worktree>/<tickets-dir>/<feature>.org: the PRD and each
;; issue are top-level headings.
;; The "s" agenda view rolls up TODOs across all live sessions' tickets.
;;; Code:

(declare-function my/sessions "sessions")
(declare-function my/session-ticket-file "sessions")
(defvar my/session-tickets-subdir)
(defvar org-ql-views)

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
  :hook (org-mode . my/tracker-columns-setup)
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
  :after org
  :config
  ;; `org-ql-views' lives in org-ql-view.el, which org-ql itself never loads.
  (with-eval-after-load 'org-ql-view
    ;; KIND is what distinguishes a tracker heading from any other Org heading,
    ;; so both views work across sessions without naming a repo.
    (setf (alist-get "Tracker: Workboard" org-ql-views nil nil #'equal)
          '(:buffers-files my/session-ticket-org-files
            :query (and (property "KIND") (todo))
            :sort (priority todo)
            :super-groups ((:name "Doing" :todo "DOING" :order 1)
                           (:name "Next" :todo "NEXT" :order 2)
                           (:name "Waiting" :todo "WAIT" :order 3)
                           (:name "Inbox" :todo "TODO" :order 4))
            :title "Tracker workboard"))
    (setf (alist-get "Tracker: Frontier" org-ql-views nil nil #'equal)
          '(:buffers-files my/session-ticket-org-files
            :query (and (property "KIND") (todo "NEXT") (not (org-entry-blocked-p)))
            :sort (priority)
            :super-groups ((:auto-property "TYPE"))
            :title "Unblocked tracker frontier"))))

(provide 'tickets)
;;; tickets.el ends here
