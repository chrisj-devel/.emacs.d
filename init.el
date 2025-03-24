(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq use-package-always-ensure t)

(load (expand-file-name "modules/theme.el" user-emacs-directory))
(load (expand-file-name "modules/ui.el" user-emacs-directory))
(load (expand-file-name "modules/evil.el" user-emacs-directory))
(load (expand-file-name "modules/vc.el" user-emacs-directory))

(cua-mode +1)
(tool-bar-mode -1)
(windmove-default-keybindings)
(set-message-beep 'silent)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruvbox-dark-hard))
 '(custom-safe-themes
   '("18a1d83b4e16993189749494d75e6adb0e15452c80c431aca4a867bcc8890ca9"
     "d5fd482fcb0fe42e849caba275a01d4925e422963d1cd165565b31d3f4189c87"
     "8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378"
     "5a0ddbd75929d24f5ef34944d78789c6c3421aa943c15218bac791c199fc897d"
     "51fa6edfd6c8a4defc2681e4c438caf24908854c12ea12a1fbfd4d055a9647a3"
     "75b371fce3c9e6b1482ba10c883e2fb813f2cc1c88be0b8a1099773eb78a7176"
     "5aedf993c7220cbbe66a410334239521d8ba91e1815f6ebde59cecc2355d7757"
     default))
 '(package-selected-packages
   '(annalist embark-consult evil evil-collection goto-chg gruvbox-theme
	      magit marginalia meow orderless solaire-mode
	      spacious-padding undo-fu undo-fu-session vertico vundo
	      wgrep)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrainsMono NFM" :foundry "outline" :slant normal :weight regular :height 120 :width normal)))))
