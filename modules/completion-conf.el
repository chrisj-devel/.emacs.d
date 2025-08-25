;;; completion.el --- Completion configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-auto t)
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package dabbrev
  :ensure nil
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
          ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

(use-package emacs
  :ensure nil
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package yasnippet
  :hook (elpaca-after-init . yas-global-mode))

(use-package yasnippet-snippets
  :after (yasnippet))

(use-package yasnippet-capf
  :after (yasnippet cape)
  :ensure (:host github :repo "elken/yasnippet-capf")
  :config (add-to-list 'completion-at-point-functions #'yasnippet-capf))

(provide 'completion-conf)
;;; completion.el ends here
