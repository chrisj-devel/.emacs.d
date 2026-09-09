---
name: tracker-edges
description: Read and write the tracker dependency graph as Edna BLOCKER properties with bare OLP paths. Use when asked what blocks a ticket, to add or remove a dependency, or to fix a broken dependency edge.
---

# Tracker edges

The dependency graph lives in `:BLOCKER:` properties. It is the only place
blocking is recorded.

Read `tickets/issue-tracker.md` first; it owns tracker semantics.

## Syntax

One `olp()` finder per dependency, space-separated, in the heading's property
drawer:

```org
:BLOCKER: olp("feature-slug.org" "00 --- Foundation ticket") olp("other-feature.org" "03 --- The gate")
```

**The path carries heading text only, never the TODO keyword.** A bare path
matches whatever state the target currently holds, so an edge survives its
target changing state. A path that embeds a keyword breaks the moment the
target moves, and `my/tracker-validate` reports it as unresolvable.

Paths resolve from the tracker directory. A same-feature edge names the
feature's own file; a cross-feature edge names the other feature's file.

The heading text must match exactly, excluding the keyword, priority cookie and
tags. If a target is retitled, update its dependants.

## Rules

- A heading is unblocked when every target is terminal (`DONE` or `CANCELED`)
- Blocking is derived, never stored as a state. A blocked ticket that is fully
  specified stays `NEXT`
- Resolving a dependency needs no edit to its dependants
- No `** Blocked by` section. Soft or historical sequencing goes under
  `** Comments`
- No edge to a heading in another repo, and no absolute path

## Reading the graph

`org-entry-blocked-p` answers whether one heading can start. For a whole
feature, the frontier is what matters — use `tracker-frontier`.

## Checking it

```
M-x my/tracker-validate
```

Reports unresolvable edges and cycles across `tickets/`. Run it after any
change to dependency metadata, and after retitling a heading. If this repo
declares extra verification commands, run those too.
