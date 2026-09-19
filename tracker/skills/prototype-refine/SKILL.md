---
name: prototype-refine
description: Refine an existing prototype by eye, one small request at a time, with nothing run and nothing recorded. Use when the user is iterating on a prototype's look or feel, asks for a tweak and wants to see it, or says to enter refinement mode.
---

# Prototype refine

Make the user's requested change to an existing running prototype; the user
reviews it by eye.

## Edit only the request

Leave surrounding structure, styling, and copy unchanged. Reuse the existing
component or treatment the request names. Do not redesign adjacent surfaces.
Ask briefly, with options, when the request is underspecified. Do not infer
unstated constraints.

## No checks or delegation

Run no tests, linters, type checks, builds, or `my/tracker-validate`. Do not
load the page, spawn subagents, parallelize, or re-read the file after editing.
The user's visual review is the check.

## Records and report

Write no comments, rationale, tracker headings, or iteration log. Record only
measurements that required substantial work, such as contrast or font-fallback
findings, under the tracker's `** Comments`.

Report one line stating what changed and where. Omit approach summaries,
alternatives, and invitations to review.

## Scope

Use `prototype` to build an experiment, `session-explore` for unattended
prototype headings, and `session-run` for production implementation. Leaving
refinement mode restores the normal workflow requirements.
