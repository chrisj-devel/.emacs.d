---
name: prototype
description: Build throwaway code that answers one design question, then hand it over to look at. Use when the user wants to sanity-check whether a state model or logic holds up, or to explore what a UI should look like.
---

# Prototype

A prototype is throwaway code that answers one question. State the question
first, in the prototype itself, and build only enough to settle it.

## Pick the shape

The question decides the artifact, and the two shapes share nothing, so ask
which when it is ambiguous and the user is around. Otherwise follow the
surrounding code — a module is logic, a page is UI — and state the assumption.

**Does this logic or state model hold up?** One self-contained HTML file, no
framework, bundler, or server, that opens by double-click. Keep the logic in a
single pure module — a reducer, a state machine, or plain functions over a data
type — with no DOM reaching into it, so the validated answer lifts out intact.
The page is a thin shell over it: the question in plain words at the top, the
full current state as labelled fields re-rendered after every action, one
free-play button per action, and guided walkthroughs as tabs, each resetting to
a known state and stepping through one case that is hard to reason about on
paper. Label everything in domain language; a non-developer drives it.

**What should this look like?** Three structurally different variants on one
route — different layout, hierarchy, and primary affordance, not different
colour — switched by a `?variant=` search param and a floating bar that cycles
with arrows and the arrow keys. Mount them inside the real page so they sit
against real data and density; create a route only when the surface genuinely
has no host, following the project's existing routing convention. Gate the bar
out of production builds.

## Rules

Put it next to what it prototypes and name it so a casual reader sees it is a
prototype. Start it from the project's task runner in one command. Keep state
in memory unless persistence is the question; if it is, use a scratch store
named to be wiped. No tests, no abstractions, and no error handling beyond what
makes it run.

## Hand over

Once it runs, report the URL or file and call the Skill tool with `refine`. Do
not wait to be asked and do not summarise the approach: the user is looking at
it now, and round-trip latency is the point.

## Capture

The answer is the deliverable — the verdict and the question it settled,
recorded under the tracker heading's `** Answer`. Fold a validated decision
into the real code. The prototype itself is not kept: delete it, or leave it
out of the commit.

## Scope

`refine` iterates on it by eye, `session-explore` works unattended prototype
headings, and `session-run` executes production tickets.
