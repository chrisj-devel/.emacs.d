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

(use-package copilot
  :disabled t
  :bind ("C-c a c" . global-copilot-mode)
  (:map copilot-completion-map
    ("C-a" . copilot-accept-completion)
    ("C-A" . copilot-accept-completion-by-line)
    ("C-M-a" . 'copilot-accept-completion-by-word)
    ("C-n" . 'copilot-next-completion)
    ("C-p" . 'copilot-previous-completion)))

(use-package claude-code-ide
  :disabled t
  :after (transient)
  :ensure (:host github :repo "manzaltu/claude-code-ide.el")
  :bind ("M-c" . claude-code-ide-menu)
  :config (claude-code-ide-emacs-tools-setup))

(use-package shell-maker
  :ensure t)

(use-package acp
  :ensure (:host github :repo "xenodium/acp.el"))

(use-package agent-shell
  :ensure (:host github :repo "xenodium/agent-shell"))

(use-package agent-shell-sidebar
  :after agent-shell
  :ensure (:host github :repo "cmacrae/agent-shell-sidebar")
  :custom
  (agent-shell-sidebar-default-config
    (agent-shell-google-make-gemini-config))
  :bind ([f5] . agent-shell-sidebar-toggle))

(provide 'ai-conf)
;;; ai.el ends here
