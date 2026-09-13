# Keel: project memory, audit and challenge framework for coding agents

**You are a coding agent reading this file because a human asked you to install
Keel in a repository.** Follow section 1 exactly. Every file you must create is
given in full in section 3. Do not improvise the structure. After install, the
repository's own `KEEL.md` becomes the entry point and this bootstrap file is
no longer needed.

Keel is agent-agnostic. It is plain markdown, plain git hooks, and a small set
of habits. Optional Claude Code skills are in section 8.

Version: 1.0.0, 2026-09-13. Repository: github.com/acshriv-alt/keel. The same files exist as a copyable tree under `template/` in that repository.

---

## 0. What Keel is for

A solo owner working with coding agents loses three things between sessions:
**context** (what is the state, what is in flight), **reasons** (why did we
decide X, why did we reject Y), and **evidence** (what was checked before a
push). Keel keeps all three in the repo, in files small enough for an agent to
load every session, with git hooks so the habit cannot silently drift.

Five mechanisms:

| Mechanism | File(s) | Answers |
|---|---|---|
| State | `keel/STATE.md` | Where are we right now, what next |
| Decisions and rejections | `keel/decisions/`, `keel/knowledge/REJECTED.md` | Why did we do X, why not Y, when to revisit |
| Knowledge | `keel/knowledge/CONSTRAINTS.md`, `ASSUMPTIONS.md` | Real-world facts we already learned, guesses we still owe proof for |
| Council | `keel/council/`, per-feature `COUNCIL-1.md` / `COUNCIL-2.md` | Who challenged this idea and this diff, and what they demanded |
| Scenarios and audit | `keel/scenarios/`, `keel/audits/AUDIT-LOG.md` | What real situations the code must survive, what was verified before each push |

Two-tier loading keeps tokens low: `KEEL.md` at the repo root is under 120
lines and is read every session. Everything else is read on demand.

---

## 1. Install steps (agent, do these in order)

1. Confirm you are at the repository root and on a non-production branch.
2. Create every file in section 3 at the path shown. Copy content verbatim,
   then fill placeholders written as `{{LIKE_THIS}}`. Ask the owner for any
   placeholder you cannot infer from the repo.
3. Make hooks executable and point git at them:
   ```sh
   chmod +x keel/hooks/*
   sh keel/hooks/install.sh
   ```
   If the repo already uses `core.hooksPath` or has hooks in `.git/hooks`,
   read section 7.3 before running install.
4. If a `CLAUDE.md`, `AGENTS.md`, `.cursorrules` or similar agent-instruction
   file exists, add this line near the top:
   `Read KEEL.md first. It is the entry point for state, decisions and the push gates.`
   If none exists, create `AGENTS.md` containing only that line.
5. Seed the knowledge files (section 9): ask the owner for the five to ten
   real-world constraints already known, and for every past decision they
   remember re-explaining. Write them now. An empty Keel is worth little.
6. Write the first `keel/STATE.md` from the current repo and branch state.
7. Run `git add keel KEEL.md AGENTS.md` (or the file edited in step 4), then
   commit with message `[keel] install Keel v1.0`.
8. Stop. Report what was created and what placeholders remain. Do not push.

---

## 2. File tree after install

```
KEEL.md                              entry point, always loaded, < 120 lines
keel/
  config.sh                          hook configuration (branches, checks, patterns)
  STATE.md                           current state, rewritten at the end of every session
  BACKLOG.md                         bugs and backlog, prioritised
  CHANGELOG.md                       one entry per production release
  decisions/
    INDEX.md                         one line per decision
    D-0001-example.md                decision records, one file each
  knowledge/
    CONSTRAINTS.md                   real-world facts and hard limits, with evidence and date
    ASSUMPTIONS.md                   ledger of unverified beliefs and how to verify them
    REJECTED.md                      ideas we said no to, why, and the trigger to revisit
  features/
    F-0001-slug/
      BRIEF.md                       problem, persona, scenario, non-goals, metric, kill criteria
      COUNCIL-1.md                   Gate 1 verdict (idea)
      COUNCIL-2.md                   Gate 2 verdict (diff)
      OUTCOME.md                     review at +14 days
  scenarios/
    PERSONAS.md                      real actors with device, network, state of mind
    SCENARIOS.md                     catalogue of Given / When / Then with IDs and status
  council/
    COUNCIL.md                       protocol, verdict format, token caps
    personas/
      user.md  adversary.md  operator.md  skeptic.md  domain.md
  audits/
    AUDIT-LOG.md                     append-only, one entry per push to an audited branch
  incidents/
    INC-0001-slug.md                 root cause analyses
  runbooks/
    README.md                        how to do recurring operational things
  templates/
    BRIEF.md  COUNCIL.md  DECISION.md  OUTCOME.md  INCIDENT.md  SCENARIO.md  AUDIT.md
  hooks/
    install.sh  pre-commit  commit-msg  pre-push
```

IDs are stable and never reused: `D-0001` decisions, `F-0001` features,
`SC-AREA-001` scenarios, `A-0001` audit entries, `INC-0001` incidents,
`P-NAME` personas, `C-001` constraints, `AS-001` assumptions, `R-001` rejected.

---

## 3. File contents

Create each file exactly as shown. Fenced blocks are the file contents.

### 3.1 `KEEL.md` (repo root)

````markdown
# {{PROJECT_NAME}}: Keel entry point

Read this file at the start of every session. Then read `keel/STATE.md`.
Then read the `keel/features/F-xxxx/` folder for whatever is in flight.
Nothing else is loaded by default. Open other files when the work needs them.

## Hard rules

1. **Search before you propose.** Before suggesting any design, grep
   `keel/decisions/INDEX.md` and `keel/knowledge/REJECTED.md` for the topic.
   If it was decided or rejected, say so and cite the ID. Reopen only with new
   evidence, recorded in a new decision that supersedes the old one.
