# Scantling: project memory, audit and challenge framework for coding agents

**You are a coding agent reading this file because a human asked you to install
Scantling in a repository.** Follow section 1 exactly. Every file you must create is
given in full in section 3. Do not improvise the structure. After install, the
repository's own `SCANTLING.md` becomes the entry point and this bootstrap file is
no longer needed.

Scantling is agent-agnostic. It is plain markdown, plain git hooks, and a small set
of habits. Optional Claude Code skills are in section 8.

Version: 2.0.0, 2026-09-14. Repository: github.com/acshriv-alt/scantling. The same files exist as a copyable tree under `template/` in that repository.

**This project was called Keel through 1.0.0.** It was renamed in 2.0.0
because "keel" is a common English word already carrying several developer
tools, so it was neither searchable nor distinctive. A scantling is the set of
structural dimensions a hull must meet, and classification societies publish
minimum scantling requirements that a vessel is certified against before it
sails. That is what this framework is: the structural standards a repository
is certified against before it ships.

2.0.0 also exists because Keel 1.0.0 priced every change at the cost of its
most dangerous change. A first adopter measured the result after one day:
eight of ten commits carried no application code, and a council pass cost 268
times what the grep that found the same defect would have cost. Scantling now
prices ceremony by a declared risk tier, splits evidence from judgement, caps
what grows, and insists on one system of record.

See section 11 for the full change list, the rename, and how to migrate an
existing Keel 1.0 install.

---

## 0. What Scantling is for

A solo owner working with coding agents loses three things between sessions:
**context** (what is the state, what is in flight), **reasons** (why did we
decide X, why did we reject Y), and **evidence** (what was checked before a
push). Scantling keeps all three in the repo, in files small enough for an agent to
load every session, with git hooks so the habit cannot silently drift.

Six mechanisms:

| Mechanism | File(s) | Answers |
|---|---|---|
| State | `scantling/STATE.md` | Where are we right now, what next |
| Decisions and rejections | `scantling/decisions/`, `scantling/knowledge/REJECTED.md` | Why did we do X, why not Y, when to revisit |
| Knowledge | `scantling/knowledge/CONSTRAINTS.md`, `ASSUMPTIONS.md` | Real-world facts we already learned, guesses we still owe proof for |
| Risk tier | the `Tier:` line in every commit | How dangerous is this change, claimed by a name, on the record |
| Council | `scantling/council/`, per-feature `EVIDENCE.md`, `COUNCIL-1.md`, `COUNCIL-2.md` | What the repository actually contains, who challenged it, and what they demanded |
| Scenarios and audit | `scantling/scenarios/`, `scantling/audits/AUDIT-LOG.md` | What real situations the code must survive, what was verified before each push |

Two-tier loading keeps tokens low: `SCANTLING.md` at the repo root is under 120
lines and is read every session. Everything else is read on demand.

### The cost principle

Scantling's value concentrates in decisions that are expensive to reverse. If its
cost is spread flat across everything, the cost exceeds the value on most
changes, and the rational move becomes routing work around the process:
batching unrelated fixes to amortise ceremony, mislabelling features to skip a
gate, not recording small decisions because recording costs more than the
decision did. Every one of those destroys the audit trail Scantling exists to
produce.

So ceremony is priced to risk, and the price is set by a claim the author
makes and signs, not by a regex over file paths. A regex knows where a change
landed. It cannot know the blast radius. Dropping a table nothing reads and
altering a column live rows depend on are both `db/`.

The two rules that follow from this, and that the rest of the framework
implements:

1. **The author declares the tier; the path only sets a floor.** Going below
   the floor is allowed and costs one line of evidence, which is auditable
   later. Inference is not auditable.
2. **Evidence is gathered once, cheaply; judgement is what gets repeated.**
   Five voices reasoning independently is the point. Five voices independently
   reading the same files is waste that recurs on every gate forever.

---

## 1. Install steps (agent, do these in order)

1. Confirm you are at the repository root and on a non-production branch.
2. Create every file in section 3 at the path shown. Copy content verbatim,
   then fill placeholders written as `{{LIKE_THIS}}`. Ask the owner for any
   placeholder you cannot infer from the repo.
3. Make hooks executable and point git at them:
   ```sh
   chmod +x scantling/hooks/*
   sh scantling/hooks/install.sh
   ```
   If the repo already uses `core.hooksPath` or has hooks in `.git/hooks`,
   read section 7.3 before running install.
4. If a `CLAUDE.md`, `AGENTS.md`, `.cursorrules` or similar agent-instruction
   file exists, add this line near the top:
   `Read SCANTLING.md first. It is the entry point for state, decisions and the push gates.`
   If none exists, create `AGENTS.md` containing only that line.
5. **Settle the system of record (do not skip this, it is the expensive one).**
   List every file in the repo that already tracks state, decisions, issues,
   releases or standards: a handoff file, `ISSUES.md`, `RELEASES.md`,
   `CODING_STANDARDS.md`, a design system doc, a project wiki page. For each,
   write one of three dispositions into `scantling/knowledge/SOURCES.md`
   (section 3.24):
   - **replaced**: Scantling now owns this. Move the live content across now, stamp
     the old file with the archive banner given in section 3.24, and add it to
     `SCANTLING_ARCHIVED_PATTERN` in `scantling/config.sh` so the hook refuses edits.
     The freezing commit is the one commit that has to touch the file after
     the pattern covers it, so make it:
     `SCANTLING_ARCHIVE_STAMP=1 git commit ...`. Every later edit is refused,
     which is the point.
   - **kept**: Scantling does not cover it (API reference, design tokens, a
     runbook that is fine where it is). Say what it owns, and make sure Scantling
     never writes the same fact.
   - **deferred**: too big to move today. Name the date and the trigger. A
     deferred file is a known cost, not a default.

   Then grep the agent-instruction file from step 4 for references to any
   replaced file and fix them. An instruction pointing at a frozen file is
   how a half-migration starts telling agents to write to the wrong place.

   Running two systems of record is the most expensive state available. Every
   fact costs two writes, the two drift, and an agent reading one gets a stale
   answer. If an owner wants no migration at all, that is a legitimate choice:
   record it as a `D-` and restrict Scantling to the mechanisms the old files do
   not cover. What is not legitimate is leaving it unstated.
6. Seed the knowledge files (section 9): ask the owner for the five to ten
   real-world constraints already known, and for every past decision they
   remember re-explaining. Write them now. An empty Scantling is worth little.
7. Set the scenario areas: fill `scantling/scenarios/AREAS.map` with one line per
   area of the codebase, so the hook can ask for the one area file a change
   touches instead of a single growing corpus.
8. Write the first `scantling/STATE.md` from the current repo and branch state.
   It has a 400 word cap and the hook enforces it.
9. Run `git add scantling SCANTLING.md AGENTS.md` (or the file edited in step 4), then
   commit with message `[scantling] install Scantling v1.1` and a `Tier: trivial` line
   in the body.
10. Stop. Report what was created, what placeholders remain, and every file
    marked **deferred** in step 5. Do not push.

---

## 2. File tree after install

```
SCANTLING.md                              entry point, always loaded, < 120 lines
scantling/
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
    SOURCES.md                       every older tracking file and its disposition
  features/
    F-0001-slug/
      BRIEF.md                       problem, persona, scenario, non-goals, metric, kill criteria
      EVIDENCE.md                    one cheap pass: commands and their output, no judgement
      COUNCIL-1.md                   Gate 1 verdict (idea)
      COUNCIL-2.md                   Gate 2 verdict (diff)
      OUTCOME.md                     review at +14 days
  scenarios/
    PERSONAS.md                      real actors with device, network, state of mind
    SCENARIOS.md                     index and coverage map only, not the scenarios
    AREAS.map                        plain text: area name and path pattern, read by the hook
    areas/
      AUTH.md  REQ.md  ...           the scenarios themselves, one file per area
  council/
    COUNCIL.md                       protocol, tier pricing, verdict format, token caps
    personas/
      user.md  adversary.md  operator.md  skeptic.md  domain.md
  audits/
    AUDIT-LOG.md                     append-only, one entry per push to an audited branch
    archive/
      AUDIT-LOG-v0.0.0.md            entries retired at a release, still append-only
  incidents/
    INC-0001-slug.md                 root cause analyses
  runbooks/
    README.md                        how to do recurring operational things
  templates/
    BRIEF.md  EVIDENCE.md  COUNCIL.md  DECISION.md  OUTCOME.md  INCIDENT.md  SCENARIO.md  AUDIT.md
  tools/
    ratio.sh                         Scantling's own drag gauge: process commits against code commits
  hooks/
    install.sh  pre-commit  commit-msg  pre-push
```

IDs are stable and never reused: `D-0001` decisions, `F-0001` features,
`SC-AREA-001` scenarios, `A-0001` audit entries, `INC-0001` incidents,
`P-NAME` personas, `C-001` constraints, `AS-001` assumptions, `R-001` rejected.

---

## 3. File contents

Create each file exactly as shown. Fenced blocks are the file contents.

### 3.1 `SCANTLING.md` (repo root)

````markdown
# {{PROJECT_NAME}}: Scantling entry point

Read this file at the start of every session. Then read `scantling/STATE.md`
(capped at 400 words). Then read only the **current** gate file of whatever is
in flight, not the whole feature folder: closed gates are history and stay
closed. Nothing else is loaded by default. Open other files when the work
needs them.

## Hard rules

1. **Search before you propose.** Before suggesting any design, grep
   `scantling/decisions/INDEX.md` and `scantling/knowledge/REJECTED.md` for the topic.
   If it was decided or rejected, say so and cite the ID. Reopen only with new
   evidence, recorded in a new decision that supersedes the old one.
2. **Every commit carries a tag**: `[F-0001]` for feature work, `[fix]`,
   `[hotfix]`, `[chore]`, `[docs]`, `[scantling]`. The commit-msg hook enforces it.
