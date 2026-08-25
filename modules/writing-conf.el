;;; writing.el --- Writing configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode))

(use-package org
  :ensure nil
  :hook (org-mode . visual-line-mode)
  :custom (org-src-fontify-natively t))

(use-package visual-fill-column
  :bind ("C-c M-v" . visual-line-mode)
  :hook (visual-line-mode . visual-fill-column-for-vline)
  :custom
  (visual-fill-column-center-text t)
  (fill-column 120))

(defun cjv/apply-org-fonts (&rest _)
  "Keep code-like Org faces monospaced under `variable-pitch-mode'."
  (dolist (face '(org-table org-code org-verbatim org-block
                   org-block-begin-line org-block-end-line org-meta-line
                   org-drawer org-property-value org-special-keyword))
    (when (facep face)
      (set-face-attribute face nil :inherit 'fixed-pitch))))

(use-package org
  :ensure nil
  :hook ((org-mode . visual-line-mode)
          (org-mode . variable-pitch-mode))
  :config
  (add-hook 'enable-theme-functions #'cjv/apply-org-fonts)
  (cjv/apply-org-fonts))

(use-package org-modern
  :hook (elpaca-after-init . global-org-modern-mode))

(use-package org-edna
  :after org
  :config (org-edna-mode 1))

(provide 'writing-conf)
;;; writing.el ends here
