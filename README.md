# Scantling

**Project memory, decision log, challenge council and push audit for
repositories built with coding agents.** Plain markdown and POSIX git hooks.
Works with Claude Code, Cursor, Codex, Copilot, Aider, Windsurf, Gemini, or a
human with a terminal.

Scantling fixes three things that go wrong when a small team (often one person)
ships software through agents:

| Problem | What it looks like | Scantling's answer |
|---|---|---|
| **Context loss** | Every session re-reads a 600-line handoff, or worse, re-derives the state from git | `SCANTLING.md` under 120 lines, `STATE.md` capped at 400 words by a hook, everything else loaded on demand |
| **Re-litigated decisions** | The agent proposes the thing you rejected in June. You explain again. Credits burn | `decisions/` and `REJECTED.md` with IDs; rule one is "search before you propose" |
| **Unchallenged pushes** | Feature looks fine in the demo, fails for the real user at 2 am on a bad phone; nobody can say what was verified before the push | Five-voice council, scenarios with personas, an audit entry per push with real command output, enforced by hooks |
| **Process that outcosts the work** | The framework charges a table drop with zero call sites what it charges a live migration, so people start routing around it | Every commit declares a risk tier; only `critical` pulls the full council |

---

## Already running Keel?

Scantling was called Keel through 1.0.0. **Nothing breaks.** Scantling installs
by copying files, with no dependency on this repository and no network call, so
a Keel install keeps working indefinitely whether or not you ever migrate.

When you want to:

```sh
git clone https://github.com/acshriv-alt/scantling
sh scantling/tools/migrate-from-keel.sh --dry-run /path/to/your/repo   # look first
sh scantling/tools/migrate-from-keel.sh /path/to/your/repo             # stages, never commits
```

It renames the tree, rewrites the identifiers, installs the 2.0 hooks, keeps
your branch lists, patterns and check commands, and stops so you read the diff.
Append-only records (audit log, decisions, rejections, incidents) keep their
Keel-era wording on purpose: they are statements about what was true when they
were written, and rule 9 says they are never edited in place.

What it cannot do for you is the part that matters: splitting scenarios into
area files and settling the system of record in `SOURCES.md`. Section 11 of
[`SCANTLING_BOOTSTRAP.md`](SCANTLING_BOOTSTRAP.md) has the full list.

---

## Install

Three ways. All produce the same tree. Pick one.

**1. Let your agent do it** (recommended, ~10 minutes plus 30 minutes of seeding)

Copy [`SCANTLING_BOOTSTRAP.md`](SCANTLING_BOOTSTRAP.md) into the target repo, or paste
it into the agent's first message, and say:

> Install Scantling following SCANTLING_BOOTSTRAP.md. Stop after the install commit.

The bootstrap is self-contained: every file's content is inside it.

**2. Shell installer**

```sh
git clone https://github.com/acshriv-alt/scantling
sh scantling/install.sh /path/to/your/repo            # template + hooks + pointer
sh scantling/install.sh /path/to/your/repo --skills   # also the Claude Code skills
```

Copies [`template/`](template/) without overwriting anything, sets
`core.hooksPath`, appends a one-line pointer to `CLAUDE.md` / `AGENTS.md` /
`.cursorrules` if present.

**3. Manual**

Copy `template/` into your repo root, run `sh scantling/hooks/install.sh`, add
`Read SCANTLING.md first.` to your agent instruction file.

Then, whichever way: fill the `{{PLACEHOLDERS}}` in `SCANTLING.md` and
`scantling/config.sh`, and **seed** `CONSTRAINTS.md`, `REJECTED.md` and
`decisions/` with what you already know. See [INSTALL.md](INSTALL.md).

---

## What lands in your repo

