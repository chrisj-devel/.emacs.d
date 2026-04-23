;;; systems-conf.el --- Systems programming and container configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package systemd
  :ensure (:host github :repo "mavit/systemd-mode" :branch "podman"))

(use-package journalctl-mode
  :bind ("M-t" . journalctl))

(use-package coterm
  :hook (elpaca-after-init . coterm-mode))

(use-package sudo-edit
  :bind ("C-c C-S" . sudo-edit)
  :config (sudo-edit-indicator-mode))

(use-package rpm-spec-mode)

(use-package tramp-rpc
  :after tramp
  :vc (:url "https://github.com/ArthurHeymans/emacs-tramp-rpc"
        :rev :newest
        :lisp-dir "lisp"))

(provide 'systems-conf)
;;; systems-conf.el ends here
