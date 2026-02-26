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

(defface pitchfork-marked
  '((t :foreground "yellow" :weight bold))
  "Face for the mark indicator."
  :group 'pitchfork)

;;;; Parsing

(defun pitchfork--run-sync (args &optional dir)
  "Run pitchfork with ARGS synchronously in DIR and return output string."
  (let ((default-directory (or dir default-directory)))
    (with-output-to-string
      (with-current-buffer standard-output
        (apply #'call-process pitchfork-executable nil t nil args)))))

;;;; Config file lookup

(defun pitchfork--find-daemon-in-file (name file)
  "Return the line number of [daemons.NAME] in FILE, or nil."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (when (re-search-forward
           (concat "^\\[daemons\\." (regexp-quote name) "\\]") nil t)
      (line-number-at-pos))))

(defun pitchfork--open-daemon-config (name root)
  "Open the pitchfork.toml in ROOT containing [daemons.NAME] and jump to it."
  (let* ((files (split-string (pitchfork--run-sync '("config") root) "\n" t))
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

(defun pitchfork--parse-list (root)
  "Run `pitchfork list' in ROOT and return a list of daemon plists.
Each entry has :name :pid :status :error :root keys."
  (let ((output (pitchfork--run-sync '("list" "--hide-header") root))
        (entries nil))
    (dolist (line (split-string output "\n" t))
      (let* ((parts (split-string line nil t))
             (len (length parts)))
        (when (>= len 1)
          (let* ((name (car parts))
                 (pid-or-status (nth 1 parts))
                 (has-pid (and pid-or-status (string-match-p "\\`[0-9]+\\'" pid-or-status)))
                 (pid (if has-pid pid-or-status ""))
                 (status (if has-pid (or (nth 2 parts) "") (or pid-or-status "")))
                 (error-msg (if has-pid
                                (mapconcat #'identity (nthcdr 3 parts) " ")
                              (mapconcat #'identity (nthcdr 2 parts) " "))))
            (push (list :name name :pid pid :status status :error error-msg :root root)
                  entries)))))
    (nreverse entries)))

(defun pitchfork--local-daemon-info (root)
  "Return an alist of (NAME . URL-OR-NIL) for daemons defined in ROOT's config files."
  (let ((files (split-string (pitchfork--run-sync '("config") root) "\n" t))
        result)
    (dolist (file files)
      (when (file-exists-p file)
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (while (re-search-forward "^\\[daemons\\.\\([^]]+\\)\\]" nil t)
            (let ((name (match-string 1))
                  url)
              ;; Scan forward until the next section for ready_http / ready_port
              (save-excursion
                (let ((section-end (save-excursion
                                     (if (re-search-forward "^\\[" nil t)
                                         (match-beginning 0)
                                       (point-max)))))
                  (cond
                   ((re-search-forward "^ready_http\\s-*=\\s-*\"\\([^\"]+\\)\"" section-end t)
                    (setq url (match-string 1)))
                   ((re-search-forward "^ready_port\\s-*=\\s-*\\([0-9]+\\)" section-end t)
                    (setq url (format "http://localhost:%s" (match-string 1)))))))
              (push (cons name url) result))))))
    result))

(defun pitchfork--parse-all-projects ()
  "Return daemon plists for all known projects that have a pitchfork.toml.
Only includes daemons whose names are defined in that project's config,
preventing daemons from other projects leaking into the wrong project.
Each plist gains a :url key from ready_http / ready_port if present."
  (seq-mapcat (lambda (root)
                (when (pitchfork--has-toml-p root)
                  (let ((info (pitchfork--local-daemon-info root)))
                    (seq-keep
                     (lambda (d)
                       (when-let ((entry (assoc (plist-get d :name) info)))
                         (append d (list :url (cdr entry)))))
                     (pitchfork--parse-list root)))))
              (project-known-project-roots)))

;;;; Tabulated list UI

(defvar-local pitchfork--marks (make-hash-table :test #'equal)
  "Hash table of marked entry IDs (cons of root . name) in the pitchfork buffer.")

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
                   (root (plist-get d :root))
                   (status (plist-get d :status))
                   (pid (plist-get d :pid))
                   (err (plist-get d :error))
                   (face (pitchfork--status-face status))
                   (id (cons root name))
                   (marked (gethash id pitchfork--marks))
                   (mark-str (if marked "*" " ")))
              (list id
                    (vector
                     (propertize mark-str 'face 'pitchfork-marked)
                     (propertize (file-name-nondirectory (directory-file-name root))
                                 'face 'default)
                     (propertize name
                                 'face 'link
                                 'action (let ((n name) (r root))
                                           (lambda (_btn)
                                             (pitchfork--open-daemon-config n r)))
                                 'follow-link t
                                 'help-echo "mouse-2, RET: open config")
                     (propertize status 'face face)
                     (propertize pid 'face 'default)
                     (propertize err 'face (if (string-empty-p err) 'default 'pitchfork-status-errored))))))
          daemons))

(defun pitchfork--list-entries ()
  "Return tabulated-list entries for all known daemons."
  (pitchfork--make-entries (pitchfork--parse-all-projects)))

(defun pitchfork--refresh ()
  "Refresh the pitchfork buffer."
  (interactive)
  (when-let ((buf (get-buffer "*pitchfork*")))
    (with-current-buffer buf
      (tabulated-list-print t))))

;;;; Marks

(defun pitchfork--advance ()
  "Reprint the list and move point to the next line."
  (tabulated-list-print t)
  (ignore-errors (forward-line 1)))

(defun pitchfork--entry-id-at-point ()
  "Return the entry ID (root . name) at point, or signal an error."
  (or (tabulated-list-get-id)
      (user-error "No daemon at point")))

(defun pitchfork--marked-ids ()
  "Return list of marked entry IDs, or nil if none are marked."
  (let (ids)
    (maphash (lambda (id _) (push id ids)) pitchfork--marks)
    ids))

(defun pitchfork--targets ()
  "Return list of entry IDs to operate on: marks if any, else entry at point."
  (or (pitchfork--marked-ids)
      (list (pitchfork--entry-id-at-point))))

(defun pitchfork-mark ()
  "Mark the daemon at point and advance to the next line."
  (interactive)
  (puthash (pitchfork--entry-id-at-point) t pitchfork--marks)
  (pitchfork--advance))

(defun pitchfork-mark-all ()
  "Mark daemons with expanding selection.
First call marks all daemons in the project of the daemon at point.
Second consecutive call marks all daemons across all projects."
  (interactive)
  (let* ((id (pitchfork--entry-id-at-point))
         (root (car id))
         (project-ids (mapcar #'car (funcall tabulated-list-entries)))
         (project-marked (seq-every-p
                          (lambda (eid)
                            (when (equal (car eid) root)
                              (gethash eid pitchfork--marks)))
                          (seq-filter (lambda (eid) (equal (car eid) root))
                                      project-ids))))
    (if project-marked
        (dolist (eid project-ids)
          (puthash eid t pitchfork--marks))
      (dolist (eid project-ids)
        (when (equal (car eid) root)
          (puthash eid t pitchfork--marks))))
    (tabulated-list-print t)))

(defun pitchfork-unmark ()
  "Unmark the daemon at point and advance to the next line."
  (interactive)
  (remhash (pitchfork--entry-id-at-point) pitchfork--marks)
  (pitchfork--advance))

(defun pitchfork-unmark-all ()
  "Unmark all daemons."
  (interactive)
  (clrhash pitchfork--marks)
  (tabulated-list-print t))

;;;; Async commands

(defun pitchfork--run-async (args root &optional callback)
  "Run pitchfork with ARGS in ROOT asynchronously.
Calls CALLBACK (if non-nil) when the process exits."
  (let ((default-directory root))
    (make-process
     :name "pitchfork"
     :buffer nil
     :command (cons pitchfork-executable args)
     :sentinel (lambda (proc _event)
                 (when (memq (process-status proc) '(exit signal))
                   (pitchfork--refresh)
                   (when callback (funcall callback)))))))

(defun pitchfork--daemon-at-point ()
  "Return the daemon name at point, or signal an error."
  (cdr (pitchfork--entry-id-at-point)))

;;;; Interactive commands

(defun pitchfork--run-on-targets (verb command)
  "Run pitchfork COMMAND on each target, logging VERB.  Clears marks after."
  (dolist (id (pitchfork--targets))
    (let ((name (cdr id)) (root (car id)))
      (message "pitchfork: %s %s..." verb name)
      (pitchfork--run-async (list command name) root)))
  (clrhash pitchfork--marks))

(defun pitchfork--run-on-all-projects (verb command)
  "Run pitchfork COMMAND --all in every project with a pitchfork.toml, logging VERB."
  (dolist (root (seq-filter #'pitchfork--has-toml-p (project-known-project-roots)))
    (message "pitchfork: %s all daemons in %s..." verb root)
    (pitchfork--run-async (list command "--all") root)))

(defun pitchfork-start ()     "Start marked daemons, or daemon at point."  (interactive) (pitchfork--run-on-targets "starting" "start"))
(defun pitchfork-stop ()      "Stop marked daemons, or daemon at point."   (interactive) (pitchfork--run-on-targets "stopping" "stop"))
(defun pitchfork-restart ()   "Restart marked daemons, or daemon at point." (interactive) (pitchfork--run-on-targets "restarting" "restart"))
(defun pitchfork-start-all () "Start all daemons in all projects."          (interactive) (pitchfork--run-on-all-projects "starting" "start"))
(defun pitchfork-stop-all ()  "Stop all daemons in all projects."           (interactive) (pitchfork--run-on-all-projects "stopping" "stop"))

(define-derived-mode pitchfork-log-mode special-mode "Pitchfork-Log"
  "Major mode for viewing pitchfork daemon logs."
  (setq-local truncate-lines t))

(defun pitchfork-logs ()
  "Open a tailing log buffer for the daemon at point.
Reuses an existing buffer and process if already running."
  (interactive)
  (let* ((id (pitchfork--entry-id-at-point))
         (name (cdr id))
         (root (car id))
         (buf-name (format "*pitchfork-logs:%s*" name))
         (buf (get-buffer-create buf-name)))
    (unless (process-live-p (get-buffer-process buf))
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (erase-buffer))
        (pitchfork-log-mode)
        (let ((default-directory root)
              (proc (make-process
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

;;;; Browse

(defun pitchfork-browse ()
  "Open the URL for the daemon at point in a browser.
The URL is derived from ready_http or ready_port in pitchfork.toml."
  (interactive)
  (let* ((id (pitchfork--entry-id-at-point))
         (name (cdr id))
         (root (car id))
         (info (pitchfork--local-daemon-info root))
         (url (cdr (assoc name info))))
    (if url
        (browse-url url)
      (user-error "No URL configured for daemon %s (set ready_http or ready_port in pitchfork.toml)" name))))

;;;; Major mode

(defvar-keymap pitchfork-mode-map
  :doc "Keymap for `pitchfork-mode'."
  "RET" #'pitchfork-browse
  "m" #'pitchfork-mark
  "M" #'pitchfork-mark-all
  "u" #'pitchfork-unmark
  "U" #'pitchfork-unmark-all
  "s" #'pitchfork-start
  "S" #'pitchfork-start-all
  "x" #'pitchfork-stop
  "k" #'pitchfork-stop
  "X" #'pitchfork-stop-all
  "r" #'pitchfork-restart
  "l" #'pitchfork-logs
  "g" #'pitchfork--refresh
  "q" #'quit-window)

(define-derived-mode pitchfork-mode tabulated-list-mode "Pitchfork"
  "Major mode for managing pitchfork daemons."
  (buffer-disable-undo)
  (setq truncate-lines t)
  (setq tabulated-list-format
        [("M"       2  nil)
         ("Project" 16 t)
         ("Name"    20 t)
         ("Status"  12 t)
         ("PID"      8 t)
         ("Error"    0 nil)])
  (setq tabulated-list-sort-key '("Project" . nil))
  (setq tabulated-list-entries #'pitchfork--list-entries)
  (tabulated-list-init-header)
  (hl-line-mode 1))

;;;; Entry point

;;;###autoload
(defun pitchfork ()
  "Open the pitchfork daemon manager buffer."
  (interactive)
  (let ((buf (get-buffer-create "*pitchfork*")))
    (with-current-buffer buf
      (unless (eq major-mode 'pitchfork-mode)
        (pitchfork-mode))
      (tabulated-list-print t))
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
        (pitchfork--run-async '("start" "--all" "-q") root)))))

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
          (pitchfork--run-async '("stop" "--all") root))))))

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
