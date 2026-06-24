;;; pitchfork.el --- Emacs interface for jdx/pitchfork daemon manager -*- lexical-binding: t; -*-

;; Author: Chris
;; Version: 0.2.0
;; Keywords: processes, tools
;; Package-Requires: ((emacs "28.1"))

;;; Commentary:
;; Thin wrapper around the pitchfork CLI: opens `pitchfork tui' in a ghostel
;; terminal, plus a global minor mode that auto-starts daemons when switching
;; into a project containing a pitchfork.toml file.

;;; Code:

(declare-function ghostel-exec "ghostel")
(declare-function ghostel-mode "ghostel")

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

;;;; Internal state

(defvar pitchfork--active-projects (make-hash-table :test #'equal)
  "Hash table of project roots with pitchfork daemons started by Emacs.
Keys are project root strings, values are t.")

;;;; Helpers

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

(defun pitchfork--run-async (args root &optional callback)
  "Run pitchfork with ARGS in ROOT asynchronously.
Calls CALLBACK (if non-nil) when the process exits."
  (let ((default-directory root))
    (make-process
     :name "pitchfork"
     :buffer nil
     :command (cons pitchfork-executable args)
     :sentinel (lambda (proc _event)
                 (when (and callback (memq (process-status proc) '(exit signal)))
                   (funcall callback))))))

;;;; TUI entry point

;;;###autoload
(defun pitchfork ()
  "Open the pitchfork TUI dashboard in a ghostel terminal.
Switch to the existing TUI buffer if its process is still live, otherwise
launch `pitchfork tui' in the current project's root.  The buffer is killed
automatically when the TUI exits (see `ghostel-kill-buffer-on-exit')."
  (interactive)
  (require 'ghostel)
  (let* ((name "*pitchfork-tui*")
         (existing (get-buffer name)))
    (if (and existing (process-live-p (get-buffer-process existing)))
        (pop-to-buffer existing)
      (let ((default-directory (or (pitchfork--project-root) default-directory))
            (buf (get-buffer-create name)))
        (with-current-buffer buf
          (unless (derived-mode-p 'ghostel-mode)
            (ghostel-mode)))
        (pop-to-buffer buf)
        (ghostel-exec buf pitchfork-executable '("tui"))))))

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
