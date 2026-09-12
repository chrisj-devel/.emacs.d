---
name: tracker-spec
description: Write or revise the heading at the top of a feature's tracker file — a PRD where the feature can be specified, a map where it must be explored. Use when asked to spec a feature, write a PRD, open an exploration, or turn a rough idea into something decomposable.
---

# Tracker spec

Write the top-level heading for one feature. It is the only heading in
`tickets/<feature-slug>.org` until the feature is decomposed.

Read `tickets/issue-tracker.md` first; it owns tracker semantics. Read
`tickets/tracker.local.md` if it exists; it supplies this repo's vocabulary.

## Which one

One gate, answered before writing: **can you state the solution?**

- Yes → `KIND: prd`. You know what to build and can say what done looks like.
- No → `KIND: map`. The shape of the answer is itself unknown, and the first
  work is finding out.

A map is not a weaker PRD, so do not write one to defer the thinking. It says
the feature decomposes into `research`, `prototype`, and `grilling` headings
before it decomposes into tickets. A feature that starts as a map and resolves
becomes a PRD by rewriting this heading — keep its `FEATURE` and its history,
and say under `** Comments` what settled.

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

A map instead:

```org
* TODO Feature name
:PROPERTIES:
:FEATURE: feature-slug
:KIND: map
:END:
** What we are trying to learn
** Decisions so far
```

`** What we are trying to learn` states the open questions as questions, and
says what would close the exploration. `** Decisions so far` starts empty;
`session-grill` and `session-explore` append to it as answers land, and it is
what a later PRD is written from.

`FEATURE` and `KIND` are required. Add the alignment property if this repo
declares an alignment vocabulary, decided once here and not revisited. Add any
properties the repo's extra-properties slot requires.

A PRD and a map carry a state like any other heading, and spec leaves it `TODO`:
a feature nobody has sliced is not yet underway. `tracker-decompose`
promotes it when the first ticket lands. Triage does not evaluate a PRD — its
gate decides who executes a heading, and nobody executes a specification.

## Writing it

These rules are the PRD's; a map states its questions and stops.

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

Spec writes the top heading only. Splitting it into tickets or exploratory
headings is `tracker-decompose`.
