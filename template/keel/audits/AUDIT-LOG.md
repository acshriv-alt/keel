# Audit log

Append-only. One entry per push to an audited branch. The pre-push hook
reads the last entry. Write it as the final commit before pushing, tagged
`[keel]`.

Evidence means the command and what it printed, not an adjective.

## A-0001 {{YYYY-MM-DDThh:mm+05:30}}
Branch: {{main | develop}}
Range: {{remote sha}}..{{local sha}}
Feature: {{F-0001 | fix | chore}}
Gate 2: {{PROCEED | PROCEED WITH CHANGES | N/A}} ({{link COUNCIL-2.md or "not required on this branch"}})
Checks:
- `{{npx tsc --noEmit}}`: {{0 errors}}
- `{{next build}}`: {{ok, largest route 143 kB}}
- Scenarios run: {{SC-REQ-012 pass manual Android Chrome 2026-09-11, SC-REQ-013 reasoning only}}
Migrations: {{none | file, applied to which env on which date, prod pending yes/no}}
Rollback: {{git revert sha | redeploy previous | flag off}}
Risk: {{low | medium | high}}: {{one line why}}
Pushed by: {{agent name}} with approval from {{owner}} at {{time}}
