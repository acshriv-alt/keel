# Risk tiers

Every commit that touches code declares one line:

```
Tier: trivial | standard | critical
```

That line decides what the rest of Scantling charges for the change. This document
is about why the line exists and how to pick honestly.

## The problem tiers solve

Keel 1.0, this project's previous name, priced ceremony by file path. `db/` was in `SCANTLING_CRITICAL_PATTERN`,
so anything under `db/` paid the maximum: a scenario, a Gate 2 council, an
audit entry, a `STATE.md` rewrite.

Measured in the first adopter's repository, closing one backlog item that
deleted a table nothing referenced looked like this:

| | |
|---|---|
| Application code changed | 19 lines deleted |
| Call sites affected | 0 |
| Files touched to land it | 8 |
| Ceremony required | scenario + Gate 2 + audit + STATE |

Path matching cannot tell "drop dead schema" from "alter a column 143 donors
depend on". Both live in `db/`. The framework had no concept of blast radius,
only of location.

## Why this matters more than it looks

The obvious cost is the wasted work. The real cost is second-order.

When following the process costs more than the change itself, the rational
move is to route around the process: batch unrelated fixes into one commit to
amortise the ceremony, label a feature `[fix]` to skip Gate 1, stop recording
small decisions because the recording costs more than the decision did.

Every one of those degrades the audit trail Scantling exists to produce. **A
framework that is expensive to follow honestly will eventually be followed
dishonestly.** Tiering is not a convenience. It is what keeps the expensive
parts credible, by making sure they are only charged where they are worth it.

## The tiers

| Tier | Means | Costs |
|---|---|---|
| `trivial` | No persona sees a difference. One revert undoes it completely, with no data effect. | The tier line, and a `Tier-reason:` if a path implied more |
| `standard` | A persona notices. Nothing irreversible: no live data destroyed, no money moved, no auth changed. | Scenario in the touched area, and Gate 1 if it is a feature |
| `critical` | Live data, money, auth, personal data, or anything a plain revert would not undo. | Scenario, both gates, the full five-voice council |

**The tier is a claim about blast radius, not about diff size.** A 400 line
deletion of code nothing calls is `trivial`. A one character change to a
default retention period is `critical`. If you find yourself reasoning about
how big the diff is, you are answering the wrong question.

## Picking one

Four questions, in order. The first `yes` sets the tier.

1. **Would a plain `git revert` leave anything behind?** Dropped rows, sent
   messages, charged cards, rotated secrets, an applied migration, a cache
   nobody can clear. If yes: `critical`.
2. **Does it read or write data that exists in production right now?** Not
   "could in principle": rows that exist today. If yes: `critical`.
3. **Would any persona in `PERSONAS.md` observe a difference?** If yes:
   `standard`.
4. Otherwise: `trivial`.

Then check the count. `grep -rn` for every symbol, table, route or env key the
change touches. **Zero call sites is the single most common reason a change on
a critical path is genuinely trivial**, and it is the thing the `Tier-reason`
line exists to record.

## The floor, and going below it

`scantling/config.sh` sets a floor from the staged paths: `critical` for
`SCANTLING_CRITICAL_PATTERN`, `standard` for `SCANTLING_CODE_PATTERN`, `trivial`
otherwise.

The floor is a prompt, not a verdict. Declaring below it is allowed, and costs
one line carrying the evidence:

```
[fix] drop donor_import_tmp

Tier: trivial
Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
```

The commit-msg hook requires 20 or more characters, and the audit entry quotes
the line verbatim. That is the whole mechanism: a regex knows where a change
landed, it cannot know what depends on it, and **a claim on the record can be
audited later while an inference cannot**.

Good and bad reasons:

| | |
|---|---|
| Good | `grep -rn donor_import_tmp app lib -> 0 hits; table has 0 rows in prod` |
| Good | `copy only; no branch, no query, no API shape changed` |
| Bad | `small change` |
| Bad | `low risk` |
| Bad | `same as last time` |

A reason that contains no command and no count is not a reason.

## Do not round up

Declaring `critical` when the change is trivial feels safe and is not free. It
is exactly what teaches a project that the council is a tax, and it is how the
process starts getting routed around. Over-declaring costs the same audit
trail that under-declaring does, one step later.

If you genuinely cannot tell, that is information: it means nobody knows what
depends on this code. Say so in the brief, run the evidence pass, and use what
it prints.

## When the tier was wrong

The outcome review at +14 days asks whether the change turned out as dangerous
as it was declared. Two answers matter:

- A `standard` that caused an incident: widen `SCANTLING_CRITICAL_PATTERN`, or fix
  the personas that failed to predict it. Record a `D-`.
- A `critical` that nothing could have broken: narrow the pattern. The
  ceremony it bought was spent on nothing.

The floors in `config.sh` are meant to move as a project learns. They are the
project's current best guess about where danger lives, not a constant.

## What tiers do not fix

The tier is self-declared, so it can be declared dishonestly, and no hook can
tell a true claim from a false one. The defence is that the claim and its
evidence are written down and readable at the outcome review and after any
incident.

A project that systematically under-declares will find out at an incident. The
honest response is a `D-` that widens the critical pattern, not more ceremony
everywhere: that is where Keel 1.0 started.

## See also

- [`docs/HOOKS.md`](HOOKS.md) for the exact checks and the config knobs.
- [`docs/COUNCIL.md`](COUNCIL.md) for what each tier buys at the gates.
- Section 11 of [`SCANTLING_BOOTSTRAP.md`](../SCANTLING_BOOTSTRAP.md) for the measured
  case that produced this design.
