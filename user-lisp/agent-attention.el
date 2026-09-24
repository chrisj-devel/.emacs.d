;;; agent-attention.el --- Which agent shells are waiting on me -*- lexical-binding: t; -*-
;;; Commentary:
;; A dot on each session tab whose agent shell awaits input, a posframe
;; listing the waiting shells I cannot see, and a macOS notification when
;; Emacs is unfocused or the shell is out of the selected frame.  Rides `agent-shell's
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
(declare-function agent-shell-buffers "agent-shell")
(declare-function agent-shell-status "agent-shell")
(declare-function posframe-show "posframe")
(declare-function posframe-hide "posframe")
(declare-function posframe-workable-p "posframe")

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

(defun my/agent-attention--dot (label)
  "A dot for LABEL: red when it wants a permission, green otherwise."
  (propertize "\u25cf " 'face (if (equal label "Permission requested")
                                  'error
                                'success)))

(defun my/agent-attention--tab-dot (name tab _i)
  "Prefix NAME with a dot when TAB's worktree has an agent shell waiting."
  (let* ((root (alist-get 'my/session-worktree tab))
         (label (and root
                     (seq-some (lambda (buffer)
                                 (and (file-in-directory-p
                                       (buffer-local-value 'default-directory buffer)
                                       root)
                                      (gethash buffer my/agent-attention--pending)))
                               (my/agent-attention--live)))))
    (if label
        (concat (my/agent-attention--dot label) name)
      name)))

(defun my/agent-attention--tab-index (buffer)
  "Index of the session tab in the selected frame holding BUFFER."
  (seq-position (tab-bar-tabs) buffer
                (lambda (tab buf)
                  (when-let* ((root (alist-get 'my/session-worktree tab)))
                    (file-in-directory-p
                     (buffer-local-value 'default-directory buf) root)))))

(defun my/agent-attention--elsewhere-p (buffer)
  "Non-nil when Emacs is unfocused or BUFFER is out of the selected frame."
  (not (and (seq-some #'frame-focus-state (frame-list))
            (or (get-buffer-window buffer)
                (my/agent-attention--tab-index buffer)))))

(defun my/agent-attention-visit (buffer)
  "Select the session tab holding agent shell BUFFER and show it."
  (when (buffer-live-p buffer)
    (when-let* ((i (my/agent-attention--tab-index buffer)))
      (tab-bar-select-tab (1+ i)))
    (pop-to-buffer buffer)
    (select-frame-set-input-focus (selected-frame))))

(defconst my/agent-attention--posframe " *agent-attention*")

(defun my/agent-attention--bottom-right (info)
  "Posframe position inside the bottom-right window's text area, inset a char.
Positive pixels, as the NS port puts a child frame at 0,0 for negative ones."
  (let* ((frame (plist-get info :parent-frame))
         (window (seq-find (lambda (w)
                             (and (window-at-side-p w 'bottom)
                                  (window-at-side-p w 'right)))
                           (window-list frame 'nomini)))
         (edges (window-inside-pixel-edges window)))
    (cons (- (nth 2 edges) (plist-get info :posframe-width)
             (frame-char-width frame))
          (- (nth 3 edges) (plist-get info :posframe-height)
             (/ (frame-char-height frame) 2)))))

(defun my/agent-attention--render (&rest _)
  "List waiting shells not visible in this tab in a posframe, or hide it."
  (when (fboundp 'posframe-workable-p)
    (let ((lines (seq-keep (lambda (buffer)
                             (unless (get-buffer-window buffer)
                               (let ((label (gethash buffer my/agent-attention--pending)))
                                 (concat (my/agent-attention--dot label)
                                         (propertize (buffer-name buffer) 'face 'bold)
                                         "  " label))))
                           (my/agent-attention--live))))
      (if (and lines (posframe-workable-p))
          (posframe-show my/agent-attention--posframe
                         :string (let ((pad (propertize " " 'face '(:height 0.5))))
                                   (concat pad (propertize "\n" 'face '(:height 0.5))
                                           (string-join lines "\n") "\n"
                                           (propertize "C-c s a to jump" 'face 'shadow)
                                           "\n" pad))
                         :poshandler #'my/agent-attention--bottom-right
                         :border-width 1
                         :border-color (face-foreground 'shadow nil t)
                         :left-fringe 12
                         :right-fringe 12)
        (posframe-hide my/agent-attention--posframe)))))

(defun my/agent-attention--rank (buffer)
  "Where BUFFER comes in the jump order: blocked, finished, idle, busy."
  (pcase (gethash buffer my/agent-attention--pending)
    ("Permission requested" 0)
    ('nil (pcase (agent-shell-status :shell-buffer buffer)
            ('blocked 0)
            ('ready 2)
            (_ 3)))
    (_ 1)))

(defvar my/agent-attention--cycle nil
  "Agent shells still to visit in the current run of jumps.")

;;;###autoload
(defun my/agent-attention-jump ()
  "Visit the next agent shell, those waiting on me first, then idle, then busy.
Repeating this cycles through every shell."
  (interactive)
  (unless (eq last-command this-command)
    (setq my/agent-attention--cycle
          (append (remq (current-buffer)
                        (seq-sort-by #'my/agent-attention--rank #'<
                                     (agent-shell-buffers)))
                  (and (derived-mode-p 'agent-shell-mode)
                       (list (current-buffer))))))
  (setq my/agent-attention--cycle
        (seq-filter #'buffer-live-p my/agent-attention--cycle))
  (if-let* ((buffer (car my/agent-attention--cycle)))
      (progn
        (setq my/agent-attention--cycle
              (append (cdr my/agent-attention--cycle) (list buffer)))
        (my/agent-attention-visit buffer))
    (message "No agent shells")))

(defvar-keymap my/agent-attention-repeat-map
  :repeat t
  "a" #'my/agent-attention-jump)

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
  (when (my/agent-attention--elsewhere-p buffer)
    (my/agent-attention--notify buffer label))
  (my/agent-attention--render)
  (force-mode-line-update t))

(defun my/agent-attention--clear (buffer)
  (remhash buffer my/agent-attention--pending)
  (my/agent-attention--render)
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
         (cond ((my/agent-attention--elsewhere-p buffer)
                (my/agent-attention--notify buffer label))
               ((not (get-buffer-window buffer))
                (message "%s: %s" (buffer-name buffer) label)))
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
  (add-hook 'tab-bar-tab-post-select-functions #'my/agent-attention--render)
  (add-to-list 'tab-bar-tab-name-format-functions #'my/agent-attention--tab-dot))

(provide 'agent-attention)
;;; agent-attention.el ends here
