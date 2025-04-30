(load-file (expand-file-name "elpaca-init.el" user-emacs-directory))
(if (eq system-type 'windows-nt) (elpaca-no-symlink-mode))
(elpaca elpaca-use-package (elpaca-use-package-mode))

(use-package benchmark-init
  :ensure (:wait t)
  :init (benchmark-init/activate)
  :hook (dashboard-mode . benchmark-init/deactivate))

(use-package elpaca
  :ensure nil
  :custom (elpaca-queue-limit 10)
  :bind ("C-x P" . elpaca-manager))

(setq use-package-always-ensure t)

(use-package el-patch
  :ensure (:wait t)
  :custom (el-patch-enable-use-package-integration t))

(use-package gcmh
  :hook (before-init))

;; Update inbuilt Emacs libraries
(use-package transient)
(use-package flymake)

(if (eq system-type 'darwin) (load-file (expand-file-name "darwin.el" user-emacs-directory)))

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

(load (expand-file-name "modules/ai.el" user-emacs-directory))
(load (expand-file-name "modules/writing.el" user-emacs-directory))

(cua-mode +1)
(savehist-mode +1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(which-key-mode +1)
(windmove-default-keybindings)
(setq ring-bell-function 'ignore)

(setq custom-file (concat user-emacs-directory "custom.el"))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

(provide 'init)
;;; init.el ends here
;;-*-no-byte-compile: t; -*-
