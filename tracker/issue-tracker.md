# Issue tracker: local Org

Issues and PRDs live as Org files in `tickets/`.

Repo-specific vocabulary lives in `tickets/tracker.local.md`. That file fills
the slots named below and may override a default this file calls out as
overridable. It supplies values; it never overrides a rule. If it is absent, the
slots are unused and the defaults stand.

## Conventions

- One file per feature: `tickets/<feature-slug>.org`
- Its first top-level heading describes the whole feature: a `KIND: prd` for
  work with a specification, or a `KIND: map` for an exploratory effort
- Work headings are siblings of it, numbered from `01` in their heading text
- Comments and conversation history append under a `** Comments` heading
  beneath the heading they belong to

The title after a work heading's number names an outcome rather than an area:
"Return the record from the existing endpoint", never "Endpoint changes". A
`TODO` heading is the exception — it records what was observed, so its title may
name the symptom; rewriting it as an outcome is triage's work.

Every heading's TODO keyword is its canonical state. Never duplicate it in a
`Status:` line or a property.

```org
* NEXT 01 --- A narrow tracer bullet
:PROPERTIES:
:FEATURE: feature-slug
:KIND: ticket
:TYPE: AFK
:BLOCKER: olp("feature-slug.org" "00 --- Foundation ticket")
:END:
```

`FEATURE` and `KIND` are required. `TYPE` is required on every `NEXT` heading.
`PRIORITY` is optional. `BRANCH` is optional on a work heading, where it names
the branch that implements it — never on a `prd` or `map`, whose branch is the
feature name. A repo may declare further required properties —
**slot: extra properties**.

## `KIND`

`KIND` says what a heading *is*. `TYPE` says who executes it; the two are
independent, so a grilling that needs a human is `KIND: grilling` with
`TYPE: HITL`.

| Kind | Meaning |
| --- | --- |
| `prd` | Specification of a feature. First heading in its file. |
| `map` | Parent of an exploratory effort, in place of a PRD. |
| `ticket` | Implementation work. |
| `research` | Answering an open question. |
| `prototype` | Throwaway work to test an approach. |
| `grilling` | Stress-testing a plan or decision. |

Exploratory kinds resolve by recording their answer under `** Answer` and
moving to `DONE`; summarise the outcome under the map's `** Decisions so far`.

## States

| State | Meaning |
| --- | --- |
| `TODO` | Filed but not yet evaluated. The inbox. |
| `NEXT` | Fully specified and actionable. `TYPE` says who acts. |
| `DOING` | Claimed and underway. |
| `WAIT` | Cannot be specified yet; a fact or decision is outstanding. Org logs a note on entry — say what is being waited on. |
| `DONE` | Terminal. Finished, not necessarily shipped. |
| `CANCELED` | Terminal. Will not be actioned. |

The vocabulary is defined in the Emacs configuration, so a repo needs no
directory-local TODO keywords.

The triage gate is one question: **could I write the agent brief right now?**

- No, a fact or decision is missing → `WAIT`
- Yes, but a machine cannot execute it → `NEXT` with `TYPE: HITL`
- Yes, and a machine can → `NEXT` with `TYPE: AFK`

The gate is for headings someone executes, so a `prd` or `map` never reaches
`NEXT` and never takes a `TYPE`. It is `TODO` while it is unsliced — `WAIT` when
one identified thing stops it being finishable — `DOING` once it has work
headings, and `DONE` when the feature closes.

An unspecified heading is `TODO`, not `WAIT`. `WAIT` means one identified thing
is outstanding; `TODO` means nobody has looked yet.

Blocking is never a state. See "Dependencies".

## `TYPE`

`TYPE` routes a `NEXT` heading to its executor. `AFK` means an unattended agent
can complete it from the heading alone. `HITL` means the execution itself is
human: an approval, a credential, physical access. It is not for work that is
merely hard.

Work a machine could do once someone decides something is not `HITL`. The
decision is its own `KIND: grilling` heading and the work stays `TYPE: AFK`,
blocked on it — see `tracker-triage`.

