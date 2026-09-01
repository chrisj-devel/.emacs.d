---
name: tracker-frontier
description: Report what is actionable right now across the tracker — NEXT headings that are not blocked, split by who can act. Use when asked what to work on next, what is unblocked, or for the state of a feature.
---

# Tracker frontier

The frontier is every `NEXT` heading whose dependencies are all terminal. It is
what can start now, as opposed to what is merely specified.

Read `docs/agents/issue-tracker.md` first; it owns tracker semantics.

## Definition

```
frontier = NEXT ∧ ¬(org-entry-blocked-p)
```

Split it by `TYPE`:

- `AFK` — an unattended agent can take it from the ticket alone
- `HITL` — needs a human, and will not move until one acts

Order within each group by heading number, which decomposition wrote in
dependency order.

Blocked `NEXT` headings are not the frontier, but they are not a problem
either — a fully specified ticket stays `NEXT` while it waits. Do not propose
changing their state.

## Reporting

For a single feature, read `tickets/<feature>.org` in full, including
`** Comments`, then report:

- the frontier, `AFK` and `HITL` separately
- what is blocked and by what
- anything in `WAIT`, with what it is waiting on
- whether the PRD has been decomposed at all

For the whole tracker, the same over every file in `tickets/`.

Say plainly when the `AFK` frontier is empty and the only unblocked work is
`HITL` — that is the signal that a human gate is holding the feature, and it is
the most useful thing this skill reports.

## Emacs

`C-c a` offers two views defined in the Emacs configuration, both over the whole
tracker of the repo at point: `f` (**frontier**) is the query above, split by
`TYPE`, and `w` (**workboard**) is every open tracker heading, grouped by state.
This skill does not depend on either; it reads the files.

## Scope

Frontier reports. It does not change state, write edges, or implement. Claiming
a ticket and building it is `session-run`.
