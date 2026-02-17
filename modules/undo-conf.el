;;; undo-conf.el --- Undo configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package undo-fu
  :custom
  (undo-fu-allow-undo-in-region t))

(use-package undo-fu-session
  :config
  (undo-fu-session-global-mode))

(use-package vundo
  :bind ("C-R" . vundo))

(provide 'undo-conf)
;;; undo-conf.el ends here
