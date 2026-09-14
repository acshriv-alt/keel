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
