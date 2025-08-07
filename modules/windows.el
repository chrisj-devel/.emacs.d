;;; windows.el --- Windows specific configuration -*- no-byte-compile: t; lexical-binding: t; -*-
(use-package emacs
  :ensure nil
  :if (eq system-type 'windows-nt)
  :init
  (menu-bar-mode -1)
  (set-language-environment "UTF-8")
  (defvar msys-home "C:/msys64")
  (add-to-list 'exec-path (concat msys-home "/usr/bin") t)
  (add-to-list 'exec-path (concat msys-home "/ucrt64/bin") t))

(use-package shell
  :ensure nil
  :if (eq system-type 'windows-nt)
  :hook (comint-output-filter-functions . comint-strip-ctrl-m)
  :bind ("<f11>" . shell)
  :custom (prefer-coding-system 'utf-8))

(use-package elisp-mode
  :ensure nil
  :if (eq system-type 'windows-nt)
  :config/el-patch
  ;; byte compilation is wonky on windows and breaks flymake
  (defun elisp-flymake-byte-compile (_report-fn &rest _args) 'ignore))
