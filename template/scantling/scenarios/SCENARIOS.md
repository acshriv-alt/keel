# Scenarios: index

**This file is an index and a coverage map. The scenarios themselves live in
`scantling/scenarios/areas/AREA.md`, one file per area.** A single scenario file
stops being read whole somewhere around ten thousand words, and a coverage map
row that says "all scenarios in the affected area" is the shape of a rule that
outgrew the format holding it.

IDs are global and never reused: `SC-AREA-000`. Areas are short caps
(AUTH, REQ, NOTIF, PAY, ADMIN).

## Areas

| Area | File | Owns |
|---|---|---|
| {{AUTH}} | `scantling/scenarios/areas/{{AUTH}}.md` | {{one line: what part of the product}} |

## Coverage map

Every row names specific scenario IDs. "All scenarios in the affected area" is
not an answer and does not belong here. A code path with no row is a gap: the
commit that adds the path adds the row.

| Code path | Area | Scenarios |
|---|---|---|
| `{{path}}` | {{AUTH}} | SC-{{AUTH}}-001, SC-{{AUTH}}-002 |

## Machine-readable areas

`scantling/scenarios/AREAS.map` holds the same mapping in the form the commit-msg hook
reads. Keep the two in step: when a row is added here, add the pattern there.
