---
name: session-run
description: Implement a feature's unblocked AFK tickets inside its Emacs session worktree, committing each ticket with its tracker update. Use when asked to implement, work through, or kick off a feature's tickets.
---

# Session run

Implement one feature's unblocked `AFK` tickets. Read `tickets/issue-tracker.md`
and, if present, `tickets/tracker.local.md` for semantics and verification.

## Start

Use the existing session worktree; do not create one or use `EnterWorktree`.
If none exists, report that and stop; the human creates it with `C-c s n`.

Read the PRD and every frontier ticket in full, including `** Comments`.
Use `tracker-frontier`, then validate the graph:

```
M-x my/tracker-validate
```

Announce the frontier and next human gate. Ask only for a forbidden command or
missing authority for a destructive or external action. Report waiting `HITL`
work and continue with unblocked `AFK` tickets.

## Work

Claim each ticket with `NEXT` → `DOING`. Split only when its acceptance cannot
form one coherent commit with passing checks. Run declared repo verification;
otherwise use its acceptance criteria and the project's test command.

For a material undecided choice, add a `KIND: grilling`, `TYPE: HITL` heading
and a dependency through `tracker-edges`, then take another `AFK` ticket.
Choose and report a defensible default where one exists.

If a ticket's premise fails, stop work on it:

- Brief still valid, choice unresolved: leave it `NEXT` and add the grilling.
- Brief invalid: set `WAIT` and record the invalidating fact under `** Comments`.

Continue with the remaining frontier. Do not leave abandoned work `DOING` or
rewrite a brief to fit the implementation.

## Finish

After acceptance and verification pass:

1. Check the acceptance criteria and set the ticket to `DONE`.
2. Stage implementation and tracker update together.
3. Commit immediately; report completion only after success.

Work that must remain uncommitted stays `DOING`. If no open heading remains,
set the `prd` or `map` to `DONE` in the same commit; PRD-less bundles have no
parent to close.

Re-derive the frontier and continue until no unblocked `AFK` work remains.
Report what landed, what remains, and human gates. Teardown belongs to the
human (`C-c s k`); leave no uncommitted work for removal.
