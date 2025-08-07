(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-oceanic-next t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :config (doom-modeline-mode))

(use-package nerd-icons
  :custom (nerd-icons-font-family "FiraCode Nerd Font"))

(use-package nerd-icons
  :defer t
  :defines (nerd-icons-octicon))

(use-package nerd-icons-dired
  :after (nerd-icons)
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :after (nerd-icons marginalia)
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup)
  (elpaca-after-init))

(use-package nerd-icons-ibuffer
  :after (nerd-icons)
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package nerd-icons-corfu
  :after (nerd-icons corfu)
  :functions (nerd-icons-corfu-formatter)
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package solaire-mode
  :config (solaire-global-mode))
