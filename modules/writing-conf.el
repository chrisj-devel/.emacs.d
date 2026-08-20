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

(use-package org-edna
  :after org
  :config
  ;; Tickets are one file each, so blocking has to cross files.  Org's built-in
  ;; dependencies are subtree-scoped and cannot; edna's :BLOCKER: can.  Targets
  ;; are written as olp("file.org" "exact heading") — see
  ;; ~/.claude/docs/agents/issue-tracker.md.
  (org-edna-mode 1))

(provide 'writing-conf)
;;; writing.el ends here
