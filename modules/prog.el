(use-package eglot
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

(use-package treesit-fold
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

(use-package envrc
  :bind
  ("C-c e" . my/open-envrc-file)
  (:map envrc-file-mode-map
    ("C-c , a" . envrc-allow)
    ("C-c , d" . envrc-deny)
    ("C-c , r" . envrc-reload))
  :custom (envrc-show-summary-in-minibuffer nil)
  :config
  (envrc-global-mode)
  (defun my/open-envrc-file ()
    "Open the .envrc file in the current project."
    (interactive)
    (let ((envrc-dir (envrc--find-env-dir)))
      (if envrc-dir
        (if (file-exists-p (concat envrc-dir ".envrc"))
          (find-file (concat envrc-dir ".envrc"))
          (find-file (concat envrc-dir ".env")))
        (message "No envrc file found in the current project.")))))

(use-package emacs
  :ensure nil
  :hook (prog-mode . display-line-numbers-mode)
  :custom (display-line-numbers-grow-only t)
  :config (setq-default require-final-newline t))
