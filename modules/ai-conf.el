;;; ai-conf.el --- AI configuration -*- no-byte-compile: t; lexical-binding: t; -*-
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

(use-package copilot
  :hook (prog-mode . copilot-mode)
  :bind
  (:map copilot-completion-map
    ("<tab>"     . my/copilot-tab)
    ("TAB"       . my/copilot-tab)
    ("C-<tab>"   . copilot-accept-completion)
    ("C-<right>" . copilot-accept-completion-by-word)
    ("M-<right>" . copilot-accept-completion-by-line))
  :config
  (defun my/copilot-tab ()
    "Accept Copilot suggestion only if corfu popup is not active."
    (interactive)
    (if (and (bound-and-true-p corfu--candidates)
          (> (length corfu--candidates) 0))
      (let ((copilot-mode nil))
        (call-interactively (key-binding (kbd "TAB"))))
      (copilot-accept-completion))))

(provide 'ai-conf)
;;; ai-conf.el ends here