2. **Every commit carries a tag**: `[F-0001]` for feature work, `[fix]`,
   `[hotfix]`, `[chore]`, `[docs]`, `[keel]`. The commit-msg hook enforces it.
3. **Code changes ship with a scenario.** Touching code under
   `KEEL_CODE_PATTERN` (see `keel/config.sh`) requires a change to
   `keel/scenarios/SCENARIOS.md` in the same commit, or an explicit waiver
   (`KEEL_WAIVE_SCENARIOS=1` plus a `Waiver:` line in the commit body).
4. **Pushes to audited branches carry an audit entry** in
   `keel/audits/AUDIT-LOG.md` and an updated `keel/STATE.md`. Pushes to
   protected branches also need `Gate 2: PROCEED`. The pre-push hook enforces
   it. Stop after committing and ask the owner before any push.
5. **Absolute dates only** (`2026-09-11`), never "yesterday" or "last week".
6. **Evidence, not claims.** An audit entry says what command ran and what it
   printed, not "tests pass".
7. **Append-only files** (`AUDIT-LOG.md`, `REJECTED.md`, decision records) are
   never edited in place. Correct with a new entry that references the old one.

## Feature lifecycle

```
idea -> check REJECTED + decisions -> F-xxxx/BRIEF.md
     -> Gate 1 council (COUNCIL-1.md) -> decisions logged
     -> scenarios written first -> code, commits tagged [F-xxxx]
     -> Gate 2 council on the diff (COUNCIL-2.md)
     -> audit entry -> owner approves -> push
     -> +14 days: OUTCOME.md -> feeds REJECTED / decisions / constraints
```

Bug fixes (`[fix]`) skip Gate 1. They still need a scenario and an audit
entry. A fix touching `KEEL_CRITICAL_PATTERN` needs Gate 2.

## Session protocol

- **Start**: read this file, `keel/STATE.md`, in-flight feature folder.
- **During**: log decisions the moment they are made, not at the end.
- **End**: rewrite `keel/STATE.md` (Now, In flight, Next, Blocked, Last
  session). Add to `BACKLOG.md` anything found but not fixed.

## Where things live

| Need | File |
|---|---|
| What is the current state | `keel/STATE.md` |
| Why we did X | `keel/decisions/INDEX.md` then the `D-` file |
| Why we did not do Y | `keel/knowledge/REJECTED.md` |
| Real-world limits we already hit | `keel/knowledge/CONSTRAINTS.md` |
| What we believe but have not proven | `keel/knowledge/ASSUMPTIONS.md` |
| Who uses this and in what conditions | `keel/scenarios/PERSONAS.md` |
| What must keep working | `keel/scenarios/SCENARIOS.md` |
| What was checked before each push | `keel/audits/AUDIT-LOG.md` |
| How to challenge an idea or a diff | `keel/council/COUNCIL.md` |
| Bugs and backlog | `keel/BACKLOG.md` |
| Release notes | `keel/CHANGELOG.md` |
| What broke and why | `keel/incidents/` |
| How to run recurring ops | `keel/runbooks/` |

## Project specifics

{{PROJECT_SPECIFIC_RULES: stack, branch model, domain rules, the two or three
things a new agent always gets wrong here. Keep under 20 lines. Link to longer
docs instead of inlining them.}}
````

### 3.2 `keel/config.sh`

```sh
# Keel hook configuration. Sourced by every hook. Plain sh, no bashisms.

# Branches that require Gate 2 PROCEED in the audit entry before push.
KEEL_PROTECTED_BRANCHES="main"

# Branches that require an audit entry and a STATE.md update before push.
KEEL_AUDITED_BRANCHES="main develop"

# Files matching this (grep -E) count as code. Code changes need a scenario.
KEEL_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'

# Fixes touching these need Gate 2 even on non-protected branches (advisory:
# the hook warns, the council protocol requires it).
KEEL_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'

# Commands run by pre-push on every branch. Empty string = skip.
KEEL_CHECK_1="{{e.g. npx tsc --noEmit}}"
KEEL_CHECK_2=""
KEEL_CHECK_3=""

# Forbid the em dash (U+2014) in added lines and commit messages. 1 = on.
KEEL_FORBID_EMDASH=1
```

### 3.3 `keel/STATE.md`

```markdown
# State

_Rewritten at the end of every session. Last updated: {{YYYY-MM-DD}} by {{agent or owner}}._

## Now
- Branch: `{{branch}}` at `{{short sha}}`. Production: `{{version or sha}}` live since {{date}}.
- Pending migrations: {{none | list with target env}}
- Env drift: {{none | which secrets or settings differ between envs}}

## In flight
- {{F-0001 slug}}: {{one line, which phase of the lifecycle}}

## Next (max 3, in order)
1. {{item, with ID}}
2. {{item}}
3. {{item}}

## Blocked
- {{item}}: blocked on {{what, who, since date}}

## Last session
{{Three to six lines: what was done, what was decided (IDs), what was left half
finished and where exactly.}}
```

### 3.4 `keel/BACKLOG.md`

```markdown
# Backlog

Priorities: P0 breaks production or loses data. P1 wrong for a real user.
P2 confusing or slow. P3 nice to have. Every item has an ID, a date found,
and where it came from (audit, council, outcome review, incident, owner).

## P0
- [ ] B-001 {{title}} ({{date}}, from {{source}}). {{one line}}. File: `{{path}}`

## P1

## P2

## P3

## Parked (read the note before touching)
- B-0xx {{title}}: parked because {{reason}}. Revisit when {{trigger}}.

## Done (move here with the closing commit or release)
```

### 3.5 `keel/CHANGELOG.md`

