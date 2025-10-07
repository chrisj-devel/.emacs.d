;;; linux.el --- Linux configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package exec-path-from-shell
  :init (exec-path-from-shell-initialize))

(add-to-list 'default-frame-alist '(undecorated . t))

(provide 'linux-conf)
;;; linux-conf.el ends here
