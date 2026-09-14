# Adopting Scantling in an existing project: BloodKonnect India

A real adoption plan, scrubbed of internal numbers. BloodKonnect is a blood
donor matching web app for India (Next.js, Postgres, one owner, several
coding agents) that already had a year of tracking docs when Scantling was
written. This shows how to adopt without a migration.

## 1. Map existing files, do not move them

| Existing file | Scantling role | Day one | Later |
|---|---|---|---|
| `CLAUDE.md` | agent entry point | add the pointer line | fold hard rules into `SCANTLING.md` Project specifics; `CLAUDE.md` becomes a 10-line pointer |
| `HANDOFF.md` (600 lines) | `scantling/STATE.md` plus history | write `STATE.md` fresh from its top block; link HANDOFF from `SCANTLING.md` | HANDOFF becomes read-only history; each "shipped" paragraph becomes a `CHANGELOG.md` entry; its "Key decisions" list becomes `D-` records |
| `RELEASES.md` | `scantling/CHANGELOG.md` | link; write new entries to both until the first release after install | freeze with a banner |
| `SCENARIOS.md` | `scantling/scenarios/SCENARIOS.md` | move as-is, keep every `SC-` ID | add `Persona:` lines when each scenario is next touched |
| `ISSUES.md` | `scantling/BACKLOG.md` | link; new items go to BACKLOG | migrate open items with `B-` IDs |
| `CODING_STANDARDS.md` | `SCANTLING.md` rules + `config.sh` | keep; link | unchanged, domain-specific |
| `DESIGN_SYSTEM.md` | not a Scantling file | unchanged | unchanged |
| `.githooks/pre-commit` (em dash check) | `scantling/hooks/pre-commit` | Scantling's hook covers it (`SCANTLING_FORBID_EMDASH=1`); switch `core.hooksPath`, delete `.githooks`, record a `D-` | |
| existing design brief and bug audit under `docs/prompts/` | `scantling/features/F-0001/BRIEF.md`, `F-0002/BRIEF.md` plus backlog items | move; the brief's decisions section becomes `D-` records; its open questions are the Gate 1 agenda | |
| `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md` | runbook source | link | extract deploy, rollback, apply-migration |

## 2. config.sh

```sh
SCANTLING_PROTECTED_BRANCHES="main"
SCANTLING_AUDITED_BRANCHES="main develop"
SCANTLING_CODE_PATTERN='^(app|lib|components|db|hooks|middleware\.ts|public/sw\.js)'
SCANTLING_CRITICAL_PATTERN='^(app/api|lib/auth|lib/broadcast|lib/eligibility|db/|middleware\.ts)'
SCANTLING_CHECK_1="npx tsc --noEmit"
SCANTLING_FORBID_EMDASH=1
```

Project rules that stay outside Scantling and are quoted in `SCANTLING.md` Project
specifics: no hardcoded colours (design tokens only), no raw SQL helper, the
Edge-safe auth split for middleware, transactions for multi-table writes,
English-only copy, features merge to production on a fixed weekday, and a
production push needs the owner's out-of-band confirmation.

## 3. Seed content

### Constraints (examples of the kind that belong here)

| ID | Area | Constraint | Evidence |
|---|---|---|---|
| C-001 | infra | Hosting plan allows two cron schedules; the frequent job depends on an external trigger | `vercel.json` |
| C-002 | infra | Connection pooler does not support nested transactions or prepared statements | ORM config |
| C-003 | infra | Each held SSE stream holds one database LISTEN connection | architecture doc |
| C-004 | sms | Transactional SMS in India requires telecom regulator (DLT) registration before any alert goes out | provider docs |
| C-005 | mobile | iOS web push works only after Add to Home Screen; social-app in-app browsers have no push API | platform docs |
| C-006 | network | Indian mobile carriers put many users behind one public IP (CGNAT); per-IP rate limits punish groups | design review |
| C-007 | domain | National transfusion council interval is 90 days (men) and 120 (women); WHO 56 days does not apply | guideline |
| C-008 | domain | Postal-code prefixes are sorting areas, not distance; one prefix can span 50 km in a metro | design review |
| C-009 | legal | Data protection act: signup IP and user agent are personal data; retention and deletion rules apply | privacy page |

### Decisions to record retroactively

Auth model (password and OAuth first, OTP dormant for cost). Alerting via
push plus SMS, in-app bell polls. City donor-count gate before requests can
be raised. Single-sourced cooldown constant. Postal-prefix zone escalation
with a country-wide final zone. Inline design-token styling kept, primitives
layer added. Logo formalised as SVG with generated rasters. Dark mode a
non-goal. Release cadence and production push confirmation. Phone numbers
revealed only after mutual acceptance.

### Rejected ideas

Donor-side SSE for the bell (memory cost). Floating feedback button (covered
footer). WHO cooldown interval. In-app i18n at this stage. Full CSS rewrite
of the styling layer. Chat between donor and requester, deferred with a
build-or-drop trigger.

### Personas

