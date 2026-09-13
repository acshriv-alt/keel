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