3. **Every commit that touches code declares a risk tier** in the body:

   ```
   Tier: trivial | standard | critical
   ```

   | Tier | Means | Costs |
   |---|---|---|
   | `trivial` | No persona sees a difference. One revert undoes it completely, with no data effect. | Nothing but the tier line |
   | `standard` | A persona notices. No irreversible data, money or auth effect. | Scenario, and Gate 1 if it is a feature |
   | `critical` | Live data, money, auth, personal data, or anything a revert does not undo. | Scenario, both gates, full council |

   The tier is a claim about **blast radius, not diff size**. Dropping a table
   no code reads is `trivial` at any line count. Altering a column live rows
   depend on is `critical` at one line.

   Paths set a floor (`scantling/config.sh`). Declaring below the floor is allowed
   and costs one line of evidence:

   ```
   Tier: trivial
   Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
   ```

   That line is the point. A regex knows where a change landed; it cannot know
   what depends on it. A signed claim with its evidence can be audited later.
   An inference cannot.
4. **Code at tier `standard` or above ships with a scenario**, in the area
   file the coverage map names (`scantling/scenarios/areas/AREA.md`). Code that
   matches no area must be mapped into `scantling/scenarios/SCENARIOS.md` in the
   same commit. Waive with `SCANTLING_WAIVE_SCENARIOS=1` plus a `Waiver:` line.
5. **Pushes to audited branches carry an audit entry** in
   `scantling/audits/AUDIT-LOG.md` and an updated `scantling/STATE.md`. Pushes to
   protected branches also need `Gate 2: PROCEED` and a `Reality-check:` line.
   The pre-push hook enforces it. Stop after committing and ask the owner
   before any push.
6. **One system of record.** Anything Scantling covers is written in `scantling/` and
   nowhere else. `scantling/knowledge/SOURCES.md` lists every older tracking file
   and whether it was replaced, kept or deferred. Archived files are never
   edited and the hook refuses to stage them.
7. **Absolute dates only** (`2026-09-11`), never "yesterday" or "last week".
8. **Evidence, not claims.** An audit entry says what command ran and what it
   printed, not "tests pass".
9. **Append-only files** (`AUDIT-LOG.md`, `REJECTED.md`, decision records) are
   never edited in place. Correct with a new entry that references the old
   one. They are archived per release, never rewritten.

## Feature lifecycle

```
idea -> check REJECTED + decisions -> F-xxxx/BRIEF.md -> declare the tier
     -> one evidence pass (EVIDENCE.md: commands and output, no judgement)
     -> Gate 1 council over EVIDENCE.md   solo at standard, five voices at critical
     -> decisions logged -> scenarios written first
     -> code, commits tagged [F-xxxx] with a Tier line
     -> Gate 2 council on the diff (critical only, or a fix on a critical path)
     -> audit entry, incl. Reality-check -> owner approves -> push
     -> +14 days: OUTCOME.md -> feeds REJECTED / decisions / constraints
```

Bug fixes (`[fix]`) skip Gate 1. They need a scenario at tier `standard` and
above, and an audit entry on audited branches. A fix at tier `critical` needs
Gate 2.

## Session protocol

- **Start**: read this file, `scantling/STATE.md`, and the current gate file only.
- **During**: log decisions the moment they are made, not at the end.
- **End**: rewrite `scantling/STATE.md` (Now, In flight, Next, Blocked, Last
  session) inside 400 words. It is rewritten, never appended. Add to
  `BACKLOG.md` anything found but not fixed.
- **Monthly**: run `sh scantling/tools/ratio.sh`. If commits carrying only process
  have outnumbered commits carrying code for a month, Scantling has become the
  project. Cut ceremony and record the cut as a `D-`.

## Where things live

| Need | File |
|---|---|
| What is the current state | `scantling/STATE.md` |
| Why we did X | `scantling/decisions/INDEX.md` then the `D-` file |
| Why we did not do Y | `scantling/knowledge/REJECTED.md` |
| Real-world limits we already hit | `scantling/knowledge/CONSTRAINTS.md` |
| What we believe but have not proven | `scantling/knowledge/ASSUMPTIONS.md` |
| Which file owns which fact | `scantling/knowledge/SOURCES.md` |
| Who uses this and in what conditions | `scantling/scenarios/PERSONAS.md` |
| What must keep working | `scantling/scenarios/SCENARIOS.md`, then the area file |
| What was checked before each push | `scantling/audits/AUDIT-LOG.md` |
| How to challenge an idea or a diff | `scantling/council/COUNCIL.md` |
| Bugs and backlog | `scantling/BACKLOG.md` |
| Release notes | `scantling/CHANGELOG.md` |
| What broke and why | `scantling/incidents/` |
| How to run recurring ops | `scantling/runbooks/` |
| Whether Scantling is still worth it | `sh scantling/tools/ratio.sh` |

## Project specifics

{{PROJECT_SPECIFIC_RULES: stack, branch model, domain rules, the two or three
things a new agent always gets wrong here. Keep under 20 lines. Link to longer
docs instead of inlining them.}}
````

### 3.2 `scantling/config.sh`

```sh
# Scantling hook configuration. Sourced by every hook. Plain sh, no bashisms.

# Which Scantling this repo is running. Set at install, changed only by an
# upgrade. Scantling makes no network call and never checks for updates: this
# is here so that "what am I running" has an answer without one, and so an
# upgrade can tell which migration steps apply. See section 11.
SCANTLING_VERSION=2.0.0

# Branches that require Gate 2 PROCEED in the audit entry before push.
SCANTLING_PROTECTED_BRANCHES="main"

# Branches that require an audit entry and a STATE.md update before push.
SCANTLING_AUDITED_BRANCHES="main develop"

# Files matching this (grep -E) count as code. Code at tier standard or above
# ships with a scenario. Matching this sets the tier floor to standard.
SCANTLING_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'

# Paths whose tier floor is critical. A commit may still declare a lower tier,
# but must justify it on the record with a Tier-reason line.
SCANTLING_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'

# Tier assumed when a commit declares none and touches no code at all.
SCANTLING_DEFAULT_TIER=trivial

# 1 = a commit may declare a tier below its path-implied floor, with a
# Tier-reason line of 20 characters or more. 0 = the floor is hard.
# Turning this off brings back the 1.0 behaviour: path decides, and trivial
# changes on critical paths pay the full toll.
SCANTLING_ALLOW_TIER_DOWNGRADE=1

# Hard cap on scantling/STATE.md in words. The pre-commit hook refuses a bigger
# file. The cap is the mechanism: STATE.md is rewritten, not grown.
# 0 = no cap.
SCANTLING_STATE_MAX_WORDS=400

# Entries allowed in the live AUDIT-LOG.md before pre-push demands an archive
# into scantling/audits/archive/. Append-only is about integrity, not about one
# file growing forever. 0 = never demand.
SCANTLING_AUDIT_MAX_ENTRIES=20

# Dated archive files: superseded by scantling/, kept for history, never edited.
# The pre-commit hook refuses to stage a change to one. Set this when a file
# is marked "replaced" in scantling/knowledge/SOURCES.md. Empty = nothing archived.
SCANTLING_ARCHIVED_PATTERN=''

# Commands run by pre-push on every branch. Empty string = skip.
SCANTLING_CHECK_1="{{e.g. npx tsc --noEmit}}"
SCANTLING_CHECK_2=""
SCANTLING_CHECK_3=""

# Forbid the em dash (U+2014) in added lines and commit messages. 1 = on.
SCANTLING_FORBID_EMDASH=1
```

### 3.3 `scantling/STATE.md`

```markdown
# State

_Rewritten at the end of every session, never appended to. Capped at
SCANTLING_STATE_MAX_WORDS (400); the pre-commit hook refuses a bigger file. If it
does not fit, the surplus is history: it belongs in the audit log, the feature
folder or a decision record, not here._

_Last updated: {{YYYY-MM-DD}} by {{agent or owner}}._

## Now
- Branch: `{{branch}}` at `{{short sha}}`. Production: `{{version or sha}}` live since {{date}}.
- Pending migrations: {{none | list with target env}}
- Env drift: {{none | which secrets or settings differ between envs}}

## In flight
- {{F-0001 slug}}: {{one line, which phase of the lifecycle, declared tier}}

## Next (max 3, in order)
1. {{item, with ID}}
2. {{item}}
3. {{item}}

## Blocked
- {{item}}: blocked on {{what, who, since date}}

## Last session (max 6 lines, replaced not extended)
{{What was done, what was decided (IDs only, no restatement), what was left
half finished and where exactly. Anything older than the last session is
already in the audit log. Do not keep a narrative here.}}
```

### 3.4 `scantling/BACKLOG.md`

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

### 3.5 `scantling/CHANGELOG.md`

```markdown
# Changelog

One entry per production release. User-facing first, then internal. Link the
audit entry and the feature folders.

## {{v0.0.0}} ({{YYYY-MM-DD}})
Audit: A-0001. Features: F-0001.
- {{user-facing change}}
- Internal: {{change}}
```

### 3.6 `scantling/decisions/INDEX.md`

```markdown
# Decisions index

One line per decision. Status: proposed | accepted | superseded by D-xxxx.
Grep this file before proposing anything.

| ID | Date | Title | Status | Tags |
|---|---|---|---|---|
| D-0001 | {{date}} | {{title}} | accepted | {{area, area}} |
```

### 3.7 `scantling/templates/DECISION.md`

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

### 3.8 `scantling/knowledge/CONSTRAINTS.md`

```markdown
# Constraints

Real-world facts and hard limits already learned. Each has evidence and a
date. Agents read this before designing anything that touches the area.
Never delete: mark `expired` with a date and reason.

| ID | Area | Constraint | Evidence | Learned | Status |
|---|---|---|---|---|---|
| C-001 | {{infra}} | {{e.g. Hosting plan allows 2 cron jobs}} | {{link or how we found out}} | {{date}} | active |
```

### 3.9 `scantling/knowledge/ASSUMPTIONS.md`

```markdown
# Assumptions ledger

Things we believe but have not proven. A feature brief must list the
assumptions it depends on. Status moves unverified -> verified | false.
False assumptions get a line in REJECTED.md or a new decision.

| ID | Assumption | Depends | How to verify | Status | Checked |
|---|---|---|---|---|---|
| AS-001 | {{e.g. Most users open the app from a push notification}} | F-0002 | {{analytics query or user interview}} | unverified | |
```

### 3.10 `scantling/knowledge/REJECTED.md`

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

### 3.11 `scantling/templates/BRIEF.md`

