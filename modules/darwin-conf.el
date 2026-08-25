;;; darwin.el --- MacOS configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package osx-trash
  :init
  (setq delete-by-moving-to-trash t)
  (when (not (fboundp 'system-move-file-to-trash))
    (defun system-move-file-to-trash (file)
      "Move FILE to trash."
      (when (not (file-remote-p default-directory))
        (osx-trash-move-file-to-trash file)))))

(use-package ns-auto-titlebar
  :config (ns-auto-titlebar-mode))

(use-package emacs
  :ensure nil
  :custom
  (frame-resize-pixelwise t)
  (ns-use-native-fullscreen nil)
  (warning-minimum-level :error)
  :config
  (if (executable-find "gls")
    (setq insert-directory-program "gls")
    (setq dired-use-ls-dired nil))
  (setq-default default-frame-alist '((font . "Monaspace Neon NF:pixelsize=13:weight=regular")))
  (set-frame-font "Monaspace Neon NF:pixelsize=13:weight=regular" nil t))

(provide 'darwin-conf)
;;; darwin.el ends here
