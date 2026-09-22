;;; init.el --- Native-first Emacs 31 configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Priority order: built-in > package > custom function.
;; Lives at ~/.emacs.d, or any checkout passed to emacs --init-directory.
;;
;; config/ holds the use-package declarations, user-lisp/ the libraries Emacs
;; 31 compiles at startup.  use-package installs `:ensure' packages at
;; byte-compile time, so a declaration left in user-lisp/ installs from inside
;; a comp subprocess.  Hence the split.
;;; Code:

;;; Packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-archive-priorities '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))
(setq package-review-policy t)

(setq use-package-always-ensure t
      use-package-vc-prefer-newest t)

;;; Configuration

;; Source, not .elc: a .elc would go to deferred native compilation.
(dolist (file '("core" "completing" "keys" "dev" "org-tracker"))
  (load (expand-file-name (format "config/%s.el" file) user-emacs-directory)
        nil :nomessage))

;;; Startup layout

;; Pulls in sessions and tickets.  tracker stays autoloaded, which is what
;; keeps org out of startup.
(require 'dashboard)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file :no-error-if-file-is-missing)

;;; init.el ends here