```markdown
# F-{{0001}}: {{title}}

Date: {{YYYY-MM-DD}}. Owner: {{name}}. Status: brief | gate-1 | building | gate-2 | shipped | reviewed | killed

## Tier
{{trivial | standard | critical}}, because {{the blast radius in one line: what
is irreversible, what live data or money is touched, what a revert would not
undo. Not the line count.}}

Estimated at {{n}} days, so the reality check {{applies at the merge gate |
does not apply}}.

## Problem
{{Two to four lines. What goes wrong for whom, today. No solution words.}}

## Who and when
Persona: P-{{NAME}} (see `scantling/scenarios/PERSONAS.md`).
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

### 3.12 `scantling/council/COUNCIL.md`

```markdown
# Council protocol

The council is five voices that challenge a proposal. **Gate 1** asks whether
this is the right thing, on the brief. **Gate 2** asks whether it was built
right, on the diff.

The council exists to find the reason this will fail in the real world
before a real person does. It is not a style review.

It is also the most expensive thing Scantling does, so it is priced.

## Cost by tier

The gates a change pays for are set by the tier its commit declares (see
`SCANTLING.md` rule 3), not by the directory the change lands in.

| Tier | Gate 1 | Gate 2 | Form |
|---|---|---|---|
| `trivial` | none | none | The `Tier-reason:` line is the whole record |
| `standard` | required for features | only on a critical path | Solo: one agent, five voices in sequence |
| `critical` | required | required | Full: five independent reasoners |

A tier is a claim about blast radius, not line count. Two things follow:

- A one line change to a live column is `critical` and buys the full council.
- A 400 line deletion of code nothing calls is `trivial` and buys nothing.
  Paying for a council there does not make it safer. It teaches the next
  session that the council is a tax to be routed around, and that is how the
  audit trail dies.

## Evidence first, then judgement

**The voices do not read the repository.** Before any voice speaks, one agent
runs a single evidence pass and writes `EVIDENCE.md` into the feature folder
from `scantling/templates/EVIDENCE.md`. Every line in it is a command and what the
command printed. No judgement, no recommendation, no prose.

The voices then reason over `EVIDENCE.md`, the brief, and the previous gate's
verdict. Nothing else.

Five independent *judgements* is the point of the council. Five independent
*reads of the same files* is waste, and because it is structural it recurs on
every gate of every feature forever. One measured Gate 1 pass cost 322,122
tokens, three voices independently reported the same defect, and a single
`grep -rn` surfaced it for about 1,200. The finding was worth having. The
mechanism was not.

If a voice needs a fact the sheet lacks, it writes one line:

```
Evidence gap: <the question>, answerable by <the command>
```

The chair runs those commands once, appends the answers to `EVIDENCE.md`, and
restarts the voices. This happens at most once per gate. A voice never goes
reading on its own, and a gate never stalls on a missing fact.

## Voices

Default personas live in `scantling/council/personas/`. A project may add a
sixth or replace `domain.md`. Never fewer than four.

| Voice | Asks |
|---|---|
| User | Will the real persona, in their worst realistic moment, get the outcome? |
| Adversary | How do I abuse, spoof, spam, leak or break this? |
| Operator | What does this cost, what breaks at 10x, who is paged, is there a runbook? |
| Skeptic | Does this need to exist? What is the simplest thing that gets 80%? What did we already reject? |
| Domain | Which law, standard, or domain practice does this touch? Who must we not embarrass? |

## How to run it

**Solo form** (tier `standard`): one agent plays the five voices in sequence
over `EVIDENCE.md` and the brief. Still five distinct questions, still the
mandatory list below, one pass.

**Full form** (tier `critical`): if the runtime has subagents, give each voice
exactly its persona file, `EVIDENCE.md`, the brief, and the mandatory
questions. Give it nothing else, and do not give it repository access. Then
synthesise.

Record which form ran, under the date line of the verdict file:

```
Form: solo | full (five subagents)
```

The constraints, rejections and scenarios a voice needs are quoted in
`EVIDENCE.md` by the evidence pass. That is what the sheet is for.

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

Use `scantling/templates/COUNCIL.md`. The chair line must be exactly one of:

- `Verdict: PROCEED`
- `Verdict: PROCEED WITH CHANGES` followed by a numbered list. Each change is
  a required edit to the brief or the diff, not a suggestion.
- `Verdict: REWORK` with the two or three reasons. Return to brief or code.
- `Verdict: REJECT` with the reason. Add an `R-` entry to REJECTED.md.

The commit-msg hook accepts `[F-xxxx]` commits only when `COUNCIL-1.md`
contains a `Verdict: PROCEED` line (with or without changes). The pre-push
hook accepts a push to a protected branch only when the audit entry says
`Gate 2: PROCEED` (with or without changes).

## Reality check rule (at the merge gate, not at Gate 1)

For any feature the brief estimates at more than two days of work, one real
person matching the persona must be asked about the scenario, and their answer
quoted in the brief under "Prior art". Agents cannot do this step. Ask the
owner.

**It does not block Gate 1 and it does not block building.** It blocks the
push to a protected branch, which is the moment the feature reaches users.
That is the only moment at which the answer actually matters, and it gives the
owner the whole build window to find someone to ask.

The audit entry carries the line, and the pre-push hook requires it:

```
Reality-check: P-PRIYA, asked 2026-09-12: "I never open the app on data, only wifi at home"
Reality-check: waived: no donor reachable before the release window (AS-006)
```

A waiver writes an `AS-` entry in `ASSUMPTIONS.md` naming what is now believed
without evidence, and who could confirm it.

**A waiver may not cite an earlier waiver as its reason.** "We waived this
last time" is not a reason, it is a habit forming, and a rule waived every
time it fires is not a gate but a paperwork generator that teaches the next
session that waiving is normal.

If three consecutive features waive it, the rule is not working. Something
real is wrong: the personas are invented, or nobody on the project can
actually reach a user. Record that as a `D-` and either fix the personas or
remove the rule. Do not keep waiving it.

## Every demanded change is tracked

Each `PROCEED WITH CHANGES` item gets a checkbox in the verdict file. Gate 2
begins by confirming every Gate 1 checkbox is ticked with a commit reference.
```

### 3.13 `scantling/templates/COUNCIL.md`

```markdown
# Council: F-{{0001}} Gate {{1|2}}

Date: {{YYYY-MM-DD}}. Input: {{BRIEF.md | diff range sha..sha}}. Chair: {{agent}}.
Tier: {{standard | critical}}. Form: {{solo | full (five subagents)}}.
Evidence: {{EVIDENCE.md at the revision the voices were given}}.

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

## Evidence gaps raised
{{"none" | one line per gap: the question and the command that answers it.
The chair runs them once, appends to EVIDENCE.md and reruns the voices.}}

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

`scantling/council/personas/user.md`
```markdown
# Voice: User

You are the persona named in the brief, on the worst device and network
listed for them in `scantling/scenarios/PERSONAS.md`, at the worst realistic
moment. You are not technical. You do not read instructions. You will give
up after the second confusing screen.

Walk the scenario step by step. At each step say what you see, what you tap,
what you expect. Stop at the first place you would give up or get the wrong
outcome. Name the file or screen. Say what would have kept you going.
```

`scantling/council/personas/adversary.md`
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

`scantling/council/personas/operator.md`
```markdown
# Voice: Operator

You run this in production on a small budget and you get the page at 3 am.
Ask: what does one use cost (compute, third-party API, SMS, storage)? What
does it cost at ten times today's usage? What new background work, cron,
connection, or long-lived process appears? What is the rollback? Which
runbook must exist before ship? What metric tells us it is broken before a
user does?

Cite `scantling/knowledge/CONSTRAINTS.md` where a known limit applies.
```

`scantling/council/personas/skeptic.md`
```markdown
# Voice: Skeptic

You have seen this idea before. Grep `scantling/decisions/INDEX.md` and
`scantling/knowledge/REJECTED.md` and quote anything that applies. Ask: what
happens if we do nothing? What is the simplest change that gets most of the
value? Which non-goal is this quietly violating? Is the success metric
measurable with what exists today? What would make us remove this in 90
days?

You are allowed to say the feature should not be built. You must then say
what should be built instead, or nothing.
```

`scantling/council/personas/domain.md`
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

### 3.15 `scantling/scenarios/PERSONAS.md`

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

### 3.16 `scantling/scenarios/SCENARIOS.md`

```markdown
# Scenarios: index

**This file is an index and a coverage map. The scenarios themselves live in
`scantling/scenarios/areas/AREA.md`, one file per area.** A single scenario file
stops being read whole somewhere around ten thousand words, and a coverage map
row that says "all scenarios in the affected area" is the shape of a rule that
outgrew the format holding it.

IDs are global and never reused: `SC-AREA-000`. Areas are short caps
(AUTH, REQ, NOTIF, PAY, ADMIN).

## Areas

| Area | File | Owns |
|---|---|---|
| {{AUTH}} | `scantling/scenarios/areas/{{AUTH}}.md` | {{one line: what part of the product}} |

## Coverage map

Every row names specific scenario IDs. "All scenarios in the affected area" is
not an answer and does not belong here. A code path with no row is a gap: the
commit that adds the path adds the row.

| Code path | Area | Scenarios |
|---|---|---|
| `{{path}}` | {{AUTH}} | SC-{{AUTH}}-001, SC-{{AUTH}}-002 |

## Machine-readable areas

`scantling/scenarios/AREAS.map` holds the same mapping in the form the commit-msg hook
reads. Keep the two in step: when a row is added here, add the pattern there.
```

### 3.17 `scantling/templates/SCENARIO.md`

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

### 3.18 `scantling/audits/AUDIT-LOG.md`

