---
name: tracker-decompose
description: Split a feature PRD into numbered implementation tickets as sibling headings in the same tracker file, with dependency edges. Use when asked to decompose a spec, break a PRD into tickets, or plan implementation slices.
---

# Tracker decompose

Turn a PRD into implementation tickets. Tickets are sibling top-level headings
in the same file as the PRD — one file per feature, never one file per ticket.

Read `tickets/issue-tracker.md` first; it owns tracker semantics. Read
`tickets/tracker.local.md` if it exists; it supplies this repo's vocabulary.

A `prd` or `map` heading with no sibling work headings has not been decomposed.
That is the structural fact this skill changes; there is no state for it.

Implementation slices are `KIND: ticket`. An exploratory effort decomposes
under a `map` into `research`, `prototype`, or `grilling` headings instead.

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

The heading names an outcome, not an area: "Return the record from the
existing endpoint", never "Endpoint changes".

Number from `01` in the heading text, in dependency order. Numbering is a
reading aid; the dependency graph is the truth.

`** What to build` is one paragraph, three to five sentences. Name the code
locations by file or module and say what changes in each. End with a boundary
sentence naming what this ticket leaves to a neighbour ("The response is
unchanged here; 05 changes it"). A ticket that needs more than a paragraph is
two tickets.

`** Acceptance criteria` is two to four items. Each is observable on an
artifact — a response, a file, a devtest resource — and none restates the
build. One covers tests.

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

## The PRD moves

Promote the PRD from `TODO` to `DOING` once its first ticket is written: a
feature with tickets is underway, and it stays `DOING` until every ticket is
terminal and it closes at `DONE`. It takes no `TYPE`.

Never `NEXT`. The frontier is every unblocked `NEXT` heading and `session-run`
drains it taking `AFK` ones, so a `NEXT` PRD reads as a ticket an unattended
agent can claim.

## Dependencies

Write the edges as you slice, with `tracker-edges`. Sequential slices each
block the next; independent slices carry no edge and can run in parallel.

Do not express ordering by state. Every ticket that is fully specified is
`NEXT`, whether or not it is currently blocked.

Sweep the graph with `M-x my/tracker-validate` when done.

## Reporting

When done, report a table of number, title, `TYPE` and blocked-on, then the
slicing choices a reader would not expect. Nothing else.

## Scope

Decompose writes tickets. It does not implement them; that is `session-run`.