```markdown
# Changelog

One entry per production release. User-facing first, then internal. Link the
audit entry and the feature folders.

## {{v0.0.0}} ({{YYYY-MM-DD}})
Audit: A-0001. Features: F-0001.
- {{user-facing change}}
- Internal: {{change}}
```

### 3.6 `keel/decisions/INDEX.md`

```markdown
# Decisions index

One line per decision. Status: proposed | accepted | superseded by D-xxxx.
Grep this file before proposing anything.

| ID | Date | Title | Status | Tags |
|---|---|---|---|---|
| D-0001 | {{date}} | {{title}} | accepted | {{area, area}} |
```

### 3.7 `keel/templates/DECISION.md`

```markdown
# D-{{0001}}: {{title}}

Date: {{YYYY-MM-DD}}
Status: proposed | accepted | superseded by D-xxxx
Feature: F-xxxx or none
Tags: {{area}}, {{area}}

## Context
{{What situation forced a choice. Two to five lines. Link constraints C-xxx
and assumptions AS-xxx that apply.}}

## Options considered
1. **{{Option A}}**: {{one line}}. Rejected because {{reason}}.
2. **{{Option B}}**: {{one line}}. Chosen.
3. **{{Option C}}**: {{one line}}. Rejected because {{reason}}.

## Decision
{{One paragraph. What we will do.}}

## Consequences
- {{What becomes easier}}
- {{What becomes harder or is now owed}}

## Revisit when
{{A concrete trigger: a number crossed, a vendor change, a date. "Never" is a
valid answer. "Later" is not.}}

## Evidence
{{Links to council verdicts, measurements, external docs, incident IDs.}}
```

### 3.8 `keel/knowledge/CONSTRAINTS.md`

```markdown
# Constraints

Real-world facts and hard limits already learned. Each has evidence and a
date. Agents read this before designing anything that touches the area.
Never delete: mark `expired` with a date and reason.

| ID | Area | Constraint | Evidence | Learned | Status |
|---|---|---|---|---|---|
| C-001 | {{infra}} | {{e.g. Hosting plan allows 2 cron jobs}} | {{link or how we found out}} | {{date}} | active |
```

### 3.9 `keel/knowledge/ASSUMPTIONS.md`

```markdown
# Assumptions ledger

Things we believe but have not proven. A feature brief must list the
assumptions it depends on. Status moves unverified -> verified | false.
False assumptions get a line in REJECTED.md or a new decision.

| ID | Assumption | Depends | How to verify | Status | Checked |
|---|---|---|---|---|---|
| AS-001 | {{e.g. Most users open the app from a push notification}} | F-0002 | {{analytics query or user interview}} | unverified | |
```

### 3.10 `keel/knowledge/REJECTED.md`

```markdown
# Rejected ideas

Append-only. Before proposing a feature or approach, grep here. If it is
listed, cite the ID and either drop it or bring the new evidence the
"Revisit when" line asks for.

## R-001 {{Idea in five words}}
Date: {{YYYY-MM-DD}}. Proposed by: {{who}}. Decided in: D-xxxx or COUNCIL F-xxxx.
Why not: {{two lines max}}
Revisit when: {{concrete trigger}}
```

### 3.11 `keel/templates/BRIEF.md`

```markdown
# F-{{0001}}: {{title}}

Date: {{YYYY-MM-DD}}. Owner: {{name}}. Status: brief | gate-1 | building | gate-2 | shipped | reviewed | killed

## Problem
{{Two to four lines. What goes wrong for whom, today. No solution words.}}

## Who and when
Persona: P-{{NAME}} (see `keel/scenarios/PERSONAS.md`).
Moment: {{the exact real-world moment this is used: time, place, device, state of mind}}

## The one scenario
{{Given / When / Then, in the persona's own words. If you cannot write this,
the feature is not ready for Gate 1.}}

## Prior art in this repo
Decisions: {{D-xxxx, D-xxxx or "none found, searched for: keywords"}}
Rejected: {{R-xxx or "none found"}}
Constraints that apply: {{C-xxx}}
Assumptions this depends on: {{AS-xxx, with status}}

## Non-goals
- {{what this deliberately does not do}}

## Success metric
{{One number, where it is measured, current value, target, by when.}}

## Kill criteria
{{What result at the outcome review means we remove or rework it.}}

## Cost check
Compute / API / SMS / storage per use: {{estimate}}. Monthly at 10x current usage: {{estimate}}.

## Rollback
{{How to turn it off or revert. Feature flag, revert commit, migration down.}}

## Scenarios to add
{{SC-IDs to create before code is written.}}
```

### 3.12 `keel/council/COUNCIL.md`

```markdown
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
```

### 3.13 `keel/templates/COUNCIL.md`

```markdown
# Council: F-{{0001}} Gate {{1|2}}

Date: {{YYYY-MM-DD}}. Input: {{BRIEF.md | diff range sha..sha}}. Chair: {{agent}}.

## User
{{<=150 words. Specific line or step where the persona fails.}}
Severity: low | medium | high

## Adversary
{{<=150 words}}
Severity:

## Operator
{{<=150 words}}
Severity:

## Skeptic
{{<=150 words. Cite D-/R- IDs.}}
Severity:

## Domain
{{<=150 words}}
Severity:

## Pre-mortem (Gate 1 only)
- User:
- Adversary:
- Operator:
- Skeptic:
- Domain:

## Chair synthesis
{{<=200 words}}

Verdict: PROCEED | PROCEED WITH CHANGES | REWORK | REJECT

## Required changes
- [ ] 1. {{change}} (done in {{sha}})
- [ ] 2. {{change}}

## Decisions to record
- D-xxxx: {{title}}
## Rejected to record
- R-xxx: {{idea}}
## Constraints or assumptions learned
- C-xxx / AS-xxx: {{fact}}
```

### 3.14 Council personas

