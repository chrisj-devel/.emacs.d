(use-package gruvbox-theme)

(use-package solaire-mode
  :config
  (solaire-global-mode))

(use-package visual-fill-column
  :bind ("C-c M-v" . visual-line-fill-column-mode)
  :custom
  (visual-fill-column-center-text t)
  (fill-column 120))
