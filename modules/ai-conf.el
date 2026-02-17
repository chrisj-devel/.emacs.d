;;; ai.el --- AI configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package gptel
  :hook (gptel-mode . visual-line-fill-column-mode)
  :bind
  ("C-c a m" . gptel-menu)
  ("C-c a a" . gptel)
  ("C-c a s" . gptel-send)
  :custom (gptel-model 'gpt-4o-mini)
  :custom-face (gptel-context-highlight ((t (:extend t)))))

(use-package agent-shell
  :bind ([f5] . agent-shell)
  :custom
  (agent-shell-display-action
    '(display-buffer-in-side-window
       (side . right)
       (slot . 0)
       (window-width . 0.4)
       (preserve-size . (t . nil)))))

(provide 'ai-conf)
;;; ai.el ends here
