;;; dev.el --- Programming, VC, terminals, agents -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Tree-sitter (all built-in modes)

(use-package treesit
  :ensure nil
  :custom
  (treesit-language-source-alist
   '((ruby "https://github.com/tree-sitter/tree-sitter-ruby")
     (rust "https://github.com/tree-sitter/tree-sitter-rust")
     (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
     (heex "https://github.com/phoenixframework/tree-sitter-heex")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
     (bash "https://github.com/tree-sitter/tree-sitter-bash")))
  :config
  (setq major-mode-remap-alist
        '((ruby-mode . ruby-ts-mode)
          (js-mode . js-ts-mode)
          (sh-mode . bash-ts-mode)))
  (dolist (entry '(("\\.rs\\'" . rust-ts-mode)
                   ("\\.exs?\\'" . elixir-ts-mode)
                   ("\\.heex\\'" . heex-ts-mode)
                   ("\\.ts\\'" . typescript-ts-mode)
                   ("\\.tsx\\'" . tsx-ts-mode)
                   ("\\.ya?ml\\'" . yaml-ts-mode)
                   ("\\.toml\\'" . toml-ts-mode)))
    (add-to-list 'auto-mode-alist entry)))

(defun my/treesit-install-missing ()
  "Install any tree-sitter grammars from `treesit-language-source-alist'."
  (interactive)
  (dolist (source treesit-language-source-alist)
    (unless (treesit-language-available-p (car source))
      (treesit-install-language-grammar (car source)))))

;;; LSP (built-in)

(use-package eglot
  :ensure nil
  :hook ((ruby-ts-mode rust-ts-mode elixir-ts-mode typescript-ts-mode tsx-ts-mode)
         . eglot-ensure))

;;; VC

(use-package magit
  :bind ("C-x g" . magit-status))

;;; Per-project env (direnv) — worktrees need their own envs

(use-package envrc
  :config
  (envrc-global-mode))

;;; Terminal

(use-package ghostel
  :vc (:url "https://github.com/dakra/ghostel")
  :custom
  (ghostel-tramp-shell-integration t)
  :bind
  ([f11] . (lambda () (interactive)
             (if (project-current) (ghostel-project) (ghostel))))
  :config
  (add-to-list 'ghostel-tramp-shells '("podman" "/bin/sh")))

;;; Agents

(use-package acp
  :vc (:url "https://github.com/xenodium/acp.el"))

(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell")
  :preface
  (defun my/agent-shell-switch-or-start (&optional arg)
    "Pick an agent shell buffer, or start one when none exist.
With prefix ARG, always start a new shell."
    (interactive "P")
    (require 'agent-shell)
    (cond (arg (agent-shell-new-shell))
          ((agent-shell-buffers) (agent-shell-switch-buffer))
          (t (agent-shell))))
  :bind ([f5] . my/agent-shell-switch-or-start)
  :custom
  (agent-shell-session-strategy 'prompt)
  (agent-shell-display-action
   '((display-buffer-reuse-mode-window
      display-buffer-in-direction)
     (direction . right)
     (window-width . 0.5)
     (preserve-size . (t . nil)))))

(use-package agent-shell-attention
  :vc (:url "https://github.com/ultronozm/agent-shell-attention.el")
  :after agent-shell
  :demand t
  :custom
  ;; Tally lives in global-mode-string, which core.el routes into the
  ;; tab bar (tab-bar-format-global), so it is visible from every tab.
  (agent-shell-attention-indicator-location 'global-mode-string)
  (agent-shell-attention-notify-function #'my/agent-attention-notify)
  :preface
  (defun my/agent-attention-notify (title body)
    "macOS notification via osascript (notifications-notify is dbus-only)."
    (start-process "agent-notify" nil "osascript" "-e"
                   (format "display notification %S with title %S" body title)))
  :config
  (agent-shell-attention-mode 1))

(provide 'dev)
;;; dev.el ends here
