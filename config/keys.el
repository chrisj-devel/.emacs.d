;;; keys.el --- Meow modal editing -*- lexical-binding: t; -*-
;;; Commentary:
;; Vim-transitional keymap for meow, ported from the previous config.
;; Changes from the old meow-conf: undo-fu -> native undo-only/undo-redo,
;; treesit-fold dropped (native outline-minor-mode covers folding).
;;; Code:

(defun join-line-below ()
  "Join the next line onto the current line, like vim's J."
  (interactive)
  (delete-indentation t))

;; Folding lives on `z', where the old config had treesit-fold-map.  Outline's
;; own prefix map is all control chords under `C-c @', which is folding you do
;; not use; dev.el turns `outline-minor-mode' on in prog-mode.
(require 'outline)

(defvar-keymap my/fold-map
  :doc "Vim-shaped folding over `outline-minor-mode'."
  "a" #'outline-cycle
  "c" #'outline-hide-subtree
  "o" #'outline-show-children
  "O" #'outline-show-subtree
  "M" #'outline-hide-body
  "R" #'outline-show-all)

;; meow binds through `define-key', which resolves a symbol through its
;; function cell, so the keymap has to live there too.
(fset 'my/fold-map my/fold-map)

(use-package meow
  :demand t
  :custom
  (meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-expand-hint-remove-delay 3.0)
  (meow-use-clipboard t)
  (meow-selection-command-fallback
   '((meow-kill . meow-C-k)
     (meow-change . meow-change-char)
     (meow-save . meow-save-char)
     (meow-cancel-selection . keyboard-quit)
     (meow-pop-selection . meow-pop-grab)
     (meow-beacon-change . meow-beacon-change-char)))
  :config
  (meow-define-state ediff
    "Meow state for ediff buffers."
    :lighter " [E]"
    :keymap (make-sparse-keymap))

  (setq meow-mode-state-list
        (append '((git-commit-mode . insert)
                  (ghostel-mode . insert)
                  (agent-shell-mode . insert)
                  (my/session-dashboard-mode . motion)
                  (diff-mode . motion))
                meow-mode-state-list))

  ;; Motion mode (read-only buffers).  Renamed on meow master; MELPA
  ;; still ships the -overwrite- name.
  (funcall
   (if (fboundp 'meow-motion-define-key)
       #'meow-motion-define-key
     #'meow-motion-overwrite-define-key)
   '("j" . next-line)
   '("k" . previous-line)
   '("G" . end-of-buffer)
   '("`" . beginning-of-buffer)
   '("v" . set-mark-command)
   '("y" . meow-save)
   '("/" . meow-visit)
   '("n" . meow-search)
   '("z" . my/fold-map)
   '("<escape>" . ignore))

  ;; Ediff mode
  (meow-define-keys 'ediff
    '("j" . ediff-next-difference)
    '("k" . ediff-previous-difference))

  ;; Leader keys (SPC prefix)
  (meow-leader-define-key
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("H" . meow-cheatsheet))

  ;; Normal mode
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("1" . meow-expand-1)
   '("2" . meow-expand-2)
   '("3" . meow-expand-3)
   '("4" . meow-expand-4)
   '("5" . meow-expand-5)
   '("6" . meow-expand-6)
   '("7" . meow-expand-7)
   '("8" . meow-expand-8)
   '("9" . meow-expand-9)
   '("-" . negative-argument)

   ;; Movement (hjkl)
   '("h" . meow-left)
   '("j" . meow-next)
   '("k" . meow-prev)
   '("l" . meow-right)
   '("H" . meow-left-expand)
   '("J" . meow-next-expand)
   '("K" . meow-prev-expand)
   '("L" . meow-right-expand)

   ;; Line position
   '("^" . meow-back-to-indentation)
   '("$" . move-end-of-line)

   ;; Buffer position
   '("`" . beginning-of-buffer)

   ;; Go to definition
   '("C-]" . xref-find-definitions)

   ;; Word/symbol motion
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("e" . meow-mark-word)
   '("E" . meow-mark-symbol)

   ;; Find/till (expand by default)
   '("f" . meow-find-expand)
   '("t" . meow-till-expand)

   ;; Insert mode entry
   '("i" . meow-insert)
   '("a" . meow-append)
   '("o" . meow-open-below)
   '("O" . meow-open-above)
   '("c" . meow-change)

   ;; Actions
   '("d" . meow-kill)
   '("m" . meow-join)
   '("M" . join-line-below)
   '("x" . meow-delete)
   '("X" . meow-backward-delete)
   '("y" . meow-save)
   '("Y" . meow-save-append)
   '("p" . meow-yank)
   '("P" . meow-yank-pop)
   '("r" . meow-replace)
   '("u" . undo-only)
   '("U" . undo-redo)

   ;; Selection
   '("v" . meow-line)
   '("V" . meow-line-expand)
   '("s" . meow-block)
   '("S" . meow-to-block)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)

   ;; Search
   '("/" . meow-visit)
   '("n" . meow-search)
   '("N" . meow-pop-search)

   ;; Indentation
   '(">" . indent-rigidly-right-to-tab-stop)
   '("<" . indent-rigidly-left-to-tab-stop)
   '("=" . meow-indent)

   ;; Other
   '(";" . meow-reverse)
   '("g" . meow-cancel-selection)
   '("G" . end-of-buffer)
   '(":" . meow-goto-line)
   '("Q" . meow-grab)
   '("'" . meow-last-buffer)
   '("\"" . meow-comment)
   '("z" . my/fold-map)
   '("C-g" . meow-cancel-selection)
   '("<escape>" . ignore))

  (meow-global-mode 1))

(use-package meow-tree-sitter
  :after meow
  :config
  (meow-tree-sitter-register-defaults)
  (meow-normal-define-key
   '("T" . meow-tree-sitter-node)))

(use-package ediff
  :ensure nil
  :after meow
  :hook (ediff-startup . meow-ediff-mode))

(provide 'keys)
;;; keys.el ends here