```markdown
# Audit log

Append-only. One entry per push to an audited branch. The pre-push hook
reads the last entry. Write it as the final commit before pushing, tagged
`[scantling]`.

Evidence means the command and what it printed, not an adjective.

**Append-only is about integrity, not about one file growing forever.** At a
release, move the entries for the shipped range into
`scantling/audits/archive/AUDIT-LOG-{{v0.0.0}}.md` unchanged, and leave a one line
pointer here. The archive is append-only too. The live log stays short enough
to read. `SCANTLING_AUDIT_MAX_ENTRIES` in `scantling/config.sh` is the point at which
pre-push starts insisting.

## Archived
- {{v0.32.0 and earlier: scantling/audits/archive/AUDIT-LOG-v0.32.0.md (A-0001 to A-0014)}}

## A-0001 {{YYYY-MM-DDThh:mm+05:30}}
Branch: {{main | develop}}
Range: {{remote sha}}..{{local sha}}
Feature: {{F-0001 | fix | chore}}
Tier: {{trivial | standard | critical}} {{, downgraded from critical: <the Tier-reason, verbatim>}}
Gate 2: {{PROCEED | PROCEED WITH CHANGES | N/A}} ({{link COUNCIL-2.md or "not required at this tier"}})
Reality-check: {{P-NAME, asked YYYY-MM-DD: "quoted sentence" | waived: reason (AS-xxx) | N/A: under two days}}
Checks:
- `{{npx tsc --noEmit}}`: {{0 errors}}
- `{{next build}}`: {{ok, largest route 143 kB}}
- Scenarios run: {{SC-REQ-012 pass manual Android Chrome 2026-09-11, SC-REQ-013 reasoning only}}
Migrations: {{none | file, applied to which env on which date, prod pending yes/no}}
Rollback: {{git revert sha | redeploy previous | flag off}}
Risk: {{low | medium | high}}: {{one line why}}
Process ratio: {{output of sh scantling/tools/ratio.sh}}
Pushed by: {{agent name}} with approval from {{owner}} at {{time}}
```

### 3.19 `scantling/templates/AUDIT.md`

```markdown
## A-{{0000}} {{YYYY-MM-DDThh:mm+05:30}}
Branch:
Range:
Feature:
Tier:
Gate 2:
Reality-check:
Checks:
- ``:
Scenarios run:
Migrations:
Rollback:
Risk:
Process ratio:
Pushed by:
```

### 3.20 `scantling/templates/OUTCOME.md`

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

### 3.21 `scantling/templates/INCIDENT.md`

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
- Runbook: `scantling/runbooks/{{name}}.md`
```

### 3.22 `scantling/runbooks/README.md`

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

`scantling/hooks/install.sh`
```sh
#!/bin/sh
# Point git at Scantling's hooks. Idempotent. Run from anywhere inside the repo.
set -e
ROOT=$(git rev-parse --show-toplevel)
chmod +x "$ROOT"/scantling/hooks/pre-commit "$ROOT"/scantling/hooks/commit-msg "$ROOT"/scantling/hooks/pre-push
chmod +x "$ROOT"/scantling/tools/*.sh 2>/dev/null || true
git config core.hooksPath scantling/hooks
echo "scantling: hooks installed (core.hooksPath = scantling/hooks)"
echo "scantling: if this repo had other hooks, chain them from scantling/hooks/* (see SCANTLING_BOOTSTRAP section 7.3)"
```

`scantling/hooks/pre-commit`
```sh
#!/bin/sh
# Scantling pre-commit: forbidden patterns, archived files, STATE.md cap.
# Scenario coverage moved to commit-msg in 1.1: it depends on the declared
# tier, and the tier lives in the commit message, which pre-commit cannot see.
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/scantling/config.sh"

STAGED=$(git diff --cached --name-only --diff-filter=ACMR)
[ -z "$STAGED" ] && exit 0

# 1. Em dash in added lines.
if [ "$SCANTLING_FORBID_EMDASH" = "1" ]; then
  EMDASH=$(printf '\342\200\224')
  if git diff --cached -U0 -- . ':(exclude)*.png' ':(exclude)*.jpg' ':(exclude)*.ico' | grep '^+' | grep -v '^+++' | grep -q "$EMDASH"; then
    echo "scantling: em dash (U+2014) found in added lines. Use a hyphen, colon or comma." >&2
    git diff --cached -U0 | grep -n '^+' | grep "$EMDASH" | head -5 >&2
    exit 1
  fi
fi

# 2. Archived files are never edited. One system of record.
# SCANTLING_ARCHIVE_STAMP=1 is the one exception: the commit that stamps the
# banner and freezes the file must be able to touch it. Nothing after that.
if [ -n "$SCANTLING_ARCHIVED_PATTERN" ] && [ "$SCANTLING_ARCHIVE_STAMP" != "1" ]; then
  HITS=$(printf '%s\n' "$STAGED" | grep -E "$SCANTLING_ARCHIVED_PATTERN")
  if [ -n "$HITS" ]; then
    echo "scantling: these files are dated archives, superseded by scantling/:" >&2
    printf '%s\n' "$HITS" | sed 's/^/scantling:   /' >&2
    echo "scantling: write the fact in scantling/ instead. See scantling/knowledge/SOURCES.md." >&2
    echo "scantling: to un-archive a file, change SCANTLING_ARCHIVED_PATTERN with a D- record." >&2
    exit 1
  fi
fi

# 3. STATE.md word cap. The cap is the mechanism that keeps it rewritten.
if [ "${SCANTLING_STATE_MAX_WORDS:-0}" -gt 0 ] && printf '%s\n' "$STAGED" | grep -q '^scantling/STATE.md$'; then
  WORDS=$(git show :scantling/STATE.md 2>/dev/null | wc -w | tr -d ' ')
  if [ -n "$WORDS" ] && [ "$WORDS" -gt "$SCANTLING_STATE_MAX_WORDS" ]; then
    echo "scantling: scantling/STATE.md is $WORDS words, cap is $SCANTLING_STATE_MAX_WORDS." >&2
    echo "scantling: STATE.md is rewritten every session, not grown. The surplus is history:" >&2
    echo "scantling: it belongs in the audit log, the feature folder or a D- record." >&2
    exit 1
  fi
fi

# 4. Critical path touched: advisory, since the commit body decides the tier.
if printf '%s\n' "$STAGED" | grep -qE "$SCANTLING_CRITICAL_PATTERN"; then
  echo "scantling: note: critical path touched, so this commit needs a 'Tier:' line." >&2
  echo "scantling: commit-msg checks it. Tier: critical unless you can justify lower." >&2
fi

exit 0
```

`scantling/hooks/commit-msg`
```sh
#!/bin/sh
# Scantling commit-msg: tag and risk tier required. The declared tier decides what
# else is required. A tier below the path-implied floor needs a reason on the
# record, because a claim can be audited later and an inference cannot.
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/scantling/config.sh"
MSG=$(sed -e '/^#/d' "$1")
STAGED=$(git diff --cached --name-only --diff-filter=ACMR)

rank() {
  case "$1" in
    trivial)  echo 0 ;;
    standard) echo 1 ;;
    critical) echo 2 ;;
    *)        echo -1 ;;
  esac
}

# 1. Tag.
TAG=$(printf '%s\n' "$MSG" | grep -oE '\[(F-[0-9]{4}|fix|hotfix|chore|docs|scantling)\]' | head -1)
if [ -z "$TAG" ]; then
  echo "scantling: commit message needs a tag: [F-0001] [fix] [hotfix] [chore] [docs] [scantling]" >&2
  exit 1
fi

# 2. Tier floor from paths, then the declared tier.
FLOOR=trivial
printf '%s\n' "$STAGED" | grep -qE "$SCANTLING_CODE_PATTERN"     && FLOOR=standard
printf '%s\n' "$STAGED" | grep -qE "$SCANTLING_CRITICAL_PATTERN" && FLOOR=critical

TIER=$(printf '%s\n' "$MSG" | sed -n 's/^Tier:[ ]*\([a-z][a-z]*\).*/\1/p' | head -1)
if [ -z "$TIER" ]; then
  if [ "$FLOOR" = "trivial" ]; then
    TIER=${SCANTLING_DEFAULT_TIER:-trivial}
  else
    echo "scantling: this commit touches $FLOOR paths and declares no tier." >&2
    echo "scantling: add a line to the commit body:" >&2
    echo "scantling:   Tier: trivial | standard | critical" >&2
    echo "scantling: the tier is the blast radius, not the diff size. See SCANTLING.md rule 3." >&2
    exit 1
  fi
fi
if [ "$(rank "$TIER")" -lt 0 ]; then
  echo "scantling: 'Tier: $TIER' is not one of trivial, standard, critical." >&2
  exit 1
fi

# 3. Downgrades below the floor are allowed, but must carry their evidence.
if [ "$(rank "$TIER")" -lt "$(rank "$FLOOR")" ]; then
  if [ "$SCANTLING_ALLOW_TIER_DOWNGRADE" != "1" ]; then
    echo "scantling: paths here imply tier $FLOOR and SCANTLING_ALLOW_TIER_DOWNGRADE is 0." >&2
    exit 1
  fi
  if ! printf '%s\n' "$MSG" | grep -qE '^Tier-reason: .{20,}'; then
    echo "scantling: tier $TIER is below the path-implied floor $FLOOR." >&2
    echo "scantling: that is allowed, and it costs one line of evidence:" >&2
    echo "scantling:   Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits" >&2
    exit 1
  fi
fi

# 4. Features need a brief always, and a Gate 1 verdict at standard and above.
case "$TAG" in
  \[F-*)
    ID=$(printf '%s' "$TAG" | tr -d '[]')
    DIR=$(ls -d "$ROOT"/scantling/features/"$ID"* 2>/dev/null | head -1)
    if [ -z "$DIR" ] || [ ! -f "$DIR/BRIEF.md" ]; then
      echo "scantling: no scantling/features/$ID-*/BRIEF.md. Write the brief first." >&2
      exit 1
    fi
    if [ "$(rank "$TIER")" -ge 1 ]; then
      if ! grep -qE '^Verdict: PROCEED' "$DIR/COUNCIL-1.md" 2>/dev/null; then
        echo "scantling: $ID is tier $TIER and has no 'Verdict: PROCEED' in COUNCIL-1.md." >&2
        echo "scantling: run Gate 1 (solo form at standard, full at critical)." >&2
        exit 1
      fi
      if [ ! -f "$DIR/EVIDENCE.md" ]; then
        echo "scantling: $ID has a verdict but no EVIDENCE.md. The voices must reason" >&2
        echo "scantling: over a written evidence pass, not over the repository." >&2
        exit 1
      fi
    fi
    ;;
esac

