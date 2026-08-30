;;; early-init.el --- Pre-init frame and GC setup -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

(setq inhibit-startup-screen t
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      native-comp-async-report-warnings-errors 'silent)

(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

;;; early-init.el ends here
