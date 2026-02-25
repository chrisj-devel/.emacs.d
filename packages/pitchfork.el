;;; pitchfork.el --- Emacs interface for jdx/pitchfork daemon manager -*- lexical-binding: t; -*-

;; Author: Chris
;; Version: 0.1.0
;; Keywords: processes, tools
;; Package-Requires: ((emacs "28.1"))

;;; Commentary:
;; Provides a tabulated-list UI for managing pitchfork daemons, plus a global
;; minor mode that auto-starts daemons when switching into a project that
;; contains a pitchfork.toml file.

;;; Code:

;;;; Customization

(defgroup pitchfork nil
  "Emacs interface for the pitchfork daemon manager."
  :group 'processes
  :prefix "pitchfork-")

(defcustom pitchfork-executable "pitchfork"
  "Path to the pitchfork executable."
  :type 'string
  :group 'pitchfork)

(defcustom pitchfork-auto-stop-on-project-switch nil
  "When non-nil, stop daemons when switching away from a project with pitchfork.toml."
  :type 'boolean
  :group 'pitchfork)

(defcustom pitchfork-log-tail-lines 200
  "Number of recent log lines to show when opening a daemon log buffer.
Set to nil to show all lines."
  :type '(choice (integer :tag "Number of lines")
                 (const :tag "All lines" nil))
  :group 'pitchfork)

;;;; Internal state

(defvar pitchfork--active-projects (make-hash-table :test #'equal)
  "Hash table of project roots with pitchfork daemons started by Emacs.
Keys are project root strings, values are t.")

;;;; Faces

(defface pitchfork-status-running
  '((t :foreground "green" :weight bold))
  "Face for running daemons."
  :group 'pitchfork)

(defface pitchfork-status-errored
  '((t :foreground "red" :weight bold))
  "Face for errored daemons."
  :group 'pitchfork)

(defface pitchfork-status-available
  '((t :foreground "gray"))
  "Face for available (not running) daemons."
  :group 'pitchfork)

;;;; Parsing

(defun pitchfork--run-sync (args)
  "Run pitchfork with ARGS synchronously and return output string."
  (with-output-to-string
    (with-current-buffer standard-output
      (apply #'call-process pitchfork-executable nil t nil args))))

;;;; Config file lookup

(defun pitchfork--config-files ()
  "Return list of pitchfork.toml paths from `pitchfork config'."
  (split-string (pitchfork--run-sync '("config")) "\n" t))

(defun pitchfork--find-daemon-in-file (name file)
  "Return the line number of [daemons.NAME] in FILE, or nil."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward
           (concat "^\\[daemons\\." (regexp-quote name) "\\]") nil t)
      (line-number-at-pos))))

(defun pitchfork--open-daemon-config (name)
  "Open the pitchfork.toml containing [daemons.NAME] and jump to it."
  (let* ((files (pitchfork--config-files))
         (found (seq-some (lambda (f)
                            (when-let ((line (pitchfork--find-daemon-in-file name f)))
                              (cons f line)))
                          files)))
    (if found
        (progn
          (find-file (car found))
          (goto-char (point-min))
          (forward-line (1- (cdr found))))
      (user-error "Could not find [daemons.%s] in any pitchfork.toml" name))))

(defun pitchfork--parse-list ()
  "Run `pitchfork list' and return a list of entries.
Each entry is a plist with :name :pid :status :error keys."
  (let ((output (pitchfork--run-sync '("list" "--hide-header")))
        (entries nil))
    (dolist (line (split-string output "\n" t))
      (let* ((parts (split-string line nil t))
             (len (length parts)))
        (when (>= len 1)
          (let* ((name (nth 0 parts))
                 (pid-or-status (nth 1 parts))
                 ;; pitchfork list columns: Name PID Status Error
                 ;; When not running, PID is omitted: Name Status Error
                 (has-pid (and pid-or-status (string-match-p "\\`[0-9]+\\'" pid-or-status)))
                 (pid (if has-pid pid-or-status ""))
                 (status (if has-pid (or (nth 2 parts) "") (or pid-or-status "")))
                 (error-msg (if has-pid
                                (mapconcat #'identity (nthcdr 3 parts) " ")
                              (mapconcat #'identity (nthcdr 2 parts) " "))))
            (push (list :name name :pid pid :status status :error error-msg)
                  entries)))))
    (nreverse entries)))

;;;; Tabulated list UI

(defun pitchfork--status-face (status)
  "Return a face for STATUS string."
  (cond
   ((string= status "running") 'pitchfork-status-running)
   ((string= status "errored") 'pitchfork-status-errored)
   (t 'pitchfork-status-available)))

(defun pitchfork--make-entries (daemons)
  "Convert DAEMONS plist list into tabulated-list entries."
  (mapcar (lambda (d)
            (let* ((name (plist-get d :name))
                   (status (plist-get d :status))
                   (pid (plist-get d :pid))
                   (err (plist-get d :error))
                   (face (pitchfork--status-face status)))
              (list name
                    (vector
                     (propertize name
                                 'face 'link
                                 'action (let ((n name))
                                           (lambda (_btn)
                                             (pitchfork--open-daemon-config n)))
                                 'follow-link t
                                 'help-echo "mouse-2, RET: open config")
                     (propertize status 'face face)
                     (propertize pid 'face 'default)
                     (propertize err 'face (if (string-empty-p err) 'default 'pitchfork-status-errored))))))
          daemons))

(defun pitchfork--refresh ()
  "Refresh the pitchfork buffer."
  (when-let ((buf (get-buffer "*pitchfork*")))
    (with-current-buffer buf
      (setq tabulated-list-entries (pitchfork--make-entries (pitchfork--parse-list)))
      (tabulated-list-print t))))

;;;; Async commands

(defun pitchfork--run-async (args &optional callback)
  "Run pitchfork with ARGS asynchronously.
Calls CALLBACK (if non-nil) when the process exits."
  (let ((proc (make-process
               :name "pitchfork"
               :buffer nil
               :command (cons pitchfork-executable args)
               :sentinel (lambda (proc _event)
                           (when (memq (process-status proc) '(exit signal))
                             (pitchfork--refresh)
                             (when callback (funcall callback)))))))
    proc))

(defun pitchfork--daemon-at-point ()
  "Return the daemon name at point, or signal an error."
  (or (tabulated-list-get-id)
      (user-error "No daemon at point")))

;;;; Interactive commands

(defun pitchfork-start (name)
  "Start daemon NAME."
  (interactive (list (pitchfork--daemon-at-point)))
  (message "pitchfork: starting %s..." name)
  (pitchfork--run-async (list "start" name)))

(defun pitchfork-start-all ()
  "Start all daemons."
  (interactive)
  (message "pitchfork: starting all daemons...")
  (pitchfork--run-async '("start" "--all")))

(defun pitchfork-stop (name)
  "Stop daemon NAME."
  (interactive (list (pitchfork--daemon-at-point)))
  (message "pitchfork: stopping %s..." name)
  (pitchfork--run-async (list "stop" name)))

(defun pitchfork-stop-all ()
  "Stop all daemons."
  (interactive)
  (message "pitchfork: stopping all daemons...")
  (pitchfork--run-async '("stop" "--all")))

(defun pitchfork-restart (name)
  "Restart daemon NAME."
  (interactive (list (pitchfork--daemon-at-point)))
  (message "pitchfork: restarting %s..." name)
  (pitchfork--run-async (list "restart" name)))

(define-derived-mode pitchfork-log-mode special-mode "Pitchfork-Log"
  "Major mode for viewing pitchfork daemon logs."
  (setq-local truncate-lines t))

(defun pitchfork-logs (name)
  "Open a tailing log buffer for daemon NAME.
Reuses an existing buffer and process if already running."
  (interactive (list (pitchfork--daemon-at-point)))
  (let* ((buf-name (format "*pitchfork-logs:%s*" name))
         (buf (get-buffer-create buf-name))
         (existing-proc (get-buffer-process buf)))
    (unless (and existing-proc (process-live-p existing-proc))
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (erase-buffer))
        (pitchfork-log-mode)
        (let ((proc (make-process
                     :name (format "pitchfork-logs-%s" name)
                     :buffer buf
                     :command (append (list pitchfork-executable "logs" name "--tail" "--no-pager")
                                      (when pitchfork-log-tail-lines
                                        (list "-n" (number-to-string pitchfork-log-tail-lines))))
                     :sentinel #'ignore
                     :filter (lambda (proc string)
                               (when (buffer-live-p (process-buffer proc))
                                 (with-current-buffer (process-buffer proc)
                                   (let ((inhibit-read-only t)
                                         (moving (= (point) (point-max))))
                                     (save-excursion
                                       (goto-char (point-max))
                                       (insert (ansi-color-apply string)))
                                     (when moving (goto-char (point-max))))))))))
          (set-process-query-on-exit-flag proc nil))))
    (switch-to-buffer buf)))

;;;; Major mode

(defvar-keymap pitchfork-mode-map
  :doc "Keymap for `pitchfork-mode'."
  "s" #'pitchfork-start
  "S" #'pitchfork-start-all
  "x" #'pitchfork-stop
  "k" #'pitchfork-stop
  "X" #'pitchfork-stop-all
  "r" #'pitchfork-restart
  "l" #'pitchfork-logs
  "g" #'pitchfork-refresh
  "q" #'quit-window)

(define-derived-mode pitchfork-mode tabulated-list-mode "Pitchfork"
  "Major mode for managing pitchfork daemons."
  (setq tabulated-list-format
        [("Name"   24 t)
         ("Status" 12 t)
         ("PID"     8 t)
         ("Error"   0 nil)])
  (setq tabulated-list-sort-key '("Name" . nil))
  (tabulated-list-init-header)
)

(defun pitchfork-refresh ()
  "Refresh the daemon list."
  (interactive)
  (pitchfork--refresh))

;;;; Entry point

;;;###autoload
(defun pitchfork ()
  "Open the pitchfork daemon manager buffer."
  (interactive)
  (let ((buf (get-buffer-create "*pitchfork*")))
    (with-current-buffer buf
      (pitchfork-mode)
      (pitchfork--refresh))
    (pop-to-buffer buf)))

;;;###autoload
(defun pitchfork-open-config ()
  "Open pitchfork.toml for the current project, creating it if it doesn't exist."
  (interactive)
  (let* ((root (or (pitchfork--project-root) default-directory))
         (toml (expand-file-name "pitchfork.toml" root)))
    (unless (pitchfork--has-toml-p root)
      (with-temp-file toml
        (insert "#:schema https://pitchfork.jdx.dev/schema.json\n\n"
                "# [daemons.example]\n"
                "# run = \"echo hello\"\n"
                "# auto = [\"start\", \"stop\"]\n")))
    (find-file toml)))

;;;; Auto-start minor mode

(defun pitchfork--project-root ()
  "Return the current project root directory, or nil."
  (when-let ((proj (project-current)))
    (project-root proj)))

(defun pitchfork--has-toml-p (dir)
  "Return non-nil if DIR contains a pitchfork.toml."
  (and dir (file-exists-p (expand-file-name "pitchfork.toml" dir))))

(defun pitchfork--project-buffers (root)
  "Return all live buffers belonging to project ROOT."
  (seq-filter (lambda (buf)
                (with-current-buffer buf
                  (equal root (pitchfork--project-root))))
              (buffer-list)))

(defun pitchfork--auto-start-maybe ()
  "Auto-start pitchfork daemons when opening the first buffer in a project."
  (let ((root (pitchfork--project-root)))
    (when (and root
               (pitchfork--has-toml-p root)
               (not (gethash root pitchfork--active-projects)))
      (puthash root t pitchfork--active-projects)
      (let ((default-directory root))
        (message "pitchfork: auto-starting daemons in %s" root)
        (pitchfork--run-async '("start" "--all" "-q"))))))

(defun pitchfork--auto-stop-maybe ()
  "Auto-stop pitchfork daemons when the last buffer in a project is killed."
  (when pitchfork-auto-stop-on-project-switch
    (let ((root (pitchfork--project-root)))
      (when (and root
                 (gethash root pitchfork--active-projects)
                 ;; current buffer is still live here, so check for <= 1
                 (<= (length (pitchfork--project-buffers root)) 1))
        (remhash root pitchfork--active-projects)
        (let ((default-directory root))
          (message "pitchfork: auto-stopping daemons in %s" root)
          (pitchfork--run-async '("stop" "--all")))))))

;;;###autoload
(define-minor-mode pitchfork-auto-start-mode
  "Global minor mode to auto-start/stop pitchfork daemons based on open buffers."
  :global t
  :group 'pitchfork
  (if pitchfork-auto-start-mode
      (progn
        (add-hook 'find-file-hook #'pitchfork--auto-start-maybe)
        (add-hook 'kill-buffer-hook #'pitchfork--auto-stop-maybe))
    (remove-hook 'find-file-hook #'pitchfork--auto-start-maybe)
    (remove-hook 'kill-buffer-hook #'pitchfork--auto-stop-maybe)
    (clrhash pitchfork--active-projects)))

(provide 'pitchfork)
;;; pitchfork.el ends here
