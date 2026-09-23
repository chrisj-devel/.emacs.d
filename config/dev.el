;;; dev.el --- Programming, VC, terminals, agents -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Tree-sitter (all built-in modes)

;; Emacs 31 ships the grammar recipes (each `*-ts-mode' registers its own) and
;; `*-ts-mode-maybe' auto-mode entries that fall back when a grammar is absent.
;; Only the languages without a `-maybe' variant need remapping.

(use-package treesit
  :ensure nil
  :custom
  (treesit-auto-install-grammar 'always)
  :config
  (setq major-mode-remap-alist
        '((javascript-mode . js-ts-mode)   ; the alias `auto-mode-alist' actually uses
          (js-mode . js-ts-mode)
          (js-json-mode . json-ts-mode)
          (sh-mode . bash-ts-mode))))

;;; LSP (built-in)

(use-package eglot
  :ensure nil
  :hook ((rust-ts-mode elixir-ts-mode typescript-ts-mode tsx-ts-mode)
         . eglot-ensure))

;;; Diagnostics

;; eglot only reports in the buffers a server manages.  Flymake's own backends
;; cover the rest — elisp and shell, which is most of this repo.
;;
;; Elisp gets checkdoc here but not the byte-compiler: Emacs 30 gated
;; `elisp-flymake-byte-compile' on `trusted-content-p', and `trusted-content'
;; is nil, so it disables itself with "untrusted content" in every buffer but
;; init.el.  The fix is per-machine — it names directories on *this* disk and
;; states what elisp you will let an editor command run — so it belongs in the
;; gitignored custom.el, not here:
;;
;;   M-x customize-variable RET trusted-content RET   ; e.g. "~/Source/"
;;
;; Matching is on the abbreviated `buffer-file-truename', and a "/" suffix
;; makes an entry a directory prefix, so one entry covers the session
;; worktrees too.
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode))

;;; Folding

;; The only folding in the config; keys.el puts the buffer-wide commands on
;; meow's `z'.  The cycle filter matters in Lisp, where every top-level `('
;; is a heading: without it TAB anywhere on such a line cycles instead of
;; indenting.
(use-package outline
  :ensure nil
  :hook (prog-mode . outline-minor-mode)
  :custom
  (outline-minor-mode-cycle t)
  (outline-minor-mode-cycle-filter 'bolp))

;;; VC

(use-package magit
  :bind
  ("C-x g" . magit-status)
  ;; Default x is magit-reset-quickly; k for discard collides with meow's
  ;; motion keys.
  (:map magit-mode-map ("x" . magit-delete-thing)))

;; Folds each file's diff --git/index/---/+++ block into one file-name line.
(use-package diff-mode
  :ensure nil
  :custom
  (diff-font-lock-prettify t))

;; Ediff is launched from magit; keys.el gives it its own meow state.  Its
;; default control window is a separate frame, which on macOS is a floating
;; window that outlives the comparison.
(use-package ediff
  :ensure nil
  :custom
  (ediff-window-setup-function #'ediff-setup-windows-plain)
  (ediff-split-window-function #'split-window-horizontally)
  (ediff-keep-variants nil))

;;; Secrets

;; Built-in auth-source reads ~/.authinfo(.gpg) and, on Linux, the D-Bus Secret
;; Service.  Neither reaches 1Password, so the alternative is a second copy of
;; every secret in a file.  Serves magit forge, tramp and the agent keys.
;;
;; Stock defaults, as the old config ran them: a search for HOST and USER runs
;; `op read op://Personal/<host>/<user>'.  So the item is named for the host,
;; lives in the Personal vault, and the field is named for the user —
;; op://Personal/github.com/chrisj-devel.  A miss is silent and falls through
;; to the remaining backends, so ~/.authinfo still answers for anything not
;; kept in 1Password.  `auth-source-1password-vault' and
;; `-construct-secret-reference' are the knobs if that convention changes.
(use-package auth-source-1password
  :demand t
  :config
  (auth-source-1password-enable))

;;; Per-project env (direnv) — worktrees need their own envs

(use-package envrc
  :config
  (envrc-global-mode))

;;; Terminal

(use-package ghostel
  :preface
  ;; Named rather than a lambda on the key: `describe-key' and the dashboard's
  ;; key pane both have only the command to go on.
  (defun my/ghostel-here ()
    "Open a ghostel terminal for the project at point, or a bare one."
    (interactive)
    (if (project-current) (ghostel-project) (ghostel)))
  :custom
  (ghostel-tramp-shell-integration t)
  :bind
  ([f11] . my/ghostel-here)
  :config
  (add-to-list 'ghostel-tramp-shells '("podman" "/bin/sh")))

;;; Markup

;; Emacs 31 ships no markdown mode at all, so every CLAUDE.md, AGENTS.md and
;; skill file opens in fundamental-mode: no highlighting, no heading folding,
;; no list or table editing.  Nothing built-in is close.
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode))

;;; HTTP

;; The built-ins are url.el and eww — a library and a browser, neither of which
;; composes a request from a document or keeps the response.  verb makes an org
;; heading the request, and is what the verb-api agent skill drives.
(use-package verb
  :after org
  :demand t                             ; nothing else pulls it in, and :config
                                        ; is what installs the prefix
  :bind (:map verb-response-body-mode-map
              ("q" . verb-kill-response-buffer-and-window))
  :config
  ;; `verb-command-map' is a keymap value, not a command.  Through `:bind'
  ;; use-package autoloads it as a function and the prefix fails to define.
  (keymap-set org-mode-map "C-c C-r" verb-command-map))

;;; Agents

(use-package acp)

(use-package agent-shell
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
  ;; Splits only a window wider than `split-width-threshold'; see the
  ;; *HTTP Response* entry in core.el for why not `display-buffer-in-direction'.
  (agent-shell-display-action
   '((display-buffer-reuse-mode-window
      display-buffer-pop-up-window
      display-buffer-use-some-window)
     (inhibit-same-window . t)
     (preserve-size . (t . nil))))
  ;; Default is same-window, which makes a followed link eat the shell's own
  ;; half of the split. A followed file always reuses a window — never a split,
  ;; not even when the frame has room for one.
  (agent-shell-file-display-action
   '((display-buffer-reuse-window display-buffer-use-some-window)
     (inhibit-same-window . t))))

