# Council protocol

The council is five voices that challenge a proposal. It runs twice per
feature: **Gate 1** on the brief (is this the right thing) and **Gate 2** on
the diff (was it built right). Bug fixes that touch critical paths get
Gate 2 only.

The council exists to find the reason this will fail in the real world
before a real person does. It is not a style review.

## Voices

Default personas live in `keel/council/personas/`. A project may add a
sixth or replace `domain.md`. Never fewer than four.

| Voice | Asks |
|---|---|
| User | Will the real persona, in their worst realistic moment, get the outcome? |
| Adversary | How do I abuse, spoof, spam, leak or break this? |
| Operator | What does this cost, what breaks at 10x, who is paged, is there a runbook? |
| Skeptic | Does this need to exist? What is the simplest thing that gets 80%? What did we already reject? |
| Domain | Which law, standard, or domain practice does this touch? Who must we not embarrass? |

## How to run it

One agent can play all voices in sequence. If the agent runtime supports
subagents, run the five in parallel with the brief or diff as input and
synthesise. Either way the output format below is mandatory.

Before speaking, every voice reads: the brief (Gate 1) or the diff plus brief
(Gate 2), `keel/knowledge/CONSTRAINTS.md`, `keel/knowledge/REJECTED.md`, and
the scenarios the brief names.

Token cap: each voice at most 150 words. Chair synthesis at most 200 words.
Quality comes from specificity, not length.

## Gate 1 (brief) mandatory questions

1. User: walk the one scenario on the worst device and network in
   `PERSONAS.md`. Where does it break?
2. Adversary: what is the cheapest abuse? What personal data is newly exposed?
3. Operator: cost per use, cost at 10x, what new thing can page us at 3 am?
4. Skeptic: cite any `R-` or `D-` that already covers this. Name the simpler
   alternative. Is the success metric measurable today?
5. Domain: what rule, law or convention applies? What does the incumbent do?
6. **Pre-mortem (all voices)**: it is 90 days after ship and this failed.
   Each voice gives the one most likely cause.

## Gate 2 (diff) mandatory questions

1. User: run every scenario the brief listed, by reading the code path. Which
   are not actually covered?
2. Adversary: new endpoints, new inputs, new data flows. Auth, validation,
   rate limits, PII in logs or push bodies.
3. Operator: bundle size delta, new dependencies, new cron or background
   work, migrations and their rollback, what the audit entry must prove.
4. Skeptic: scope creep against the brief's non-goals. Dead code. Duplicated
   logic that already exists in the repo.
5. Domain: copy and behaviour still correct against the standard cited in
   Gate 1?

## Verdict format (write to COUNCIL-1.md or COUNCIL-2.md)

Use `keel/templates/COUNCIL.md`. The chair line must be exactly one of:

- `Verdict: PROCEED`
- `Verdict: PROCEED WITH CHANGES` followed by a numbered list. Each change is
  a required edit to the brief or the diff, not a suggestion.
- `Verdict: REWORK` with the two or three reasons. Return to brief or code.
- `Verdict: REJECT` with the reason. Add an `R-` entry to REJECTED.md.

The commit-msg hook accepts `[F-xxxx]` commits only when `COUNCIL-1.md`
contains a `Verdict: PROCEED` line (with or without changes). The pre-push
hook accepts a push to a protected branch only when the audit entry says
`Gate 2: PROCEED` (with or without changes).

## Reality check rule

For any feature the brief estimates at more than two days of work, Gate 1
cannot return PROCEED until one real person matching the persona has been
asked about the scenario, and their answer is quoted in the brief under
"Prior art". Agents cannot do this step. Ask the owner.

## Every demanded change is tracked

Each `PROCEED WITH CHANGES` item gets a checkbox in the verdict file. Gate 2
begins by confirming every Gate 1 checkbox is ticked with a commit reference.
