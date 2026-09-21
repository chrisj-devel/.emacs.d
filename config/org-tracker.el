;;; org-tracker.el --- Org and the tracker's agenda views -*- lexical-binding: t; -*-
;;; Commentary:
;; The "w" and "f" agenda views cover one repo's whole tracker: every feature
;; in the main checkout, each shown in its worktree's copy when one exists.
;; "F" is the frontier again, over every known repo — what dashboard.el opens on.
;;; Code:

;; Spliced into the agenda commands below at load time, so not autoloadable.
(require 'tickets)

(use-package org
  :ensure nil
  ;; `consult-outline' (M-g o) reads headings as text; in Org they are real
  ;; entries, so the Org-aware command takes the key here — it matches on the
  ;; outline path and narrows by TODO keyword and tag.
  :bind (("C-c a" . org-agenda)
         :map org-mode-map
         ("M-g o" . consult-org-heading))
  ;; Ticket files carry one logical line per paragraph and list item, so the
  ;; wrapping is visual-line-mode's job; visual-wrap-prefix-mode then indents
  ;; the continuation under the bullet it belongs to.
  :hook ((org-mode . my/tracker-columns-setup)
         (org-mode . my/tracker-anchor-directory)
         (org-mode . visual-line-mode)
         (org-mode . visual-wrap-prefix-mode))
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
  ;; Org's default set omits md, which is what tickets leave the tracker as.
  (org-export-backends '(ascii html icalendar latex odt md))
  ;; KIND is what distinguishes a tracker heading from any other Org heading,
  ;; so both views work across sessions without naming a repo.
  (org-agenda-custom-commands
   `(("w" "Tracker workboard"
      ((todo "DOING") (todo "NEXT") (todo "WAIT") (todo "TODO"))
      ((org-agenda-files (my/tracker-org-files))))
     ("f" "Tracker frontier" ,my/tracker-frontier-blocks
      ;; Frontier means startable, so blocked entries drop out rather than dim.
      ((org-agenda-files (my/tracker-org-files))
       (org-agenda-dim-blocked-tasks 'invisible)))
     ("F" "Tracker frontier, every repo" ,my/tracker-frontier-blocks
      ((org-agenda-files (my/tracker-all-org-files))
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

(provide 'org-tracker)
;;; org-tracker.el ends here