`TYPE` survives completion. A `DONE` heading keeps the `TYPE` it was executed
under, which is why routing is a property and not a state.

## Priority

A repo may define a vocabulary describing how a feature relates to its current
priorities, and where that bar is written down — **slot: alignment**. Decide it
once, when the spec is written, and do not revisit it.

Work that scores low is recorded, not refused. Name what a feature does not
move and what it displaces, once, at spec time, and then build it. Never
decline work on scope grounds.

## No size or complexity field

Do not add `EFFORT`, `COMPLEXITY`, or any other size estimate.

Effort is a sum over a decomposition that does not exist at PRD stage, so
estimating it there guesses at slicing rather than at the work. Complexity
either reads process state off the spec text or fails to discriminate once
most work lands in one bucket. What both reach for is already free: the states
say what is undecided (`WAIT`, `TYPE: HITL`, or no tickets at all), and counting
a feature's open tickets says how much is left. A repo that declares an
alignment slot reads what is on its bar there as well.

Do not store what can be counted. A repo that has tested this may record its
own evidence in `tracker.local.md`.

## Categories

`TRACKER_CATEGORY` is optional and its vocabulary is repo-defined —
**slot: categories**. Absent a declared vocabulary, omit the property.

## Dependencies

Edna `:BLOCKER:` is the canonical dependency graph. Use one
`olp("<file>.org" "Exact heading")` finder per dependency in the heading's
property drawer.

Every edge stays inside one tracker. Edna resolves a finder within the tracker
being swept, so a path reaching into another repo does not block anything — it
reads as a dependency and never behaves as one. Record cross-repo sequencing
under `** Comments` and order the work by hand.

**The OLP path carries the heading text only, never its TODO keyword.** A bare
path matches whatever state the target currently holds, so an edge survives its
target changing state. Paths resolve from the tracker directory, so a
same-feature edge names the feature's own file.

A heading is unblocked when every target is terminal (`DONE` or `CANCELED`).
Blocking is derived from these edges, never duplicated as a state: a fully
specified ticket stays `NEXT` while its dependencies are unresolved, and
`org-entry-blocked-p` decides whether it can start. Resolving a dependency
therefore needs no state change on its dependants.

Do not add a `** Blocked by` section; historical or soft sequencing belongs
under `** Comments`.

Sweep the graph with `M-x my/tracker-validate` after changing dependency
metadata. It reports unresolvable edges and cycles. A repo may declare
additional verification commands — **slot: verification**.

## Decomposition

A `prd` or `map` heading with no sibling work headings in its file has not been
decomposed. That is a structural fact; do not record it as a state. Writing the
first ticket does move the parent to `DOING`, which says the feature is
underway — read whether it was decomposed from the file, not from that.

## Markup and links

Org, not Markdown: `=verbatim=` for code and identifiers, `*bold*`, `/italic/`,
`+strikethrough+`, `#+begin_src`/`#+end_src`. Checkboxes are the one carry-over —
org reads `- [ ]` / `- [X]` and rolls a `[/]` cookie up to the heading.

Never hard-wrap. A paragraph is one line, a list item is one line. Org wraps
them for display through `visual-line-mode`; hand-inserted newlines survive into
the file, so they break re-flow and turn a one-word edit into a whole-paragraph
diff.

Links: another feature `[[file:<feature>.org][<feature>]]`; a Jira issue
`[[jira:ABC-123]]`; source with a line target
`[[file:~/Source/<org>/<repo>/<path>::39][<file>:39]]`. The `jira:`
abbreviation is a machine-local customize setting, not a `#+SETUPFILE:` line.

## Manual verification

Put hand-run requests in a `** Verify` subtree **tagged `:verb:`**. Verb only
collects request specs from tagged headings, and tag inheritance covers the
requests nested under it. Do not use a file-wide `#+FILETAGS: :verb:` — that
tags the feature heading too. `api-conf.el` binds `verb-command-map` into
`org-mode-map`, so `C-c C-r C-r` works in any Org buffer.

