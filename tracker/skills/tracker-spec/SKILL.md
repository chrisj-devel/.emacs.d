---
name: tracker-spec
description: Write or revise the heading at the top of a feature's tracker file — a PRD where the feature can be specified, a map where it must be explored. Use when asked to spec a feature, write a PRD, open an exploration, or turn a rough idea into something decomposable.
---

# Tracker spec

Write the first top-level heading in `tickets/<feature-slug>.org`. Read
`tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## Choose the kind

Use `KIND: prd` when the solution and completion criteria are known. Use
`KIND: map` when research, prototyping, or decisions must establish the solution.
When a map resolves, rewrite that heading as a PRD, retain its `FEATURE` and
necessary decisions, and record what settled under `** Comments`.

## Shape

```org
* TODO Feature name
:PROPERTIES:
:FEATURE: feature-slug
:KIND: prd
:END:
** Problem Statement
** Solution
** User Stories
```

For a map:

```org
* TODO Feature name
:PROPERTIES:
:FEATURE: feature-slug
:KIND: map
:END:
** What we are trying to learn
** Decisions so far
```

State a map's open questions and completion criteria under
`** What we are trying to learn`. Leave `** Decisions so far` empty until
`session-grill` or `session-explore` records answers.

Require `FEATURE`, `KIND`, and any repo-declared extra properties. Add alignment
only from declared repo vocabulary; decide it once here. New unsliced features
remain `TODO`; `tracker-decompose` promotes them when work headings are added.
PRDs and maps never take `TYPE` or `NEXT` and are not evaluated by triage's
executor gate.

## Write or revise

For a PRD, state the current problem and its cost, the solution, scope boundaries,
and displaced work. Name relevant modules, routes, tables, and files. Record
work outside current priorities without refusing it on that basis.

A PRD needing further discovery before decomposition remains `WAIT`; state the
missing fact under `** Comments`. Add no size or complexity estimate.

Revisions preserve state, properties, and settled alignment. Update the current
requirements and record necessary decisions under `** Comments`; omit revision
narratives and justification.

Write only the feature heading. `tracker-decompose` creates its work headings.
