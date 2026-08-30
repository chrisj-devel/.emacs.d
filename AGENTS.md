# Working on this Emacs config

Native-first Emacs 31 config. Read README.md for the design overview and
keybindings first. This file is the working contract for agents.

## Design rules (settled — do not relitigate)

1. **Priority: built-in > package > custom function.** Before adding a
   package, name the specific built-in that almost covers the need and why it
   falls short; scope the package to exactly that gap. Before writing a
   custom function, show no package covers it acceptably.
2. **Sessions are derived, never persisted.** `my/sessions` reconstructs
   everything from `git worktree list` + tickets dirs + live buffers. Never
   serialize session state; never cache it across commands.
3. **Sessions are an overlay, not a mode.** Zero cost when absent: no global
   advice, no hooks assuming a session exists, no hijacked stock bindings.
   Without a session this must behave like clean Emacs 31 + listed packages.
4. **Tab = session, 1:1 with worktree.** Scoping comes from project.el
   commands (`C-x p …`), not buffer-list filtering.

Already rejected (with reasons — don't re-add): elpaca (package.el + `:vc`
suffices), bufferlo/otpp (project.el scoping replaced them), popper /
auto-side-windows (native side windows), evil (meow won), activities.el
(persists state; conflicts with rule 2), undo-fu (native undo-only/redo).
Deliberately deferred: vertico — only if the native eager *Completions* UI
chafes after real use. orderless is minibuffer-scoped only; in-buffer
completion must keep prefix semantics for completion-preview.

## Layout

- `init.el` — package setup + requires. `user-lisp/` is auto-compiled and
  added to load-path by Emacs 31 (`prepare-user-lisp`); no manual load-path.
- `user-lisp/core.el` — defaults, native completion, side windows, tab-bar
- `user-lisp/keys.el` — meow (vim-transitional; see meow-cheatsheet.org)
- `user-lisp/sessions.el` — the only real custom code: session derivation,
  spawn/teardown, dashboard. Keep it small; prefer deleting to extending.
- `user-lisp/tickets.el` — org + cross-session agenda
- `user-lisp/dev.el` — treesit, eglot, magit, envrc, ghostel, agent stack

## Verifying changes

Batch boot (must stay clean; batch skips startup, so emulate it):

    emacs --batch --init-directory <this dir> \
      --eval "(progn (package-activate-all) (prepare-user-lisp))" \
      -l <this dir>/init.el --eval '(message "OK")'

Session lifecycle test: spawn/teardown against a throwaway repo (temp dir,
`git init`, empty commit), stubbing `my/session-open` to `ignore` and
`yes-or-no-p` to return t. Assert: worktree + tickets scaffold created,
`my/sessions` derives it, teardown removes worktree and forgets project.

Never commit batch-test droppings: `projects.eld`, `recentf.eld`, `history`,
`custom.el` (gitignored — keep it that way).

## Gotchas

- meow on MELPA still ships `meow-motion-overwrite-define-key`; master
  renamed it to `meow-motion-define-key`. keys.el handles both — keep that.
- Teardown of a dirty worktree needs `git worktree remove --force`; always
  confirm with the user-facing prompt first (fresh spawns are always dirty —
  the ticket scaffold is untracked).
- agent-shell-attention loads lazily `:after agent-shell`; its tally renders
  in the tab bar via `global-mode-string` + `tab-bar-format-global`.
- Byte-compile warnings about meow/agent-shell functions in `:config` blocks
  are expected use-package noise; a clean boot is the real check.
