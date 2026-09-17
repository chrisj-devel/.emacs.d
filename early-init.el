;;; early-init.el --- Frame, GC and the native-comp toolchain -*- lexical-binding: t; -*-
;;; Commentary:
;; Package setup is in init.el, and belongs there now that no use-package
;; declaration is compiled at startup.
;;; Code:

(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

(setq inhibit-startup-screen t
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(when (eq system-type 'darwin)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

;; Native compilation shells out to Homebrew's gcc driver by name, so it needs
;; /opt/homebrew/bin on PATH.  A GUI launch inherits launchd's PATH, which lacks
;; it, and every native compile dies with "error invoking gcc driver".
;; exec-path-from-shell fixes this too late: it runs from config/core.el, long
;; after Emacs has compiled user-lisp/.
(let ((brew "/opt/homebrew/bin"))
  (when (and (file-directory-p brew) (not (member brew exec-path)))
    (setenv "PATH" (concat brew ":" (getenv "PATH")))
    (push brew exec-path)))

;;; early-init.el ends here