```org
** Verify :verb:
template {{(verb-var carts-base "http://carts.localhost:8088")}}
Accept: application/json

*** GET an unknown cart id -> expect 404
get /v3/carts/00000000-0000-0000-0000-000000000000
X-Customer-Id: {{(verb-var customer-id)}}
```

**Always give `verb-var` a default inline.** Verb variables are buffer-local, so
a feature file does not see values set in a `test-<service>-api` file and will
prompt without one. Stored responses *are* session-global, so
`verb-stored-response` still resolves things created there.

Never put a token, password or secret in a tracker file.

## Skills that do not speak this tracker

Most skills are unaffected by where tickets live — they read code, write docs,
or run a conversation. Some publish into the tracker while describing their
output with Markdown-shaped templates. The template supplies content, not
storage syntax: render it into the shape above rather than publishing Markdown.

- "Publish to the issue tracker" means add a heading to
  `tickets/<feature-slug>.org`, creating the file if it does not exist. Never
  publish a Markdown tracker file, and never keep a Markdown mirror.
- "Fetch the relevant ticket" means read that heading in full, including its
  `** Comments`.
- A template `##` section becomes `**` beneath the heading
- Fenced code becomes `#+begin_src <language>` / `#+end_src`
- Links become Org links, inline code becomes `=code=`, checkboxes stay `- [ ]`
- A template's status or label field becomes the TODO keyword and the property
  drawer, never prose

A skill publishing a specification writes the file's `prd` heading; one
publishing implementation work writes sibling `ticket` headings; an
exploratory skill writes its own kind beside a `map`.

## Completion and commit boundary

`DONE` is the commit boundary, not an earlier bookkeeping step. Once the
ticket's acceptance criteria and required verification pass:

1. Mark its acceptance criteria complete and change the state to `DONE`.
2. Stage the implementation and the tracker update together.
3. Commit immediately.
4. Report completion only after the commit succeeds.

Never leave a `DONE` ticket as uncommitted work. If the work should remain
uncommitted, leave the ticket `DOING`.

A repo that does not version its tracker with the code says so, and says what
step 2 stages instead — **slot: tracker versioning**.

## Sessions

A feature is worked in its own session: one git worktree, one tab, one agent,
created by the Emacs session layer (`C-c s n`). The worktree lives outside the
repository and beside it, at `worktrees/<repo>/<feature>` in the repo's own
parent directory — a repo at `~/Source/<org>/<repo>` has its sessions under
`~/Source/<org>/worktrees/`.

An agent started inside a session is already in its worktree. Do not create
another worktree; in particular do not use `EnterWorktree`, which would nest one
inside the session.

The session's copy of the tracker is the one being worked. Ticket state travels
with the feature branch and merges alongside the code that justifies it, so
there is nothing to reconcile against the default branch mid-feature. A repo
whose tracker is not versioned with the code overrides this —
**slot: tracker versioning**.

The session layer names the branch after the feature, so a PRD records no
branch: the file name already is it.

## Closing a feature

A feature closes when its PRD is `DONE` (PRD-less bundles skip this) and every
ticket is `DONE` or `CANCELED`. Nothing moves: the file stays in `tickets/`.
Every heading being terminal is what closed means, and no todo view surfaces a
file with no open headings.

## Emacs

`C-c a` opens the agenda. Two views cover the tracker of the repo you are in:

- `w` — **workboard**: every open tracker heading, grouped by state
- `f` — **frontier**: unblocked `NEXT` headings only, split by `TYPE`

Both span every feature, not just the ones in flight — a feature checked out in
a worktree resolves to that worktree's copy, so in-flight state wins, and every
other feature resolves to the main checkout. Scope comes from `git worktree
list` in the repo at point, so other repos are never touched.

`C-c s n` spawns a session, `C-c s k` tears one down.

Both are stock `org-agenda-custom-commands`; only dependency enforcement needs a
package (`org-edna`). The views and the package are declared in the Emacs
configuration, not in the repo.
