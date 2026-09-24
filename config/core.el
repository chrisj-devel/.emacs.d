;;; core.el --- Environment, defaults, completion, windows, tabs -*- lexical-binding: t; -*-
;;; Commentary:
;; Built-in except gruvbox-theme, dirvish, and exec-path-from-shell.
;;; Code:

;;; Environment

;; A GUI Emacs is launched by launchd, not a shell, so it inherits a bare PATH
;; with no homebrew and no mise.  Nothing built-in recovers it: the PATH is
;; assembled in ~/.zshrc, which launchd never runs, and mise's entries move with
;; every tool version so they cannot be hardcoded into `exec-path'.  This runs
;; first because everything below resolves executables.
(use-package exec-path-from-shell
  :config
  (when (or (daemonp) (memq window-system '(mac ns x pgtk)))
    (exec-path-from-shell-initialize)))

;;; Defaults

(use-package emacs
  :ensure nil
  :custom
  (use-short-answers t)
  (ring-bell-function #'ignore)
  (create-lockfiles nil)
  (backup-directory-alist `(("." . ,(expand-file-name "backup" user-emacs-directory))))
  (auto-save-file-name-transforms
   `((".*" ,(expand-file-name "autosave/" user-emacs-directory) t)))
  (recentf-max-saved-items 300)
  (auto-revert-interval 2)
  (global-auto-revert-non-file-buffers t)
  (standard-indent 2)
  (js-indent-level 2)
  :config
  (setq-default require-final-newline t)
  (setq-default tab-width 2)
  ;; Emacs creates the backup directory on demand but not the auto-save one.
  (make-directory (expand-file-name "autosave/" user-emacs-directory) t)
  (savehist-mode 1)
  (recentf-mode 1)
  (save-place-mode 1)
  (repeat-mode 1)
  (which-key-mode 1)
  (delete-selection-mode 1)
  (electric-pair-mode 1)
  (global-auto-revert-mode 1)
  (pixel-scroll-precision-mode 1)
  (context-menu-mode 1)
  (column-number-mode 1)
  ;; `visual-line-mode' suppresses the continuation arrows on its own
  ;; (`visual-line-fringe-indicators'), so their presence says which kind of
  ;; wrapping a buffer is doing. Worth keeping, not worth full contrast.
  (set-fringe-bitmap-face 'left-curly-arrow 'shadow)
  (set-fringe-bitmap-face 'right-curly-arrow 'shadow))

;;; Mode line

;; Arranged for half-width windows: a mode line truncates from the right, so
;; everything volatile sits right of `mode-line-format-right-align'.

(use-package emacs
  :ensure nil
  :custom
  (mode-line-collapse-minor-modes t)
  ;; Both are the third rendering of what the tab bar already says: a tab is a
  ;; session is a worktree, and `my/session-tab-name' is <repo>/<branch>.
  (project-mode-line nil)
  (mode-line-percent-position nil)
  :config
  (setq-default
   mode-line-format
   '("%e"
     mode-line-front-space
     mode-line-modified
     mode-line-remote
     mode-line-window-dedicated
     " "
     mode-line-buffer-identification
     ;; `fboundp' rather than a `require': sessions are an overlay (rule 3).
     (:eval (and (fboundp 'my/session-mode-line) (my/session-mode-line)))
     "  "
     mode-line-modes
     mode-line-format-right-align
     (flymake-mode (" " flymake-mode-line-counters))
     ;; eglot rides here, and so would `global-mode-string' but that
     ;; suppresses itself while `tab-bar-format-global' is live.
     mode-line-misc-info
     " "
     mode-line-position
     mode-line-end-spaces)))

;;; Completion (native: eager live-updating *Completions*, Emacs 31)

(use-package minibuffer
  :ensure nil
  :custom
  (completion-styles '(basic partial-completion flex))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (read-file-name-completion-ignore-case t)
  (completions-detailed t)
  (completions-format 'one-column)
  (completions-max-height 12)
  (completions-sort 'historical)
  (completion-eager-display t)
  (completion-eager-update t)
  (minibuffer-visible-completions 'up-down)
  ;; Run a command that prompts from inside a prompt — `embark-act' on a
  ;; candidate then answering its own minibuffer, or M-x mid-prompt.
  (enable-recursive-minibuffers t)
  ;; M-x offers only the commands that work in this buffer's mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :config
  ;; Recursive minibuffers with no depth in the prompt is how you lose track of
  ;; which prompt you are answering; this is what makes the above survivable.
  (minibuffer-depth-indicate-mode 1))

;; Minibuffer-scoped out-of-order matching lives in completing.el with the rest
;; of the carve-out; in-buffer completion keeps the native styles above so
;; completion-preview retains prefix semantics.
(add-hook 'prog-mode-hook #'completion-preview-mode)

;;; Windows: side windows replace popper/auto-side-windows

(windmove-default-keybindings)  ; shift+arrows between windows

(use-package window
  :ensure nil
  :bind
  ([f12] . window-toggle-side-windows)
  ;; Per-tab window-config undo (winner replacement, via tab-bar-history-mode)
  ("C-c <left>" . tab-bar-history-back)
  ("C-c <right>" . tab-bar-history-forward)
  :custom
  (switch-to-buffer-obey-display-actions t)
  (display-buffer-alist
   `(("\\*\\(Help\\|info\\|eldoc\\|Apropos\\)"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . right) (window-width . 0.35))
     ("\\*\\(compilation\\|grep\\|Occur\\|xref\\|Warnings\\|Messages\\|Flymake\\)"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3))
     ("\\*.*ghostel.*\\*"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3))
     ;; verb (dev.el) sends from an org heading; the response belongs beside it.
     ;; Not `display-buffer-in-direction': it splits the selected window and
     ;; then resizes the result to half the *frame*, stealing the difference
     ;; from a neighbour down to `window-safe-min-width'.  pop-up-window splits
     ;; only a window wider than `split-width-threshold', so on an already
     ;; halved frame it declines and the response takes a window over instead
     ;; of wedging in a third column.
     ("\\`\\*HTTP Response"
      (display-buffer-reuse-mode-window
       display-buffer-pop-up-window
       display-buffer-use-some-window)
      (inhibit-same-window . t))
     ("\\*Sessions\\*"
      (display-buffer-reuse-mode-window display-buffer-in-side-window)
      (side . bottom) (window-height . 0.3)))))

;;; Tabs: one tab per session (see sessions.el)

(use-package tab-bar
  :ensure nil
  :bind
  ("M-s-<right>" . tab-bar-switch-to-next-tab)
  ("M-s-<left>" . tab-bar-switch-to-prev-tab)
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-auto-width nil)
  (tab-bar-separator " | ")
  (tab-bar-format '(tab-bar-format-tabs
                    tab-bar-separator
                    tab-bar-format-align-right
                    tab-bar-format-global))
  :config
  (tab-bar-mode 1)
  (tab-bar-history-mode 1))