`keel/council/personas/user.md`
```markdown
# Voice: User

You are the persona named in the brief, on the worst device and network
listed for them in `keel/scenarios/PERSONAS.md`, at the worst realistic
moment. You are not technical. You do not read instructions. You will give
up after the second confusing screen.

Walk the scenario step by step. At each step say what you see, what you tap,
what you expect. Stop at the first place you would give up or get the wrong
outcome. Name the file or screen. Say what would have kept you going.
```

`keel/council/personas/adversary.md`
```markdown
# Voice: Adversary

You want to abuse this for money, spite, or curiosity, cheaply. Look for:
unauthenticated or under-authenticated endpoints, inputs without bounds,
rate limits keyed on something shared (IP behind carrier NAT), personal data
in URLs, push bodies, logs or public pages, account linking without
verification, replay of old sessions, state changes without ownership checks.

Give the cheapest attack first. Name the file and line. Say what one change
closes it.
```

`keel/council/personas/operator.md`
```markdown
# Voice: Operator

You run this in production on a small budget and you get the page at 3 am.
Ask: what does one use cost (compute, third-party API, SMS, storage)? What
does it cost at ten times today's usage? What new background work, cron,
connection, or long-lived process appears? What is the rollback? Which
runbook must exist before ship? What metric tells us it is broken before a
user does?

Cite `keel/knowledge/CONSTRAINTS.md` where a known limit applies.
```

`keel/council/personas/skeptic.md`
```markdown
# Voice: Skeptic

You have seen this idea before. Grep `keel/decisions/INDEX.md` and
`keel/knowledge/REJECTED.md` and quote anything that applies. Ask: what
happens if we do nothing? What is the simplest change that gets most of the
value? Which non-goal is this quietly violating? Is the success metric
measurable with what exists today? What would make us remove this in 90
days?

You are allowed to say the feature should not be built. You must then say
what should be built instead, or nothing.
```

`keel/council/personas/domain.md`
```markdown
# Voice: Domain

{{PROJECT: replace this paragraph with the domain this project lives in:
the laws, regulators, industry standards, and the incumbents users compare
against. Example for a health app in India: NBTC guidelines, DPDP Act 2023,
TRAI DLT rules for SMS, what eRaktKosh does.}}

Ask: which rule does this touch? Is the copy accurate to the standard? What
would a professional in this domain find wrong or embarrassing? What does
the incumbent do, and why might they be right?
```

### 3.15 `keel/scenarios/PERSONAS.md`

```markdown
# Personas

Real actors, not marketing segments. Each has a device, a network, a moment,
and a state of mind. Scenarios and council verdicts reference these IDs.

## P-{{NAME}}
Who: {{one line}}
Device: {{e.g. 3 year old Android, 2 GB RAM, Chrome, battery saver on}}
Network: {{e.g. 4G with drops, shared carrier IP}}
Moment: {{e.g. 2 am, hospital corridor, panicking}}
Knows: {{what they already understand}}
Does not know: {{what they will not read or figure out}}
Gives up when: {{the specific friction that ends the session}}
```

### 3.16 `keel/scenarios/SCENARIOS.md`

```markdown
# Scenarios

What must keep working, written as Given / When / Then against a persona.
Every code change adds or updates one. Status is the last real run, with
date and how (manual on device, automated test, reasoning only).

IDs: SC-AREA-000. Areas are short caps (AUTH, REQ, NOTIF, PAY, ADMIN).

## Coverage map
| Code path | Scenarios |
|---|---|
| `{{path}}` | SC-AREA-001, SC-AREA-002 |

## Scenarios

### SC-{{AREA}}-001 {{title}}
Persona: P-{{NAME}}
Given {{state}}
When {{action, including the bad conditions}}
Then {{observable outcome}}
Also check: {{the failure branch: timeout, double tap, back button, stale tab}}
Status: pass {{date}} ({{how}}) | fail {{date}} | untested
Covers: `{{path}}`
```

### 3.17 `keel/templates/SCENARIO.md`

```markdown
### SC-{{AREA}}-{{000}} {{title}}
Persona: P-{{NAME}}
Given {{state}}
When {{action}}
Then {{outcome}}
Also check: {{failure branch}}
Status: untested
Covers: `{{path}}`
```

### 3.18 `keel/audits/AUDIT-LOG.md`

```markdown
# Audit log

Append-only. One entry per push to an audited branch. The pre-push hook
reads the last entry. Write it as the final commit before pushing, tagged
`[keel]`.

Evidence means the command and what it printed, not an adjective.

## A-0001 {{YYYY-MM-DDThh:mm+05:30}}
Branch: {{main | develop}}
Range: {{remote sha}}..{{local sha}}
Feature: {{F-0001 | fix | chore}}
Gate 2: {{PROCEED | PROCEED WITH CHANGES | N/A}} ({{link COUNCIL-2.md or "not required on this branch"}})
Checks:
- `{{npx tsc --noEmit}}`: {{0 errors}}
- `{{next build}}`: {{ok, largest route 143 kB}}
- Scenarios run: {{SC-REQ-012 pass manual Android Chrome 2026-09-11, SC-REQ-013 reasoning only}}
Migrations: {{none | file, applied to which env on which date, prod pending yes/no}}
Rollback: {{git revert sha | redeploy previous | flag off}}
Risk: {{low | medium | high}}: {{one line why}}
Pushed by: {{agent name}} with approval from {{owner}} at {{time}}
```

### 3.19 `keel/templates/AUDIT.md`

```markdown
## A-{{0000}} {{YYYY-MM-DDThh:mm+05:30}}
Branch:
Range:
Feature:
Gate 2:
Checks:
- ``:
Scenarios run:
Migrations:
Rollback:
Risk:
Pushed by:
```

### 3.20 `keel/templates/OUTCOME.md`

