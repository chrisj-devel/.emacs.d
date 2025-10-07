;;; windows.el --- Windows specific configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(use-package emacs
  :ensure nil
  :init
  (menu-bar-mode -1)
  (set-language-environment "UTF-8")
  :config
  (setq-default default-frame-alist '((font . "Cascadia Mono:pixelsize=20:weight=regular")))
  (set-frame-font "Cascadia Mono:pixelsize=20:weight=regular" nil t))

(use-package shell
  :ensure nil
  :hook (comint-output-filter-functions . comint-strip-ctrl-m)
  :bind ("<f11>" . shell)
  :custom (prefer-coding-system 'utf-8))

(use-package elisp-mode
  :ensure nil
  :config/el-patch
  ;; byte compilation is wonky on windows and breaks flymake
  (defun elisp-flymake-byte-compile (_report-fn &rest _args) 'ignore))

(provide 'windows-conf)
;;; windows.el ends here
