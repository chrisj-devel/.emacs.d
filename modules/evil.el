(use-package evil
  :custom
  (evil-want-keybinding nil)
  (evil-undo-system 'undo-fu)
  (evil-respect-visual-line-mode t)
  :bind
  (:map evil-motion-state-map ("C-f" . consult-line))
  (:map evil-normal-state-map ("C-." . consult-project-extra-find))
  :hook
  (elpaca-after-init . evil-mode))

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
