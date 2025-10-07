;;; systems.el --- Systems programming and container configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package systemd
  :ensure (:host github :repo "mavit/systemd-mode" :branch "podman"))

(use-package journalctl-mode
  :bind ("M-t" . journalctl))

(use-package devcontainer
  :ensure (:host github :repo "johannes-mueller/devcontainer.el"))

(use-package coterm
  :hook (elpaca-after-init . coterm-mode))

(provide 'systems-conf)
;;; systems.el ends here