# 5. Scenario coverage, by area, at tier standard and above.
if [ "$(rank "$TIER")" -ge 1 ] && printf '%s\n' "$STAGED" | grep -qE "$SCANTLING_CODE_PATTERN"; then
  MISSING=""
  MAPPED=0
  if [ -f "$ROOT/scantling/scenarios/AREAS.map" ]; then
    while read -r area pattern; do
      [ -z "$area" ] && continue
      case "$area" in \#*) continue ;; esac
      [ -z "$pattern" ] && continue
      if printf '%s\n' "$STAGED" | grep -qE "$pattern"; then
        MAPPED=1
        if ! printf '%s\n' "$STAGED" | grep -q "^scantling/scenarios/areas/$area\.md$"; then
          MISSING="$MISSING scantling/scenarios/areas/$area.md"
        fi
      fi
    done < "$ROOT/scantling/scenarios/AREAS.map"
  fi
  UNMAPPED=0
  if [ "$MAPPED" = "0" ] && ! printf '%s\n' "$STAGED" | grep -q '^scantling/scenarios/SCENARIOS.md$'; then
    MISSING="$MISSING scantling/scenarios/SCENARIOS.md"
    UNMAPPED=1
  fi
  if [ -n "$MISSING" ] && [ "$SCANTLING_WAIVE_SCENARIOS" != "1" ]; then
    echo "scantling: tier $TIER code change with no scenario staged. Expected:" >&2
    for m in $MISSING; do echo "scantling:   $m" >&2; done
    if [ "$UNMAPPED" = "1" ]; then
      echo "scantling: this code path matches no area in scantling/scenarios/AREAS.map." >&2
      echo "scantling: add the pattern there and a coverage map row in SCENARIOS.md." >&2
    fi
    echo "scantling: write the scenario, or declare 'Tier: trivial' with a Tier-reason," >&2
    echo "scantling: or waive: SCANTLING_WAIVE_SCENARIOS=1 git commit ... plus a 'Waiver: <reason>' line." >&2
    exit 1
  fi
fi

if [ "$SCANTLING_WAIVE_SCENARIOS" = "1" ]; then
  if ! printf '%s\n' "$MSG" | grep -qE '^Waiver: .{10,}'; then
    echo "scantling: scenario waiver used but no 'Waiver: <reason>' line (10+ chars) in the commit body." >&2
    exit 1
  fi
fi

if [ "$SCANTLING_FORBID_EMDASH" = "1" ]; then
  if printf '%s\n' "$MSG" | grep -q "$(printf '\342\200\224')"; then
    echo "scantling: em dash in commit message." >&2
    exit 1
  fi
fi

exit 0
```

`scantling/hooks/pre-push`
```sh
#!/bin/sh
# Scantling pre-push: audit entry + STATE.md for audited branches, Gate 2 for protected, checks everywhere.
# stdin lines: <local ref> <local sha> <remote ref> <remote sha>
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/scantling/config.sh"
REMOTE_NAME=$1
ZERO=0000000000000000000000000000000000000000
FAIL=0

# Advisory only: tell the repo when its config and its hooks disagree about
# which Scantling this is. There is no network call and nothing to check
# against upstream; this only catches a half-finished migration in this repo.
SCANTLING_HOOKS_VERSION=2.0.0
if [ -z "$SCANTLING_VERSION" ]; then
  echo "scantling: config.sh sets no SCANTLING_VERSION. This looks like a Keel 1.0" >&2
  echo "scantling: config running under 2.0 hooks. See section 11 of the bootstrap," >&2
  echo "scantling: or run tools/migrate-from-keel.sh from the Scantling repository." >&2
elif [ "$SCANTLING_VERSION" != "$SCANTLING_HOOKS_VERSION" ]; then
  echo "scantling: config says $SCANTLING_VERSION, hooks say $SCANTLING_HOOKS_VERSION." >&2
  echo "scantling: finish the upgrade, or correct SCANTLING_VERSION if it is stale." >&2
fi

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

  if in_list "$branch" "$SCANTLING_AUDITED_BRANCHES"; then
    if ! printf '%s\n' "$CHANGED" | grep -q '^scantling/audits/AUDIT-LOG.md$'; then
      echo "scantling: push to '$branch' has no new entry in scantling/audits/AUDIT-LOG.md in $range" >&2; FAIL=1
    fi
    if ! printf '%s\n' "$CHANGED" | grep -q '^scantling/STATE.md$'; then
      echo "scantling: push to '$branch' does not update scantling/STATE.md in $range" >&2; FAIL=1
    fi
    LAST=$(awk '/^## A-/{b=""} {b=b $0 "\n"} END{printf "%s", b}' "$ROOT/scantling/audits/AUDIT-LOG.md")
    if ! printf '%s' "$LAST" | grep -q "^Branch: $branch"; then
      echo "scantling: last audit entry is not for branch '$branch'" >&2; FAIL=1
    fi
    if in_list "$branch" "$SCANTLING_PROTECTED_BRANCHES"; then
      if ! printf '%s' "$LAST" | grep -qE '^Gate 2: PROCEED'; then
        echo "scantling: '$branch' is protected and the last audit entry lacks 'Gate 2: PROCEED'" >&2; FAIL=1
      fi
      # The reality check binds here, at the moment the work reaches users,
      # not at Gate 1 where it only ever produced waivers.
      if ! printf '%s' "$LAST" | grep -qE '^Reality-check: .{10,}'; then
        echo "scantling: '$branch' is protected and the last audit entry has no 'Reality-check:' line." >&2
        echo "scantling: quote the real person who was asked, or write" >&2
        echo "scantling:   Reality-check: waived: <reason> (AS-xxx)" >&2
        echo "scantling: a waiver writes an assumption and may not cite an earlier waiver." >&2
        FAIL=1
      fi
    fi
  fi
done

# Append-only is about integrity, not about one file growing forever.
if [ "${SCANTLING_AUDIT_MAX_ENTRIES:-0}" -gt 0 ]; then
  ENTRIES=$(grep -c '^## A-' "$ROOT/scantling/audits/AUDIT-LOG.md" 2>/dev/null)
  [ -z "$ENTRIES" ] && ENTRIES=0
  if [ "$ENTRIES" -gt "$SCANTLING_AUDIT_MAX_ENTRIES" ]; then
    echo "scantling: AUDIT-LOG.md holds $ENTRIES entries, max is $SCANTLING_AUDIT_MAX_ENTRIES." >&2
    echo "scantling: move the shipped ones unchanged into scantling/audits/archive/AUDIT-LOG-<version>.md" >&2
    echo "scantling: and leave a pointer line under '## Archived'. Nothing is edited or deleted." >&2
    FAIL=1
  fi
fi

[ "$FAIL" = "1" ] && exit 1

for c in "$SCANTLING_CHECK_1" "$SCANTLING_CHECK_2" "$SCANTLING_CHECK_3"; do
  [ -z "$c" ] && continue
  echo "scantling: running: $c"
  if ! sh -c "$c"; then
    echo "scantling: check failed: $c" >&2
    exit 1
  fi
done

# Advisory, never blocking: Scantling's own drag gauge.
[ -f "$ROOT/scantling/tools/ratio.sh" ] && sh "$ROOT/scantling/tools/ratio.sh" 2>/dev/null

exit 0
```

### 3.24 `scantling/knowledge/SOURCES.md`

The file that keeps Scantling from becoming the second system of record. Written at
install (step 5) and updated whenever a disposition changes.

```markdown
# Sources of record

One fact, one home. This file says which file owns what, so that closing a
backlog item is one edit and not two, and so an agent reading one file is not
reading a stale copy of another.

Running two systems of record is the most expensive state available: every
fact costs two writes, the two drift, and nothing tells you which is current.

Last reviewed: {{YYYY-MM-DD}}.

## Scantling owns

| Fact | File | Replaced |
|---|---|---|
| Current state, in flight, next | `scantling/STATE.md` | {{HANDOFF.md sections 1-3}} |
| Bugs and backlog | `scantling/BACKLOG.md` | {{ISSUES.md}} |
| Release notes | `scantling/CHANGELOG.md` | {{RELEASES.md}} |
| Why we did X | `scantling/decisions/` | {{nothing, new}} |
| What must keep working | `scantling/scenarios/` | {{nothing, new}} |

## Kept, outside Scantling

| File | Owns | Why it stays |
|---|---|---|
| {{docs/API.md}} | {{endpoint reference}} | {{generated from code, Scantling does not cover it}} |

Scantling must never write these facts. If a council or an audit wants to state one,
it links instead.

## Archived (never edited, listed in SCANTLING_ARCHIVED_PATTERN)

| File | Frozen at | Where the live version is |
|---|---|---|
| {{HANDOFF.md}} | {{2026-09-13, v0.32.0}} | {{scantling/STATE.md}} |

Every archived file carries this banner at the top:

    > ARCHIVED {{YYYY-MM-DD}}. Superseded by {{scantling/STATE.md}}.
    > Kept for history. Do not edit: the pre-commit hook refuses changes.
    > Anything still true about the project today lives in scantling/.

## Deferred (a known cost, with a date)

| File | Why not yet | Trigger to finish | Owner |
|---|---|---|---|
| {{CODING_STANDARDS.md}} | {{1,400 lines, not urgent}} | {{next time it is edited at all}} | {{name}} |

A deferred file is a decision to run two records for a while. Say so out loud
here rather than letting it be the default.

## Agent instruction files

Files that tell agents where to look ({{CLAUDE.md}}, `AGENTS.md`,
`.cursorrules`) must not point at an archived file. Checked on
{{YYYY-MM-DD}}: {{what was found and fixed}}.
```

### 3.25 `scantling/templates/EVIDENCE.md`

```markdown
# Evidence: F-{{0001}} Gate {{1|2}}

Collected by one agent **before** any voice speaks, so that five voices
reason independently instead of reading the same files five times.

Rules for this file: every line is a command and what it printed. No
judgement, no recommendation, no adjectives. If a fact is not the output of
something that was actually run, it belongs in the brief, not here.

Date: {{YYYY-MM-DD}}. Collected by: {{agent}}. Input: {{BRIEF.md | sha..sha}}.

## Prior art
- `grep -n "{{keyword}}" scantling/decisions/INDEX.md` -> {{matching lines, or "no match"}}
- `grep -n "{{keyword}}" scantling/knowledge/REJECTED.md` -> {{...}}
- `grep -n "{{keyword}}" scantling/knowledge/CONSTRAINTS.md` -> {{... quoted in full, the voices cannot open it}}

