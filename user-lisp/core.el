;;; core.el --- Environment, defaults, completion, windows, tabs -*- lexical-binding: t; -*-
;;; Commentary:
;; Built-in except gruvbox-theme, dirvish, and exec-path-from-shell.
;;; Code:

;;; Environment

;; A GUI Emacs is launched by launchd, not a shell, so it inherits a bare PATH
;; with no homebrew and no mise.  Nothing built-in recovers it: the PATH is
;; assembled in ~/.zshrc, which launchd never runs, and mise's entries move with
;; every tool version so they cannot be hardcoded into `exec-path'.  This runs
;; first because everything below resolves executables.
(use-package exec-path-from-shell
  :config
  (when (or (daemonp) (memq window-system '(mac ns x pgtk)))
    (exec-path-from-shell-initialize)))

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

;; Minibuffer-scoped out-of-order matching lives in completing.el with the rest
;; of the carve-out; in-buffer completion keeps the native styles above so
;; completion-preview retains prefix semantics.
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

(use-package dired
  :ensure nil
  :custom
  ;; --group-directories-first is GNU-only; the macOS block below adds it when
  ;; gls is available.
  (dired-listing-switches "-Alh")
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-clean-confirm-killing-deleted-buffers nil))

(declare-function dirvish-side-follow-mode "dirvish-side")

;; `dirvish-icons' only declares the nerd-icons functions, so nothing loads the
;; library on our behalf.  "Symbols Nerd Font Mono" (the nerd-icons default) is
;; not installed; the patched Monaspace already carries the glyphs.
(use-package nerd-icons
  :custom (nerd-icons-font-family "Monaspace Neon NF"))

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons subtree-state vc-state file-size))
  (dirvish-side-attributes '(nerd-icons subtree-state vc-state))
  (dirvish-side-width 30)
  :bind
  ([f1] . dirvish-side)
  (:map dirvish-mode-map
        ("l" . dirvish-subtree-toggle)
        ("h" . dirvish-subtree-up))
  :config
  ;; GNU ELPA ships the extensions in a subdirectory that the package autoloads
  ;; never put on `load-path'.  Without this, `dirvish-side' (sessions.el) and
  ;; every attribute library `dirvish--check-dependencies' requires — vc,
  ;; subtree, collapse, icons, peek — are unreachable.
  (add-to-list 'load-path
               (expand-file-name "extensions"
                                 (file-name-directory (locate-library "dirvish"))))
  ;; f1 reaches `dirvish-side' before any session exists, and the extension has
  ;; no autoload to pull it in.  Subtree arrives via the subtree-state attribute.
  (require 'dirvish-side)
  (dirvish-override-dired-mode)
  (dirvish-side-follow-mode))

;;; macOS

(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        delete-by-moving-to-trash t
        trash-directory "~/.Trash")
  (if (executable-find "gls")
      (setq insert-directory-program "gls"
            dired-listing-switches "-Alh --group-directories-first")
    (setq dired-use-ls-dired nil))
  (set-face-attribute 'default nil :font "Monaspace Neon NF" :height 130))

(provide 'core)
;;; core.el ends here
