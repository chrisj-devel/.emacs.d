;;; dashboard.el --- What Emacs opens on -*- lexical-binding: t; -*-
;;; Commentary:
;; Three panes in a tab of their own: the sessions in flight, the tracker
;; frontier across every repo, and the keys that drive them.  No new state
;; and no new renderer — the first two panes are `my/session-dashboard' and
;; `org-agenda' placed in windows, and the key pane is read out of the live
;; keymaps, so a rebound key cannot leave a stale cheat sheet behind.
;;
;; Startup runs it from `emacs-startup-hook', which with
;; `inhibit-startup-screen' (early-init.el) is the last thing to touch the
;; window layout.  Files named on the command line win over it.
;;; Code:

(require 'seq)
(require 'tab-bar)
(require 'sessions)
(require 'tickets)

(declare-function org-agenda "org-agenda")
;; Let-bound below before org-agenda's own defcustom has necessarily run; the
;; declaration is what keeps that binding dynamic rather than lexical.
(defvar org-agenda-window-setup)

(defgroup my/dashboard nil
  "Startup mission control."
  :group 'convenience)

(defcustom my/dashboard-tab-name "dashboard"
  "Name of the tab the dashboard lays itself out in."
  :type 'string)

(defcustom my/dashboard-at-startup t
  "Whether to open the dashboard when Emacs starts."
  :type 'boolean)

(defcustom my/dashboard-sessions-height 0.38
  "Fraction of the frame the sessions pane takes across the top."
  :type 'number)

(defconst my/dashboard-keys
  '(("Sessions"
     (my/dashboard . "this board")
     (my/session-dashboard . "sessions of one repo")
     (my/session-spawn . "worktree + branch + ticket + agent")
     (my/session-open . "jump to a work tab")
     (my/session-browse . "browse tab: sidebar + code")
     (my/session-teardown . "kill buffers, remove worktree"))
    ("Tracker"
     (org-agenda . "then w workboard, f frontier, F every repo"))
    ("Tools"
     (my/agent-shell-switch-or-start . "agent shell (C-u: a new one)")
     (my/ghostel-here . "terminal for the project at point")
     (dirvish-side . "file sidebar")
     (magit-status . "git")
     (window-toggle-side-windows . "hide/show side windows"))
    ("Find"
     (consult-buffer . "buffers, < narrows by source")
     (project-find-file . "file in this worktree")
     (consult-ripgrep . "search the worktree")
     (consult-line . "search the buffer")
     (embark-act . "act on the candidate at point")))
  "Key pane contents: groups of (COMMAND . LABEL).
Only the label is written down.  The key beside it is whatever the
command is bound to when the pane is drawn, and a command bound to
nothing is left out — including one reachable only from a mode map, since
the pane is drawn in a buffer where that map is not active.")

(defvar my/dashboard-keys-buffer "*Keys*")

(defun my/dashboard--binding (command)
  "Shortest key sequence bound to COMMAND, described, or nil for none."
  (when-let* (((fboundp command))
              (keys (where-is-internal command)))
    (key-description (car (sort keys :key #'length :lessp #'<)))))

(defun my/dashboard--special-buffer (name)
  "Empty writable NAME buffer in `special-mode', ready to be filled."
  (let ((buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (unless (derived-mode-p 'special-mode) (special-mode))
      (setq buffer-read-only nil)
      (erase-buffer))
    buffer))

(defun my/dashboard--keys-pane ()
  "Buffer listing `my/dashboard-keys' against the current bindings."
  (let ((buffer (my/dashboard--special-buffer my/dashboard-keys-buffer)))
    (with-current-buffer buffer
      (pcase-dolist (`(,group . ,entries) my/dashboard-keys)
        (insert (propertize group 'face 'bold) "\n")
        (pcase-dolist (`(,command . ,label) entries)
          (when-let* ((key (my/dashboard--binding command)))
            (insert (format "  %-14s %s\n"
                            (propertize key 'face 'help-key-binding)
                            label))))
        (insert "\n"))
      (goto-char (point-min))
      (setq buffer-read-only t))
    buffer))

(defun my/dashboard--frontier-pane (window)
  "Show the cross-repo tracker frontier in WINDOW."
  (require 'org-agenda)
  (with-selected-window window
    (if (my/tracker-all-org-files)
        ;; The agenda picks its own window otherwise, which is the one thing
        ;; a laid-out pane cannot allow.
        (let ((org-agenda-window-setup 'current-window))
          (org-agenda nil "F"))
      (let ((buffer (my/dashboard--special-buffer "*Tracker*")))
        (with-current-buffer buffer
          (insert "No ticket files in any known repo.\n")
          (setq buffer-read-only t))
        (set-window-buffer window buffer)))))

(defun my/dashboard--layout ()
  "Lay the three panes out over the selected tab, replacing what is there.
Sessions across the top, frontier and keys below, refreshed on every
call — the dashboard is only worth opening if it is current."
  (delete-other-windows)
  (let* ((top (selected-window))
         (bottom (split-window
                  top
                  (round (* my/dashboard-sessions-height (window-total-height top)))
                  'below))
         (keys (split-window bottom nil 'right)))
    ;; `set-window-buffer' rather than `display-buffer': *Sessions* has a
    ;; side-window entry in `display-buffer-alist' (core.el) that would pull
    ;; it out of the layout.
    (set-window-buffer top (my/session-dashboard--buffer nil))
    (set-window-buffer keys (my/dashboard--keys-pane))
    (my/dashboard--frontier-pane bottom)
    (select-window top)))

(defun my/dashboard ()
  "Open the dashboard tab: sessions, tracker frontier, keys."
  (interactive)
  (tab-bar-switch-to-tab my/dashboard-tab-name)
  (my/dashboard--layout))

(defun my/dashboard--startup ()
  "Open the dashboard on the tab Emacs started in.
Renaming the initial tab rather than adding one keeps the frame at the
single tab it booted with.  A file named on the command line is already
on screen by now and is what was actually asked for, so it wins."
  (remove-hook 'server-after-make-frame-hook #'my/dashboard--startup)
  (unless (seq-some #'buffer-file-name (buffer-list))
    (tab-bar-rename-tab my/dashboard-tab-name)
    (my/dashboard--layout)))

(defun my/dashboard--restore ()
  "Redraw the dashboard tab a restored desktop brought back empty.
A desktop that restored is the layout that was asked for, so the startup
dashboard stands down — `desktop-after-read-hook' runs before
`emacs-startup-hook', which is what makes standing it down possible.  Its
own tab is the exception: the three panes are generated buffers, which
desktop does not restore, so the tab returns holding whatever the frameset
fell through to.  The tab the desktop was saved in is the tab to be left
in, so the redraw goes back to it."
  (remove-hook 'emacs-startup-hook #'my/dashboard--startup)
  (remove-hook 'server-after-make-frame-hook #'my/dashboard--startup)
  (when (my/session--tab-p my/dashboard-tab-name)
    (let ((current (alist-get 'name (assq 'current-tab (funcall tab-bar-tabs-function)))))
      (my/dashboard)
      (unless (equal current my/dashboard-tab-name)
        (tab-bar-switch-to-tab current)))))

(add-hook 'desktop-after-read-hook #'my/dashboard--restore)

(when (and my/dashboard-at-startup (not noninteractive))
  (if (daemonp)
      ;; A daemon's startup hook runs with no real frame to lay out.
      (add-hook 'server-after-make-frame-hook #'my/dashboard--startup)
    (add-hook 'emacs-startup-hook #'my/dashboard--startup)))

(keymap-global-set "<f7>" #'my/dashboard)
(keymap-global-set "C-c d" #'my/dashboard)

(provide 'dashboard)
;;; dashboard.el ends here
