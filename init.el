;;; init.el --- Native-first Emacs 31 configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Priority order: built-in > package > custom function.
;; Launch with: emacs --init-directory ~/Source/dotfiles/emacs31/.emacs.d
;;; Code:

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))

(setq use-package-always-ensure t
      use-package-vc-prefer-newest t)

;; user-lisp/ is auto-compiled and added to load-path (Emacs 31).
(require 'core)
(require 'keys)
(require 'sessions)
(require 'tickets)
(require 'dev)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error-if-file-is-missing)

;;; init.el ends here
