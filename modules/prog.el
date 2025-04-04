(use-package eglot
  :ensure nil
  :hook
  ((c++-mode
     c++-ts-mode
     elixir-ts-mode
     js-mode
     js-ts-mode
     typescript-mode
     typescript-ts-mode
     css-mode
     css-ts-mode
     scss-mode
     ruby-mode
     ruby-ts-mode
     rust-mode
     rust-ts-mode) . eglot-ensure)
  :custom
  (eglot-sync-connect nil) ;; Connect asynchronously without blocking
  (eglot-events-buffer-config '(:size nil :format lisp))
  (eglot-autoshutdown t)
  :config
  (dolist (mode '((elixir-ts-mode "elixir-ls")
                   (nix-ts-mode "nixd")))
    (add-to-list 'eglot-server-programs mode))

  (setq-default eglot-workspace-configuration
    '(:elixirLS (:dialyzerEnabled t :dialyzerFormat "dialyxir_short" :mixEnv "test"))))

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
  (add-to-list 'apheleia-formatters '(htmlbeautifier . ("htmlbeautifier")))
  (add-to-list 'apheleia-mode-alist '(ruby-ts-mode . rubocop))
  (add-to-list 'apheleia-mode-alist '(ruby-mode . rubocop))
  (add-to-list 'apheleia-mode-alist '("\\.erb\\'" . htmlbeautifier))
  (add-to-list 'apheleia-mode-alist '(nxml-mode . html-tidy))
  (add-to-list 'apheleia-mode-alist '(nix-ts-mode . nixfmt)))

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode))

(use-package flymake-collection
  :after (flymake)
  :hook (after-init . flymake-collection-hook-setup))

(use-package scratch
  :bind ("C-c s" . scratch))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))
