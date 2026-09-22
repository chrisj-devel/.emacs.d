# Emacs 31 config

This is mostly built-in Emacs. The rule I've followed is built-in first, then a
package, then my own code, and only when the thing before it won't do the job.
So there's a lot of configuration here and not many packages.

Clone it to `~/.emacs.d` and start Emacs. If you've already got a config and
just want a look at this one:

    emacs --init-directory /path/to/this/checkout

`config/` has the use-package declarations and `user-lisp/` has the libraries.
They're split because use-package installs `:ensure` packages at byte-compile
time, and Emacs 31 compiles `user-lisp/` at startup, so a declaration left in
there would try to install from inside a compile subprocess.

## Sessions

The one idea I've put on top of Emacs is a session: a git worktree, its
`tickets/<feature>/` file, an agent shell and a tab. None of it is saved
anywhere. It's worked out from what's on disk and what buffers are open, every
time something asks. If I remove a worktree by hand the session goes with it,
and there's no state file to drift.

Every worktree of a repo is a session, the main checkout included. That one has
no ticket file so it opens on dired, and it's where I do my git work.

If you never spawn a session you just get ordinary Emacs. It isn't a mode you
have to be in.

Buffers, window layouts and tabs come back from the last Emacs with
`desktop-save-mode`. Sessions don't get restored, they get worked out again,
and agent shells are processes so they start fresh.

- `f7` / `C-c d` is the dashboard Emacs opens on: every worktree I've got going
  across all my repos, the tracker frontier over all of them, and a key
  reference read out of the live keymaps. Run it again to refresh it.
- `f6` / `C-c s d` is the same thing for the repo at point (`RET` to jump, `b`
  browse, `n` spawn, `k` teardown). The Drift column is how many commits the
  session is ahead of its base and behind it as of the last fetch. The behind
  count goes red past `my/session-stale-threshold`.
- Every `C-c s` command works on the repo at point, or, in a dashboard, on the
  repo that dashboard is showing — the cross-repo one shows them all, so it
  asks which. `C-u` asks anyway.
- `C-c s n` spawns one: worktree, branch, ticket scaffold, tab, agent. The
  branch forks from whichever of `main` or `origin/main` contains the other. If
  they've diverged it asks.
- `C-c s j` jumps to a session's work tab, main checkout included.
- `C-c s b` opens a browse tab: dirvish sidebar and code, same session, second
  tab.
- `C-c s r` opens a review tab: any branch the repo knows about, diffed against
  its merge base on the left, agent on the right. If the branch has no worktree
  it gets one, built from the remote ref when there's no local head for it yet,
  so someone else's branch reviews the same as my own and nothing gets
  scaffolded in the tracker for it. `g` rebuilds the diff. An agent reports a
  finding with `emacsclient --eval '(my/review-note ROOT FILE LINE TEXT)'` and
  it gets marked on the line in the diff. Findings clear when you rebuild.
- `C-c s k` tears down: kills the buffers, removes the worktree, closes both
  tabs. The branch stays, and it won't remove the main checkout.
- `C-c a` then `w` or `f` gives the tracker workboard or the unblocked frontier
  for the repo at point. A feature in a worktree shows that worktree's copy.
  `F` is the frontier across every repo it knows about.
- `f5` agent shell, `f11` ghostel, `f12` toggles the side windows.

Scoping is just project.el (`C-x p ...`), since each worktree is a project root.
Attention, which is the tally of shells waiting on me in the tab bar plus a
macOS notification, is about 60 lines in `user-lisp/agent-attention.el` sitting
on `agent-shell`'s public event API.

## Mode line

I run a lot of half-width windows, so the mode line is arranged for that.
Identity sits hard left, anything that changes a lot goes right of
`mode-line-format-right-align` (flymake counters, eglot, position), and
`mode-line-modes` is in the middle because it's what I mind losing least. Minor
mode lighters collapse into one glyph with `mode-line-collapse-minor-modes`,
which is built in to Emacs 31.

`project-mode-line` and `vc-mode` are off, since the tab bar already says
`<repo>/<branch>`. `my/session-mode-line` is there instead and only says
anything when the tab name no longer matches the buffer, which happens if
you're looking at a buffer from another worktree, or the main checkout's branch
has moved under a tab named for the branch it opened on.

## Completion

This is the one place I've gone against built-in first. It's vertico, consult,
marginalia and embark in the minibuffer with corfu at point, and completion
styles stay native everywhere outside the minibuffer. It's all in
`config/completing.el`.

- `C-x p g` / `M-s r` is consult-ripgrep, scoped to the session's worktree. `#`
  splits the input, so `#regexp#filter` gives rg the first part and narrows
  live on the rest.
- `M-s l` consult-line, `M-g i` imenu, `M-g o` outline, `M-g f` flymake.
- `C-x b` consult-buffer, `C-x p b` project buffers, `<` narrows by source.
- `C-.` runs embark-act on the candidate, which is how you export a search into
  a grep buffer.
- `C-j` and `C-k` move up and down the candidate list.

## Code buffers

Every `prog-mode` buffer gets flymake, not just the ones eglot is managing,
plus `outline-minor-mode` and completion-preview.

- `z` is the fold prefix: `a` cycle, `c` close, `o` open, `O` open recursively,
  `M` fold the buffer, `R` unfold it.
- `TAB` and `S-TAB` at the start of a heading line cycle that heading or the
  whole buffer.
- `M-g f` is consult-flymake over the buffer's diagnostics.

## Packages

magit, meow (and meow-tree-sitter), dirvish, envrc, ghostel, acp, agent-shell,
orderless (minibuffer only, because the native styles can't match out of
order), and the minibuffer stack above. Everything else here is built in.