```markdown
# Outcome: F-{{0001}}

Shipped: {{date}} in {{version}}. Reviewed: {{date, target +14 days}}.

## Metric
Brief said: {{metric, target}}. Actual: {{value, where measured}}.

## What happened
{{Three to six lines. Usage, support messages, incidents, surprises.}}

## Kill criteria met?
{{yes | no | partly}}. Action: keep | rework (F-xxxx) | remove (D-xxxx).

## Learned
- Constraint: C-xxx {{new fact}}
- Assumption AS-xxx: verified | false
- Rejected: R-xxx {{if the approach should not be tried again}}
```

### 3.21 `keel/templates/INCIDENT.md`

```markdown
# INC-{{0001}}: {{title}}

Date: {{YYYY-MM-DD}}. Detected: {{how, by whom, at what time}}. Duration: {{}}.
Severity: P0 | P1 | P2. Users affected: {{number or description}}.

## Timeline (absolute times)
- {{hh:mm}} {{event}}

## Root cause
{{The mechanism, not the symptom. Name file and line.}}

## Why it was not caught
{{Which scenario was missing or wrong. Which council question was skipped.}}

## Fix
{{Commit, audit entry A-xxxx.}}

## Prevention
- Scenario added: SC-xxx
- Constraint recorded: C-xxx
- Runbook: `keel/runbooks/{{name}}.md`
```

### 3.22 `keel/runbooks/README.md`

```markdown
# Runbooks

One file per recurring operational task. Written so a tired person at 3 am
can follow it without thinking. Every runbook has: when to use, exact
commands, expected output, what to do if the output differs, who to tell.

- {{`deploy-rollback.md`}}
- {{`apply-migration.md`}}
- {{`rotate-secret.md`}}
```

### 3.23 Hooks

`keel/hooks/install.sh`
```sh
#!/bin/sh
# Point git at Keel's hooks. Idempotent. Run from anywhere inside the repo.
set -e
ROOT=$(git rev-parse --show-toplevel)
chmod +x "$ROOT"/keel/hooks/pre-commit "$ROOT"/keel/hooks/commit-msg "$ROOT"/keel/hooks/pre-push
git config core.hooksPath keel/hooks
echo "keel: hooks installed (core.hooksPath = keel/hooks)"
echo "keel: if this repo had other hooks, chain them from keel/hooks/* (see KEEL_BOOTSTRAP section 7.3)"
```

`keel/hooks/pre-commit`
```sh
#!/bin/sh
# Keel pre-commit: forbidden patterns in added lines, scenario coverage for code.
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/keel/config.sh"

STAGED=$(git diff --cached --name-only --diff-filter=ACMR)
[ -z "$STAGED" ] && exit 0

# 1. Em dash in added lines.
if [ "$KEEL_FORBID_EMDASH" = "1" ]; then
  EMDASH=$(printf '\342\200\224')
  if git diff --cached -U0 -- . ':(exclude)*.png' ':(exclude)*.jpg' ':(exclude)*.ico' | grep '^+' | grep -v '^+++' | grep -q "$EMDASH"; then
    echo "keel: em dash (U+2014) found in added lines. Use a hyphen, colon or comma." >&2
    git diff --cached -U0 | grep -n '^+' | grep "$EMDASH" | head -5 >&2
    exit 1
  fi
fi

# 2. Code changed => SCENARIOS.md must be staged too, unless waived.
if printf '%s\n' "$STAGED" | grep -qE "$KEEL_CODE_PATTERN"; then
  if ! printf '%s\n' "$STAGED" | grep -q '^keel/scenarios/SCENARIOS.md$'; then
    if [ "$KEEL_WAIVE_SCENARIOS" != "1" ]; then
      echo "keel: code changed but keel/scenarios/SCENARIOS.md is not staged." >&2
      echo "keel: add or update a scenario, or waive with:" >&2
      echo "keel:   KEEL_WAIVE_SCENARIOS=1 git commit ...   (and put a 'Waiver: <reason>' line in the body)" >&2
      exit 1
    fi
  fi
fi

# 3. Critical path touched: advisory reminder that Gate 2 is required.
if printf '%s\n' "$STAGED" | grep -qE "$KEEL_CRITICAL_PATTERN"; then
  echo "keel: critical path touched. Gate 2 council is required before push (see keel/council/COUNCIL.md)." >&2
fi

exit 0
```

`keel/hooks/commit-msg`
```sh
#!/bin/sh
# Keel commit-msg: tag required; feature commits need a Gate 1 verdict; waivers need a reason.
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/keel/config.sh"
MSG=$(sed -e '/^#/d' "$1")

TAG=$(printf '%s\n' "$MSG" | grep -oE '\[(F-[0-9]{4}|fix|hotfix|chore|docs|keel)\]' | head -1)
if [ -z "$TAG" ]; then
  echo "keel: commit message needs a tag: [F-0001] [fix] [hotfix] [chore] [docs] [keel]" >&2
  exit 1
fi

case "$TAG" in
  \[F-*)
    ID=$(printf '%s' "$TAG" | tr -d '[]')
    DIR=$(ls -d "$ROOT"/keel/features/"$ID"* 2>/dev/null | head -1)
    if [ -z "$DIR" ] || [ ! -f "$DIR/BRIEF.md" ]; then
      echo "keel: no keel/features/$ID-*/BRIEF.md. Write the brief first." >&2
      exit 1
    fi
    if ! grep -qE '^Verdict: PROCEED' "$DIR/COUNCIL-1.md" 2>/dev/null; then
      echo "keel: $ID has no 'Verdict: PROCEED' in COUNCIL-1.md. Run Gate 1 first." >&2
      exit 1
    fi
    ;;
esac

if [ "$KEEL_WAIVE_SCENARIOS" = "1" ]; then
  if ! printf '%s\n' "$MSG" | grep -qE '^Waiver: .{10,}'; then
    echo "keel: scenario waiver used but no 'Waiver: <reason>' line (10+ chars) in the commit body." >&2
    exit 1
  fi
fi

if [ "$KEEL_FORBID_EMDASH" = "1" ]; then
  if printf '%s\n' "$MSG" | grep -q "$(printf '\342\200\224')"; then
    echo "keel: em dash in commit message." >&2
    exit 1
  fi
fi

exit 0
```

