(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :config (doom-modeline-mode))

(use-package nerd-icons
  :custom (nerd-icons-font-family "FiraCode Nerd Font"))

(use-package solaire-mode
  :config (solaire-global-mode))
