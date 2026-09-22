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
   serialize session state; never cache it across commands. `desktop-save-mode`
   (core.el) is not an exception: what it persists is Emacs state — buffers,
   window layouts, the tab bar — and nothing reads it back into the session
   layer. activities.el stayed rejected because it persists the sessions
   themselves.
3. **Sessions are an overlay, not a mode.** Zero cost when absent: no global
   advice, no hooks assuming a session exists, no hijacked stock bindings.
   Without a session this must behave like clean Emacs 31 + listed packages.
4. **Tab = session, 1:1 with worktree.** Scoping comes from project.el
   commands (`C-x p …`), not buffer-list filtering.
5. **Completion is a carve-out from rule 1** (taken after real use — the
   native eager *Completions* chafed). vertico + orderless + consult +
   marginalia + embark + corfu live in `completing.el`; the gaps they fill
   are named in that file's header. corfu draws in-buffer completion at
   point, one line per candidate; *Completions* is a window and wraps a long
   capf annotation rather than clipping it. Completion styles stay native
   outside the minibuffer so completion-preview retains prefix semantics, and
   orderless stays minibuffer-scoped. Scoping still comes from project.el —
   consult resolves roots via `consult-project-function`, not its own notion
   of a workspace.

Already rejected (with reasons — don't re-add): elpaca (package.el + `:vc`
suffices), bufferlo/otpp (project.el scoping replaced them), popper /
auto-side-windows (native side windows), evil (meow won), activities.el
(persists state; conflicts with rule 2), undo-fu (native undo-only/redo).

## Layout

- `early-init.el` — frame, GC, and the PATH native compilation needs.
- `init.el` — package setup, then `load`s each `config/` file, then
  `(require 'dashboard)`.

`config/` — use-package declarations, loaded as source and never compiled.
A `use-package` form goes here and nowhere else; see the byte-compile gotcha.

- `config/core.el` — shell environment, defaults, native completion, side
  windows, tab-bar, desktop
- `config/completing.el` — the completion stack (rule 5)
- `config/keys.el` — meow (vim-transitional)
- `config/dev.el` — treesit, eglot, magit, envrc, ghostel, agent stack
- `config/org-tracker.el` — org and the tracker's agenda views. Not `org.el`,
  which would shadow the real one if `config/` ever reached `load-path`.

`user-lisp/` — libraries, compiled and scraped for autoload cookies at startup
(`prepare-user-lisp`) before init.el runs. So: no use-package, and no
third-party dependency at all, since a top-level `require` runs inside that
compile. Prefer a `;;;###autoload` cookie to a `require` in init.el.

- `user-lisp/sessions.el` — the only real custom code: session derivation,
  spawn/teardown, dashboard, and the three tab layouts. Keep it small; prefer
  deleting to extending.
- `user-lisp/tickets.el` — which org files make up a repo's tracker
- `user-lisp/dashboard.el` — the startup layout: session dashboard + agenda +
  a key pane derived from the keymaps. Composition only; it owns no state
- `user-lisp/tracker.el` — install/update/validate the tracker contract.
  Autoloaded, which is what keeps org out of startup. Don't require it.
- `user-lisp/agent-attention.el` — which agent shells are waiting. Defines
  only; `config/dev.el` calls `my/agent-attention-setup`.
- `tracker/` — the portable tracker contract and skills `my/tracker-install`
  copies into repos. `migration.org` is the runbook for moving an existing
  repo onto the contract; it stays here and is not installed.

## Verifying changes

Batch boot (must stay clean). `--batch` loads neither early-init.el nor
init.el and never runs `prepare-user-lisp`, so the whole startup has to be
spelled out. Disabling native compilation keeps the check from forking
compiler subprocesses:

    emacs --batch --init-directory <this dir> \
      --eval '(setq native-comp-jit-compilation nil \
                    inhibit-automatic-native-compilation t)' \
      -l <this dir>/early-init.el \
      --eval "(progn (package-activate-all) (prepare-user-lisp))" \
      -l <this dir>/init.el --eval '(message "OK")'

