---
name: tracker-edges
description: Read and write the tracker dependency graph as Edna BLOCKER properties with bare OLP paths. Use when asked what blocks a ticket, to add or remove a dependency, or to fix a broken dependency edge.
---

# Tracker edges

Read `tickets/issue-tracker.md` first. Record dependencies only in `:BLOCKER:`
properties, with one space-separated finder per dependency:

```org
:BLOCKER: olp("feature-slug.org" "00 --- Foundation ticket") olp("other-feature.org" "03 --- The gate")
```

Paths are relative to `tickets/`; no absolute paths or edges across repos.
Heading text must match exactly, excluding TODO keyword, priority cookie,
and tags. Retitling a target requires updating its dependants.

A heading is unblocked when all targets are `DONE` or `CANCELED`.
`org-entry-blocked-p` derives this; specified blocked tickets remain `NEXT`.
Completing a target requires no edits to its dependants. Put soft or historical
sequencing under `** Comments`, never `** Blocked by`.

Use `tracker-frontier` for a feature's actionable headings.

## Validation

```
M-x my/tracker-validate
```

Run after dependency changes or retitling, plus any repo-declared verification.
It reports unresolvable edges and cycles across `tickets/`.
