---
name: refine
description: Refine an existing UI by eye, one small request at a time, in a prototype or real implementation. Use when the user wants to iterate on a running UI's look or feel or enter refinement mode.
---

# Refine

Make the user's requested change to an existing running UI, whether a
prototype or real implementation. Optimise for round-trip latency; the user
reviews each change by eye.

Target the implementation the user is refining. Once a prototype has been
promoted, work on the real implementation.

## Edit only the request

Leave surrounding structure, styling, and copy unchanged. Reuse the existing
component or treatment the request names. Do not redesign adjacent surfaces.
Ask briefly, with options, when the request is underspecified. Do not infer
unstated constraints.

## No checks or delegation

During refinement rounds, run no tests, linters, type checks, builds, or
`my/tracker-validate`. Do not load the page, spawn subagents, parallelize, or
re-read the file after editing. The user's visual review is the check.

## Records and report

Edits persist; one-off visual choices are not standing requirements. Write
no comments, rationale, tracker headings, or iteration log. Record only
measurements that required substantial work, such as contrast or font-fallback
findings, under the tracker's `** Comments`.

Report one line stating what changed and where. Omit approach summaries,
alternatives, and invitations to review.

## Scope

Use `prototype` to build an experiment, `session-explore` for unattended
prototype headings, and `session-run` to execute production tickets.

A request to commit ends refinement mode. At that boundary, follow the repo's
normal verification and commit requirements. They also apply whenever you
leave this mode for other work.
