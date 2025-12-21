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

(use-package shell-maker)

(use-package acp
  :ensure (:host github :repo "xenodium/acp.el"))

(use-package agent-shell
  :after (shell-maker acp)
  :ensure (:host github :repo "xenodium/agent-shell")
  :bind ([f5] . agent-shell-toggle-or-create)
  :custom
  (agent-shell-display-action
    '(display-buffer-in-side-window
       (side . right)
       (slot . 0)
       (window-width . 0.4)
       (preserve-size . (t . nil))))
  :config
  (defcustom agent-shell-default-config nil
    "Default agent configuration to use when creating new shells.
Should be one of the configs from `agent-shell-agent-configs'.
When nil, prompts for agent selection.
Set this in custom.el for computer-local configuration."
    :type '(choice (const :tag "Prompt for selection" nil)
             (alist :tag "Agent config"))
    :group 'agent-shell)

  (defun agent-shell-toggle-or-create ()
    "Toggle agent shell if buffer exists, otherwise create new agent shell."
    (interactive)
    (if (agent-shell-project-buffers)
      (agent-shell-toggle)
      (let ((config (or agent-shell-default-config
                      (agent-shell-select-config
                        :prompt "Start new agent: "))))
        (if config
          (let ((shell-buffer (agent-shell--start :config config :no-focus t :new-session t)))
            (agent-shell--display-buffer shell-buffer))
          (error "No agent config found"))))))

(provide 'ai-conf)
;;; ai.el ends here