```
SCANTLING.md                    entry point. Hard rules, lifecycle, where things live. Read every session.
AGENTS.md                  one-line pointer (or appended to your existing CLAUDE.md / .cursorrules)
scantling/
  STATE.md                 where the project is right now. Rewritten at the end of every session.
  BACKLOG.md  CHANGELOG.md
  config.sh                branches, code patterns, check commands for the hooks
  decisions/               D-0001-slug.md per decision + INDEX.md (one line each)
  knowledge/               CONSTRAINTS.md (facts learned the hard way)
                           ASSUMPTIONS.md (beliefs owed proof)
                           REJECTED.md (ideas declined, why, and when to revisit)
                           SOURCES.md (which file owns which fact, so nothing is written twice)
  features/F-0001-slug/    BRIEF.md, EVIDENCE.md, COUNCIL-1.md, COUNCIL-2.md, OUTCOME.md
  council/                 protocol + five persona files
  scenarios/               PERSONAS.md (real users, real devices)
                           SCENARIOS.md (index + coverage map), AREAS.map, areas/*.md (the scenarios)
  audits/AUDIT-LOG.md      append-only, one entry per push, with evidence; archive/ per release
  incidents/  runbooks/  templates/
  tools/ratio.sh           process commits against code commits: Scantling's own drag gauge
  hooks/                   commit-msg, pre-commit, pre-push, install.sh
.claude/skills/scantling-*/     optional slash commands for Claude Code
```

---

## How a feature moves

```
idea -> grep decisions + REJECTED -> F-xxxx/BRIEF.md -> declare the tier
     -> one evidence pass (EVIDENCE.md: commands and their output)
     -> Gate 1 council over that sheet  (solo at standard, five voices at critical)
     -> scenarios written first -> code, commits tagged [F-xxxx] + Tier:
     -> Gate 2 council on the diff      (critical only)
     -> audit entry with real output -> owner approves -> push
     -> +14 days: OUTCOME.md -> feeds REJECTED / decisions / constraints
```

Bug fixes skip Gate 1. What the rest costs depends on the tier the commit
declares, not on the directory it lands in. Details in
[docs/WORKFLOW.md](docs/WORKFLOW.md).

---

## Risk tiers

Scantling's value concentrates in changes that are expensive to reverse. Spreading
its cost flat across everything is what makes people batch unrelated fixes to
amortise the ceremony, or mislabel a feature to skip a gate. So every commit
that touches code names its blast radius:

| Tier | Means | Costs |
|---|---|---|
| `trivial` | No persona sees a difference; one revert undoes it completely | The tier line |
| `standard` | A persona notices; nothing irreversible | Scenario, and Gate 1 if it is a feature |
| `critical` | Live data, money, auth, personal data, or a revert would not undo it | Scenario, both gates, full council |

Paths set a floor. Going below it is allowed, and costs one line of evidence:

```
Tier: trivial
Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
```

A regex knows where a change landed; it cannot know what depends on it. A
signed claim with its evidence can be audited at the outcome review. An
inference cannot.

---

## The council

Five voices challenge every feature twice: once on the idea, once on the
diff. **User** walks the scenario on the worst realistic device. **Adversary**
finds the cheapest abuse. **Operator** prices it at 10x and asks who gets
paged. **Skeptic** quotes what was already rejected and names the simpler
alternative. **Domain** checks the law, the standard, and what the incumbent
does. Then a pre-mortem: it is 90 days later and this failed, why.

**The voices do not read the repository.** One cheap pass writes
`EVIDENCE.md` first: every line a command and what it printed. The voices then
reason over that sheet and the brief, and nothing else. Five independent
judgements is the point; five independent reads of the same files is a tax
that recurs on every gate forever. One measured Gate 1 pass cost 322,122
tokens, and three voices reported the same defect that a single `grep -rn`
surfaced for about 1,200. A voice needing a missing fact writes
`Evidence gap:`, and the chair fills it once.

Each voice is capped at 150 words. The verdict is one of four exact strings
that the hooks read: `PROCEED`, `PROCEED WITH CHANGES`, `REWORK`, `REJECT`.
At tier `standard` one agent plays all five in sequence; at `critical`,
runtimes with subagents run them in parallel.
Guide: [docs/COUNCIL.md](docs/COUNCIL.md).

---

## What the hooks block