`keel/hooks/pre-push`
```sh
#!/bin/sh
# Keel pre-push: audit entry + STATE.md for audited branches, Gate 2 for protected, checks everywhere.
# stdin lines: <local ref> <local sha> <remote ref> <remote sha>
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/keel/config.sh"
REMOTE_NAME=$1
ZERO=0000000000000000000000000000000000000000
FAIL=0

in_list() { for x in $2; do [ "$1" = "$x" ] && return 0; done; return 1; }

while read -r local_ref local_sha remote_ref remote_sha; do
  [ "$local_sha" = "$ZERO" ] && continue   # deleting a branch
  branch=${remote_ref#refs/heads/}

  # Files touched by the commits being pushed. For a branch that is new on the
  # remote, take every local commit not already on any of that remote's refs.
  if [ "$remote_sha" = "$ZERO" ]; then
    range="$local_sha (not yet on $REMOTE_NAME)"
    CHANGED=$(git log --name-only --pretty=format: "$local_sha" --not --remotes="$REMOTE_NAME" 2>/dev/null)
  else
    range="$remote_sha..$local_sha"
    CHANGED=$(git log --name-only --pretty=format: "$range" 2>/dev/null)
  fi

  if in_list "$branch" "$KEEL_AUDITED_BRANCHES"; then
    if ! printf '%s\n' "$CHANGED" | grep -q '^keel/audits/AUDIT-LOG.md$'; then
      echo "keel: push to '$branch' has no new entry in keel/audits/AUDIT-LOG.md in $range" >&2; FAIL=1
    fi
    if ! printf '%s\n' "$CHANGED" | grep -q '^keel/STATE.md$'; then
      echo "keel: push to '$branch' does not update keel/STATE.md in $range" >&2; FAIL=1
    fi
    LAST=$(awk '/^## A-/{b=""} {b=b $0 "\n"} END{printf "%s", b}' "$ROOT/keel/audits/AUDIT-LOG.md")
    if ! printf '%s' "$LAST" | grep -q "^Branch: $branch"; then
      echo "keel: last audit entry is not for branch '$branch'" >&2; FAIL=1
    fi
    if in_list "$branch" "$KEEL_PROTECTED_BRANCHES"; then
      if ! printf '%s' "$LAST" | grep -qE '^Gate 2: PROCEED'; then
        echo "keel: '$branch' is protected and the last audit entry lacks 'Gate 2: PROCEED'" >&2; FAIL=1
      fi
    fi
  fi
done

[ "$FAIL" = "1" ] && exit 1

for c in "$KEEL_CHECK_1" "$KEEL_CHECK_2" "$KEEL_CHECK_3"; do
  [ -z "$c" ] && continue
  echo "keel: running: $c"
  if ! sh -c "$c"; then
    echo "keel: check failed: $c" >&2
    exit 1
  fi
done

exit 0
```

---

## 4. Workflow in detail

### 4.1 Intake (10 minutes, before any code)

1. Write the idea in one sentence.
2. Grep `keel/decisions/INDEX.md`, `keel/knowledge/REJECTED.md`,
   `keel/BACKLOG.md` for its keywords. Quote hits.
3. Pick the persona from `PERSONAS.md`. If none fits, write one first.
4. Create `keel/features/F-xxxx-slug/BRIEF.md` from the template. The "one
   scenario" section is the test: if it cannot be written in the persona's
   words, stop.
5. List assumptions in `ASSUMPTIONS.md` with IDs and reference them.

### 4.2 Gate 1

Run the council per `COUNCIL.md`. Write `COUNCIL-1.md`. Record every
decision as a `D-` file and index line, every rejection as `R-`. Tick the
required changes into the brief. Only then start code.

### 4.3 Build

1. Add scenario stubs to `SCENARIOS.md` with `Status: untested`.
2. Code. Commit small, every message tagged `[F-xxxx]`.
3. When a scenario is actually exercised (device, test, or careful reasoning),
   update its status line with date and method.
4. Log decisions the moment they happen. A decision made in a chat and not
   written down does not exist.

### 4.4 Gate 2

Run the council on the diff range. Write `COUNCIL-2.md`. Fix required
changes, tick them with commit references.

### 4.5 Audit and push

1. Update `STATE.md`.
2. Append the audit entry to `AUDIT-LOG.md` with real command output.
3. Commit `[keel] audit A-xxxx for F-xxxx`.
4. Stop. Show the owner the audit entry. Push only on explicit approval for
   this push. Earlier approvals do not carry over.

### 4.6 Outcome review

Fourteen days after the production release, write `OUTCOME.md`. Move learned
facts into `CONSTRAINTS.md`, flip assumptions, add `R-` entries for
approaches that should not be repeated. Update `BACKLOG.md`.

### 4.7 Bug fixes

`[fix]`: scenario required, audit entry required for audited branches, Gate 2
required if `KEEL_CRITICAL_PATTERN` is touched. `[hotfix]` on production:
same, and an `INC-` file within 24 hours.

### 4.8 Brainstorming sessions (owner and agent, no code)

Structure that produces decisions instead of chat:

1. **Problem first** (5 min): one paragraph, no solution words.
2. **Persona walk** (10 min): the agent narrates the persona living the
   problem today, step by step. Owner corrects the narration. This surfaces
   what the owner knows and the agent does not.
3. **Constraints check** (2 min): read `CONSTRAINTS.md` entries for the area
   aloud.
4. **Three options** (10 min): agent proposes three, including "do nothing"
   and "the simplest possible". One line each with cost and risk.