;;; Restoring the last Emacs: buffers, windows, tabs

;; A carve-out from "sessions are derived, never persisted" (AGENTS.md rule 2).
;; What desktop.el writes is Emacs state — buffers, window layouts, the tab bar
;; — and nothing reads it back into the session layer, which still derives
;; every session from git on each access.  Tabs come back with their windows
;; because the frameset carries each tab's printable window state; agent shells
;; do not, being processes, so a restored session shows no agent until one is
;; started.
(use-package desktop
  :ensure nil
  :custom
  (desktop-restore-frames t)
  (desktop-save t)
  ;; The default, `ask', holds startup behind a prompt whenever a crash left
  ;; the lock behind; `check-pid' takes the desktop when its owner is gone.
  (desktop-load-locked-desktop 'check-pid)
  ;; Magit buffers are derived from the repo they are pointed at, and restore
  ;; as transcripts of whatever it looked like last time.
  (desktop-modes-not-to-save
   '(tags-table-mode magit-status-mode magit-diff-mode
                     magit-revision-mode magit-process-mode))
  :config
  ;; Nothing to restore or save in a batch run, and the boot check is one.
  (unless noninteractive (desktop-save-mode 1)))

;;; Theme

(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-hard :no-confirm)
  ;; Gruvbox tints diff context rather than changes.  Drop these with gruvbox.
  (custom-theme-set-faces
   'gruvbox-dark-hard
   '(diff-context           ((t :background unspecified)))
   '(diff-added             ((t :background "#253021" :extend t)))
   '(diff-removed           ((t :background "#35201f" :extend t)))
   '(diff-indicator-added   ((t :inherit diff-added :foreground "#b8bb26")))
   '(diff-indicator-removed ((t :inherit diff-removed :foreground "#fb4934")))
   '(diff-refine-added      ((t :background "#3d4f2c")))
   '(diff-refine-removed    ((t :background "#5a2b28")))
   '(diff-hunk-header       ((t :background "#282828" :foreground "#83a598" :extend t)))
   '(diff-header            ((t :background unspecified)))
   '(diff-file-header       ((t :background unspecified :weight bold)))))

;;; Dired

(use-package dired
  :ensure nil
  :custom
  ;; --group-directories-first is GNU-only; the macOS block below adds it when
  ;; gls is available.
  (dired-listing-switches "-Alh")
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-clean-confirm-killing-deleted-buffers nil))

