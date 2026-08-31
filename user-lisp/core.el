;;; core.el --- Defaults, completion, windows, tabs -*- lexical-binding: t; -*-
;;; Commentary:
;; Everything here is built-in except dirvish.
;;; Code:

;;; Defaults

(use-package emacs
  :ensure nil
  :custom
  (use-short-answers t)
  (ring-bell-function #'ignore)
  (create-lockfiles nil)
  (backup-directory-alist `(("." . ,(expand-file-name "backup" user-emacs-directory))))
  (auto-save-file-name-transforms
   `((".*" ,(expand-file-name "autosave/" user-emacs-directory) t)))
  (recentf-max-saved-items 300)
  (auto-revert-interval 2)
  (global-auto-revert-non-file-buffers t)
  (project-mode-line t)
  :config
  ;; Emacs creates the backup directory on demand but not the auto-save one.
  (make-directory (expand-file-name "autosave/" user-emacs-directory) t)
  (savehist-mode 1)
  (recentf-mode 1)
  (save-place-mode 1)
  (repeat-mode 1)
  (which-key-mode 1)
  (delete-selection-mode 1)
  (electric-pair-mode 1)
  (global-auto-revert-mode 1)
  (pixel-scroll-precision-mode 1)
  (context-menu-mode 1)
  (column-number-mode 1))

;;; Completion (native: eager live-updating *Completions*, Emacs 31)

(use-package minibuffer
  :ensure nil
  :custom
  (completion-styles '(basic partial-completion flex))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (completions-detailed t)
  (completions-format 'one-column)
  (completions-max-height 12)
  (completions-sort 'historical)
  (completion-eager-display t)
  (completion-eager-update t)
  (minibuffer-visible-completions 'up-down))

;; Out-of-order matching in the minibuffer only; in-buffer completion keeps
;; the native styles so completion-preview retains prefix semantics.
(use-package orderless
  :demand t
  :config
  (add-hook 'minibuffer-setup-hook
            (lambda () (setq-local completion-styles '(orderless basic)))))

(add-hook 'prog-mode-hook #'completion-preview-mode)

;;; Windows: side windows replace popper/auto-side-windows

(windmove-default-keybindings)  ; shift+arrows between windows

(use-package window
  :ensure nil
  :bind
  ([f12] . window-toggle-side-windows)
  ;; Per-tab window-config undo (winner replacement, via tab-bar-history-mode)
  ("C-c <left>" . tab-bar-history-back)
  ("C-c <right>" . tab-bar-history-forward)
  :custom
  (switch-to-buffer-obey-display-actions t)
  (display-buffer-alist
   `(("\\*\\(Help\\|info\\|eldoc\\|Apropos\\)"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . right) (window-width . 0.35))
     ("\\*\\(compilation\\|grep\\|Occur\\|xref\\|Warnings\\|Messages\\|Flymake\\)"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3))
     ("\\*.*ghostel.*\\*"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3))
     ("\\*Sessions\\*"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3)))))

;;; Tabs: one tab per session (see sessions.el)

(use-package tab-bar
  :ensure nil
  :bind
  ("M-s-<right>" . tab-bar-switch-to-next-tab)
  ("M-s-<left>" . tab-bar-switch-to-prev-tab)
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-auto-width nil)
  (tab-bar-separator " | ")
  (tab-bar-format '(tab-bar-format-tabs
                    tab-bar-separator
                    tab-bar-format-align-right
                    tab-bar-format-global))
  :config
  (tab-bar-mode 1)
  (tab-bar-history-mode 1))

;;; Theme

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-hard :no-confirm))

;;; Dired

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

;;; macOS

(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        delete-by-moving-to-trash t
        trash-directory "~/.Trash")
  (if (executable-find "gls")
      (setq insert-directory-program "gls")
    (setq dired-use-ls-dired nil))
  (set-face-attribute 'default nil :font "Monaspace Neon NF" :height 130))

(provide 'core)
;;; core.el ends here
