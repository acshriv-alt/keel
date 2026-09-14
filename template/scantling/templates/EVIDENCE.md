# Evidence: F-{{0001}} Gate {{1|2}}

Collected by one agent **before** any voice speaks, so that five voices
reason independently instead of reading the same files five times.

Rules for this file: every line is a command and what it printed. No
judgement, no recommendation, no adjectives. If a fact is not the output of
something that was actually run, it belongs in the brief, not here.

Date: {{YYYY-MM-DD}}. Collected by: {{agent}}. Input: {{BRIEF.md | sha..sha}}.

## Prior art
- `grep -n "{{keyword}}" scantling/decisions/INDEX.md` -> {{matching lines, or "no match"}}
- `grep -n "{{keyword}}" scantling/knowledge/REJECTED.md` -> {{...}}
- `grep -n "{{keyword}}" scantling/knowledge/CONSTRAINTS.md` -> {{... quoted in full, the voices cannot open it}}

## Code in scope
- `grep -rn "{{symbol}}" {{dirs}}` -> {{file:line list, or "0 call sites"}}
- Entry points: {{routes, jobs, handlers that reach this code}}
- {{path}}: {{what it does today in two lines, no opinion}}

## Data
- Tables or collections touched: {{list}}
- Live rows: {{n}}, counted by `{{command}}` on {{YYYY-MM-DD}}
- Personal data in scope: {{fields}}
- Reversible? {{what a revert would and would not undo}}

## Scenarios already covering this area
- {{SC-AREA-001 title: Status line verbatim}}

## Gaps
Facts the voices may want that are not here, and the command that would get
them. The chair fills these once when a voice raises an `Evidence gap:` line.
- {{question}} -> `{{command}}`
