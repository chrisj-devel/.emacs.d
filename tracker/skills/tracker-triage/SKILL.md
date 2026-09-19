---
name: tracker-triage
description: Evaluate untriaged tracker headings and move them to an actionable state, setting TYPE and recording the brief. Use when asked to triage an issue, work the tracker inbox, or decide what a filed issue should become.
---

# Tracker triage

Evaluate whether a heading has an executable brief and who can act. Read
`tickets/issue-tracker.md` and, if present, `tickets/tracker.local.md` first.

## State and executor

- Identified missing fact or decision → `WAIT`; record what is missing and
  who can supply it in the entry note.
- Specified human execution → `NEXT`, `TYPE: HITL`.
- Specified machine execution → `NEXT`, `TYPE: AFK`.
- Work that will not be done → `CANCELED`.
- Unevaluated work remains `TODO`.

`HITL` requires human execution: approval, credentials, or physical access.
A material undecided choice gets a separate `KIND: grilling`, `TYPE: HITL`
heading; machine-executable work stays `AFK`, blocked on it via `tracker-edges`.
Split mixed decision/action headings accordingly. Choose and record defensible
defaults for minor calls instead of creating grilling headings.

Dependencies do not change state: a specified ticket stays `NEXT` while
`org-entry-blocked-p` derives whether it can start.

## Brief

Read the relevant code, failing path, and neighbouring tickets before writing.
Every `NEXT` heading must contain its brief:

- `KIND: ticket`: follow `tracker-decompose` — one `** What to build` paragraph
  naming code locations, then two to four observable `** Acceptance criteria`,
  including test coverage.
- Exploratory kinds: state the question and what constitutes an answer.

If acceptance cannot be specified, use `WAIT` and name the missing fact.

Set `FEATURE` and `KIND` if missing, and `TYPE` on every `NEXT`. Add
`TRACKER_CATEGORY` only from declared repo vocabulary. Give a heading leaving
`TODO` an outcome title. Add no size or complexity fields.

Under `** Comments`, record the conclusion, necessary evidence, and any
outstanding fact. Do not repeat the canonical state in prose.

## Scope

Do not implement or decompose features. Use `tracker-decompose` for a PRD ready
to split and `session-run` for implementation. Report one line per changed
heading.
