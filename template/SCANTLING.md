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
