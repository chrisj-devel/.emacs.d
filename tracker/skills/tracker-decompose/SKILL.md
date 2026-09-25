---
name: tracker-decompose
description: Split a feature PRD into numbered implementation tickets as sibling headings in the same tracker file, with dependency edges. Use when asked to decompose a spec, break a PRD into tickets, or plan implementation slices.
---

# Tracker decompose

Create numbered sibling work headings in the feature's existing tracker file.
Read `tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.
Use `KIND: ticket` under a PRD; use `research`, `prototype`, or `grilling` under
a map.

## Shape

```org
* NEXT 01 --- Return the record from the existing endpoint
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:TYPE: AFK
:END:
** What to build
** Acceptance criteria
- [ ] ...
```

Name an outcome. Number from `01` in dependency order; record actual ordering
with dependency edges.

`** What to build` is one paragraph of three to five sentences naming the files
or modules and their changes. End with a boundary naming work left to a
neighbour. Split work that needs more than one paragraph.

`** Acceptance criteria` has two to four observable items covering artifacts
such as responses, files, or devtest resources. Do not restate the build;
include test coverage.

## Slicing and state

Start with the narrowest end-to-end slice proving the approach. Each ticket
must form one coherent commit with passing checks; split only when needed to
meet that boundary.

Use `WAIT` when machine-checkable acceptance cannot yet be written, naming the
missing fact under `** Comments`. Otherwise use `NEXT`, with `TYPE` assigned by
the triage gate. Identify any required human approvals or credentials.

Move the parent from `TODO` to `DOING` when its first work heading is written.
It remains `DOING` until every work heading is terminal, then closes at `DONE`.
It never takes `TYPE` or `NEXT`.

## Dependencies and report

Use `tracker-edges`: sequential slices block their successors; independent
slices have no edge and can run in parallel. Specified blocked tickets remain
`NEXT`. Validate after writing the edges (`issue-tracker.md`).

Report a table of number, title, `TYPE`, and dependencies, followed by any
necessary slicing constraints. Do not implement; `session-run` does that.
