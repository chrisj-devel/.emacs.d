;;; ruby.el --- Ruby programming language configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package rspec-mode
  :config (rspec-install-snippets))

(use-package inf-ruby)

(use-package rails-i18n
  :bind
  (:map ruby-ts-mode-map
    ("C-c i i" . rails-i18n-insert-with-cache)
    ("C-c i I" . rails-i18n-insert-no-cache)))

(use-package rails-routes
  :bind
  (:map ruby-ts-mode-map
    ("C-c r" . rails-routes-jump)
    ("C-c i r" . rails-routes-insert)
    ("C-c i R" . rails-routes-insert-no-cache)))

(provide 'ruby-conf)
;;; ruby.el ends here