5. **Gate 1 lite** (10 min): Skeptic and User voices only.
6. **Write it down** (5 min): brief or `R-` entry or `D-` record. A session
   that ends without a file is a session to repeat later.

---

## 5. Logging rules

- **IDs are permanent.** Never renumber, never reuse.
- **Absolute dates**, ISO, with timezone on timestamps.
- **Append-only** for `AUDIT-LOG.md`, `REJECTED.md`, incidents, decision
  records. Supersede, do not edit.
- **Index lines are one line.** `INDEX.md`, `BACKLOG.md` items, coverage
  map rows. Detail lives in the linked file.
- **Evidence over adjectives.** "tsc: 0 errors" not "types are fine".
- **Link, do not copy.** A brief links a decision by ID. It does not restate it.
- **Compaction**: `STATE.md` is rewritten, not appended. Once a year, move
  `AUDIT-LOG.md` entries older than twelve months to
  `keel/audits/archive/AUDIT-LOG-YYYY.md`. Same for `CHANGELOG.md`.
- **Token budget**: `KEEL.md` under 120 lines, `STATE.md` under 60, a brief
  under 120, a council verdict under 150. If a file grows past that, split
  or link.

---

## 6. What counts as a decision

Record a `D-` when any of these happen:

- Two or more viable options existed and one was chosen.
- A default was changed (timeout, limit, threshold, retention period).
- A dependency, vendor, or service was added or removed.
- A rule in `KEEL.md` or `config.sh` changed.
- The owner said "let's not do that" about something plausible (that is an
  `R-`, plus a `D-` if a replacement was chosen).
- A council verdict demanded a change of approach.

Do not record: formatting choices, variable names, anything reversible in
under ten minutes with no downstream effect.

---

## 7. Hooks: behaviour and edge cases

### 7.1 What each hook blocks

| Hook | Blocks when |
|---|---|
| pre-commit | em dash in added lines (if enabled); code changed without `SCENARIOS.md` staged and no waiver |
| commit-msg | no tag; `[F-xxxx]` without brief or Gate 1 PROCEED; waiver without reason; em dash in message |
| pre-push | audited branch without new audit entry or `STATE.md` change in the pushed range; last audit entry for a different branch; protected branch without `Gate 2: PROCEED`; any `KEEL_CHECK_n` failing |

Note on protected branches: the pushed range is "commits not yet on the
remote". A fast-forward of `develop` onto `main` therefore contains no new
commits and is blocked until an audit commit is made on `main` itself. That
is intended: every production push gets its own entry with `Gate 2: PROCEED`.

Verified 2026-09-11 in a throwaway repo (Git for Windows, sh): untagged
commit blocked; `[F-xxxx]` without brief blocked; with `Verdict: REWORK`
blocked; with `Verdict: PROCEED WITH CHANGES` allowed; code without
`SCENARIOS.md` blocked; em dash in added line blocked; waiver without
`Waiver:` line blocked, with reason allowed; first push to a new remote
branch without audit blocked, with audit allowed; second push without a new
entry blocked; push to `main` with last entry for `develop` blocked; with
`Gate 2: REWORK` blocked; with `Gate 2: PROCEED` allowed; failing
`KEEL_CHECK_1` blocked.

### 7.2 Bypass

`git commit --no-verify` and `git push --no-verify` exist. Keel does not try
to prevent them. Using one is itself a decision: record a `D-` or an `R-`
line saying why. Agents must never bypass without the owner's explicit
instruction for that specific commit or push.

### 7.3 Existing hooks

If the repo already has `core.hooksPath` set (for example `.githooks`), do
not overwrite. Either move the existing scripts' logic into Keel's hooks, or
make Keel's hooks call the old ones at the end:
```sh
[ -x "$ROOT/.githooks/pre-commit" ] && exec "$ROOT/.githooks/pre-commit" "$@"
```
Record the choice as a `D-`.

### 7.4 Windows

Hooks are POSIX sh and run under Git for Windows' bundled shell. Line endings
must be LF. If a hook fails with "bad interpreter", run
`git config core.autocrlf false` for the repo and re-save the hook files.

---

## 8. Optional: Claude Code skills

If the owner uses Claude Code, create these so the workflow is one slash
command away. Each is a folder `.claude/skills/<name>/SKILL.md`. Other
agents ignore them.

`.claude/skills/keel-brief/SKILL.md`
```markdown
---
name: keel-brief
description: Start a feature the Keel way. Greps decisions and rejected ideas, picks a persona, writes keel/features/F-xxxx-slug/BRIEF.md from the template, and lists assumptions. Use when the user says "new feature", "let's build", "brief this", or /keel-brief.
---
Read KEEL.md and keel/STATE.md. Take the idea from the user's message.
1. Grep keel/decisions/INDEX.md, keel/knowledge/REJECTED.md, keel/BACKLOG.md for the idea's keywords. Quote every hit with its ID before anything else.
2. Pick the next free F- number from keel/features/. Pick a persona from keel/scenarios/PERSONAS.md or propose a new one.
3. Write BRIEF.md from keel/templates/BRIEF.md. Do not leave placeholders; ask the user for anything you cannot infer.
4. Add assumptions to keel/knowledge/ASSUMPTIONS.md with IDs and reference them in the brief.
5. Stop and show the brief. Do not write code. Suggest /keel-council 1.
```

