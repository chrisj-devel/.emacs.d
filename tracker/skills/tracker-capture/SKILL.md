---
name: tracker-capture
description: File one new heading into the tracker inbox as TODO, without triaging or specifying it. Use when asked to file a ticket, log a bug, capture an idea, note a question, or add something to the tracker.
---

# Tracker capture

Put one thing into the tracker and stop. Capture is lossless recording, not
evaluation: it writes down what it was told, at `TODO`, and leaves every
decision to `tracker-triage`.

Read `docs/agents/issue-tracker.md` first; it owns tracker semantics. Read
`docs/agents/tracker.local.md` if it exists; it supplies this repo's vocabulary.

## Shape

```org
* TODO 11 --- Short imperative title
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:END:

What was observed, what it costs, and how to reach it again.
```

`FEATURE` and `KIND` are required. **No `TYPE`** — `TYPE` is required on `NEXT`
headings, and a captured heading is not one yet. No `BLOCKER` unless the
dependency was stated outright, in which case write it with `tracker-edges`.
No size field.

`KIND` follows what the thing is, not what it will become: work is `ticket`, an
open question is `research`, an approach to test is `prototype`, a decision to
stress-test is `grilling`. When it is genuinely unclear, `ticket` is the
default — triage can change it.

## Which file

One file per feature, so capture never creates a file per item.

- It belongs to a feature already in `tickets/` → append as the next-numbered
  sibling in that file. Numbers run per file; take one past the highest and
  never renumber the others.
- It belongs to no feature → append to the PRD-less bundle file for the area it
  touches, creating `tickets/<area>.org` if none fits. A bundle carries loose
  work with no specification above it; do not write a `prd` or `map` heading to
  justify one item.

Check the target file for an open heading covering the same thing before
writing. A duplicate belongs under that heading's `** Comments` as a new
observation, not as a second heading — say that is what you did.

## What to write

The body is one paragraph: what happened, why it matters, and what someone
needs to see it again — the error text, the file and line, the link. Attribute
anything reported rather than observed.

Do not investigate. Capture records the report; if answering "what is really
going on here" would change the wording, that answer is triage's work, not
this skill's. Uncertainty goes in the body as uncertainty.

Do not write acceptance criteria. They belong to a heading someone has decided
to build.

Org markup, and never hard-wrap — one line per paragraph.

## Scope

Capture files at `TODO` and stops. Deciding the state and `TYPE` is
`tracker-triage`; writing a specification is `tracker-spec`; splitting one into
tickets is `tracker-decompose`.

Report the file and heading you wrote, one line.
