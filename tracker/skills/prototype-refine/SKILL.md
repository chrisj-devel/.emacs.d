---
name: prototype-refine
description: Refine an existing prototype by eye, one small request at a time, with nothing run and nothing recorded. Use when the user is iterating on a prototype's look or feel, asks for a tweak and wants to see it, or says to enter refinement mode.
---

# Prototype refine

A mode, not a procedure. The user is looking at a running prototype and
adjusting it by eye. Every round is: he names a change, you make it, he looks.
The only thing that matters is how long that round takes.

Optimise for round-trip latency. Everything below follows from that.

## Do only what was asked

Change what the request names and nothing adjacent. Leave surrounding
structure, styling and copy alone, including things you think are wrong.

Where the request names an existing thing, use that thing. Do not write a new
one because the existing one nearly fits — nearly fitting is what it is for.

Never redesign on the way. A redesign smuggled into a small request costs a
round trip to unpick, and its justification is almost always your own earlier
reasoning read back as a requirement.

## Ask instead of guessing

The user is present. A question costs one short exchange; a wrong guess costs
a round trip plus the unpicking. When a request is under-specified, ask it —
briefly, with the options you see.

Do not fill a gap with an inferred rule. If you cannot point at where a
constraint was stated, it is not one.

## Nothing runs

No tests, no linter, no type or `svelte-check` pass, no build, no
`my/tracker-validate`. Do not load the page to check your work. The user is
looking at it; that is the check, and it is faster than yours.

No subagents, no parallel fan-out, no re-reading a file you just edited. They
buy confidence the user is already supplying.

## Nothing is recorded

These decisions are point-in-time and die with the turn. Write no code
comments, no rationale, no tracker headings, no round-by-round log. Recording
a one-off judgment is what turns it into a fake standing rule for the next
turn to obey.

The exception is a measurement that cost real work — a contrast ratio, a
figure taken at six widths, a font-fallback finding. Those go in the tracker
under `** Comments`. Arguments do not.

## Reporting

One line: what changed, where. No summary of the approach, no list of what you
considered, no invitation to review. The next message is the user's reaction to
what he sees.

## Scope

This mode refines a prototype that exists. Building one to answer a question is
`prototype`; working a feature's `KIND: prototype` headings unattended is
`session-explore`. Folding a settled result into real code is a ticket, and
`session-run` takes it — leaving the mode is what makes the normal bars apply
again.
