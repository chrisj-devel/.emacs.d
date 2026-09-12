;;; init.el --- Native-first Emacs 31 configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Priority order: built-in > package > custom function.
;; Launch with: emacs --init-directory ~/Source/dotfiles/emacs31/.emacs.d
;;; Code:

;; Package archives and use-package defaults live in early-init.el; the
;; user-lisp/ compile that installs them runs before this file.
;; user-lisp/ is auto-compiled and added to load-path (Emacs 31).
(require 'core)
(require 'completing)
(require 'keys)
(require 'sessions)
(require 'tickets)
(require 'tracker)
(require 'dev)
(require 'dashboard)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error-if-file-is-missing)

;;; init.el ends here
