;;; display-conf.el --- Window and buffer configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:
(use-package auto-side-windows
  :ensure (:host github :repo "MArpogaus/auto-side-windows")
  :custom
  ;; Respects display actions when switching buffers
  (switch-to-buffer-obey-display-actions t)

  ;; Top side window configurations
  (auto-side-windows-top-buffer-names
    '("^\\*Backtrace\\*$"
       "^\\*Async-native-compile-log\\*$"
       "^\\*Compile-Log\\*$"
       "^\\*Multiple Choice Help\\*$"
       "^\\*Quick Help\\*$"
       "^\\*TeX Help\\*$"
       "^\\*TeX errors\\*$"
       "^\\*Warnings\\*$"
       "^\\*Process List\\*$"))
  (auto-side-windows-top-buffer-modes
    '(flymake-diagnostics-buffer-mode
       locate-mode
       occur-mode
       grep-mode
       xref--xref-buffer-mode))

  ;; Bottom side window configurations
  (auto-side-windows-bottom-buffer-names
    '("^\\*eshell\\*$"
       "^\\*shell\\*$"
       "^\\*term\\*$"))
  (auto-side-windows-bottom-buffer-modes
    '(eshell-mode
       shell-mode
       term-mode
       comint-mode
       debugger-mode))

  ;; Right side window configurations
  (auto-side-windows-right-buffer-names
    '("^\\*eldoc.*\\*$"
       "^\\*info\\*$"
       "^\\*Metahelp\\*$"))
  (auto-side-windows-right-buffer-modes
    '(Info-mode
       TeX-output-mode
       eldoc-mode
       help-mode
       helpful-mode
       shortdoc-mode))

  ;; Example: Custom parameters for top windows (e.g., fit height to buffer)
  ;; (auto-side-windows-top-alist '((window-height . fit-window-to-buffer)))
  ;; (auto-side-windows-top-window-parameters '((mode-line-format . ...))) ;; Adjust mode-line

  ;; Maximum number of side windows on the left, top, right and bottom
  (window-sides-slots '(1 1 1 1)) ; Example: Allow one window per side

  ;; Force left and right side windows to occupy full frame height
  (window-sides-vertical t)

  ;; Make changes to tab-/header- and mode-line-format persistent when toggling windows visibility
  (window-persistent-parameters
    (append window-persistent-parameters
      '((tab-line-format . t)
         (header-line-format . t)
         (mode-line-format . t))))
  :bind ;; Example keybindings (adjust prefix as needed)
  (:map global-map ; Or your preferred keymap prefix
    ("C-c w t" . auto-side-windows-display-buffer-top)
    ("C-c w b" . auto-side-windows-display-buffer-bottom)
    ("C-c w l" . auto-side-windows-display-buffer-left)
    ("C-c w r" . auto-side-windows-display-buffer-right)
    ("C-c w w" . auto-side-windows-switch-to-buffer)
    ("C-c w t" . window-toggle-side-windows) ; Toggle all side windows
    ("C-c w T" . auto-side-windows-toggle-side-window)) ; Toggle current buffer in/out of side window
  :hook (elpaca-after-init . auto-side-windows-mode))

(use-package popper
  :bind
  ([f12] . popper-toggle)
  ("M-<f12>" . popper-toggle-type)
  :hook
  (elpaca-after-init)
  (popper-mode . popper-echo-mode)
  :custom
  (popper-window-height 25)
  (popper-reference-buffers
    '("\\*Messages\\*"
       ("\\*Warnings\\*" . hide)
       "\\*compilation\\*"
       "\\*compilation-.*\\*"
       "\\*vc-diff.*\\*"
       "\\*vc-git.*\\*"
       "\\*vc\\*"
       "Output\\*$"
       "\\*Async Shell Command\\*"
       "\\*Buffer List\\*"
       "\\*shell\\*"
       "\\*.*-shell\\*"
       "\\*.*eshell.*\\*" eshell-mode
       compilation-mode
       rspec-compilation-mode
       exunit-compilation-mode
       "^\\*.*vterm.*\\*$" vterm-mode
       "^\\*prodigy.*\\*$" prodigy-mode
       "^\\*RE-Builder.*\\*$" reb-mode
       "^\\*Heroku.*\\*$"
       "^\\*jest-test-compilation\\*$"
       "^\\*Bundler\\*$"
       "^\\*EGLOT.*\\*$"
       "^\\*.*-eat.*\\*$"
       "^\\*.*Agent.*\\*$" agent-shell-mode
       "^\\*Inf-Elixir.*\\*$" inf-elixir-mode)))

(use-package popper
  :after auto-side-windows ; Ensure auto-side-windows variables are defined
  :hook (auto-side-windows-mode . popper-mode) ; Activate popper alongside
  :custom
  ;; Tell Popper to consider buffers matching auto-side-windows rules as popups
  (popper-reference-buffers
    (append auto-side-windows-top-buffer-names auto-side-windows-top-buffer-modes
      auto-side-windows-left-buffer-names auto-side-windows-left-buffer-modes
      auto-side-windows-right-buffer-names auto-side-windows-right-buffer-modes
      auto-side-windows-bottom-buffer-names auto-side-windows-bottom-buffer-modes))
  ;; Optional: Don't let Popper decide where to display, auto-side-windows handles that
  (popper-display-control nil) ; Or 'user if you prefer popper commands for display
  :config
  (popper-mode +1) ; Enable popper-mode
  (popper-echo-mode +1) ; Optional: echo area notifications
  :bind ;; Example bindings
  (:map your-prefix-map ;; e.g. my/toggle-map
    ("p" . popper-toggle)      ; Toggle last popup
    ("P" . popper-toggle-type) ; Toggle popups of specific type
    ("C-p" . popper-cycle)))   ; Cycle through visible popups

(provide 'display-conf)
;;; display-conf.el ends here
