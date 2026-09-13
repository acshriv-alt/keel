# Keel

**Project memory, decision log, challenge council and push audit for
repositories built with coding agents.** Plain markdown and POSIX git hooks.
Works with Claude Code, Cursor, Codex, Copilot, Aider, Windsurf, Gemini, or a
human with a terminal.

Keel fixes three things that go wrong when a small team (often one person)
ships software through agents:

| Problem | What it looks like | Keel's answer |
|---|---|---|
| **Context loss** | Every session re-reads a 600-line handoff, or worse, re-derives the state from git | `KEEL.md` under 120 lines, `STATE.md` under 60, everything else loaded on demand |
| **Re-litigated decisions** | The agent proposes the thing you rejected in June. You explain again. Credits burn | `decisions/` and `REJECTED.md` with IDs; rule one is "search before you propose" |
| **Unchallenged pushes** | Feature looks fine in the demo, fails for the real user at 2 am on a bad phone; nobody can say what was verified before the push | Five-voice council at two gates, scenarios with personas, an audit entry per push with real command output, enforced by hooks |

---

## Install

Three ways. All produce the same tree. Pick one.

**1. Let your agent do it** (recommended, ~10 minutes plus 30 minutes of seeding)

Copy [`KEEL_BOOTSTRAP.md`](KEEL_BOOTSTRAP.md) into the target repo, or paste
it into the agent's first message, and say:

> Install Keel following KEEL_BOOTSTRAP.md. Stop after the install commit.

The bootstrap is self-contained: every file's content is inside it.

**2. Shell installer**

```sh
git clone https://github.com/acshriv-alt/keel
sh keel/install.sh /path/to/your/repo            # template + hooks + pointer
sh keel/install.sh /path/to/your/repo --skills   # also the Claude Code skills
```

Copies [`template/`](template/) without overwriting anything, sets
`core.hooksPath`, appends a one-line pointer to `CLAUDE.md` / `AGENTS.md` /
`.cursorrules` if present.

**3. Manual**

Copy `template/` into your repo root, run `sh keel/hooks/install.sh`, add
`Read KEEL.md first.` to your agent instruction file.

Then, whichever way: fill the `{{PLACEHOLDERS}}` in `KEEL.md` and
`keel/config.sh`, and **seed** `CONSTRAINTS.md`, `REJECTED.md` and
`decisions/` with what you already know. See [INSTALL.md](INSTALL.md).

---

## What lands in your repo

```
KEEL.md                    entry point. Hard rules, lifecycle, where things live. Read every session.
AGENTS.md                  one-line pointer (or appended to your existing CLAUDE.md / .cursorrules)
keel/
  STATE.md                 where the project is right now. Rewritten at the end of every session.
  BACKLOG.md  CHANGELOG.md
  config.sh                branches, code patterns, check commands for the hooks
  decisions/               D-0001-slug.md per decision + INDEX.md (one line each)
  knowledge/               CONSTRAINTS.md (facts learned the hard way)
                           ASSUMPTIONS.md (beliefs owed proof)
                           REJECTED.md (ideas declined, why, and when to revisit)
  features/F-0001-slug/    BRIEF.md, COUNCIL-1.md, COUNCIL-2.md, OUTCOME.md
  council/                 protocol + five persona files
  scenarios/               PERSONAS.md (real users, real devices), SCENARIOS.md (Given/When/Then, IDs, last run)
  audits/AUDIT-LOG.md      append-only, one entry per push, with evidence
  incidents/  runbooks/  templates/
  hooks/                   commit-msg, pre-commit, pre-push, install.sh
.claude/skills/keel-*/     optional slash commands for Claude Code
```

---

## How a feature moves

```
idea -> grep decisions + REJECTED -> F-xxxx/BRIEF.md
     -> Gate 1 council on the brief -> decisions recorded
     -> scenarios written first -> code, commits tagged [F-xxxx]
     -> Gate 2 council on the diff
     -> audit entry with real output -> owner approves -> push
     -> +14 days: OUTCOME.md -> feeds REJECTED / decisions / constraints
```

Bug fixes skip Gate 1. Everything still needs a scenario and, on audited
branches, an audit entry. Details in [docs/WORKFLOW.md](docs/WORKFLOW.md).

---

## The council

Five voices challenge every feature twice: once on the idea, once on the
diff. **User** walks the scenario on the worst realistic device. **Adversary**
finds the cheapest abuse. **Operator** prices it at 10x and asks who gets
paged. **Skeptic** quotes what was already rejected and names the simpler
alternative. **Domain** checks the law, the standard, and what the incumbent
does. Then a pre-mortem: it is 90 days later and this failed, why.

Each voice is capped at 150 words. The verdict is one of four exact strings
that the hooks read: `PROCEED`, `PROCEED WITH CHANGES`, `REWORK`, `REJECT`.
One agent can play all five; runtimes with subagents run them in parallel.
Guide: [docs/COUNCIL.md](docs/COUNCIL.md).

---

## What the hooks block

| Hook | Blocks |
|---|---|
| `commit-msg` | no tag (`[F-0001]` `[fix]` `[hotfix]` `[chore]` `[docs]` `[keel]`); a feature commit whose brief is missing or whose Gate 1 verdict is not PROCEED; a scenario waiver without a written reason |
| `pre-commit` | code changed without a change to `SCENARIOS.md` (waivable with a reason); em dash in added lines (optional) |
| `pre-push` | push to an audited branch without a new audit entry and a `STATE.md` update; push to a protected branch whose last audit entry is not `Gate 2: PROCEED`; any configured check (`tsc`, tests) failing |

Verified with 13 cases in Git for Windows sh; the matrix is in
[docs/HOOKS.md](docs/HOOKS.md). `--no-verify` still exists. Using it is a
decision, and Keel asks you to write it down.

---

## Token and credit effect

Measured on the project Keel was extracted from (a Next.js app with about a
year of history, one owner, several agents):

| Loaded at session open | Lines | Approx. tokens |
|---|---|---|
| Before: handoff file + agent rules file | 711 | 18,800 |
| After: `KEEL.md` + `STATE.md` + in-flight brief | about 220 | about 2,500 |

That is a one-time saving per session. The recurring saving is larger and
harder to measure: an agent that greps `REJECTED.md` and finds the idea in
ten seconds does not spend twenty minutes designing it, and a council that
kills a feature at Gate 1 saves the whole build. Word caps on council
verdicts and briefs keep the framework's own files from becoming the next
600-line handoff.

---

## Better brainstorming

Keel's brainstorming protocol (in [docs/WORKFLOW.md](docs/WORKFLOW.md)) is
six timed steps that end in a file, not a chat: problem first, persona walk,
constraints check, three options including "do nothing", Skeptic and User
voices only, write it down. The persona walk is where the owner's real-world
knowledge gets transferred to the agent: the agent narrates the persona living
the problem today, the owner corrects the narration.

For anything over two days of work, Gate 1 cannot pass until one real person
matching the persona has been asked and quoted. Agents cannot do that step.

---

## Docs

- [INSTALL.md](INSTALL.md): the three install paths, seeding, first push.
- [docs/CONCEPTS.md](docs/CONCEPTS.md): the five mechanisms and why each exists.
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

MIT licence. Version 1.0.0. See [CHANGELOG.md](CHANGELOG.md) and
[CONTRIBUTING.md](CONTRIBUTING.md).
