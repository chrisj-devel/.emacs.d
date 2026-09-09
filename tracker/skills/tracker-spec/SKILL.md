---
name: tracker-spec
description: Write or revise a feature PRD as the top-level heading of its tracker file. Use when asked to spec a feature, write a PRD, or turn a rough idea into a specification.
---

# Tracker spec

Write the PRD for one feature. The PRD is the top-level `KIND: prd` heading in
`tickets/<feature-slug>.org`, and it is the only heading in that file until the
feature is decomposed.

Read `docs/agents/issue-tracker.md` first; it owns tracker semantics. Read
`docs/agents/tracker.local.md` if it exists; it supplies this repo's vocabulary.

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

`FEATURE` and `KIND` are required. Add the alignment property if this repo
declares an alignment vocabulary, decided once here and not revisited. Add any
properties the repo's extra-properties slot requires.

The PRD carries a state like any other heading, and spec leaves it `TODO`: a
specification nobody has sliced is not yet underway. `tracker-decompose`
promotes it when the first ticket lands. Triage does not evaluate a PRD — its
gate decides who executes a heading, and nobody executes a specification.

## Writing it

Establish the problem before the solution, and say what the problem costs
today. A solution section that could apply to any product means the problem
section is too vague.

State what the feature does **not** do and what it displaces. Work that is off
the current bar is recorded, not refused — name the tradeoff and then build it.

Prefer specifics that can be checked: named modules, routes, tables, files.
A PRD that cannot be decomposed into tickets without further discovery is not
finished; say so under `** Comments` and leave it `WAIT`.

Do not add a size or complexity estimate. `issue-tracker.md` says why.

## Revising

Editing an existing PRD keeps its state and properties. Where the repo declares
an alignment vocabulary, it is settled at spec time; do not revisit it during a
revision. Record what changed and why under `** Comments`.

## Scope

Spec writes the PRD only. Splitting it into implementation tickets is
`tracker-decompose`.
