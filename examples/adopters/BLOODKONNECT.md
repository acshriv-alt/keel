# Adopting Keel in an existing project: BloodKonnect India

A real adoption plan, scrubbed of internal numbers. BloodKonnect is a blood
donor matching web app for India (Next.js, Postgres, one owner, several
coding agents) that already had a year of tracking docs when Keel was
written. This shows how to adopt without a migration.

## 1. Map existing files, do not move them

| Existing file | Keel role | Day one | Later |
|---|---|---|---|
| `CLAUDE.md` | agent entry point | add the pointer line | fold hard rules into `KEEL.md` Project specifics; `CLAUDE.md` becomes a 10-line pointer |
| `HANDOFF.md` (600 lines) | `keel/STATE.md` plus history | write `STATE.md` fresh from its top block; link HANDOFF from `KEEL.md` | HANDOFF becomes read-only history; each "shipped" paragraph becomes a `CHANGELOG.md` entry; its "Key decisions" list becomes `D-` records |
| `RELEASES.md` | `keel/CHANGELOG.md` | link; write new entries to both until the first release after install | freeze with a banner |
| `SCENARIOS.md` | `keel/scenarios/SCENARIOS.md` | move as-is, keep every `SC-` ID | add `Persona:` lines when each scenario is next touched |
| `ISSUES.md` | `keel/BACKLOG.md` | link; new items go to BACKLOG | migrate open items with `B-` IDs |
| `CODING_STANDARDS.md` | `KEEL.md` rules + `config.sh` | keep; link | unchanged, domain-specific |
| `DESIGN_SYSTEM.md` | not a Keel file | unchanged | unchanged |
| `.githooks/pre-commit` (em dash check) | `keel/hooks/pre-commit` | Keel's hook covers it (`KEEL_FORBID_EMDASH=1`); switch `core.hooksPath`, delete `.githooks`, record a `D-` | |
| existing design brief and bug audit under `docs/prompts/` | `keel/features/F-0001/BRIEF.md`, `F-0002/BRIEF.md` plus backlog items | move; the brief's decisions section becomes `D-` records; its open questions are the Gate 1 agenda | |
| `docs/ARCHITECTURE.md`, `docs/DEPLOYMENT.md` | runbook source | link | extract deploy, rollback, apply-migration |

## 2. config.sh

```sh
KEEL_PROTECTED_BRANCHES="main"
KEEL_AUDITED_BRANCHES="main develop"
KEEL_CODE_PATTERN='^(app|lib|components|db|hooks|middleware\.ts|public/sw\.js)'
KEEL_CRITICAL_PATTERN='^(app/api|lib/auth|lib/broadcast|lib/eligibility|db/|middleware\.ts)'
KEEL_CHECK_1="npx tsc --noEmit"
KEEL_FORBID_EMDASH=1
```

Project rules that stay outside Keel and are quoted in `KEEL.md` Project
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
8. Commit `[keel] install Keel and seed from existing docs`.
9. Stop. The first push to `develop` needs `A-0001` and is the first test of
   the gate.

Do not, in this migration: touch code, rename scenario IDs, delete the old
docs, or re-run Gate 1 on a brief whose questions the owner already answered
(record those answers as the verdict instead).

## 5. What the first Keel audit would have caught

Reviewing the project's most recent pushes against Keel's rules, without
Keel installed, found: decisions recorded as prose in the handoff rather
than indexed records, so a superseded brief still read as current; 27 new
scenarios written but none marked as run; no Gate 2 on fixes touching API,
auth and background-job paths; no per-push evidence of which checks ran;
several real-world facts learned during the work (device reach, cron
behaviour, framework quirks) living in chat memory instead of a constraints
register. All of these are one file each in Keel and two of them are hook
failures.