`.claude/skills/keel-council/SKILL.md`
```markdown
---
name: keel-council
description: Run the Keel council on a feature. Argument "1" runs Gate 1 on the brief, "2" runs Gate 2 on the diff. Plays the five voices from keel/council/personas, writes COUNCIL-1.md or COUNCIL-2.md with a Verdict line. Use for /keel-council, "challenge this", "council", "gate 1", "gate 2".
---
Read keel/council/COUNCIL.md fully. Identify the feature (argument or the in-flight item in keel/STATE.md).
Gate 1: input is BRIEF.md. Gate 2: input is the diff since the branch point plus BRIEF.md and COUNCIL-1.md (verify every Gate 1 checkbox first).
Read keel/knowledge/CONSTRAINTS.md and keel/knowledge/REJECTED.md before speaking.
If subagents are available, run the five voices in parallel, each with its persona file, the input, and the mandatory questions; then synthesise. Otherwise play them in sequence. Respect the word caps.
Write the verdict file from keel/templates/COUNCIL.md. The Verdict line must be one of the four exact strings. List required changes as checkboxes. List decisions and rejections to record, then record them (/keel-decide).
```

`.claude/skills/keel-decide/SKILL.md`
```markdown
---
name: keel-decide
description: Record a decision or a rejection in Keel. Writes keel/decisions/D-xxxx-slug.md plus its INDEX.md line, or appends an R- entry to keel/knowledge/REJECTED.md. Use when a choice was just made, when the user says "let's go with", "we won't do", "decide", or /keel-decide.
---
Determine whether this is a decision (something chosen) or a rejection (something declined with no replacement). Grep INDEX.md and REJECTED.md for prior entries on the topic; if one exists, the new record must reference it and, for decisions, mark the old one superseded.
Decision: next free D- number, file from keel/templates/DECISION.md, all sections filled including "Revisit when" as a concrete trigger. Add the INDEX.md line.
Rejection: next free R- number appended to REJECTED.md with why and a revisit trigger.
Never edit an existing record. Show the file and stop.
```

`.claude/skills/keel-scenario/SKILL.md`
```markdown
---
name: keel-scenario
description: Add or update scenarios in keel/scenarios/SCENARIOS.md for the code being changed. Picks the area prefix and next ID, writes Given/When/Then against a persona including the failure branch, updates the coverage map. Use before committing code, or on /keel-scenario, "add scenario", "what should we test".
---
Look at the staged or described change. For each behaviour that a real persona would notice, write one scenario from keel/templates/SCENARIO.md with the next free ID in the right area. Always include the "Also check" failure branch (timeout, double tap, back button, stale tab, offline). Add the code path to the coverage map. Set Status to untested unless you actually exercised it, in which case record date and method.
```

`.claude/skills/keel-audit/SKILL.md`
```markdown
---
name: keel-audit
description: Prepare a push the Keel way. Runs the configured checks, collects real output, updates keel/STATE.md, appends an A- entry to keel/audits/AUDIT-LOG.md, commits as [keel], then stops and asks for push approval. Use for /keel-audit, "prepare push", "ready to push", "audit this".
---
Read keel/config.sh for the target branch rules. Determine the push range (remote branch tip to HEAD).
Run KEEL_CHECK_1..3 and any build command the project uses. Capture the actual output lines that matter (error counts, bundle sizes).
List scenarios touched in the range and their current Status lines.
For protected branches confirm COUNCIL-2.md exists with a PROCEED verdict; otherwise say so and stop.
Rewrite keel/STATE.md. Append the audit entry from keel/templates/AUDIT.md with the real evidence. Commit with "[keel] audit A-xxxx for <feature>".
Show the entry. Ask: "Push to <branch>? (yes/no)". Do not push without a yes in this conversation for this push.
```

`.claude/skills/keel-session/SKILL.md`
```markdown
---
name: keel-session
description: Open or close a Keel session. "open" reads KEEL.md, STATE.md and the in-flight feature and summarises in ten lines. "close" rewrites STATE.md, files unfinished findings into BACKLOG.md, and lists decisions made this session that are not yet recorded. Use at the start and end of work, or /keel-session open|close.
---
open: read KEEL.md, keel/STATE.md, and every file in the in-flight F- folder. Report in at most ten lines: where we are, what is next, what is blocked, which Gate the feature is at. Ask nothing unless STATE.md is stale by more than seven days.
close: scan the conversation for choices made and not recorded; run /keel-decide for each or list them for the user. Move any bug or gap found but not fixed into keel/BACKLOG.md with an ID, date and source. Rewrite keel/STATE.md completely. Do not commit unless asked.
```

---

## 9. Seeding an existing project

An empty Keel is a form nobody fills in. On install, spend thirty minutes
with the owner to seed:

- **Constraints (5 to 10)**: every "we found out the hard way" fact. Hosting
  limits, vendor blocks, device quirks, regulatory rules, data residency.
- **Decisions (5 to 10)**: every choice the owner has had to re-explain to an
  agent. Write them as `accepted` with today's date and "recorded
  retroactively" in Context.
- **Rejected (3 to 5)**: every idea that keeps coming back.
- **Personas (2 to 4)**: the real users, with their real devices.
- **Scenarios**: import existing test scenarios if any, keep their IDs.
- **Runbooks**: deploy, rollback, apply migration, rotate a secret.

Then write `STATE.md` and the "Project specifics" block of `KEEL.md`.

For a project with existing tracking docs (a handoff file, release notes, an
issues list), do not migrate content on day one. Map them: `KEEL.md` links
to the existing files, and new entries go to Keel. Migrate when a file is
next rewritten anyway. A worked example is in `examples/adopters/` in the Keel repository (github.com/acshriv-alt/keel).

---

## 10. Adapting Keel

Keel is a starting point. Change it through its own mechanism: a `D-` record
in the project, and a change to `KEEL.md` or `config.sh` in the same commit.
Things commonly adjusted:

- Gate 2 on every push to the working branch (stricter) or only at release
  (looser). Default: release branch only.
- A sixth council voice (Accessibility, Finance, Legal).
- Scenario waiver never allowed (remove the env check from pre-commit).
- Outcome review at +30 days for low-traffic products.

Do not remove: the search-before-propose rule, the audit entry on push, the
verdict line format. Those are what make the hooks and the habit hold.
