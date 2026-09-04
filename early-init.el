;;; early-init.el --- Package bootstrap, frame and GC setup -*- lexical-binding: t; -*-
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

;; Native compilation shells out to Homebrew's gcc driver by name, so it needs
;; /opt/homebrew/bin on PATH.  A GUI launch inherits launchd's PATH, which lacks
;; it, and every native compile dies with "error invoking gcc driver".
;; exec-path-from-shell fixes this too late: it runs from init.el, long after
;; the user-lisp compile below.
(let ((brew "/opt/homebrew/bin"))
  (when (and (file-directory-p brew) (not (member brew exec-path)))
    (setenv "PATH" (concat brew ":" (getenv "PATH")))
    (push brew exec-path)))

;; Package setup has to happen here, not in init.el.  Emacs 31 byte-compiles
;; `user-lisp-directory' during startup (`prepare-user-lisp'), and use-package
;; installs `:ensure' packages at byte-compile time rather than at load time.
;; That compile runs before init.el, so anything configured there — the MELPA
;; entry, the priorities, `use-package-always-ensure' — arrives too late and
;; nothing is ever installed.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))
(setq package-review-policy t)

(setq use-package-always-ensure t
      use-package-vc-prefer-newest t)

;;; early-init.el ends here
