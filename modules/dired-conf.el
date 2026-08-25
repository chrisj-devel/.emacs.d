;;; dired-conf.el --- Dired configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-Alh --group-directories-first")
  (dired-clean-confirm-killing-deleted-buffers nil)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package dired-filter)

(use-package dirvish
  :hook (elpaca-after-init . dirvish-override-dired-mode)
  :custom
  (dirvish-attributes '(nerd-icons subtree-state vc-state file-size))
  (dirvish-side-attributes '(nerd-icons subtree-state vc-state))
  (dirvish-side-width 30)
  :bind
  (([f1] . dirvish-side)
    :map dirvish-mode-map
    ("l" . dirvish-subtree-toggle)
    ("h" . dirvish-subtree-up))
  :config/el-patch
  ;; Projects rooted by `project-vc-extra-root-markers' alone have no
  ;; `vc-root-dir', which leaves side sessions at `default-directory'.
  (defun dirvish--vc-root-dir ()
    "Get expanded `vc-root-dir'."
    (when-let* ((root (el-patch-swap
                        (vc-root-dir)
                        (or (vc-root-dir)
                            (when-let* ((pr (project-current)))
                              (project-root pr))))))
      (expand-file-name root)))
  :config
  (dirvish-side-follow-mode))

(provide 'dired-conf)
;;; dired-conf.el ends here
