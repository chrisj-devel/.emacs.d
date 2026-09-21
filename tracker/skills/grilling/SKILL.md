---
name: grilling
description: Interview the user to resolve an open design decision, one round of questions at a time. Use when the user wants to stress-test a plan, decision, or idea, or uses any 'grill' trigger phrase.
---

# Grilling

Interview the user until every branch of a decision is settled. Map the
decisions as a tree: each answer branches into the decisions hanging off it.

## Rounds

The frontier is every decision whose prerequisites are already settled. Ask the
whole frontier in one round; a question depending on another still open belongs
to a later round. Number each question and recommend an answer to it.

```
❓ **Q1** - **<question title>**: <question body, may be several paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```

Wait for the user's answers, recompute the frontier, and ask the next round.
Finish when the frontier is empty, with nothing left silently assumed.

## Facts and decisions

Finding facts is your job. Dispatch repo or environment fact-finding to a
subagent and ask the rest of the frontier while it runs; only the questions
downstream of it wait. Never ask the user for something you can look up.

The decisions are the user's. Put each to them and wait. Do not act on the
outcome until they confirm the understanding is shared.

## Docs

Write the model down as it resolves, through `domain-modeling`. A term settles
into `CONTEXT.md` in the same turn it resolves. A constraint that will outlive
the feature is drafted as an ADR and proposed; the maintainer elevates it. When
an answer contradicts a live ADR, name that ADR and stop.

## Scope

`session-grill` runs this interview against a feature's filed grilling headings
and records each decision in the tracker. Use it when the decisions are filed;
use this skill directly when they are not.
