---
name: session-grill
description: Work a feature's unblocked grilling headings to a recorded decision inside its Emacs session, committing each answer. Use when asked to clear a feature's open decisions, grill its questions, or unblock work waiting on a human call.
---

# Session grill

Work one feature's open decisions to completion. This is the human-facing
counterpart of `session-run`: that skill drains the `AFK` frontier, this one
drains the `grilling` headings on the `HITL` frontier.

Read `tickets/issue-tracker.md` first; it owns tracker semantics. Read
`tickets/tracker.local.md` if it exists.

## Where this runs

A feature's tracker copy travels with its branch, so grill where the feature is
worked: inside its session worktree when one exists, in the main checkout when
none does. Never grill a feature from the main checkout while a session holds
it — the answers would land on a copy that session never sees.

Do not create a worktree. In particular do not use `EnterWorktree`.

## What this takes

`KIND: grilling` headings that are `NEXT`, unblocked, and `TYPE: HITL`. Get them
with `tracker-frontier`.

It never takes a `KIND: ticket` that is `TYPE: HITL`. That heading needs a human
*action* — a credential provisioned, an approval given, physical access — and no
interview converts it. Report those as waiting and leave them alone.

Read the PRD and every grilling heading in full, including `** Comments`, before
the first round.

## The interview

Interview the user relentlessly until you reach a shared understanding. Map the
open decisions as a **design tree**: every decision branches into the decisions
that hang off it. A heading is a root of that tree, rarely the whole of it.

Work the tree in **rounds**. The frontier is every decision whose prerequisites
are already settled — the questions you can ask *now* without guessing at
answers you have not heard yet. Ask the whole frontier in one round: number each
question and give your recommended answer. Then wait for the user before the
next round.

```
❓ **Q1** - **<question title>**: <question body, may be several paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Each round of answers reshapes the tree: settled decisions push the frontier
outward and unblock questions that depended on them. A question whose answer
depends on another question still open in this round belongs to a later round.

A round may span several grilling headings. Group its questions under the
heading each one resolves, so an answer has somewhere to land.

Finding *facts* is your job, never the user's. When a question needs a fact from
the repo or the environment, dispatch a sub-agent for it and carry on: a running
exploration is an unsettled prerequisite, so only the questions downstream of it
wait. Ask the rest of the frontier now. The *decisions* are the user's — put
each to them and wait.

## Recording an answer

A grilling heading resolves the moment its decision is settled, not when the
whole session ends:

1. Write the decision and the reasoning that survived under `** Answer`.
2. Set the state to `DONE`.
3. Where the feature has a `map`, summarise the outcome under its
   `** Decisions so far`.
4. Commit the tracker update immediately.

Never leave a `DONE` grilling uncommitted. Dependants need no edit — a ticket
blocked on the grilling unblocks as soon as it is terminal.

An answer that changes the work changes the graph too. Add the tickets it
implies with `tracker-decompose`, the edges with `tracker-edges`, and
`CANCELED` what it rules out — all in the same commit as the answer.

## Finishing the run

The run ends when the grilling frontier is empty. Report what was decided, what
it unblocked for `session-run`, and what still waits on a human action.

Do not implement what you just decided, even when the answer is fresh and the
ticket is obvious. Building it is `session-run`.

## Scope

Session grill decides. It does not implement, and it does not triage untriaged
headings into existence — that is `tracker-triage`.
