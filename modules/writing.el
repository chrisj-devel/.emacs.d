(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode))

(use-package visual-fill-column
  :bind ("C-c M-v" . visual-line-fill-column-mode)
  :custom
  (visual-fill-column-center-text t)
  (fill-column 120))
