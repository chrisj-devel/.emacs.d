;;; prog-conf.el --- General Programming configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package emacs
  :ensure nil
  :hook (prog-mode . display-line-numbers-mode)
  :custom
  (display-line-numbers-grow-only t)
  (lisp-indent-offset 2)
  (yaml-indent-offset 2)
  (standard-indent 2)
  (js-indent-level 2)
  :config
  (setq-default require-final-newline t)
  (setq-default tab-width 2))

(use-package jsonrpc)

(use-package eglot
  :after (jsonrpc)
  :hook
  ((c++-mode
     c++-ts-mode
     js-mode
     js-ts-mode
     typescript-mode
     typescript-ts-mode
     css-mode
     css-ts-mode
     scss-mode
     ruby-mode
     ruby-ts-mode) . eglot-ensure)
  :custom
  (eglot-sync-connect nil) ;; Connect asynchronously without blocking
  (eglot-events-buffer-config '(:size nil :format lisp))
  (eglot-autoshutdown t)
  (eglot-code-action-indicator "*")
  (eglot-code-action-indications '())
  :config
  (add-to-list 'eglot-server-programs '(elixir-ts-mode "elixir-ls"))
  (setq-default eglot-workspace-configuration
    '(:elixirLS (:dialyzerEnabled t :dialyzerFormat "dialyxir_short" :mixEnv "dev" :mcpEnabled t))))

(use-package eglot-signature-eldoc-talkative
  :after (eldoc eglot)
  :config
  (advice-add #'eglot-signature-eldoc-function
    :override #'eglot-signature-eldoc-talkative))

(use-package apheleia
  :hook (prog-mode . apheleia-mode)
  :defines (apheleia-formatters apheleia-mode-alist)
  :config
  (add-to-list 'apheleia-formatters
    '(rubocop . ("rubocop" "--stdin" filepath "-a" "--stderr" "--format" "quiet" "--fail-level" "fatal")))
  (add-to-list 'apheleia-formatters '(htmlbeautifier . ("htmlbeautifier" "--keep-blank-lines" "1")))
  (add-to-list 'apheleia-mode-alist '(ruby-ts-mode . rubocop))
  (add-to-list 'apheleia-mode-alist '(ruby-mode . rubocop))
  (add-to-list 'apheleia-mode-alist '("\\.erb\\'" . htmlbeautifier))
  (add-to-list 'apheleia-mode-alist '(nxml-mode . html-tidy))
  (add-to-list 'apheleia-mode-alist '(nix-ts-mode . nixfmt))
  (add-to-list 'apheleia-formatters '(ts-standard . ("apheleia-from-project-root" "tsconfig.json" "ts-standard" "--fix" file)))
  (add-to-list 'apheleia-mode-alist '(typescript-ts-mode . ts-standard))
  (add-to-list 'apheleia-mode-alist '(tsx-ts-mode . ts-standard))
  (add-to-list 'apheleia-formatters '(standard . ("standard" "--fix" inplace)))
  (add-to-list 'apheleia-mode-alist '(js-mode . standard))
  (add-to-list 'apheleia-mode-alist '(js-ts-mode . standard)))

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode))

(use-package flymake-collection
  :after (flymake)
  :hook (elpaca-after-init . flymake-collection-hook-setup))

(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

(use-package scratch
  :bind ("C-c s" . scratch))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package treesit-fold
  :init (define-prefix-command 'treesit-fold-map)
  :bind (:map treesit-fold-map
          ("a" . treesit-fold-toggle)
          ("c" . treesit-fold-close)
          ("o" . treesit-fold-open)
          ("O" . treesit-fold-open-recursively)
          ("M" . treesit-fold-close-all)
          ("R" . treesit-fold-open-all))
  :config (global-treesit-fold-mode))

(use-package indent-bars
  :hook
  (prog-mode . indent-bars-mode)
  (yaml-ts-mode . indent-bars-mode)
  :bind ("C-c M-i" . indent-bars-toggle)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-color '(highlight :face-bg t :blend 0.15))
  (indent-bars-pattern ".")
  (indent-bars-width-frac 0.1)
  (indent-bars-pad-frac 0.1)
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1))
  (indent-bars-highlight-current-depth '(:blend 0.5))
  (indent-bars-display-on-blank-lines t)
  (indent-bars-prefer-character t))

(use-package stripspace
  :hook ((prog-mode . stripspace-local-mode)
          (text-mode . stripspace-local-mode)
          (conf-mode . stripspace-local-mode))
  :custom
  (stripspace-only-if-initially-clean nil)
  (stripspace-restore-column t))

(use-package eat
  :defines (eat-eshell-mode eat-project)
  :hook (eshell-load-hook . eat-eshell-mode)
  :bind ([f9] . eat-project))

(use-package ghostel
  :after popper
  :defines (ghostel-mode-map)
  :custom
  (ghostel-tramp-shells '(("ssh" login-shell) ("podman" "/bin/sh")))
  (ghostel-tramp-shell-integration t)
  :bind
  ([f11] . (lambda () (interactive) (if (project-current) (ghostel-project) (ghostel))))
  (:map ghostel-mode-map
    ([f11] . popper-toggle)
    ([f12] . popper-toggle)))

(use-package envrc
  :bind
  ("C-c e" . my/open-envrc-file)
  (:map envrc-file-mode-map
    ("C-c , a" . envrc-allow)
    ("C-c , d" . envrc-deny)
    ("C-c , r" . envrc-reload))
  :custom (envrc-show-summary-in-minibuffer nil)
  :hook (elpaca-after-init . envrc-global-mode)
  :config
  (defun my/open-envrc-file ()
    "Open the .envrc file in the current project."
    (interactive)
    (let ((envrc-dir (envrc--find-env-dir)))
      (if envrc-dir
        (if (file-exists-p (concat envrc-dir ".envrc"))
          (find-file (concat envrc-dir ".envrc"))
          (find-file (concat envrc-dir ".env")))
        (message "No envrc file found in the current project.")))))

(use-package dotenv-mode
  :mode
  ("\\.env\\..*\\'" . dotenv-mode))

(use-package mise
  :hook (elpaca-after-init . global-mise-mode))

(use-package csv-mode
  :mode
  ("\\.csv\\'" . csv-mode)
  ("\\.tsv\\'" . tsv-mode))

(use-package rainbow-csv
  :ensure (:host github :repo "emacs-vs/rainbow-csv")
  :hook ((csv-mode tsv-mode) . rainbow-csv-mode))

(use-package ligature
  :functions (ligature-set-ligatures)
  :hook (elpaca-after-init . global-ligature-mode)
  :config
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                        ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                        "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                        "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                        "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                        "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                        "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                        "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                        ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                        "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                        "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                        "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                        "\\\\" "://")))

(use-package kdl-mode)

(provide 'prog-conf)
;;; prog-conf.el ends here
