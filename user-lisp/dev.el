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
  :bind ("C-x g" . magit-status))

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
  :custom
  (ghostel-tramp-shell-integration t)
  :bind
  ([f11] . (lambda () (interactive)
             (if (project-current) (ghostel-project) (ghostel))))
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
  (agent-shell-display-action
   '((display-buffer-reuse-mode-window
      display-buffer-in-direction)
     (direction . right)
     (window-width . 0.5)
     (preserve-size . (t . nil))))
  ;; Default is same-window, which makes a followed link eat the shell's own
  ;; half of the split. Reuse a window on the left rather than splitting —
  ;; pop-up-window splits the largest window and slices get tiny fast.
  (agent-shell-file-display-action
   '((display-buffer-reuse-window display-buffer-use-some-window)
     (inhibit-same-window . t))))

;;; Agent attention
;;
;; Which shells are waiting on me, tallied in the tab bar, plus a macOS
;; notification when I am not looking at the shell. Rides `agent-shell's
;; public event API only; agent-shell-attention.el does the same but advises
;; `agent-shell--send-command' and rebinds `acp-send-request' to also track
;; busy state, which is more surface than a counter is worth.

(require 'map)
(declare-function agent-shell-subscribe-to "agent-shell")

(defvar my/agent-attention--pending (make-hash-table :test #'eq)
  "Agent shell buffers awaiting input, mapped to why they are waiting.")

(defun my/agent-attention--live ()
  "Pending buffers, reaping any that died."
  (let (live)
    (maphash (lambda (buffer _label)
               (if (buffer-live-p buffer)
                   (push buffer live)
                 (remhash buffer my/agent-attention--pending)))
             my/agent-attention--pending)
    live))

(defun my/agent-attention--indicator ()
  "Tally for `global-mode-string', which core.el routes into the tab bar."
  (let ((n (length (my/agent-attention--live))))
    (when (> n 0)
      (propertize (format " AS:%d " n) 'face 'mode-line-emphasis))))

(defun my/agent-attention--away-p (buffer)
  "Non-nil when BUFFER is not what I am currently looking at."
  (or (not (eq buffer (window-buffer (selected-window))))
      (not (seq-some #'frame-focus-state (frame-list)))))

(defun my/agent-attention--notify (buffer label)
  "Notify LABEL for BUFFER via osascript (notifications-notify is dbus-only)."
  (start-process "agent-notify" nil "osascript" "-e"
                 (format "display notification %S with title %S"
                         label (buffer-name buffer))))

(defun my/agent-attention--mark (buffer label)
  (puthash buffer label my/agent-attention--pending)
  (when (my/agent-attention--away-p buffer)
    (my/agent-attention--notify buffer label))
  (force-mode-line-update t))

(defun my/agent-attention--clear (buffer)
  (remhash buffer my/agent-attention--pending)
  (force-mode-line-update t))

(defun my/agent-attention--on-event (buffer event)
  (pcase (map-elt event :event)
    ('permission-request (my/agent-attention--mark buffer "Permission requested"))
    ('permission-response (my/agent-attention--clear buffer))
    ('turn-complete
     (let* ((data (map-elt event :data))
            (reason (or (map-elt data 'stopReason)
                        (map-elt data :stop-reason)))
            (label (pcase reason
                     ("max_tokens" "Max token limit reached")
                     ("max_turn_requests" "Exceeded request limit")
                     ("refusal" "Refused")
                     ("cancelled" "Cancelled")
                     (_ "Finished"))))
       ;; Only end_turn means it is my move; the rest are just worth knowing.
       (if (equal reason "end_turn")
           (my/agent-attention--mark buffer label)
         (when (my/agent-attention--away-p buffer)
           (my/agent-attention--notify buffer label))
         (my/agent-attention--clear buffer))))))

(defun my/agent-attention--subscribe ()
  (let ((buffer (current-buffer)))
    (agent-shell-subscribe-to
     :shell-buffer buffer
     :on-event (lambda (event)
                 (when (buffer-live-p buffer)
                   (my/agent-attention--on-event buffer event))))))

(defun my/agent-attention--maybe-clear ()
  "Clear attention once I actually visit the shell."
  (when (and (derived-mode-p 'agent-shell-mode)
             (gethash (current-buffer) my/agent-attention--pending))
    (my/agent-attention--clear (current-buffer))))

(add-hook 'agent-shell-mode-hook #'my/agent-attention--subscribe)
(add-hook 'buffer-list-update-hook #'my/agent-attention--maybe-clear)
(add-to-list 'global-mode-string '(:eval (my/agent-attention--indicator)) t)

(provide 'dev)
;;; dev.el ends here