(declare-function dirvish-side-follow-mode "dirvish-side")

;; `dirvish-icons' only declares the nerd-icons functions, so nothing loads the
;; library on our behalf.  "Symbols Nerd Font Mono" (the nerd-icons default) is
;; not installed; the patched Monaspace already carries the glyphs.
(use-package nerd-icons
  :custom (nerd-icons-font-family "Monaspace Neon NF"))

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons subtree-state vc-state file-size))
  (dirvish-side-attributes '(nerd-icons subtree-state vc-state))
  (dirvish-side-width 30)
  :bind
  ([f1] . dirvish-side)
  (:map dirvish-mode-map
        ("l" . dirvish-subtree-toggle)
        ("h" . dirvish-subtree-up))
  :config
  ;; GNU ELPA ships the extensions in a subdirectory that the package autoloads
  ;; never put on `load-path'.  Without this, `dirvish-side' (sessions.el) and
  ;; every attribute library `dirvish--check-dependencies' requires — vc,
  ;; subtree, collapse, icons, peek — are unreachable.
  (add-to-list 'load-path
               (expand-file-name "extensions"
                                 (file-name-directory (locate-library "dirvish"))))
  ;; f1 reaches `dirvish-side' before any session exists, and the extension has
  ;; no autoload to pull it in.  Subtree arrives via the subtree-state attribute.
  (require 'dirvish-side)
  ;; Sessions are scoped to a tab by its position, which shifts when an
  ;; earlier tab closes, handing one tab's session to its neighbour.  The
  ;; interned name is stable and still compares with `eq'.
  (setq dirvish--scopes
        (plist-put dirvish--scopes :tab
                   (lambda () (intern (alist-get 'name (tab-bar--current-tab))))))
  (dirvish-override-dired-mode)
  (dirvish-side-follow-mode))

;;; Server

(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start)))

;;; macOS

(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        delete-by-moving-to-trash t
        trash-directory "~/.Trash")
  (if (executable-find "gls")
      (setq insert-directory-program "gls"
            dired-listing-switches "-Alh --group-directories-first")
    (setq dired-use-ls-dired nil))
  (set-face-attribute 'default nil :font "Monaspace Neon NF" :height 130))

(provide 'core)
;;; core.el ends here
