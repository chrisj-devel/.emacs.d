# Tracker: repo-specific vocabulary

This file is yours. `my/tracker-install` creates it once and never overwrites
it. It fills the slots declared in `issue-tracker.md`, which owns the rules.

Delete any section you do not use — an undeclared slot is simply unused.

## Slot: alignment

Declare how a feature relates to this repo's current priorities, and where that
bar is written down. Decided once, at spec time, and not revisited.

Example shape:

```
`ALIGNMENT` is required on a PRD, measured against <doc> §<n>:

- `core`: on the path to the current bar
- `supporting`: serves the core indirectly
- `adjacent`: real value, not on the current bar
- `off-bar`: does not add to the core premise
```

## Slot: categories

Declare the `TRACKER_CATEGORY` vocabulary for this repo — typically `bug` for
defects plus a set of area tags. Say whether compound `area / area` values are
allowed.

## Slot: extra properties

Declare any properties this repo requires beyond `FEATURE`, `KIND`, and `TYPE`,
and say which headings require them.

## Slot: tracker versioning

Declare this only if `tickets/` is not versioned with the code — a local
breakdown of an upstream tracker, symlinked in from its own repository. Name
the upstream source of truth, say what the commit boundary stages, and say
where the tracker itself is committed.

## Slot: verification

Declare the commands a ticket must pass before it can be marked `DONE`, and any
repo-specific tracker checks that run alongside `M-x my/tracker-validate`.

## Evidence

Record anything this repo has tested and settled, so it is not relitigated —
conventions that were tried and dropped, and why.
