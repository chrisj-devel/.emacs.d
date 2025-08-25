;;; auth.el --- Authentication configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package auth-source-1password
  :hook (elpaca-after-init . auth-source-1password-enable))

(provide 'auth-conf)
;;; auth.el ends here
