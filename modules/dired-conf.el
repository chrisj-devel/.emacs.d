;;; dired.el --- Dired configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package dired
  :ensure nil
  :custom
  (dired-clean-confirm-killing-deleted-buffers nil)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package dired-filter)
(use-package dired-subtree)

(use-package dired-sidebar
  :custom
  (dired-sidebar-should-follow-file t)
  (dired-sidebar-theme 'nerd)
  (dired-sidebar-width 30)
  :bind ([f1] . dired-sidebar-toggle-sidebar))

(provide 'dired-conf)
;;; dired.el ends here
