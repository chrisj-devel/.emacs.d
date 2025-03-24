(use-package evil
  :custom
  (evil-want-keybinding nil)
  (evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package undo-fu
  :custom
  (undo-fu-allow-undo-in-region t))

(use-package undo-fu-session
  :config
  (undo-fu-session-global-mode))

(use-package vundo
  :bind ("C-R" . vundo))

(use-package goto-chg)
