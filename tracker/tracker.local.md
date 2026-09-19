# Tracker: repo-specific vocabulary

`my/tracker-install` creates this file once and never overwrites it. Fill the
slots declared in `issue-tracker.md`; delete unused sections.

## Slot: alignment

Declare the alignment property, its values, and the document defining the
repo's priorities. Decide alignment once at spec time. Omit this section if
the repo has no documented priorities.

## Slot: categories

Declare the `TRACKER_CATEGORY` vocabulary and whether compound `area / area`
values are allowed.

## Slot: extra properties

Declare required properties beyond `FEATURE`, `KIND`, and `TYPE`, and which
headings require them.

## Slot: tracker versioning

Use only when `tickets/` is versioned separately from code. Name the upstream
source of truth, what the commit boundary stages, and where tracker updates
are committed.

## Slot: verification

Declare commands required before `DONE`, including any repo-specific checks
in addition to `M-x my/tracker-validate`.

## Current constraints

Record necessary repo-specific decisions and evidence needed for open work.
Omit rejected alternatives, rationale, and implementation history.
