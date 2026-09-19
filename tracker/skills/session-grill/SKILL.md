---
name: session-grill
description: Work a feature's unblocked grilling headings to a recorded decision inside its Emacs session, committing each answer. Use when asked to clear a feature's open decisions, grill its questions, or unblock work waiting on a human call.
---

# Session grill

Resolve unblocked `NEXT`, `KIND: grilling`, `TYPE: HITL` headings. Read
`tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## Start

Use the feature's session worktree if one exists; otherwise use main. Do not
create a worktree or use `EnterWorktree`.

Get the grilling frontier with `tracker-frontier`. Read the PRD and each
heading in full, including `** Comments`. Report `HITL` tickets as waiting
human actions; do not treat them as interview questions.

## Interview

Map the decisions and their dependencies as a design tree. Ask every question
whose prerequisites are settled in the current round. Group questions by
tracker heading, number them, and recommend an answer to each. Wait for the
user before asking dependent questions in the next round.

```
❓ **Q1** - **<question title>**: <question body, may be several paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Dispatch repo or environment fact-finding to a subagent. While it runs, ask
questions independent of those findings. Put decisions to the user and wait
for their answers; continue until the decision tree is resolved.

## Record and finish

As each heading resolves:

1. Record the decision and necessary constraints under `** Answer`.
2. Set it to `DONE`.
3. Summarise the outcome under the map's `** Decisions so far`, if present.
4. Commit the tracker update immediately.

Use `tracker-decompose` for implied tickets, `tracker-edges` for dependencies,
and `CANCELED` for ruled-out work, in the same commit. If no open heading
remains, close the `prd` or `map` in that commit.

Continue until the grilling frontier is empty. Report decisions, newly
unblocked implementation, and remaining human actions. Do not implement or
triage untriaged headings; those belong to `session-run` and `tracker-triage`.
