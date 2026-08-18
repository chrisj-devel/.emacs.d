;;; ai-conf.el --- AI configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package agent-shell
  :preface
  (defun my/agent-shell-switch-or-start ()
    "Pick an agent shell buffer, or start one when none exist."
    (interactive)
    (require 'agent-shell)
    (if (agent-shell-buffers)
      (agent-shell-switch-buffer)
      (agent-shell)))
  :bind ([f5] . my/agent-shell-switch-or-start)
  :custom
  (agent-shell-session-strategy 'prompt)
  (agent-shell-display-action
    '(display-buffer-in-side-window
       (side . right)
       (slot . 0)
       (window-width . 0.4)
       (preserve-size . (t . nil)))))

(use-package gptel
  :custom (gptel-use-tools t)
  :bind ("C-c ?" . my/gptel-emacs-help)
  :config
  ;; Introspection tools: let the model answer from this Emacs, not from
  ;; whatever it remembers about a stock config.
  (defvar my/gptel-emacs-tools
    (list
      (gptel-make-tool
        :name "describe_function"
        :function (lambda (name)
                    (let ((sym (intern-soft name)))
                      (if (fboundp sym)
                        (or (documentation sym) "(no docstring)")
                        (format "%s is not defined" name))))
        :description "Get the docstring of an Emacs command or function."
        :args '((:name "name" :type string :description "Function name"))
        :category "emacs")

      (gptel-make-tool
        :name "where_is"
        :function (lambda (name)
                    (let ((keys (where-is-internal (intern-soft name) nil)))
                      (if keys
                        (mapconcat #'key-description keys ", ")
                        (format "%s is not bound to any key" name))))
        :description "List the key bindings for a command in the user's config."
        :args '((:name "name" :type string :description "Command name"))
        :category "emacs")

      (gptel-make-tool
        :name "apropos_command"
        :function (lambda (regexp)
                    (let ((cmds (apropos-internal regexp #'commandp)))
                      (if cmds
                        (mapconcat #'symbol-name (seq-take cmds 60) " ")
                        "no matching commands")))
        :description "Find available commands whose name matches a regexp."
        :args '((:name "regexp" :type string :description "Regexp to match command names"))
        :category "emacs")))

  (defun my/gptel-emacs-help (question)
    "Ask QUESTION about Emacs, answered against this running session."
    (interactive "sEmacs: ")
    ;; `gptel-request' takes no :tools argument; it reads `gptel-tools' from
    ;; the calling buffer while building the prompt, which happens inside this
    ;; call, so a dynamic binding is enough.
    (let ((gptel-tools my/gptel-emacs-tools))
      (gptel-request question
        :system "Answer using the user's actual running Emacs. Use the tools to \
check which commands exist and what keys they are on before answering — do not \
guess from a default config. Be terse: name the command, its binding (or say it \
is unbound), and nothing else unless asked."
        :callback (lambda (response _info)
                    (message "%s" (if (stringp response)
                                    response
                                    "gptel: no response")))))))

;; (use-package copilot
;;   :bind
;;   (:map copilot-completion-map
;;     ("<tab>"     . my/copilot-tab)
;;     ("TAB"       . my/copilot-tab)
;;     ("C-<tab>"   . copilot-accept-completion)
;;     ("C-<right>" . copilot-accept-completion-by-word)
;;     ("M-<right>" . copilot-accept-completion-by-line))
;;   :config
;;   (add-to-list 'copilot-disable-predicates
;;     (lambda () (derived-mode-p 'dotenv-mode 'envrc-file-mode)))
;;
;;   (defun my/copilot-tab ()
;;     "Accept Copilot suggestion only if corfu popup is not active."
;;     (interactive)
;;     (if (and (bound-and-true-p corfu--candidates)
;;           (> (length corfu--candidates) 0))
;;       (let ((copilot-mode nil))
;;         (call-interactively (key-binding (kbd "TAB"))))
;;       (copilot-accept-completion))))

(provide 'ai-conf)
;;; ai-conf.el ends here
