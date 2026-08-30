---
name: tracker-triage
description: Evaluate untriaged tracker headings and move them to an actionable state, setting TYPE and recording the brief. Use when asked to triage an issue, work the tracker inbox, or decide what a filed issue should become.
---

# Tracker triage

Take a heading out of the inbox. Triage decides two things: whether the work is
specified enough to act on, and who acts.

Read `docs/agents/issue-tracker.md` first; it owns tracker semantics. Read
`docs/agents/tracker.local.md` if it exists; it supplies this repo's vocabulary.

## The gate

One question decides the state: **could I write the agent brief right now?**

- No, a fact or decision is missing → `WAIT`. Org prompts for a note on entry;
  say what is outstanding and who can supply it.
- Yes, but a machine cannot execute it → `NEXT`, `TYPE: HITL`
- Yes, and a machine can → `NEXT`, `TYPE: AFK`
- The work will not be done → `CANCELED`

`HITL` is for approvals, credentials, product calls, physical access, and
judgment that is not written down. It is not for work that is merely hard.

Leave a heading `TODO` if nobody has evaluated it yet. `WAIT` is narrower: the
heading is understood and one identified thing is outstanding.

## Never encode blocking

A dependency is not a state. A fully specified ticket stays `NEXT` while its
dependencies are unresolved — `org-entry-blocked-p` derives whether it can
start. If triage reveals a dependency, record it as a `:BLOCKER:` edge with
`tracker-edges` and leave the state alone.

## What to write

On the heading: the state from the gate, `TYPE` on every `NEXT`, and `FEATURE`
and `KIND` if missing. Add `TRACKER_CATEGORY` only if this repo declares a
category vocabulary.

Under `** Comments`, append the triage brief: what you concluded, what evidence
you read, and for `WAIT` exactly what is being waited on. Never restate the
state in prose — the keyword is canonical.

Do not add `EFFORT`, `COMPLEXITY`, or any size field.

## Scope

Triage evaluates. It does not decompose or implement. A PRD ready to split into
tickets is `tracker-decompose`; a `NEXT` `AFK` ticket ready to build is
`session-run`.

Report what changed, one line per heading.
