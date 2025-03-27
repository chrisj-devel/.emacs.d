(use-package gptel
  :hook (gptel-mode . visual-line-fill-column-mode)
  :bind
  ("C-c a m" . gptel-menu)
  ("C-c a a" . gptel)
  ("C-c a s" . gptel-send)
  :custom (gptel-model 'gpt-4o-mini)
  :custom-face (gptel-context-highlight ((t (:extend t)))))

(use-package copilot
  :hook (prog-mode . copilot-mode)
  :bind
  ("C-c a c" . copilot-mode)
  (:map copilot-completion-map
    ("C-a" . copilot-accept-completion)
    ("C-A" . copilot-accept-completion-by-line)
    ("C-M-a" . 'copilot-accept-completion-by-word)
    ("C-n" . 'copilot-next-completion)
    ("C-p" . 'copilot-previous-completion)))