;;; MCP

;; The stdio bridge enables the tool set itself, over emacsclient, but
;; `mcp-server-lib-process-jsonrpc' refuses every request until the server is
;; started, so startup owes it that much. `mcp-server-lib-install-directory'
;; defaults to `user-emacs-directory', which is this repo through a symlink;
;; the script is the package's to version, not ours.
(use-package mcp-server-lib
  :custom
  (mcp-server-lib-install-directory (expand-file-name "~/.local/bin/"))
  :config
  (unless noninteractive (mcp-server-lib-start)))

;; Multi-file packages point package-lint at their main file through a
;; file-local, and the property marking it safe rides on package-lint's
;; autoloads, which we do not install. Visiting such a file prompts otherwise.
(put 'package-lint-main-file 'safe-local-variable #'stringp)

;; `elisp-dev-mcp-enable' is autoloaded and the bridge is what calls it.
(use-package elisp-dev-mcp
  :defer t
  :config
  ;; Natively compiled Elisp satisfies `subrp', so the dispatch's C branch
  ;; claims every ELPA and user function and returns no source at all.
  ;; `subr-native-elisp-p' is what separates those from a real subr.
  (define-advice elisp-dev-mcp--get-function-definition-dispatch
      (:around (orig function sym fn-info) native-comp-is-not-c)
    (let ((fn (nth 0 fn-info))
          (file (find-lisp-object-file-name sym 'defun)))
      (if (and file (subrp fn) (subr-native-elisp-p fn))
          (elisp-dev-mcp--get-function-definition-from-file
           function sym file (nth 1 fn-info) (nth 2 fn-info))
        (funcall orig function sym fn-info)))))

;;; Agent attention

(my/agent-attention-setup)

(provide 'dev)
;;; dev.el ends here
