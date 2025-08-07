;;; post-init.el --- General configuration -*- no-byte-compile: t; lexical-binding: t; -*-
(use-package el-patch
  :ensure (:wait t)
  :custom (el-patch-enable-use-package-integration t))

(use-package memoize)

;; Update inbuilt Emacs libraries
(use-package transient)
(use-package flymake)

(if (eq system-type 'darwin) (load-file (expand-file-name "modules/darwin.el" user-emacs-directory)))
(if (eq system-type 'windows-nt) (load-file (expand-file-name "modules/windows.el" user-emacs-directory)))

(load (expand-file-name "modules/theme.el" user-emacs-directory))
(load (expand-file-name "modules/ui.el" user-emacs-directory))
(load (expand-file-name "modules/evil.el" user-emacs-directory))
(load (expand-file-name "modules/completion.el" user-emacs-directory))

(load (expand-file-name "modules/vc.el" user-emacs-directory))
(load (expand-file-name "modules/auth.el" user-emacs-directory))

(load (expand-file-name "modules/prog.el" user-emacs-directory))
(load (expand-file-name "modules/lisp.el" user-emacs-directory))
(load (expand-file-name "modules/systems.el" user-emacs-directory))
(load (expand-file-name "modules/rust.el" user-emacs-directory))
(load (expand-file-name "modules/elixir.el" user-emacs-directory))
(load (expand-file-name "modules/api.el" user-emacs-directory))

(load (expand-file-name "modules/ai.el" user-emacs-directory))
(load (expand-file-name "modules/writing.el" user-emacs-directory))

(use-package emacs
  :ensure nil
  :custom
  (make-backup-files t)
  (vc-make-backup-files t)
  (kept-old-versions 10)
  (kept-new-versions 10)
  (ring-bell-function 'ignore)
  (display-line-numbers-grow-only t)
  (custom-file (concat user-emacs-directory "custom.el"))
  :hook
  (elpaca-after-init . global-auto-revert-mode)
  (elpaca-after-init . (lambda() (let ((inhibit-message t)) (recentf-mode 1))))
  (kill-emacs-hook . recentf-cleanup)
  (elpaca-after-init . savehist-mode)
  (elpaca-after-init . save-place-mode)
  (elpaca-after-init . show-paren-mode)
  (elpaca-after-init . winner-mode)
  (elpaca-after-init . which-key-mode)
  (elpaca-after-init . (lambda () (load custom-file 'noerror)))
  :init
  (windmove-default-keybindings))
