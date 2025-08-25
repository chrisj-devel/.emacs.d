;;; rust.el --- Rust programming language configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package rust-ts-mode
  :ensure nil
  :hook (rust-ts-mode . eglot-ensure)
  :config/el-patch
  ;; Running this in a cargo project doesn't work very well...
  (defun rust-ts-flymake (_report-fn &rest _args) 'ignore))

(use-package rust-mode
  :init (setq rust-mode-treesitter-derive t))

(provide 'rust-conf)
;;; rust.el ends here
