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

;;; VC

(use-package magit
  :bind ("C-x g" . magit-status))

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
     (preserve-size . (t . nil)))))

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