| Hook | Blocks |
|---|---|
| `commit-msg` | no tag (`[F-0001]` `[fix]` `[hotfix]` `[chore]` `[docs]` `[scantling]`); a code change with no `Tier:` line; a tier below the path floor with no `Tier-reason:`; a feature whose brief is missing, or which at `standard` and above lacks a Gate 1 PROCEED or an `EVIDENCE.md`; code at `standard` and above with no scenario in the area it touches; a waiver without a written reason |
| `pre-commit` | editing a file frozen in `SCANTLING_ARCHIVED_PATTERN`; `STATE.md` over its word cap; em dash in added lines (optional) |
| `pre-push` | push to an audited branch without a new audit entry and a `STATE.md` update; push to a protected branch whose last audit entry is not `Gate 2: PROCEED` or has no `Reality-check:` line; `AUDIT-LOG.md` past its archive threshold; any configured check (`tsc`, tests) failing |

Verified with 27 cases in Git for Windows sh; the matrix is in
[docs/HOOKS.md](docs/HOOKS.md). `--no-verify` still exists. Using it is a
decision, and Scantling asks you to write it down.

---

## Token and credit effect

Measured on the project Scantling was extracted from (a Next.js app with about a
year of history, one owner, several agents):

| Loaded at session open | Lines | Approx. tokens |
|---|---|---|
| Before: handoff file + agent rules file | 711 | 18,800 |
| After: `SCANTLING.md` + `STATE.md` + in-flight brief | about 220 | about 2,500 |

That is a one-time saving per session. The recurring saving is larger and
harder to measure: an agent that greps `REJECTED.md` and finds the idea in
ten seconds does not spend twenty minutes designing it, and a council that
kills a feature at Gate 1 saves the whole build. Word caps on council
verdicts and briefs keep the framework's own files from becoming the next
600-line handoff.

---

## Better brainstorming

Scantling's brainstorming protocol (in [docs/WORKFLOW.md](docs/WORKFLOW.md)) is
six timed steps that end in a file, not a chat: problem first, persona walk,
constraints check, three options including "do nothing", Skeptic and User
voices only, write it down. The persona walk is where the owner's real-world
knowledge gets transferred to the agent: the agent narrates the persona living
the problem today, the owner corrects the narration.

For anything over two days of work, one real person matching the persona must
be asked and quoted. Agents cannot do that step. It does not block Gate 1 or
the build: it blocks the push to a protected branch, which is when the work
reaches users, and the audit entry carries the answer or an explicit waiver.
A waiver may not cite an earlier waiver as its reason.

---

## Docs

- [INSTALL.md](INSTALL.md): the three install paths, seeding, first push.
- [docs/CONCEPTS.md](docs/CONCEPTS.md): the six mechanisms and why each exists.
- [docs/TIERS.md](docs/TIERS.md): how to pick a tier, and the cost argument behind it.
- [docs/WORKFLOW.md](docs/WORKFLOW.md): lifecycle, sessions, brainstorming, bug fixes.
- [docs/COUNCIL.md](docs/COUNCIL.md): running the council well, good and bad challenges.
- [docs/HOOKS.md](docs/HOOKS.md): behaviour, bypass, Windows, chaining, CI, smoke test.
- [docs/AGENTS.md](docs/AGENTS.md): pointer snippets for each agent and editor.
- [docs/FAQ.md](docs/FAQ.md).
- [examples/](examples/): a filled decision, brief, council verdict, audit entry, state file, and a scrubbed adoption plan for an existing project.

---

## Principles

Search before you propose. Evidence, not adjectives. Absolute dates.
Append-only logs. Small always-loaded index, everything else on demand.
Every push audited. Every idea challenged twice. Every decision written the
moment it is made.

Price ceremony to risk, and make the author state the risk on the record.
Gather evidence once, judge independently. Give every growing file a
compaction path. One fact, one home.

MIT licence. Version 2.0.0, released 2026-09-14. Previously named Keel; see
[CHANGELOG.md](CHANGELOG.md) for the rename and the migration path, and
[CONTRIBUTING.md](CONTRIBUTING.md).
