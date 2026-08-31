;;; completing.el --- Minibuffer stack: vertico, consult, marginalia, embark -*- lexical-binding: t; -*-
;;; Commentary:
;; The carve-out from built-in > package.  The native eager *Completions*
;; (core.el) is a fine selection UI, but three gaps have no built-in answer:
;;
;;   - live-narrowing async search over a repo (consult-ripgrep vs. one-shot
;;     project-find-regexp, where refining means re-running the search)
;;   - previewing a candidate before committing to it
;;   - acting on a candidate without leaving the prompt (embark)
;;
;; Scope of the carve-out: the minibuffer only.  In-buffer completion-at-point
;; keeps the native styles and *Completions*, so completion-preview retains
;; prefix semantics.
;;; Code:

;;; Vertico — vertical candidate list, replaces the eager *Completions* popup

(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-count 12)
  ;; Vertico owns the minibuffer UI now; core.el's eager *Completions* would
  ;; otherwise display alongside it.
  (completion-eager-display nil)
  :bind
  (:map vertico-map
        ("C-j" . vertico-next)
        ("C-k" . vertico-previous))
  :config
  (vertico-mode 1))

;; Shipped inside the vertico package: path-aware RET/DEL in file prompts.
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind
  (:map vertico-map
        ("RET" . vertico-directory-enter)
        ("DEL" . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;;; Marginalia — annotations; supersedes completions-detailed

(use-package marginalia
  :after vertico
  :demand t
  :bind
  (:map minibuffer-local-map
        ("M-A" . marginalia-cycle))
  :config
  (marginalia-mode 1))

;;; Consult — the reason for the carve-out

;; Session scoping still comes from project.el: consult-ripgrep and
;; consult-project-buffer resolve their root through consult-project-function,
;; which is project.el, so inside a session they see that worktree only.
(use-package consult
  :bind
  (("C-x b" . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x r b" . consult-bookmark)
   ("M-y" . consult-yank-pop)
   ("M-g g" . consult-goto-line)
   ("M-g i" . consult-imenu)
   ("M-g o" . consult-outline)
   ("M-g m" . consult-mark)
   ("M-g f" . consult-flymake)
   ("M-s l" . consult-line)
   ("M-s r" . consult-ripgrep)
   :map minibuffer-local-map
   ("M-r" . consult-history))
  :init
  ;; project-prefix-map exists only once project.el loads.
  (with-eval-after-load 'project
    (keymap-set project-prefix-map "b" #'consult-project-buffer)
    (keymap-set project-prefix-map "g" #'consult-ripgrep))
  :custom
  (consult-narrow-key "<")
  ;; Route xref through the minibuffer with preview; the *xref* buffer rule in
  ;; core.el still covers grep/compile and any xref caller that bypasses this.
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (register-preview-delay 0.3)
  (register-preview-function #'consult-register-format)
  :config
  ;; Previewing every candidate would visit files on each keystroke.
  (consult-customize consult-ripgrep consult-line consult-xref
                     :preview-key '(:debounce 0.2 any)))

;;; Embark — act on the candidate under point

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :custom
  (prefix-help-command #'embark-prefix-help-command))

;; Keeps consult previews alive inside embark-export/collect buffers.
(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(provide 'completing)
;;; completing.el ends here
