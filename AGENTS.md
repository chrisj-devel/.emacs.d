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
5. **The minibuffer is a carve-out from rule 1** (taken after real use — the
   native eager *Completions* chafed). vertico + orderless + consult +
   marginalia + embark live in `completing.el`; the gaps they fill are named
   in that file's header. The carve-out ends at the minibuffer: in-buffer
   completion keeps native styles and *Completions* so completion-preview
   retains prefix semantics, and orderless stays minibuffer-scoped. Scoping
   still comes from project.el — consult resolves roots via
   `consult-project-function`, not its own notion of a workspace.

Already rejected (with reasons — don't re-add): elpaca (package.el + `:vc`
suffices), bufferlo/otpp (project.el scoping replaced them), popper /
auto-side-windows (native side windows), evil (meow won), activities.el
(persists state; conflicts with rule 2), undo-fu (native undo-only/redo).

## Layout

- `init.el` — package setup + requires. `user-lisp/` is auto-compiled and
  added to load-path by Emacs 31 (`prepare-user-lisp`); no manual load-path.
- `user-lisp/core.el` — shell environment, defaults, native completion, side
  windows, tab-bar
- `user-lisp/completing.el` — the minibuffer stack (rule 5)
- `user-lisp/keys.el` — meow (vim-transitional)
- `user-lisp/sessions.el` — the only real custom code: session derivation,
  spawn/teardown, dashboard. Keep it small; prefer deleting to extending.
- `user-lisp/tickets.el` — org + cross-session agenda
- `user-lisp/dashboard.el` — the startup layout: session dashboard + agenda +
  a key pane derived from the keymaps. Composition only; it owns no state
- `user-lisp/dev.el` — treesit, eglot, magit, envrc, ghostel, agent stack
- `tracker/` — the portable tracker contract and skills `my/tracker-install`
  copies into repos. `migration.org` is the runbook for moving an existing
  repo onto the contract; it stays here and is not installed.

## Verifying changes

Batch boot (must stay clean; batch skips startup, so emulate it — including
early-init.el, which batch does not load and which now carries the package
bootstrap):

    emacs --batch --init-directory <this dir> \
      -l <this dir>/early-init.el \
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
- Agent attention (dev.el) rides only `agent-shell-subscribe-to`, the public
  event API; its tally renders in the tab bar via `global-mode-string` +
  `tab-bar-format-global`. agent-shell-attention.el was dropped — it advised
  `agent-shell--send-command` and rebound `acp-send-request` to track busy
  state, and both packages ship daily MELPA snapshots. Don't re-add it.
- Byte-compile warnings about meow/agent-shell functions in `:config` blocks
  are expected use-package noise; a clean boot is the real check.
- use-package installs `:ensure` packages at **byte-compile** time, and Emacs
  31 compiles `user-lisp/` during startup, before init.el. Anything the
  compile depends on — `package-archives`, `use-package-always-ensure` —
  belongs in early-init.el; in init.el it arrives too late and nothing is ever
  installed (silently, since already-present packages still load).
- GNU ELPA's dirvish keeps its extensions in a subdirectory its autoloads
  never add to `load-path`. core.el adds it; without that, `dirvish-side` and
  the attribute libraries are unreachable.
