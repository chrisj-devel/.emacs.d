---
name: domain-modeling
description: Build and sharpen a project's domain model. Use when discussing codebase terminology, writing or editing a CONTEXT.md, or recording or editing an ADR.
---

# Domain modeling

Actively build and sharpen the project's domain model as you design: challenge
terms, probe boundaries with concrete scenarios, and write the glossary and the
constraints down the moment they resolve.

Reading `CONTEXT.md` for vocabulary is not this skill — that is a habit any
skill can hold. This skill is for changing the model.

`docs/agents/domain.md` owns the contract: what `CONTEXT.md` and an ADR may
contain, in what form, and what happens to a constraint that dies. Read it
before writing either document. `docs/agents/domain.local.md` supplies that
repo's values.

## During the session

Update `CONTEXT.md` inline, in the same turn a term resolves. Do not batch.

Offer an ADR when a constraint has emerged that will outlive the feature
producing it. Durability is the whole test: do not look for a trade-off, and do
not record one if there was one. Draft it and propose it; the maintainer
elevates it.

When a proposal contradicts a live ADR, say which one and stop. An agent does
not resolve a standing constraint against itself.
