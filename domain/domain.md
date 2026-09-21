# Domain docs: CONTEXT.md and ADRs

A repo's domain model lives in two documents. `CONTEXT.md` at the root defines
vocabulary. `docs/adr/` holds one file per standing constraint.
`docs/agents/domain.local.md` supplies the repo-specific slots below and may
override only defaults explicitly marked overridable. Absent slots use the
defaults.

Read `CONTEXT.md` and the relevant ADRs before designing. Proceed silently if a
document is absent; create it when you first have something to put in it.

## Authority

`CONTEXT.md` defines vocabulary. An entry may point at the ADR that constrains
its term and never argues for it. A constraint found only in `CONTEXT.md` is a
missing ADR: promote it and leave the definition behind.

An ADR states a constraint. It does not define vocabulary, restate a definition,
or hold anything a reader could reach by reading `CONTEXT.md`.

Neither document holds procedure. A repeatable operation is a runbook.

Use the glossary's terms as it defines them, in code, tickets and test names
alike. A term used against its definition is a defect in one of the two.

## What an ADR is

An ADR records a constraint that outlives the feature that produced it.
Durability admits it. A trade-off is not required, is not evidence, and is not
recorded: a constraint arrived at without alternatives binds exactly as hard as
one argued for.

An ADR contains exactly:

1. A title naming the constraint.
2. The constraint, as a present-tense rule.
3. A prohibition, only where a competent agent would otherwise arrive at the
   forbidden thing by default.

Nothing else. No context section, no considered options, no rejected
alternatives, no consequences, no status. A consequence that binds is itself a
constraint and is stated as one; a consequence that does not bind is removed.

A prohibition is a cost, not a free annotation. Naming a forbidden thing puts it
in every later reader's working set, and across a long context the prohibition
decays faster than its subject. Write one only where its absence would let a
competent reader walk into the forbidden thing by default.

An agent drafts and proposes an ADR. The maintainer elevates it. No agent lands
a standing rule alone.

## ADR format

ADRs are Org, numbered sequentially, at `docs/adr/0001-slug.org`. Scan the
directory for the highest number and increment. Numbers are never reused.

```org
#+title: Bands derive from Track progression

Band is derived from a player's Track progression and partitions matchmaking.
The derived Band is the ceiling for a chosen Arena difficulty.

A played Band below the derived one does not change Level.
```

A superseding ADR carries the numbers it spends:

```org
:PROPERTIES:
:SUPERSEDES: 0009 0026
:END:
```

Cite an ADR as `ADR-NNNN`, which is format-agnostic, rather than by path.

## Lifecycle

A dead or superseded ADR is deleted, not marked. Everything present in
`docs/adr/` is live, so there is no status to record. Git holds the removed
text; residency is what makes a spent constraint keep getting cited.

Its successor takes a `:SUPERSEDES:` entry for each number it spends, and every
citation of the dead ADR is rewritten to state the live rule and cite the live
ADR.

An ADR that is superseded in part was holding two constraints. Split it: one
live ADR for the constraint that survives, and the spent number recorded on
whatever replaces the other.

## CONTEXT.md format

```md
# {Context name}

{One or two sentences: what this context is.}

## Language

**Order**: A customer's request for goods, priced and committed.
_Avoid_: purchase, transaction

**Invoice**: A request for payment sent after delivery. Terms are fixed at
issue (ADR-0014).
_Avoid_: bill, payment request
```

- Define what a term **is**, not what it does. One or two sentences.
- Be opinionated. Where several words name one concept, pick one and list the
  rest under `_Avoid_`.
- Only terms specific to this context. A general programming concept does not
  belong however heavily the project uses it.
- Group under subheadings when natural clusters emerge; a flat list is fine
  otherwise.
- No implementation detail, no spec, no scratch notes. It is a glossary.

Record a term the moment its meaning is resolved, in the same session. Do not
batch them.

## Multiple contexts

A `CONTEXT-MAP.md` at the root means the repo has several contexts, and lists
where each lives and how they relate. Each context then owns a `CONTEXT.md` and
a `docs/adr/` beside it; repo-wide decisions stay in the root `docs/adr/`.

If `CONTEXT-MAP.md` is absent and a root `CONTEXT.md` is present, the repo has
one context. If neither exists, it has one context and no glossary yet.

## Working the model

Sharpen the model as you design, rather than recording it afterwards.

- **Challenge against the glossary.** A term used against its definition is a
  contradiction to surface, not to absorb: "the glossary defines cancellation as
  X, and you mean Y. Which is it?"
- **Sharpen fuzzy language.** Propose the precise term. "Account: the Customer
  or the User? Those are different things."
- **Probe with scenarios.** Stress a proposed relationship with a concrete case
  that forces the boundary between two concepts to be stated.
- **Cross-reference with code.** When someone states how something works, check
  whether the code agrees, and surface the contradiction rather than the doubt.
