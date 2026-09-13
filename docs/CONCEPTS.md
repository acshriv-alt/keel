# Concepts

Keel is five mechanisms. Each exists because a specific failure kept
happening in agent-built projects. Remove one and that failure returns.

## 1. State: `keel/STATE.md`

**Failure it prevents**: the agent spends the first twenty minutes of every
session reconstructing where things are from git log and a long handoff, and
gets it slightly wrong.

**Shape**: five headings, under 60 lines. Now (branch, production, pending
migrations, env drift). In flight. Next three, in order. Blocked. Last
session in six lines.

**Rule**: rewritten, never appended. The previous state has no value once
superseded; history lives in git.

## 2. Decisions and rejections

**Failure it prevents**: the agent proposes, in good faith and in detail, an
approach the owner rejected months ago. The owner explains again. Multiply by
every agent and every session.

**Shape**: one file per decision (`D-0001-slug.md`) with Context, Options
considered (each rejected option says why), Decision, Consequences, Revisit
when, Evidence. `INDEX.md` has one line per decision so grepping is cheap.
`REJECTED.md` is append-only: idea, why not, revisit trigger.

**Rule one of Keel**: search before you propose. The agent greps both files
for the topic and quotes hits with IDs before saying anything else. Reopening
requires new evidence and a new record that supersedes the old one.

**What counts**: two viable options and one chosen; a default changed; a
dependency added or removed; a rule changed; the owner said "not that". Not:
naming, formatting, anything reversible in ten minutes with no downstream
effect.

## 3. Knowledge: constraints and assumptions

**Failure it prevents**: rediscovering that the hosting plan allows two cron
jobs, that the SMS provider needs a regulatory registration, that a certain
browser has no push API. Each rediscovery costs a session and sometimes a
production incident.

**Shape**: `CONSTRAINTS.md` is a table of facts with evidence and the date
learned. `ASSUMPTIONS.md` is a ledger of beliefs a feature depends on, each
with a way to verify and a status: unverified, verified, false.

**Rule**: a brief lists the constraints that apply and the assumptions it
depends on, by ID. The council reads `CONSTRAINTS.md` before speaking.
Outcome reviews flip assumptions and add constraints.

## 4. Council at two gates

**Failure it prevents**: the feature that works in the demo and fails for the
actual user on an old phone in a basement, or opens an abuse path, or costs
ten times what anyone estimated, or duplicates something already rejected.
Reviews by the author, or by one agent playing "reviewer", miss these because
they share the author's frame.

**Shape**: five fixed voices with distinct frames. User (worst realistic
conditions). Adversary (cheapest abuse). Operator (cost, scale, on-call).
Skeptic (prior rejections, simpler alternative, kill criteria). Domain (law,
standard, incumbent). Gate 1 on the brief with a pre-mortem. Gate 2 on the
diff. Word caps. A verdict line the hooks can read.

**Rule**: `[F-xxxx]` commits are refused until Gate 1 says PROCEED. Pushes to
protected branches are refused until the audit entry says Gate 2 PROCEED.
Every "PROCEED WITH CHANGES" item is a checkbox that Gate 2 verifies first.

**Why two gates**: Gate 1 is cheap (a brief, a few hundred words) and kills
bad features before any code exists. Gate 2 catches what changed during the
build. One gate gets you one or the other.

## 5. Scenarios and audit

**Failure it prevents**: "tests pass" as a claim with nothing behind it; a
push where nobody can say afterwards what was checked; behaviour that only
exists in someone's head.

**Shape**: `PERSONAS.md` describes real actors with device, network, moment,
and the friction that makes them give up. `SCENARIOS.md` holds Given / When /
Then items with IDs, a persona, a failure branch ("Also check"), a last-run
status with date and method, and a coverage map to code paths.
`AUDIT-LOG.md` gets one append-only entry per push: range, feature, Gate 2
verdict, each check command with what it printed, scenarios run, migrations,
rollback, risk, who approved.

**Rule**: code changes need a scenario change in the same commit or a
written waiver. Pushes need an audit entry. Evidence is command output, not
adjectives.

## Two-tier loading

Everything above could become a second bloated handoff. Keel prevents that
structurally: `KEEL.md` under 120 lines is the only file always loaded. It
tells the agent where each other file is and when to open it. Briefs under
120 lines, verdicts under 150, `STATE.md` under 60. Append-only logs rotate
yearly into `archive/`.

## Why files and hooks, not a tool

Files in the repo travel with the code, survive vendor changes, diff in pull
requests, and can be read by any agent or human. Git hooks run everywhere
git runs, need no server, and fail loudly with a message that says what is
missing. A dashboard would be nicer to look at and would be abandoned in a
month.