## Code in scope
- `grep -rn "{{symbol}}" {{dirs}}` -> {{file:line list, or "0 call sites"}}
- Entry points: {{routes, jobs, handlers that reach this code}}
- {{path}}: {{what it does today in two lines, no opinion}}

## Data
- Tables or collections touched: {{list}}
- Live rows: {{n}}, counted by `{{command}}` on {{YYYY-MM-DD}}
- Personal data in scope: {{fields}}
- Reversible? {{what a revert would and would not undo}}

## Scenarios already covering this area
- {{SC-AREA-001 title: Status line verbatim}}

## Gaps
Facts the voices may want that are not here, and the command that would get
them. The chair fills these once when a voice raises an `Evidence gap:` line.
- {{question}} -> `{{command}}`
```

### 3.26 `scantling/scenarios/AREAS.map`

Plain text, read by the commit-msg hook: area name, whitespace, then a
`grep -E` pattern for the code paths that area covers. Keep it in step with
the coverage map in `SCENARIOS.md`.

```
# area   pattern (grep -E) matched against staged paths
# A code path matching no line here forces an update to SCENARIOS.md,
# which is how new paths get mapped instead of quietly escaping coverage.
{{AUTH}}    {{^(lib/auth|app/api/auth|app/\(auth\))/}}
{{REQ}}     {{^(app/request|lib/request|app/api/request)/}}
{{NOTIF}}   {{^(lib/notify|app/api/notify)/}}
{{DB}}      {{^db/}}
```

### 3.27 `scantling/scenarios/areas/AUTH.md`

One file per area. Create the ones the project actually has, named to match
the `AREAS.map` file. This is where scenarios live; `SCENARIOS.md` only indexes
them.

```markdown
# Scenarios: {{AUTH}}

{{One line: what this area covers.}}
Covers: {{^(lib/auth|app/api/auth)/}} (keep in step with `scantling/scenarios/AREAS.map`)

Status is the last real run, with the date and how it was run: manual on a
named device, an automated test, or reasoning only. "Reasoning only" is an
honest status and is better than a false pass.

### SC-{{AUTH}}-001 {{title}}
Persona: P-{{NAME}}
Given {{state}}
When {{action, including the bad conditions}}
Then {{observable outcome}}
Also check: {{the failure branch: timeout, double tap, back button, stale tab}}
Status: pass {{date}} ({{how}}) | fail {{date}} | untested
Covers: `{{path}}`
```

### 3.28 `scantling/tools/ratio.sh`

Scantling's own drag gauge. The framework should be able to measure itself, and
this is the number that says when it has stopped being worth its cost.

```sh
#!/bin/sh
# Process commits against code commits. If process has outrun code for a
# month, Scantling has become the project: cut ceremony and record the cut.
# Usage: sh scantling/tools/ratio.sh ["30 days ago"]
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/scantling/config.sh"
SINCE=${1:-30 days ago}

CODE=0
PROCESS=0
for sha in $(git log --since="$SINCE" --format=%H); do
  if git show --name-only --pretty=format: "$sha" | grep -qE "$SCANTLING_CODE_PATTERN"; then
    CODE=$((CODE + 1))
  else
    PROCESS=$((PROCESS + 1))
  fi
done

TOTAL=$((CODE + PROCESS))
if [ "$TOTAL" -eq 0 ]; then
  echo "scantling: no commits since $SINCE"
  exit 0
fi

echo "scantling: since $SINCE, $CODE of $TOTAL commits carry code, $PROCESS carry only process."
if [ "$CODE" -eq 0 ]; then
  echo "scantling: ratio is $PROCESS:0. Nothing shipped in this window."
  exit 0
fi
R=$((PROCESS * 10 / CODE))
echo "scantling: process:code is $((R / 10)).$((R % 10)):1 (target: at or below 1.0:1)."
if [ "$R" -gt 10 ]; then
  echo "scantling: above 1:1. If it stays here for a month, cut ceremony and record a D-."
  echo "scantling: usual causes: a tier floor set too wide, or two systems of record."
