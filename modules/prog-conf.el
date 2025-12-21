;;; prog.el --- General Programming configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package emacs
  :ensure nil
  :hook (prog-mode . display-line-numbers-mode)
  :custom
  (display-line-numbers-grow-only t)
  (lisp-indent-offset 2)
  (yaml-indent-offset 2)
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
  :config
  ;; Workaround for the mise install having a bug
  ;; https://github.com/mise-plugins/mise-elixir-ls/issues/3
  (setenv "ELS_INSTALL_PREFIX" (substring (shell-command-to-string "mise where elixir-ls") 0 -1))
  (dolist (mode '((ruby-mode "ruby-lsp")
                   (ruby-ts-mode "ruby-lsp")
                   (elixir-ts-mode "elixir-ls")
                   ))
    (add-to-list 'eglot-server-programs mode))

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

(use-package vterm
  :if (not (eq system-type 'windows-nt))
  :after popper
  :functions (vterm my/vterm-show my/project-vterm)
  :defines (vterm-mode-map)
  :hook (vterm-mode . visual-line-mode)
  :custom
  (vterm-tramp-shells '((t login-shell) ("podman" "/bin/sh")))
  :bind
  ([f11] . my/vterm-show)
  (:map vterm-mode-map ([f11] . popper-toggle))
  (:map vterm-mode-map ([f12] . popper-toggle))
  :config
  (defun my/project-vterm ()
    "Open or switch to a vterm buffer for the current project.

     If the prefix ARG is set, open another vterm buffer."
    (interactive)
    (let* ((default-directory (project-root (project-current t)))
            (default-project-vterm-name (project-prefixed-buffer-name "vterm"))
            (vterm-buffer (get-buffer default-project-vterm-name)))
      (if (and vterm-buffer (not current-prefix-arg))
        (pop-to-buffer vterm-buffer (bound-and-true-p display-comint-buffer-action))
        (vterm (generate-new-buffer-name default-project-vterm-name)))))

  (defun my/vterm-show ()
    "Show or open a vterm buffer, context aware of whether it should be
     a project buffer."
    (interactive)
    (if (and (fboundp 'project-current) (project-current))
      (my/project-vterm)
      (if-let* ((vterm-buffer (get-buffer "*vterm*")))
        (pop-to-buffer vterm-buffer)
        (vterm)))))

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

(provide 'prog-conf)
;;; prog.el ends here
