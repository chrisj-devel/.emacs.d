---
name: session-grill
description: Work a feature's unblocked grilling headings to a recorded decision inside its Emacs session, committing each answer. Use when asked to clear a feature's open decisions, grill its questions, or unblock work waiting on a human call.
---

# Session grill

Resolve unblocked `NEXT`, `KIND: grilling`, `TYPE: HITL` headings. Read
`tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## Start

Use the feature's session worktree if one exists; otherwise use main. Do not
create a worktree or use `EnterWorktree`.

Get the grilling frontier with `tracker-frontier`. Read the PRD and each
heading in full, including `** Comments`. Report `HITL` tickets as waiting
human actions; do not treat them as interview questions.

## Interview

Run the interview with `grilling`, which owns the rounds, the question format,
and the split between facts you find and decisions the user makes. Group each
round's questions by tracker heading. A heading blocked by another belongs to
a later round.

## Record and finish

As each heading resolves:

1. Record the decision and necessary constraints under `** Answer`.
2. Set it to `DONE`.
3. Summarise the outcome under the map's `** Decisions so far`, if present.
4. Commit the tracker update immediately.

Use `tracker-decompose` for implied tickets, `tracker-edges` for dependencies,
and `CANCELED` for ruled-out work, in the same commit. If no open heading
remains, close the `prd` or `map` in that commit.

Continue until the grilling frontier is empty. Report decisions, newly
unblocked implementation, and remaining human actions. Do not implement or
triage untriaged headings; those belong to `session-run` and `tracker-triage`.
