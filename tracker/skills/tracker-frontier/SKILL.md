---
name: tracker-frontier
description: Report what is actionable right now across the tracker — NEXT headings that are not blocked, split by who can act. Use when asked what to work on next, what is unblocked, or for the state of a feature.
---

# Tracker frontier

Read `tickets/issue-tracker.md` first. Report unblocked `NEXT` headings:

```
frontier = NEXT ∧ ¬(org-entry-blocked-p)
```

Split by `TYPE`: `AFK` for unattended agents and `HITL` for human execution.
Order each group by heading number. Specified blocked headings remain `NEXT`;
do not propose state changes for them.

## Report

Read the feature's whole file, including `** Comments`, or every file in
`tickets/` for a whole-tracker request. Report:

- The `AFK` and `HITL` frontiers separately.
- Blocked headings and their dependencies.
- `WAIT` headings and their missing facts or decisions.
- Whether each PRD has been decomposed.

State when only human work is unblocked and the `AFK` frontier is empty.

## Emacs and scope

`C-c a f` shows the frontier; `C-c a w` shows all open headings by state, both
for the repo at point. This skill reads the files and requires neither view.

Do not edit states or edges, claim tickets, or implement. `session-run` handles
implementation.
