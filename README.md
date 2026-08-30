# Native-first Emacs 31 config

Launch alongside the existing config:

    emacs --init-directory ~/Source/dotfiles/emacs31/.emacs.d

## Design

One custom abstraction: a **session** = (git worktree, `tickets/<feature>/`,
agent buffer, tab), derived from disk + live buffers on every access — never
persisted. Sessions are an overlay, not a mode: no session ⇒ stock Emacs.

- `f6` / `C-c s d` — mission control dashboard (`RET` jump, `n` spawn, `k` teardown)
- `C-c s n` — spawn: worktree + branch + ticket scaffold + tab + agent
- `C-c s k` — teardown: kill buffers, remove worktree, close tab (branch kept)
- `C-c a` then `s` — org agenda across all in-flight sessions' tickets
- `f5` agent shell, `f11` ghostel, `f12` toggle side windows

Scoping comes from project.el (`C-x p …`) since each worktree is a project
root. Attention (busy/blocked/ready, notifications, mode-line tally in the
tab bar) comes from `agent-shell-attention`.

## Packages (everything else is built-in)

magit, meow (+meow-tree-sitter), dirvish, envrc, ghostel, acp, agent-shell,
agent-shell-attention, orderless (minibuffer-only; native styles can't match
out of order). The UI is still native Emacs 31 (eager live-updating
*Completions*); add vertico only if that chafes after real use.