fi
exit 0
```

---

## 4. Workflow in detail

### 4.1 Intake (10 minutes, before any code)

1. Write the idea in one sentence.
2. Grep `scantling/decisions/INDEX.md`, `scantling/knowledge/REJECTED.md`,
   `scantling/BACKLOG.md` for its keywords. Quote hits.
3. Pick the persona from `PERSONAS.md`. If none fits, write one first.
4. Create `scantling/features/F-xxxx-slug/BRIEF.md` from the template. The "one
   scenario" section is the test: if it cannot be written in the persona's
   words, stop.
5. **Declare the tier in the brief**, with the blast radius in one line. This
   sets what the rest of the lifecycle costs, so it is a real decision and not
   a field to fill. Getting it wrong in either direction is expensive:
   over-declaring buys ceremony that teaches people to route around the
   process, under-declaring is how a live column gets altered on a Friday.
6. List assumptions in `ASSUMPTIONS.md` with IDs and reference them.

### 4.2 Evidence pass (one agent, once)

Write `EVIDENCE.md` from the template: grep the decisions, the rejections, the
constraints and the code, and record each command with its output. Quote what
the voices will need, because they will not be able to open anything else.

This is the cheap half of the council and it replaces five agents doing the
same reading. Budget one pass, not one per voice.

### 4.3 Gate 1

Skip at tier `trivial`. Otherwise run the council per `COUNCIL.md`: solo form
at `standard`, full form at `critical`. The voices get `EVIDENCE.md`, the
brief, and nothing else. Write `COUNCIL-1.md` with the `Form:` line.

Record every decision as a `D-` file and index line, every rejection as `R-`.
Tick the required changes into the brief. Only then start code.

### 4.4 Build

1. Add scenario stubs to the area file, `scantling/scenarios/areas/AREA.md`, with
   `Status: untested`. If the code path is in no area, add it to `AREAS.map` and
   to the coverage map in `SCENARIOS.md` first.
2. Code. Commit small, every message tagged `[F-xxxx]` with a `Tier:` line.
3. When a scenario is actually exercised (device, test, or careful reasoning),
   update its status line with date and method.
4. Log decisions the moment they happen. A decision made in a chat and not
   written down does not exist.

### 4.5 Gate 2

At tier `critical`, or for a fix on a critical path. Refresh `EVIDENCE.md` for
the diff range, then run the council on it. Write `COUNCIL-2.md`. Fix required
changes, tick them with commit references.

At tier `standard` there is no Gate 2: the scenario and the audit entry are
the check, which is what they are for.

### 4.6 Audit and push

1. Rewrite `STATE.md`, inside the 400 word cap.
2. Append the audit entry to `AUDIT-LOG.md` with real command output, the
   declared `Tier:`, and the `Reality-check:` line. If the log is over
   `SCANTLING_AUDIT_MAX_ENTRIES`, archive the shipped entries first.
3. Commit `[scantling] audit A-xxxx for F-xxxx`.
4. Stop. Show the owner the audit entry. Push only on explicit approval for
   this push. Earlier approvals do not carry over.

### 4.7 Outcome review

Fourteen days after the production release, write `OUTCOME.md`. Move learned
facts into `CONSTRAINTS.md`, flip assumptions, add `R-` entries for
approaches that should not be repeated. Update `BACKLOG.md`.

Also check the tier: did the change turn out to be as dangerous as it was
declared? A `standard` that caused an incident and a `critical` that nothing
could have broken are both worth a line, because the tier floors in
`config.sh` are what should change as a result.

### 4.8 Bug fixes

`[fix]` with a declared tier, like anything else. At `standard` and above: a
scenario, and an audit entry on audited branches. At `critical`: Gate 2.
At `trivial`: the `Tier-reason` line is the record.

`[hotfix]` on production is `critical` by definition, and needs an `INC-` file
within 24 hours.

### 4.9 Brainstorming sessions (owner and agent, no code)

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
- **Every growing file has a compaction path, or it is a bug.** Append-only
  means entries are never edited, not that one file grows forever:
  - `STATE.md` is rewritten every session and capped at
    `SCANTLING_STATE_MAX_WORDS`. The hook enforces it.
  - `AUDIT-LOG.md` is archived per release into
    `scantling/audits/archive/AUDIT-LOG-<version>.md`, unchanged, with a pointer
    line left behind. `SCANTLING_AUDIT_MAX_ENTRIES` is when pre-push insists.
  - `SCENARIOS.md` is an index. Scenarios live in per-area files.
  - A feature folder is loaded one gate at a time. Closed gates stay closed.
  - `CHANGELOG.md` is archived per major version.

  A rule that is correct for integrity and has no archival story still ends
  up unread, which costs the integrity anyway.
- **Token budget**: `SCANTLING.md` under 120 lines, `STATE.md` under 400 words, a
  brief under 120 lines, an evidence sheet under 200, a council verdict under
  150. If a file grows past that, split or link.

---

## 6. What counts as a decision

Record a `D-` when any of these happen:

- Two or more viable options existed and one was chosen.
- A default was changed (timeout, limit, threshold, retention period).
- A dependency, vendor, or service was added or removed.
- A rule in `SCANTLING.md` or `config.sh` changed.
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
| pre-commit | em dash in added lines (if enabled); a file matching `SCANTLING_ARCHIVED_PATTERN` is staged; `STATE.md` over `SCANTLING_STATE_MAX_WORDS` |
| commit-msg | no tag; no `Tier:` line on a code change; an unknown tier; a tier below the path floor without a 20+ char `Tier-reason:`; `[F-xxxx]` without a brief; `[F-xxxx]` at tier standard or above without Gate 1 PROCEED or without `EVIDENCE.md`; tier standard or above touching code with no area scenario staged and no waiver; waiver without reason; em dash in message |
| pre-push | audited branch without new audit entry or `STATE.md` change in the pushed range; last audit entry for a different branch; protected branch without `Gate 2: PROCEED` or without a `Reality-check:` line; `AUDIT-LOG.md` over `SCANTLING_AUDIT_MAX_ENTRIES`; any `SCANTLING_CHECK_n` failing |

The scenario check moved from pre-commit to commit-msg in 1.1. It depends on
the declared tier, and the tier is in the commit message, which pre-commit
cannot read. This means a scenario failure now surfaces after the editor
closes rather than before it opens. The commit is rejected either way and
`git commit` reruns from the same staged index.

Note on protected branches: the pushed range is "commits not yet on the
remote". A fast-forward of `develop` onto `main` therefore contains no new
commits and is blocked until an audit commit is made on `main` itself. That
is intended: every production push gets its own entry with `Gate 2: PROCEED`.

Verified 2026-09-14 in a throwaway repo (Git for Windows, sh), 27 cases, all
behaving as written:

*Tag and tier*: untagged commit blocked; `[scantling]` with no code allowed at the
default tier; code change with no `Tier:` line blocked; `Tier: medium`
blocked as not a tier; `Tier: trivial` on `src/` blocked with no reason;
same commit allowed with a `Tier-reason:` line; `Tier: standard` on `db/`
blocked, since `db/` implies a `critical` floor.

*The case this release exists for*: dropping a table on a `critical` path at
`Tier: trivial` with a `Tier-reason` citing zero call sites is allowed, with
no scenario and no council. The same path at `Tier: critical` demands the
area scenario.

*Scenarios*: a mapped path demands `scantling/scenarios/areas/DB.md` specifically,
not the whole corpus; an unmapped path demands a `SCENARIOS.md` coverage row
instead, so new paths cannot quietly escape coverage.

*Features*: `[F-0001]` without a brief blocked; with a brief but no
`Verdict: PROCEED` blocked; with a verdict but no `EVIDENCE.md` blocked; with
both, plus the area scenario, allowed. A feature at `Tier: trivial` needs the
brief but no council.

*Caps and archives*: `STATE.md` at 450 words blocked, at 50 allowed; editing
a file matching `SCANTLING_ARCHIVED_PATTERN` blocked, and allowed only for the one
stamping commit with `SCANTLING_ARCHIVE_STAMP=1`; `AUDIT-LOG.md` at 25 entries
blocked the push against a max of 20.

*Push*: push to protected `main` with no audit entry blocked; with
`Gate 2: PROCEED` but no `Reality-check:` line blocked; with both, allowed,
and `ratio.sh` printed `process:code is 1.0:1` without blocking.

*Regression*: em dash in an added line still blocked.

### 7.2 Bypass

`git commit --no-verify` and `git push --no-verify` exist. Scantling does not try
to prevent them. Using one is itself a decision: record a `D-` or an `R-`
line saying why. Agents must never bypass without the owner's explicit
instruction for that specific commit or push.

### 7.3 Existing hooks

If the repo already has `core.hooksPath` set (for example `.githooks`), do
not overwrite. Either move the existing scripts' logic into Scantling's hooks, or
make Scantling's hooks call the old ones at the end:
```sh
[ -x "$ROOT/.githooks/pre-commit" ] && exec "$ROOT/.githooks/pre-commit" "$@"
```
Record the choice as a `D-`.

### 7.4 Windows

Hooks are POSIX sh and run under Git for Windows' bundled shell. Line endings
must be LF. If a hook fails with "bad interpreter", run
`git config core.autocrlf false` for the repo and re-save the hook files.

**Names must differ by more than case.** Windows and macOS default to
case-insensitive filesystems, so `scantling/scenarios/AREAS` and
`scantling/scenarios/areas/` cannot both exist: creating the second fails with
"Not a directory". That is why the map is `AREAS.map`. Keep the rule in mind
when adding area names or new Scantling files of your own.

---

## 8. Optional: Claude Code skills

If the owner uses Claude Code, create these so the workflow is one slash
command away. Each is a folder `.claude/skills/<name>/SKILL.md`. Other
agents ignore them.

`.claude/skills/scantling-brief/SKILL.md`
```markdown
---
name: scantling-brief
description: Start a feature the Scantling way. Greps decisions and rejected ideas, picks a persona, writes scantling/features/F-xxxx-slug/BRIEF.md from the template, and lists assumptions. Use when the user says "new feature", "let's build", "brief this", or /scantling-brief.
---
Read SCANTLING.md and scantling/STATE.md. Take the idea from the user's message.
1. Grep scantling/decisions/INDEX.md, scantling/knowledge/REJECTED.md, scantling/BACKLOG.md for the idea's keywords. Quote every hit with its ID before anything else.
2. Pick the next free F- number from scantling/features/. Pick a persona from scantling/scenarios/PERSONAS.md or propose a new one.
3. Write BRIEF.md from scantling/templates/BRIEF.md. Do not leave placeholders; ask the user for anything you cannot infer.
4. Add assumptions to scantling/knowledge/ASSUMPTIONS.md with IDs and reference them in the brief.
5. Stop and show the brief. Do not write code. Suggest /scantling-council 1.
```

`.claude/skills/scantling-council/SKILL.md`
```markdown
---
name: scantling-council
description: Run the Scantling council on a feature. Argument "1" runs Gate 1 on the brief, "2" runs Gate 2 on the diff. Gathers evidence once, then plays the five voices from scantling/council/personas over that evidence, and writes COUNCIL-1.md or COUNCIL-2.md with a Verdict line. Use for /scantling-council, "challenge this", "council", "gate 1", "gate 2".
---
Read scantling/council/COUNCIL.md fully. Identify the feature (argument or the in-flight item in scantling/STATE.md) and its declared tier from BRIEF.md.
Tier trivial: say so and stop. There is no council at trivial; the Tier-reason line in the commit is the record.
Step 1, evidence, once: write EVIDENCE.md in the feature folder from scantling/templates/EVIDENCE.md. Grep decisions, REJECTED, CONSTRAINTS and the code in scope; record each command and its output; quote what the voices will need in full, because they will not be able to open anything else. Count call sites explicitly.
Step 2, voices: give them EVIDENCE.md, the brief, and the prior verdict. Do NOT give them repository access and do not let them re-read files the evidence pass already covered. Tier standard: solo form, five voices in sequence, one pass. Tier critical: full form, five subagents in parallel, each with only its persona file plus that input. Respect the 150 word cap.
If a voice raises "Evidence gap:", run those commands once, append the answers to EVIDENCE.md, rerun the voices. At most once per gate.
Gate 2 first verifies every Gate 1 checkbox is ticked with a commit reference.
Write the verdict file from scantling/templates/COUNCIL.md including the Tier and Form lines. The Verdict line must be one of the four exact strings. List required changes as checkboxes. List decisions and rejections to record, then record them (/scantling-decide).
```

`.claude/skills/scantling-tier/SKILL.md`
```markdown
---
name: scantling-tier
description: Work out and justify the risk tier for a change before committing. Greps for call sites, checks live data and reversibility, and writes the Tier and Tier-reason lines for the commit body. Use before any commit that touches code, on /scantling-tier, "what tier is this", "is this trivial".
---
Read scantling/config.sh for SCANTLING_CODE_PATTERN and SCANTLING_CRITICAL_PATTERN, and SCANTLING.md rule 3.
Work out the path-implied floor from the staged files. Then work out the real blast radius, which is the actual answer:
1. Call sites: grep the repo for every symbol, table, route or key the change touches. Report the count and the files. Zero call sites is the single most common reason a critical path change is genuinely trivial.
2. Live data: does this read or write rows that exist in production right now? How many, and counted how?
3. Reversibility: what would a plain revert NOT undo? Dropped data, sent messages, charged money, rotated secrets, migrated schema.
4. Personas: would any persona in PERSONAS.md observe a difference?
Then state: trivial (nothing observable, fully reversible), standard (observable, reversible), critical (live data, money, auth, personal data, or not fully reversible).
Output the exact lines for the commit body. If the tier is below the floor, the Tier-reason must contain the command and its output, not an assertion:
  Tier: trivial
  Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
