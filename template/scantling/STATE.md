# State

_Rewritten at the end of every session, never appended to. Capped at
SCANTLING_STATE_MAX_WORDS (400); the pre-commit hook refuses a bigger file. If it
does not fit, the surplus is history: it belongs in the audit log, the feature
folder or a decision record, not here._

_Last updated: {{YYYY-MM-DD}} by {{agent or owner}}._

## Now
- Branch: `{{branch}}` at `{{short sha}}`. Production: `{{version or sha}}` live since {{date}}.
- Pending migrations: {{none | list with target env}}
- Env drift: {{none | which secrets or settings differ between envs}}

## In flight
- {{F-0001 slug}}: {{one line, which phase of the lifecycle, declared tier}}

## Next (max 3, in order)
1. {{item, with ID}}
2. {{item}}
3. {{item}}

## Blocked
- {{item}}: blocked on {{what, who, since date}}

## Last session (max 6 lines, replaced not extended)
{{What was done, what was decided (IDs only, no restatement), what was left
half finished and where exactly. Anything older than the last session is
already in the audit log. Do not keep a narrative here.}}
