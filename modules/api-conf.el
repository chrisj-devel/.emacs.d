;;; api.el --- API related configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package restclient
  :ensure (:host github :repo "pashky/restclient.el" :files ("restclient.el" "restclient-jq.el"))
  ;; disable url redirections in restclient mode
  :hook (restclient-mode . (lambda () (setq url-max-redirections 0))))

(use-package jq-mode
  :after (restclient))

(use-package uuidgen
  :after (restclient))

(use-package hmac
  :after (restclient))

(provide 'api-conf)
;;; api.el ends here
