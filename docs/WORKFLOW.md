# Workflow

## Session protocol

**Open**: read `KEEL.md`, `keel/STATE.md`, and every file in the in-flight
feature folder. Ten lines back to the owner: where we are, what is next, what
is blocked, which gate the feature is at. Ask nothing unless `STATE.md` is
more than seven days old.

**During**: record decisions the moment they are made. A decision that lives
only in the chat does not exist by the next session.

**Close**: rewrite `STATE.md` completely. Move anything found but not fixed
into `BACKLOG.md` with an ID, date and source. List decisions made this
session that were not recorded, and record them.

With Claude Code: `/keel-session open` and `/keel-session close`.

## Feature lifecycle

### Intake (10 minutes, no code)

1. Idea in one sentence.
2. Grep `keel/decisions/INDEX.md`, `keel/knowledge/REJECTED.md`,
   `keel/BACKLOG.md`. Quote hits with IDs.
3. Pick a persona from `PERSONAS.md`. If none fits, write one first.
4. Create `keel/features/F-xxxx-slug/BRIEF.md` from the template. The "one
   scenario" section is the test: if it cannot be written in the persona's
   words, the feature is not ready.
5. Add assumptions to `ASSUMPTIONS.md` and reference them by ID.

### Gate 1

Run the council on the brief (`docs/COUNCIL.md`). Write `COUNCIL-1.md`.
Record decisions and rejections. Apply required changes to the brief and tick
them. Only then write code.

### Build

1. Add scenario stubs to `SCENARIOS.md`, `Status: untested`.
2. Code. Small commits, every message tagged `[F-xxxx]`.
3. When a scenario is actually exercised, update its status with date and
   method: manual on a named device, automated test, or careful reasoning.
4. Log decisions as they happen.

### Gate 2

Run the council on the diff range plus the brief and `COUNCIL-1.md`. The
chair first confirms every Gate 1 checkbox is ticked with a commit reference.
Write `COUNCIL-2.md`. Fix required changes, tick them.

### Audit and push

1. Rewrite `STATE.md`.
2. Run the configured checks and any build. Capture the lines that matter.
3. Append the audit entry to `AUDIT-LOG.md`.
4. Commit `[keel] audit A-xxxx for F-xxxx`.
5. Stop. Show the owner the entry. Push only on explicit approval for this
   push. An earlier "go ahead" does not carry over.

With Claude Code: `/keel-audit`.

### Outcome review (+14 days after production)

Write `OUTCOME.md`: metric said versus actual, what happened, kill criteria
met or not, action. Move learned facts to `CONSTRAINTS.md`, flip assumptions,
add `R-` entries for approaches not to repeat, update `BACKLOG.md`.

## Bug fixes

`[fix]`: no Gate 1. Scenario required. Audit entry required on audited
branches. Gate 2 required when the fix touches `KEEL_CRITICAL_PATTERN`
(auth, payments, data model, background jobs, whatever the project lists).

`[hotfix]` on production: same, plus an `INC-` file within 24 hours using
`keel/templates/INCIDENT.md`. The "Why it was not caught" section names the
missing scenario or the skipped council question and adds them.

## Brainstorming sessions (owner and agent, no code)

Six timed steps that end in a file. A session that ends without a file will
be repeated later.

| Step | Minutes | What happens |
|---|---|---|
| Problem first | 5 | One paragraph. Who is hurt, when, how often. No solution words. |
| Persona walk | 10 | The agent narrates the persona living the problem today, step by step, on their real device. The owner corrects the narration. This is where the owner's real-world knowledge transfers. |
| Constraints check | 2 | Read the `CONSTRAINTS.md` rows for this area aloud. |
| Three options | 10 | Agent proposes three, always including "do nothing" and "the simplest thing that gets 80%". One line each with cost and risk. |
| Gate 1 lite | 10 | Skeptic and User voices only. |
| Write it down | 5 | A brief, an `R-` entry, or a `D-` record. |

What makes this accurate to the real world rather than to the chat:

- The persona walk forces concrete conditions: which phone, which network,
  what time, what the person already knows and does not.
- The constraints check stops the group from designing around a limit that
  is already known to be hard.
- "Do nothing" as a mandatory option exposes features that solve a problem
  nobody has.
- For anything over two days of work, Gate 1 proper cannot pass until one
  real person matching the persona has been asked and quoted in the brief.
  Agents cannot do that step. The owner does, before the next session.

## Tags

| Tag | Use | Needs |
|---|---|---|
| `[F-0001]` | feature work | brief + Gate 1 PROCEED |
| `[fix]` | bug fix | scenario |
| `[hotfix]` | production fix | scenario + incident file within 24 h |
| `[chore]` | dependencies, tooling, refactor with no behaviour change | scenario or waiver |
| `[docs]` | documentation only | nothing |
| `[keel]` | Keel's own files: state, audit, decisions | nothing |

## Waivers

`KEEL_WAIVE_SCENARIOS=1 git commit -m "[chore] bump deps" -m "Waiver: no behaviour change, lockfile only"`

The env var lets pre-commit pass; commit-msg then insists on a `Waiver:`
line of at least ten characters. The waiver is in the commit, so it is in
the history.
