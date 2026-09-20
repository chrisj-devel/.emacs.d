# Native-first Emacs 31 config

Launch alongside the existing config:

    emacs --init-directory ~/Source/dotfiles/emacs31/.emacs.d

## Design

One custom abstraction: a **session** = (git worktree, `tickets/<feature>/`,
agent buffer, tab), derived from disk + live buffers on every access — never
persisted. Sessions are an overlay, not a mode: no session ⇒ stock Emacs.
Every worktree of a repo is a session, the main checkout included — that one
has no ticket file, so it opens on dired, and is where git work belongs.

Buffers, window layouts and tabs are restored from the last Emacs
(`desktop-save-mode`). Sessions are still derived, not restored — the desktop
holds no session state, and agent shells, being processes, start again.

- `f7` / `C-c d` — the dashboard Emacs opens on: every worktree in flight
  across all known repos, the tracker frontier over all of them, and a key
  pane read out of the live keymaps. Re-run it to refresh.
- `f6` / `C-c s d` — mission control dashboard for the repo at point (`RET`
  jump, `b` browse, `n` spawn, `k` teardown). Its Drift column is the
  session's commits ahead of base and behind it as last fetched, the behind
  count reddening past `my/session-stale-threshold`
- `C-c s n` — spawn: worktree + branch + ticket scaffold + tab + agent. The
  branch forks from whichever of `main` / `origin/main` contains the other;
  diverged, it asks
- `C-c s j` — jump to a session's work tab, main checkout included
- `C-c s b` — browse tab: dirvish sidebar + code, same session, second tab
- `C-c s k` — teardown: kill buffers, remove worktree, close both tabs (branch
  kept; the main checkout is never removed)
- `C-c a` then `w` / `f` — tracker workboard / unblocked frontier over the
  whole tracker of the repo at point; a feature in a worktree shows that
  worktree's copy. `F` is the frontier over every known repo
- `f5` agent shell, `f11` ghostel, `f12` toggle side windows

Scoping comes from project.el (`C-x p …`) since each worktree is a project
root. Attention (which shells are waiting on you, as a tab-bar tally plus a
macOS notification) is ~60 lines in `user-lisp/agent-attention.el` over
`agent-shell`'s public event API.

The **mode line** is arranged for half-width windows: identity hard left,
everything volatile right of `mode-line-format-right-align` (flymake counters,
eglot, position), `mode-line-modes` in the middle as the first thing worth
losing. Minor lighters collapse into one glyph
(`mode-line-collapse-minor-modes`, built in to Emacs 31). `project-mode-line`
and `vc-mode` are off — the tab bar already names `<repo>/<branch>`. In their
place `my/session-mode-line` speaks only when the tab's name has come apart
from the buffer: a buffer from another worktree, or the main checkout's branch
moving under a tab named for the branch it opened on.

## Completion (the one carve-out from native-first)

vertico + consult + marginalia + embark in the minibuffer, corfu at point;
completion styles stay native outside the minibuffer. See
`config/completing.el`.

- `C-x p g` / `M-s r` — consult-ripgrep, scoped to the session's worktree
  (`#` splits input: `#regexp#filter` — rg sees the first, live narrowing the rest)
- `M-s l` consult-line, `M-g i` imenu, `M-g o` outline, `M-g f` flymake
- `C-x b` consult-buffer, `C-x p b` project buffers, `<` narrows by source
- `C-.` embark-act on the candidate (export a search to a grep buffer, etc.)
- `C-j` / `C-k` move in the candidate list

## Code buffers

`prog-mode` gets flymake in every buffer (not only the eglot-managed ones),
`outline-minor-mode`, and completion-preview.

- `z` — fold prefix: `a` cycle, `c` close, `o` open, `O` open recursively,
  `M` fold the buffer, `R` unfold the buffer
- `TAB` / `S-TAB` at the start of a heading line — cycle it / the whole buffer
- `M-g f` — consult-flymake over the buffer's diagnostics

## Packages (everything else is built-in)

magit, meow (+meow-tree-sitter), dirvish, envrc, ghostel, acp, agent-shell,
orderless (minibuffer-only; native styles can't match out of order), plus the
minibuffer stack above.