Never round the tier up "to be safe". Over-declaring is not free: it is what teaches a project to route around its own process.
```

`.claude/skills/scantling-decide/SKILL.md`
```markdown
---
name: scantling-decide
description: Record a decision or a rejection in Scantling. Writes scantling/decisions/D-xxxx-slug.md plus its INDEX.md line, or appends an R- entry to scantling/knowledge/REJECTED.md. Use when a choice was just made, when the user says "let's go with", "we won't do", "decide", or /scantling-decide.
---
Determine whether this is a decision (something chosen) or a rejection (something declined with no replacement). Grep INDEX.md and REJECTED.md for prior entries on the topic; if one exists, the new record must reference it and, for decisions, mark the old one superseded.
Decision: next free D- number, file from scantling/templates/DECISION.md, all sections filled including "Revisit when" as a concrete trigger. Add the INDEX.md line.
Rejection: next free R- number appended to REJECTED.md with why and a revisit trigger.
Never edit an existing record. Show the file and stop.
```

`.claude/skills/scantling-scenario/SKILL.md`
```markdown
---
name: scantling-scenario
description: Add or update scenarios for the code being changed, in the right area file under scantling/scenarios/areas/. Picks the area and next ID, writes Given/When/Then against a persona including the failure branch, updates the coverage map. Use before committing code, or on /scantling-scenario, "add scenario", "what should we test".
---
Look at the staged or described change. Read scantling/scenarios/AREAS.map and find the area whose pattern matches the changed paths; open only that area file, not the whole corpus.
If no area matches, that is the finding: add a pattern to scantling/scenarios/AREAS.map and a row to the coverage map in scantling/scenarios/SCENARIOS.md in this commit, then create scantling/scenarios/areas/<AREA>.md.
For each behaviour a real persona would notice, write one scenario from scantling/templates/SCENARIO.md with the next free ID in that area. Always include the "Also check" failure branch (timeout, double tap, back button, stale tab, offline).
Update the coverage map row with the specific scenario IDs. Never write "all scenarios in the affected area": a row that cannot be acted on is not a row.
Set Status to untested unless you actually exercised it, in which case record date and method. "Reasoning only" is an honest status; a false pass is not.
```

`.claude/skills/scantling-audit/SKILL.md`
```markdown
---
name: scantling-audit
description: Prepare a push the Scantling way. Runs the configured checks, collects real output, updates scantling/STATE.md, appends an A- entry to scantling/audits/AUDIT-LOG.md, commits as [scantling], then stops and asks for push approval. Use for /scantling-audit, "prepare push", "ready to push", "audit this".
---
Read scantling/config.sh for the target branch rules. Determine the push range (remote branch tip to HEAD).
Run SCANTLING_CHECK_1..3 and any build command the project uses. Capture the actual output lines that matter (error counts, bundle sizes).
Collect the declared Tier of every commit in the range. The entry records the highest one, and quotes any Tier-reason verbatim: a downgrade is exactly what a later reader needs to see.
List scenarios touched in the range and their current Status lines.
For protected branches confirm COUNCIL-2.md exists with a PROCEED verdict; otherwise say so and stop.
For protected branches write the Reality-check line. If the feature was estimated over two days, it needs a real person quoted, or an explicit waiver plus a new AS- entry. Check scantling/audits/ for the two previous entries: if both waived, say so out loud, because three in a row means the rule needs changing rather than waiving again. A waiver may never cite an earlier waiver as its reason.
Run sh scantling/tools/ratio.sh and put the output in the Process ratio line.
If AUDIT-LOG.md is over SCANTLING_AUDIT_MAX_ENTRIES, move the shipped entries unchanged into scantling/audits/archive/AUDIT-LOG-<version>.md and leave a pointer line, before appending.
Rewrite scantling/STATE.md inside its word cap. Append the audit entry from scantling/templates/AUDIT.md with the real evidence. Commit with "[scantling] audit A-xxxx for <feature>" and a Tier line.
Show the entry. Ask: "Push to <branch>? (yes/no)". Do not push without a yes in this conversation for this push.
```

`.claude/skills/scantling-session/SKILL.md`
```markdown
---
name: scantling-session
description: Open or close a Scantling session. "open" reads SCANTLING.md, STATE.md and the in-flight feature and summarises in ten lines. "close" rewrites STATE.md, files unfinished findings into BACKLOG.md, and lists decisions made this session that are not yet recorded. Use at the start and end of work, or /scantling-session open|close.
---
open: read SCANTLING.md, scantling/STATE.md, and only the CURRENT gate file of the in-flight feature, not the whole folder. Closed gates are history: open one only if the work in front of you turns on what it said. Report in at most ten lines: where we are, what is next, what is blocked, which gate the feature is at and its declared tier. Ask nothing unless STATE.md is stale by more than seven days.
close: scan the conversation for choices made and not recorded; run /scantling-decide for each or list them for the user. Move any bug or gap found but not fixed into scantling/BACKLOG.md with an ID, date and source. Rewrite scantling/STATE.md completely, inside SCANTLING_STATE_MAX_WORDS; if it does not fit, the surplus is history and belongs in the audit log or the feature folder, not in STATE.md. Do not commit unless asked.
```

---

## 9. Seeding an existing project

An empty Scantling is a form nobody fills in. On install, spend thirty minutes
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

Then write `STATE.md` and the "Project specifics" block of `SCANTLING.md`.

### Existing tracking docs

1.0 said: do not migrate on day one, map the old files, let new entries go to
Scantling, migrate when a file is next rewritten anyway. That advice was wrong, and
the first adopter paid for it within a day. It produces two systems of record
by default. Closing one backlog item meant editing `ISSUES.md` and
`scantling/BACKLOG.md`; a branch change meant editing `HANDOFF.md` and
`scantling/STATE.md`. The instruction file still pointed at a release doc that had
frozen, so the mandated checklist told agents to update a dead file.

Half-migrated is the most expensive state available, and "migrate it later"
has no forcing function, so later does not arrive.

Do this instead, at install (step 5), per file:

- **Replace it.** Move the live content into Scantling now, stamp the old file with
  the archive banner, add it to `SCANTLING_ARCHIVED_PATTERN`. The hook then refuses
  edits, so drift is not possible rather than merely discouraged. This is the
  default for anything Scantling covers: state, backlog, releases, decisions.
- **Keep it.** Scantling does not cover it. Write down what it owns, and make sure
  Scantling never states the same fact.
- **Defer it.** With a date and a trigger, in `SOURCES.md`. This is a decision
  to run two records for a while, with a cost, taken deliberately.

Then grep every agent-instruction file for references to what you replaced.
An instruction that points at a frozen file is the half-migration teaching the
next agent to write to the wrong place.

If the owner does not want to migrate at all, that is legitimate: record a
`D-`, and scope Scantling to the mechanisms the old files do not cover (council,
audit, scenarios, decisions) rather than installing `STATE.md` and
`BACKLOG.md` beside their existing twins.

A worked example is in `examples/adopters/` in the Scantling repository
(github.com/acshriv-alt/scantling).

---

## 10. Adapting Scantling

Scantling is a starting point. Change it through its own mechanism: a `D-` record
in the project, and a change to `SCANTLING.md` or `config.sh` in the same commit.
Things commonly adjusted:

- Gate 2 on every push to the working branch (stricter) or only at release
  (looser). Default: release branch only.
- A sixth council voice (Accessibility, Finance, Legal).
- Scenario waiver never allowed (remove the env check from pre-commit).
- Outcome review at +30 days for low-traffic products.

Do not remove: the search-before-propose rule, the audit entry on push, the
verdict line format. Those are what make the hooks and the habit hold.

---

## 11. What changed in 2.0.0, and how to migrate from Keel

### Why

BloodKonnect India installed Keel 1.0.0 on 2026-09-13 and measured it after
one working session. In that session Scantling prevented two expensive mistakes: a
production bug that would have blanked a requestor's phone number mid
donation, and a weeks-long feature carrying legal exposure. Neither would have
been caught by a handoff document. That part works and is unchanged.

What did not work was the price:

| Measured | Value |
|---|---|
| Commits carrying no application code | 8 of 10 since install |
| Markdown vs application code | 109,580 words vs 102,655 |
| Mandated read before work starts | 8,317 words, growing |
| One Gate 1 pass | 322,122 tokens, against ~1,200 for the grep that found the same defect |
| Reality check rule: fired / waived | 2 / 2, the second citing the first as precedent |

Scantling was not failing. It was mispriced: it charged for a table drop with zero
call sites what it charged for a schema migration on a live donor database.

### Changes

| Change | Addresses |
|---|---|
| One system of record settled at install; archived files frozen by hook; `SOURCES.md` | Two records, every fact written twice |
| Declared risk tier per commit; path sets a floor, not a verdict; downgrades carry evidence | Trivial changes paying the maximum toll |
| Evidence pass split from judgement; voices never read the repo | Five redundant reads of the same files, on every gate forever |
| `STATE.md` capped by hook; audits archived per release; one gate file loaded, not the folder | A mandated session read that only grew |
| Reality check moved to the merge gate, waiver may not cite a waiver | A rule waived on every invocation |
| `SCENARIOS.md` split into an index plus per-area files; hook checks the touched area | A scenario file past the size anyone reads |
| `scantling/tools/ratio.sh` and a `Process ratio:` line in the audit entry | Scantling could not measure its own cost |

### Does an existing Keel 1.0 install break?

No. Nothing that follows is urgent, and nothing happens to a repository that
ignores this release entirely.

Keel and Scantling are installed by **copying files**. The target repository
owns its own `keel/hooks/`, and there is no package manager, no dependency and
no network call anywhere in the framework. A Keel 1.0 install keeps working
exactly as it did, indefinitely. Nothing reaches in to change it.

The flip side is that nothing tells it either. Keel 1.0 wrote no version
marker, so an installed repo cannot say which version it runs, and has no way
to learn that a newer one exists. That is the same class of failure the
framework exists to prevent, which is why `SCANTLING_VERSION` now exists and
why the pre-push hook warns when the config and the hooks disagree.

If you maintain a Keel install and want nothing to do with 2.0, the correct
action is to record a `D-` saying so, with a revisit trigger. Then the choice
is on the record instead of being a thing nobody got round to.

### Migrating a Keel 1.0 install

The mechanical half is scripted: run `sh tools/migrate-from-keel.sh` from a
clone of the Scantling repository, pointed at your repo. It renames the tree,
rewrites the identifiers, stages the result and stops without committing, so
you review the diff before anything lands. Pass `--dry-run` first.

What it does, and what it deliberately leaves to you:

| Step | Scripted | Yours |
|---|---|---|
| `KEEL.md` -> `SCANTLING.md`, `keel/` -> `scantling/` | yes | |
| `KEEL_*` -> `SCANTLING_*`, `[keel]` -> `[scantling]`, skills renamed | yes | |
| `core.hooksPath` repointed, hooks and templates replaced with 2.0 | yes | |
| Agent pointer files (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`) updated | yes | |
| Your branch lists, patterns and check commands preserved | yes | |
| `SCANTLING_VERSION=2.0.0` written | yes | |
| Scenarios split from `SCENARIOS.md` into area files | | **yes** |
| `AREAS.map` filled with your real code paths | | **yes** |
| `SOURCES.md` filled: replaced / kept / deferred per old doc | | **yes** |
| `STATE.md` trimmed under 400 words | | **yes** |
| Audit entries archived per release | | **yes** |
| A tier declared in each in-flight brief | | **yes** |

The right-hand column is judgement about your repository and cannot be
scripted. It is also where the value is: splitting scenarios by area and
settling the system of record are the two findings that cost the first adopter
the most.

Do the mechanical half in one `[scantling]` commit at tier `standard`, then
the judgement half in as many as it takes. In-flight features keep their
existing `COUNCIL-1.md` and do not rerun Gate 1; just declare a tier in the
brief before the next commit.

Two things to know before you start:

- **The commit tag changes.** New commits need `[scantling]`, not `[keel]`.
  History is untouched: the hooks only ever read the message being written.
- **Your first push after migrating will be noisier than usual.** The 2.0
  pre-push hook wants a `Reality-check:` line and an archived audit log, and
  your last Keel-era audit entry has neither. Write one fresh audit entry for
  the migration itself and the gate opens.

### If you are renaming the GitHub repository too

GitHub redirects the old URL after a rename, so existing clones keep fetching
and old links keep resolving. Update the remote anyway, for clarity:

```sh
git remote set-url origin https://github.com/<you>/scantling
```

### What 2.0 does not fix

The tier is self-declared, so it can be declared dishonestly. The defence is
that the claim and its evidence are on the record and readable at the outcome
review, not that the hook can tell the truth from a lie. A project that
systematically under-declares will find out at an incident, and the honest
response is a `D-` that widens `SCANTLING_CRITICAL_PATTERN`, not more ceremony
everywhere.

These changes come from one adopter over one session. That is a thin evidence
base. They should be re-measured after five more features rather than treated
as settled.
