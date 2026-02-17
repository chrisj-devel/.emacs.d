;;; meow-conf.el --- Meow modal editing configuration -*- no-byte-compile: t; lexical-binding: t; -*-
;;; Commentary:
;; Vim-transitional keymap for meow.
;; Paradigm: select first, then act. hjkl and action keys (d/y/c/p)
;; are in their vim positions.
;;; Code:

(defun meow-open-cheatsheet ()
  "Open the meow cheatsheet in a side window."
  (interactive)
  (let ((file (expand-file-name "modules/meow-cheatsheet.org" user-emacs-directory)))
    (when (file-exists-p file)
      (with-current-buffer (find-file-noselect file)
        (read-only-mode 1)
        (select-window
          (display-buffer (current-buffer)
            '(display-buffer-in-side-window
               (side . right)
               (window-width . 0.4))))))))

(use-package meow
  :ensure t
  :demand t
  :custom
  (meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-expand-hint-remove-delay 3.0)
  (meow-selection-command-fallback
    '((meow-kill . meow-C-k)
       (meow-change . meow-change-char)
       (meow-save . meow-save-char)
       (meow-cancel-selection . keyboard-quit)
       (meow-pop-selection . meow-pop-grab)
       (meow-beacon-change . meow-beacon-change-char)))
  :hook
  (git-commit-mode . meow-insert-mode)
  :config
  ;; Motion mode (read-only buffers)
  (meow-motion-define-key
    '("j" . meow-next)
    '("k" . meow-prev)
    '("<escape>" . ignore))

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
    '("?" . meow-cheatsheet))

  ;; Normal mode
  (meow-normal-define-key
    ;; Expand hints (0-9)
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
    '("$" . end-of-line)

    ;; Buffer position
    '("`" . beginning-of-buffer)

    ;; Scrolling
    '("C-d" . meow-page-down)
    '("C-u" . meow-page-up)

    ;; Word/symbol motion
    '("w" . meow-next-word)
    '("W" . meow-next-symbol)
    '("b" . meow-back-word)
    '("B" . meow-back-symbol)
    '("e" . meow-mark-word)
    '("E" . meow-mark-symbol)

    ;; Find/till
    '("f" . meow-find)
    '("t" . meow-till)

    ;; Insert mode entry
    '("i" . meow-insert)
    '("a" . meow-append)
    '("o" . meow-open-below)
    '("O" . meow-open-above)
    '("c" . meow-change)

    ;; Actions
    '("d" . meow-kill)
    '("x" . meow-delete)
    '("X" . meow-backward-delete)
    '("y" . meow-save)
    '("Y" . meow-save-append)
    '("p" . meow-yank)
    '("P" . meow-yank-pop)
    '("r" . meow-replace)
    '("u" . undo-fu-only-undo)
    '("U" . undo-fu-only-redo)

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

    ;; Other
    '(";" . meow-reverse)
    '("g" . meow-cancel-selection)
    '("G" . meow-goto-line)
    '("m" . meow-join)
    '("q" . meow-quit)
    '("Q" . meow-grab)
    '("'" . repeat)
    '("\"" . meow-comment)
    '("?" . meow-open-cheatsheet)
    '("<escape>" . ignore))

  (meow-global-mode 1))

(use-package meow-tree-sitter
  :after (meow)
  :config
  (meow-tree-sitter-register-defaults)
  (meow-normal-define-key
    '("T" . meow-tree-sitter-node)))

(provide 'meow-conf)
;;; meow-conf.el ends here
