---
name: session-run
description: Implement a feature's unblocked AFK tickets inside its Emacs session worktree, committing each ticket with its tracker update. Use when asked to implement, work through, or kick off a feature's tickets.
---

# Session run

Work one feature's frontier to completion inside its session.

Read `tickets/issue-tracker.md` first; it owns tracker semantics. Read
`tickets/tracker.local.md` if it exists; it supplies this repo's
verification commands.

## You are already in the worktree

A session is one worktree, one tab, one agent, created by the Emacs session
layer. An agent started in a session already has the worktree as its working
directory.

Do not create a worktree. In particular do not use `EnterWorktree`, which would
nest one inside the session. If you are not in a session worktree, say so and
stop — the human spawns it with `C-c s n`.

The session's tracker copy is the one being worked. Ticket state travels with
the feature branch and merges alongside the code, so there is nothing to
reconcile against the default branch mid-feature — unless
`tickets/tracker.local.md` says this repo's tracker is versioned elsewhere, in
which case follow it.

The session's branch is the feature name. Do not record it on the PRD; add
`BRANCH` to a work heading only when its branch differs.

## Before writing code

Read the PRD and every frontier ticket in full, including `** Comments`. Get the
frontier with `tracker-frontier`, and sweep the graph:

```
M-x my/tracker-validate
```

Stop and ask only for:

- a blocking `HITL` ticket — it will not move without a human
- an unresolved choice that materially changes the implementation
- a command the ticket forbids
- missing authority for a destructive or external action

Otherwise announce the frontier and the next expected human gate, then work.

## One ticket at a time

Claim before working: `NEXT` → `DOING`. The ticket is the unit of work and the
commit boundary. Split it only when its acceptance criteria cannot form one
coherent green commit; never split it merely to make progress look finer.

Take `AFK` tickets only. Leave `HITL` for the human and say what is waiting.

Run the repo's verification before claiming completion. If this repo declares
verification commands, those are the bar; otherwise use the ticket's acceptance
criteria and the project's own test command.

## Finishing a ticket

`DONE` is the commit boundary, not a bookkeeping step:

1. Mark the acceptance criteria complete and set the state to `DONE`.
2. Stage the implementation and the tracker update together.
3. Commit immediately.
4. Report completion only after the commit succeeds.

Never leave a `DONE` ticket uncommitted. If the work should stay uncommitted,
leave it `DOING`.

Then re-derive the frontier — finishing a ticket usually unblocks the next —
and continue until the `AFK` frontier is empty.

## Finishing the run

Report what landed, what remains, and what is waiting on a human. Teardown is
the human's call (`C-c s k`); it removes the worktree, so do not leave work
uncommitted behind you.
