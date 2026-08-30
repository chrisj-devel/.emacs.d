---
name: tracker-decompose
description: Split a feature PRD into numbered implementation tickets as sibling headings in the same tracker file, with dependency edges. Use when asked to decompose a spec, break a PRD into tickets, or plan implementation slices.
---

# Tracker decompose

Turn a PRD into implementation tickets. Tickets are sibling top-level headings
in the same file as the PRD — one file per feature, never one file per ticket.

Read `docs/agents/issue-tracker.md` first; it owns tracker semantics. Read
`docs/agents/tracker.local.md` if it exists; it supplies this repo's vocabulary.

A PRD with no sibling `KIND: ticket` headings has not been decomposed. That is
the structural fact this skill changes; there is no state for it.

## Shape

```org
* NEXT 01 --- A narrow tracer bullet
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:TYPE: AFK
:END:
** What to build
** Acceptance criteria
- [ ] ...
```

Number from `01` in the heading text, in dependency order. Numbering is a
reading aid; the dependency graph is the truth.

## Slicing

The first ticket is a tracer bullet: the narrowest slice that proves the
approach end to end. Prefer a slice that lands a real path over one that lands
a layer.

Each ticket must be one coherent commit that leaves the tree green. If its
acceptance criteria cannot form one green commit, split it. Do not create
micro-tickets to make the list look thorough.

Every ticket needs acceptance criteria a machine can check without asking. If
you cannot write them, the ticket is `WAIT`, not `NEXT` — and say what is
missing under `** Comments`.

Set `TYPE` per ticket with the triage gate. A decomposition that is entirely
`AFK` when parts plainly need approvals or credentials is wrong.

## Dependencies

Write the edges as you slice, with `tracker-edges`. Sequential slices each
block the next; independent slices carry no edge and can run in parallel.

Do not express ordering by state. Every ticket that is fully specified is
`NEXT`, whether or not it is currently blocked.

Sweep the graph with `M-x my/tracker-validate` when done.

## Scope

Decompose writes tickets. It does not implement them; that is `session-run`.
