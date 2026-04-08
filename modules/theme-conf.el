;;; theme-conf.el --- Theming configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package catppuccin-theme
  :disabled t
  :config
  (load-theme 'catppuccin t))

(use-package batppuccin-mocha-theme
  :vc (:url "https://github.com/bbatsov/batppuccin-emacs" :rev :newest)
  :config
  (load-theme 'batppuccin-mocha t))

(defun cjv/toggle-theme ()
  "Toggle between batppuccin-mocha (dark) and batppuccin-latte (light)."
  (interactive)
  (let ((current (car custom-enabled-themes)))
    (mapc #'disable-theme custom-enabled-themes)
    (if (eq current 'batppuccin-mocha)
        (load-theme 'batppuccin-latte t)
      (load-theme 'batppuccin-mocha t))))

(keymap-global-set "C-x w t" #'cjv/toggle-theme)

(use-package doom-modeline
  :config (doom-modeline-mode))

(use-package nerd-icons
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

(use-package winpulse
  :config (winpulse-mode +1))

(provide 'theme-conf)
;;; theme-conf.el ends here
