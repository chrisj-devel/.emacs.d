;;; agent-attention.el --- Which agent shells are waiting on me -*- lexical-binding: t; -*-
;;; Commentary:
;; A dot on each session tab whose agent shell awaits input, plus a macOS
;; notification when I am not looking at the shell.  Rides `agent-shell's
;; public event API only; agent-shell-attention.el does the same but advises
;; `agent-shell--send-command' and rebinds `acp-send-request' to also track
;; busy state, which is more surface than a counter is worth.
;;
;; Defines only; `my/agent-attention-setup' installs the hooks.
;;; Code:

(require 'map)
(require 'seq)
(require 'tab-bar)

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

(defun my/agent-attention--tab-dot (name tab _i)
  "Prefix NAME with a dot when TAB's worktree has an agent shell waiting.
Red when it wants a permission, green when its turn is over."
  (let* ((root (alist-get 'my/session-worktree tab))
         (label (and root
                     (seq-some (lambda (buffer)
                                 (and (file-in-directory-p
                                       (buffer-local-value 'default-directory buffer)
                                       root)
                                      (gethash buffer my/agent-attention--pending)))
                               (my/agent-attention--live)))))
    (if label
        (concat (propertize "\u25cf " 'face (if (equal label "Permission requested")
                                                'error
                                              'success))
                name)
      name)))

(defun my/agent-attention--away-p (buffer)
  "Non-nil when BUFFER is not visible in the tab I am looking at."
  (or (not (get-buffer-window buffer))
      (not (seq-some #'frame-focus-state (frame-list)))))

(defun my/agent-attention-visit (buffer)
  "Select the session tab holding agent shell BUFFER and show it."
  (when (buffer-live-p buffer)
    (when-let* ((i (seq-position
                    (tab-bar-tabs) buffer
                    (lambda (tab buf)
                      (when-let* ((root (alist-get 'my/session-worktree tab)))
                        (file-in-directory-p
                         (buffer-local-value 'default-directory buf) root))))))
      (tab-bar-select-tab (1+ i)))
    (pop-to-buffer buffer)
    (select-frame-set-input-focus (selected-frame))))

(defun my/agent-attention--notify (buffer label)
  "Notify LABEL for BUFFER via alerter; clicking it visits BUFFER."
  (let ((name (buffer-name buffer)))
    (make-process
     :name "agent-notify"
     :command (list "alerter" "--title" name "--message" label
                    "--group" name "--sender" "org.gnu.Emacs"
                    "--timeout" "600" "--json")
     :filter (lambda (_proc output)
               (when (string-match-p "\"activationType\" : \"[a-zA-Z]*Clicked\"" output)
                 (my/agent-attention-visit buffer))))))

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

;;;###autoload
(defun my/agent-attention-setup ()
  "Track which agent shells are waiting, on their tabs and by notification."
  (add-hook 'agent-shell-mode-hook #'my/agent-attention--subscribe)
  (add-hook 'buffer-list-update-hook #'my/agent-attention--maybe-clear)
  (add-to-list 'tab-bar-tab-name-format-functions #'my/agent-attention--tab-dot))

(provide 'agent-attention)
;;; agent-attention.el ends here
