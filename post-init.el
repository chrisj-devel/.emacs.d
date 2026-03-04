;;; post-init.el --- General configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(use-package el-patch
  :ensure (:wait t)
  :custom (el-patch-enable-use-package-integration t))

(use-package memoize)

;; Update inbuilt Emacs libraries
(use-package transient)
(use-package flymake)
(use-package project)
(use-package track-changes)

(add-to-list 'load-path (expand-file-name "modules/" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "packages/" user-emacs-directory))

(if (eq system-type 'darwin) (require 'darwin-conf))
(if (eq system-type 'windows-nt) (require 'windows-conf))
(if (eq system-type 'gnu/linux) (require 'linux-conf))
(require 'theme-conf)
(require 'general-conf)
(require 'undo-conf)
(require 'meow-conf)
(require 'completion-conf)
(require 'vc-conf)
(require 'auth-conf)
(require 'prog-conf)
(require 'systems-conf)
(require 'rust-conf)
(require 'ruby-conf)
(require 'dired-conf)
(require 'elixir-conf)
(require 'api-conf)
(require 'ai-conf)
(require 'writing-conf)
(require 'web-conf)
(require 'pitchfork-conf)
(require 'casual-conf)

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

(provide 'post-init)
;;; post-init.el ends here
