;;; dired-conf.el --- Dired configuration -*- no-byte-compile: t; lexical-binding: t; -*-
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
  (dired-sidebar-theme 'nerd-icons)
  (dired-sidebar-width 30)
  :bind
  (([f1] . dired-sidebar-toggle-sidebar)
    :map dired-sidebar-mode-map
    ("l" . dired-sidebar-subtree-expand)
    ("h" . dired-sidebar-subtree-collapse))
  :config
  (defun dired-sidebar-subtree-expand ()
    "Expand subtree at point with icon refresh."
    (interactive)
    (dired-subtree-insert)
    (dired-sidebar-redisplay-icons))
  (defun dired-sidebar-subtree-collapse ()
    "Collapse subtree at point, or move to parent directory line."
    (interactive)
    (if (dired-subtree--is-expanded-p)
      (progn
        (dired-next-line 1)
        (dired-subtree-remove)
        (dired-sidebar-redisplay-icons))
      (dired-subtree-up))))

(provide 'dired-conf)
;;; dired-conf.el ends here
