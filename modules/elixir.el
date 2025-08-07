;;; elixir.el --- Elixir programming language configuration -*- no-byte-compile: t; lexical-binding: t; -*-
(use-package elixir-ts-mode
  :ensure nil
  :mode "\\.exs?\\'"
  :hook (elixir-ts-mode . eglot-ensure)
  :config (add-to-list 'elixir-ts--test-definition-keywords "property"))

(use-package exunit
  :hook (elixir-ts-mode))

(use-package mix
  :after (memoize)
  :hook (elixir-ts-mode . mix-minor-mode)
  :config (memoize 'mix--fetch-all-mix-tasks))

(use-package inf-elixir
  :after (elixir-ts-mode popper)
  :bind (:map elixir-ts-mode-map
          ("C-c i i" . inf-elixir)
          ("C-c i p" . inf-elixir-project)
          ("C-c i l" . inf-elixir-send-line)
          ("C-c i r" . inf-elixir-send-region)
          ("C-c i b" . inf-elixir-send-buffer)
          ("C-c i R" . inf-elixir-reload-module))
  :config
  (add-to-list popper-reference-buffers "^\\*Inf-Elixir.*\\*$" )
  (add-to-list popper-reference-buffers inf-elixir-mode))

(use-package erlang
  :mode ("\\.erl\\'" . erlang-mode))
