---
name: session-explore
description: Work a feature's unblocked research and prototype headings to a recorded answer inside its Emacs session, committing each one. Use when asked to answer a feature's open questions, run its spikes, or work an exploratory map.
---

# Session explore

Work one feature's open questions to an answer. It is the third runner over the
frontier: `session-run` drains `AFK` tickets, `session-grill` drains `grilling`
headings, this one drains `research` and `prototype`.

Read `tickets/issue-tracker.md` first; it owns tracker semantics. Read
`tickets/tracker.local.md` if it exists.

## Where this runs

Inside the feature's session worktree, which an agent started there already has
as its working directory. Do not create one; in particular do not use
`EnterWorktree`. The answers land on the feature's branch with the work they
justify.

## What this takes

`KIND: research` and `KIND: prototype` headings that are `NEXT`, unblocked, and
`TYPE: AFK`. Get them with `tracker-frontier`, and read the map and each heading
in full, including `** Comments`, before starting.

A `TYPE: HITL` heading of either kind needs a human — an account, a device, a
system you cannot reach. Report it as waiting and leave it.

Both kinds resolve the same way: an answer under `** Answer`, `DONE`, committed.
What differs is how you get there.

## Research

Answer the question the heading asks, from the highest-trust source available:
the code and its tests before its documentation, primary documentation before a
summary of it. Say where each finding came from, with a path and line or a URL,
so the next reader can check it rather than trust it.

Answer the question that was asked. Where the question turns out to be the wrong
one, say so and answer the right one — but say both, because a question silently
replaced reads as an answer to the original.

## Prototype

Write the smallest thing that settles the question and no more. The code is an
instrument, not a deliverable: it does not need tests, error handling, or a
tidy shape, and it must not be committed to the feature branch. Keep it out of
the commit, or delete it once you have read the result.

State the verdict plainly — the approach works, does not, or works with a cost
worth naming. A prototype that ran and taught you nothing is a finding too; say
what you would try next.

Never let the prototype become the implementation. Building it properly is a
ticket, and `session-run` takes it.

## Recording an answer

Per heading, as soon as it resolves:

1. Write the finding or verdict under `** Answer`, with its evidence.
2. Set the state to `DONE`.
3. Where the feature has a `map`, summarise the outcome under its
   `** Decisions so far`.
4. Commit the tracker update immediately.

Never leave a `DONE` heading uncommitted. Dependants need no edit — anything
blocked on the heading unblocks as soon as it is terminal.

An answer that implies work writes it: tickets with `tracker-decompose`, edges
with `tracker-edges`, `CANCELED` for what it rules out, all in that commit. An
answer that instead exposes a decision for the human writes a
`KIND: grilling`, `TYPE: HITL` heading for `session-grill`.

Where the answer closes the last open heading in the file, close the feature in
the same commit — set the `prd` or `map` to `DONE`.

## Finishing the run

The run ends when the exploratory frontier is empty. Report what was answered,
what it unblocked, what it ruled out, and what still waits on a human.

## Scope

Explore answers. It does not implement what the answer implies — that is
`session-run` — and it does not settle questions that are the human's to decide,
which are `grilling` headings and `session-grill`'s work.