```
## P-REQUESTOR-NIGHT
Who: family member of a patient, asked to arrange blood by morning
Device: mid-range Android, Chrome, low battery
Network: hospital basement 4G, drops, carrier-shared IP
Moment: 1 am, hospital corridor, staff asking every 20 minutes
Knows: patient's blood group (maybe), hospital name
Does not know: hospital pincode, what "units" means, that a donor must be eligible
Gives up when: the form asks for something they must leave to find, or nothing happens after submit

## P-DONOR-DEFAULT
Who: registered donor who kept every default and has not opened the app since
Device: older Android, Chrome, notifications allowed once; or iPhone Safari never added to Home Screen
Moment: gets a push at 11 pm, or never does
Does not know: how far their notification radius reaches, that they must confirm a donation in the app
Gives up when: the request card is gone when they open the app, or the hospital is 40 km away

## P-DONOR-INSTAGRAM
Who: tapped a shared link inside a social app's in-app browser
Device: any phone, webview, no push API, no persistent login
Moment: on a bus, 30 seconds of attention
Gives up when: asked to install, or login fails on redirect
```

## 4. Order of migration (one session)

1. Bootstrap with the values above.
2. Seed constraints, decisions, rejected, personas.
3. Move `SCENARIOS.md`; add stubs for behaviours the recent audit found untested.
4. Move the two briefs into `F-0001` and `F-0002`.
5. Write `STATE.md` from the handoff's top block.
6. Switch hooks; record the decision.
7. Pointer line in `CLAUDE.md`.
8. Commit `[scantling] install Scantling and seed from existing docs`.
9. Stop. The first push to `develop` needs `A-0001` and is the first test of
   the gate.

Do not, in this migration: touch code, rename scenario IDs, or re-run Gate 1
on a brief whose questions the owner already answered (record those answers as
the verdict instead).

**Do settle the system of record in this same session** (install step 5). This
plan originally said to keep the old docs authoritative and migrate later.
That was wrong, and section 6 is what it cost.

## 5. What the first Scantling audit would have caught

Reviewing the project's most recent pushes against Scantling's rules, without
Scantling installed, found: decisions recorded as prose in the handoff rather
than indexed records, so a superseded brief still read as current; 27 new
scenarios written but none marked as run; no Gate 2 on fixes touching API,
auth and background-job paths; no per-push evidence of which checks ran;
several real-world facts learned during the work (device reach, cron
behaviour, framework quirks) living in chat memory instead of a constraints
register. All of these are one file each in Scantling and two of them are hook
failures.

---

## 6. What one working session actually measured

Keel 1.0.0 (this project's previous name) was installed on 2026-09-13. After
a single working session the
project measured the framework in its own repository rather than estimating.
The full write-up is the Scantling Drag Report; this is the part that changed Scantling.

**What it earned, and this is not in dispute:**

- Rule 1 caught in seconds that "redesign the website" was already decided
  (`D-0006`), already rejected in one form (`R-005`), and already parked in
  another an hour earlier. No handoff document does this.
- Gate 1 found a defect that would have blanked a requestor's phone number
  mid-donation and double-booked a slot, before a line was written.
- `REJECTED.md` with a revisit trigger killed in-app chat once, with reasons.
  Ordinary process had parked it twice and it came back both times.
- `commit-msg:21` hard-blocked feature code that had no Gate 1 verdict. A
  convention in a markdown file would not have.

**What it cost:**

| Measured 2026-09-14 | Value |
|---|---|
| Commits carrying no application code | 8 of 10 since install |
| Markdown vs application code | 109,580 words vs 102,655 |
| Mandated read before work starts | 8,317 words, growing every gate |
| One Gate 1 pass | 322,122 tokens, vs ~1,200 for the grep that found the same defect |
| Reality check rule: fired / waived | 2 / 2, the second citing the first as precedent |

The framework was not failing. It was mispriced: it charged a table drop with
zero call sites what it charged a schema migration on a live donor database,
because both live in `db/`. Closing one backlog item touched 8 files to delete
19 lines that nothing referenced.

Two findings were about this plan rather than about the framework:

- **Two systems of record.** `D-0013` kept `HANDOFF.md`, `RELEASES.md`,
  `ISSUES.md` and others authoritative while Scantling added `STATE.md`,
  `BACKLOG.md` and `CHANGELOG.md` over the same ground. Closing `B-0023`
  required editing `ISSUES.md:343` **and** `scantling/BACKLOG.md`; the branch
  state lived in `HANDOFF.md:205` **and** `scantling/STATE.md`. `CLAUDE.md` step 3
  still pointed at `RELEASES.md`, which had frozen at v0.32.0, so the
  mandated checklist told agents to update a dead file.
- **No compaction path.** `SCENARIOS.md` reached 12,853 words and its
  coverage map had degraded to rows like `db/schema.ts | All scenarios in
  affected area`, which cannot be acted on.

**What Scantling 2.0.0 changed as a result:** declared risk tiers, the evidence
pass split from the council, hook-enforced caps and per-release archives, the
reality check moved to the merge gate, scenarios split by area, and
`scantling/tools/ratio.sh` so the framework can measure its own drag. Full list in
`CHANGELOG.md`, upgrade steps in section 11 of `SCANTLING_BOOTSTRAP.md`.

One number this project now tracks about Scantling itself: process commits against
code commits. It was **8 to 2** in the first day. If it is still above 1:1 in
a month, the framework is the project.

A single session is a thin evidence base for a framework critique. These
findings should be re-read after five more features rather than treated as
settled. That caveat is itself a Scantling rule.