Worth asserting after a startup-path change:

    (featurep 'org)                ; => nil, org stays out of startup
    (featurep 'tracker)            ; => nil, autoloaded
    (autoloadp (symbol-function 'my/tracker-validate))  ; => t
    (featurep 'dashboard)          ; => t

Session lifecycle test: spawn/teardown against a throwaway repo (temp dir,
`git init`, empty commit), stubbing `my/session-open` to `ignore` and
`yes-or-no-p` to return t. Assert: worktree + tickets scaffold created,
`my/sessions` derives it, teardown removes worktree and forgets project.

Never commit batch-test droppings: `projects.eld`, `recentf.eld`, `history`,
`custom.el` (gitignored — keep it that way).

## Gotchas

- meow on MELPA still ships `meow-motion-overwrite-define-key`; master
  renamed it to `meow-motion-define-key`. config/keys.el handles both — keep
  that.
- Teardown of a dirty worktree needs `git worktree remove --force`; always
  confirm with the user-facing prompt first (fresh spawns are always dirty —
  the ticket scaffold is untracked).
- Agent attention (`user-lisp/agent-attention.el`) rides only
  `agent-shell-subscribe-to`, the public event API; its tally renders in the
  tab bar via `global-mode-string` + `tab-bar-format-global`. It defines only
  — `config/dev.el` calls `my/agent-attention-setup` to install the hooks.
  agent-shell-attention.el was dropped — it advised
  `agent-shell--send-command` and rebound `acp-send-request` to track busy
  state, and both packages ship daily MELPA snapshots. Don't re-add it.
- `user-lisp/` is compiled and holds no use-package forms, so a byte-compile
  warning there is a real one.
- The mode line spans two files: `config/core.el` owns the arrangement,
  `my/session-mode-line` (sessions.el) is the one bespoke element in it, and
  core.el reaches it through `fboundp` so that without sessions the mode line
  is stock (rule 3). It reads a `my/session-worktree` tab parameter that
  `my/session--open-tab` sets — a fact about a *tab*, not persisted session
  state, so not a rule 2 exception; `tab-bar--current-tab-make` copies
  parameters it does not recognise, which is what carries it across a switch.
  Anything referenced by symbol in `mode-line-format` must have
  `risky-local-variable`, or its `:eval` forms are silently not processed.
- `format-mode-line` returns `""` under `--batch` — there is no live window —
  so a mode-line change cannot be verified by the batch boot. The boot only
  proves the construct loads.
- use-package installs `:ensure` packages at **byte-compile** time
  (`use-package-ensure.el` calls the ensure function directly when
  `byte-compile-current-file` is set). Emacs 31 compiles `user-lisp/` at
  startup in async subprocesses, so declarations there installed packages
  from inside those: one wedged on 1 Sep 2026 and spun a core for 16 days,
  with 27 abandoned `.eln.tmp` files behind it. Hence `config/`. Don't move a
  use-package form back, and don't add a step that compiles `config/`.
- `native-comp-async-report-warnings-errors` is left at its default. It was
  `'silent`, which is why the above went unseen.
- A restored desktop stands the startup dashboard down
  (`my/dashboard--restore`, on `desktop-after-read-hook`, which runs before
  `emacs-startup-hook`) and redraws the dashboard tab if one was saved — its
  panes are generated buffers that desktop cannot restore. Agent shells cannot
  be restored either; a restored session simply reads as having no agent.
- The review layout diffs through `vc-diff-internal` rather than magit: a
  `diff-mode` buffer is static text, so the overlays `my/review-note` hangs on
  it stay where they were put. Two things about that call — it gives each
  session its own buffer, and vc's `revert-buffer-function` drops the buffer
  argument and rebuilds into `*vc-diff*`, so `my/session--review-diff` sets its
  own. Notes are addressed by (root, file, line-as-the-branch-leaves-it) and
  placed by reading the unified-diff hunk headers, which is why a line only
  the base has cannot carry one. `my/session--materialise` is the worktree
  half of spawn, shared with review; review calls it and stops there, which
  is what keeps a colleague's branch from scaffolding a ticket.
- GNU ELPA's dirvish keeps its extensions in a subdirectory its autoloads
  never add to `load-path`. config/core.el adds it; without that, `dirvish-side` and
  the attribute libraries are unreachable.
