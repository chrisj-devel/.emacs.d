;;; otpp-conf.el --- One-tab-per-project configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; Declared special so the `let' below binds it dynamically even before
;; magit (which owns the `defcustom') has loaded.
(defvar magit-display-buffer-function)

(defun my/project-magit-status ()
  "Open Magit status full-frame for the current project.
Used by `project-switch-project' so a freshly created otpp tab shows
Magit instead of a stale buffer from another project, without
affecting `magit-display-buffer-function' elsewhere.

First display the project root in Dired so that burying Magit with
`q' reveals the new project rather than the buffer left in the tab
by otpp."
  (interactive)
  (let ((root (project-root (project-current t))))
    (dired root)
    (delete-other-windows)
    (let ((magit-display-buffer-function
           #'magit-display-buffer-fullframe-status-v1))
      (magit-project-status))))

(use-package otpp
  :after project
  :hook
  (elpaca-after-init . otpp-mode)
  (elpaca-after-init . otpp-override-mode)
  :config
  (add-to-list 'otpp-override-commands 'consult-project-extra-find)
  (setq switch-to-prev-buffer-skip
        (lambda (_window buffer _bury-or-kill)
          (when-let ((proj (project-current)))
            (not (memq buffer (project-buffers proj)))))))

(use-package project
  :ensure nil
  :after otpp
  :custom
  (project-switch-commands 'my/project-magit-status))

(provide 'otpp-conf)
;;; otpp-conf.el ends here
