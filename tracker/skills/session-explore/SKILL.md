---
name: session-explore
description: Work a feature's unblocked research and prototype headings to a recorded answer inside its Emacs session, committing each one. Use when asked to answer a feature's open questions, run its spikes, or work an exploratory map.
---

# Session explore

Answer unblocked `NEXT` research and prototype headings with `TYPE: AFK`.
Read `tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## Start

Use the existing feature session worktree. Do not create one or use
`EnterWorktree`. Get the work with `tracker-frontier`; read the map and each
heading in full, including `** Comments`. Report `HITL` headings as waiting
for human access or action and leave them unchanged.

## Research and prototypes

Use the highest-trust source: code and tests before repo documentation,
primary documentation before summaries. Cite paths and lines or URLs.
Answer the stated question. If its premise fails, identify that before
answering the corrected question.

Build only enough prototype to settle its question. Tests, error handling,
and production polish are not required. Keep prototype code out of the feature
commit or delete it after reading the result. State the verdict, relevant
limits or costs, and any next experiment when inconclusive. Production
implementation belongs in a ticket for `session-run`.

## Record and finish

As each heading resolves:

1. Record the finding or verdict and evidence under `** Answer`.
2. Set it to `DONE`.
3. Summarise the outcome under the map's `** Decisions so far`, if present.
4. Commit the tracker update immediately.

Add implied tickets with `tracker-decompose`, dependencies with `tracker-edges`,
and cancel ruled-out work in that commit. A new human decision gets a
`KIND: grilling`, `TYPE: HITL` heading for `session-grill`. If no open heading
remains, close the `prd` or `map` in the same commit.

Continue until the exploratory frontier is empty. Report answers, work
unblocked or ruled out, and remaining human gates. Do not implement or make
the user's design decisions.
