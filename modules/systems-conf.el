;;; systems.el --- General Programming configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package systemd
  :ensure (:host github :repo "mavit/systemd-mode" :branch "podman"))

(use-package journalctl-mode
  :bind ("M-t" . journalctl))

(provide 'systems-conf)
;;; systems.el ends here
