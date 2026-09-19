# Issue tracker: local Org

Issues and PRDs live in `tickets/`. `tickets/tracker.local.md` supplies the
repo-specific slots below and may override only defaults explicitly marked
overridable. Absent slots use the defaults.

## Conventions

- One file per feature: `tickets/<feature-slug>.org`.
- The first top-level heading is a `KIND: prd` specification or `KIND: map`
  exploration. Work headings are numbered siblings, starting at `01`.
- Work titles name outcomes; captured `TODO` titles may name symptoms until triage.
- The heading's TODO keyword is its only state; no `Status:` line or property.
- Put necessary decisions, evidence, and outstanding facts under `** Comments`.

Keep current requirements, contracts, decisions, procedures, and evidence needed
for open work. Remove stale accounts, rejected alternatives, justification,
gotcha narratives, and duplicate explanations. Retain a necessary precondition
or limitation as a direct statement.

```org
* NEXT 01 --- A narrow tracer bullet
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:TYPE: AFK
:BLOCKER: olp("feature-slug.org" "00 --- Foundation ticket")
:END:
```

`FEATURE` and `KIND` are required; `TYPE` is required on `NEXT` work headings.
`PRIORITY` is optional. A work heading may use `BRANCH` for its implementation
branch; a `prd` or `map` never does. Additional requirements belong to
**slot: extra properties**.

## `KIND`

| Kind | Meaning |
| --- | --- |
| `prd` | Feature specification. |
| `map` | Feature exploration, in place of a PRD. |
| `ticket` | Implementation work. |
| `research` | Answering a question. |
| `prototype` | Throwaway work to test an approach. |
| `grilling` | Resolving a design decision. |

Exploratory headings record their result under `** Answer` before reaching
`DONE`; summarise it under the map's `** Decisions so far`.

## States

| State | Meaning |
| --- | --- |
| `TODO` | Not yet evaluated, or an unsliced feature. |
| `NEXT` | Specified and actionable; `TYPE` identifies the executor. |
| `DOING` | Claimed and underway. |
| `WAIT` | One identified fact or decision prevents specification; record it in the entry note. |
| `DONE` | Finished, not necessarily shipped. |
| `CANCELED` | Will not be actioned. |

The Emacs configuration defines these keywords; do not add directory-local ones.
Triage asks whether an executable brief can be written:

- Missing fact or decision → `WAIT`.
- Specified human execution → `NEXT`, `TYPE: HITL`.
- Specified machine execution → `NEXT`, `TYPE: AFK`.

Unevaluated work stays `TODO`. A `prd` or `map` never takes `NEXT` or `TYPE`:
it is `TODO` before decomposition, `WAIT` for an identified missing fact,
`DOING` once work headings exist, and `DONE` when the feature closes.

## `TYPE`

`AFK` means an unattended agent can execute the brief. `HITL` means execution
requires a human action, such as approval, credentials, or physical access.
Difficulty alone does not make work `HITL`.

A material unresolved decision gets a `KIND: grilling`, `TYPE: HITL` heading.
Machine-executable work remains `AFK`, with a dependency on that decision.
`TYPE` is retained on completion.

## Priority

**Slot: alignment** may define a property's values and the document specifying
the repo's priorities. Decide alignment once at spec time. Record what work
outside those priorities does not advance and what it displaces; do not refuse
it on that basis.

Do not add `EFFORT`, `COMPLEXITY`, or other size estimates, or store counts that
can be derived from the tracker.

## Categories

`TRACKER_CATEGORY` is optional. Use **slot: categories** for its vocabulary;
omit the property when the repo declares none.

## Dependencies

Edna `:BLOCKER:` is the canonical graph. Put one
`olp("<file>.org" "Exact heading")` finder per dependency in the property drawer.
Paths resolve from `tickets/` and contain bare heading text, without its TODO
keyword. Edges must stay inside one repo's tracker; record cross-repo or soft
sequencing under `** Comments`, not `** Blocked by`.

A heading is unblocked when every target is `DONE` or `CANCELED`.
`org-entry-blocked-p` derives blocking; a specified ticket remains `NEXT` while
blocked, and completing a dependency needs no edit to its dependants.

Run `M-x my/tracker-validate` after dependency changes to find unresolvable edges
and cycles, plus any commands in **slot: verification**.

## Decomposition

A `prd` or `map` without sibling work headings is undecomposed. Adding the first
work heading moves the parent to `DOING`; do not store a separate decomposition
state.

## Markup and links

Use Org: `=verbatim=`, `*bold*`, `/italic/`, `+strikethrough+`, and
`#+begin_src`/`#+end_src`. Checkboxes use `- [ ]` / `- [X]` with a `[/]` cookie.
Keep each paragraph and list item on one line; do not hard-wrap.

Links: `[[file:<feature>.org][<feature>]]`, `[[jira:ABC-123]]`, or
`[[file:~/Source/<org>/<repo>/<path>::39][<file>:39]]`. Define `jira:` through
machine-local customization, not a `#+SETUPFILE:` line.

## Manual verification

Put hand-run requests under `** Verify :verb:`. Its children inherit the tag;
do not use file-wide `#+FILETAGS: :verb:`. `C-c C-r C-r` invokes Verb through
`api-conf.el`'s Org binding.

```org
** Verify :verb:
template {{(verb-var carts-base "http://carts.localhost:8088")}}
Accept: application/json

*** GET an unknown cart id -> expect 404
get /v3/carts/00000000-0000-0000-0000-000000000000
X-Customer-Id: {{(verb-var customer-id)}}
```

Give every `verb-var` an inline default. Variables are buffer-local; stored
responses are session-global and available through `verb-stored-response`.
Never put secrets in tracker files.

## Completion and commit boundary

Once acceptance criteria and required verification pass:

1. Check the acceptance criteria and set the heading to `DONE`.
2. Stage the implementation and tracker update together.
3. Commit immediately; report completion only after success.

Keep work `DOING` while it must remain uncommitted. **Slot: tracker versioning**
defines what to stage and where to commit the tracker when it is versioned
separately from code.

## Sessions

A feature session is one worktree, tab, and agent, created by `C-c s n`.
For `~/Source/<org>/<repo>`, worktrees live under
`~/Source/<org>/worktrees/<repo>/<feature>`. An agent started in a session is
already there; do not create another worktree or use `EnterWorktree`.

The session's running Emacs provides `emacsclient --eval` for querying the
session layer. Work on the session's tracker copy; its state merges with the
feature branch. Do not reconcile it against the main copy mid-feature, except
as specified by **slot: tracker versioning**.

Before working the frontier, report drift from the base:

```sh
emacsclient --eval "(my/session-drift-report \"$PWD\")"
```

Account for drift when scoping. Do not merge or rebase to close it without the
human's instruction. The feature file names its branch; no parent `BRANCH`
property is needed.

## Closing a feature

When the last open heading becomes terminal, set the `prd` or `map` to `DONE`
in the same commit. PRD-less bundles have no parent to close. A closed feature
has only `DONE` or `CANCELED` headings and stays in its existing file.

## Emacs

`C-c a w` shows all open headings by state; `C-c a f` shows unblocked `NEXT`
headings by executor. Both cover the repo at point. A feature's worktree copy
overrides main's copy; other features use main. Scope comes from
`git worktree list`.

`C-c s n` spawns a session; `C-c s k` tears it down. The Emacs configuration
owns these bindings, agenda views, and the `org-edna` dependency.
