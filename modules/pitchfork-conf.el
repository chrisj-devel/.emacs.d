;;; pitchfork-conf.el --- Configuration for pitchfork.el -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package pitchfork
  :ensure nil
  :custom (pitchfork-auto-stop-on-project-switch t)
  :hook (elpaca-after-init . pitchfork-auto-start-mode)
  :bind
  ("C-c p f" . pitchfork)
  ("C-c p t" . pitchfork-open-config))

(provide 'pitchfork-conf)
;;; pitchfork-conf.el ends here
