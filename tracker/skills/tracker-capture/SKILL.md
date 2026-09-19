---
name: tracker-capture
description: File one new heading into the tracker inbox as TODO, without triaging or specifying it. Use when asked to file a ticket, log a bug, capture an idea, note a question, or add something to the tracker.
---

# Tracker capture

Record one item at `TODO`, preserving the report and its uncertainty. Read
`tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## Shape

```org
* TODO 11 --- Short title naming the symptom
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:END:

What was observed, what it costs, and how to reach it again.
```

Require `FEATURE` and `KIND`. Add no `TYPE`, size field, or acceptance criteria.
Add `BLOCKER` with `tracker-edges` only for an explicitly stated dependency.

Choose `ticket` for work, `research` for a question, `prototype` for an approach
to test, or `grilling` for a decision. Default to `ticket` when unclear.

## File and content

- Existing feature: append the next-numbered sibling; never renumber others.
- No matching feature: use or create a PRD-less `tickets/<area>.org` bundle.
  Do not create a separate file or parent specification for each item.
- Duplicate open item: append the observation under its `** Comments` and
  report that instead of creating another heading.

Write one paragraph with the observation, impact, and reproduction evidence
(error text, file/line, or link). Attribute reported facts. Do not investigate
or triage. Use Org markup without hard wrapping.

Report the file and heading in one line, then stop. `tracker-triage` evaluates
it, `tracker-spec` specifies a feature, and `tracker-decompose` slices it.
