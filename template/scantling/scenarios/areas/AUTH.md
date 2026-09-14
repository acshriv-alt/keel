# Scenarios: {{AUTH}}

{{One line: what this area covers.}}
Covers: {{^(lib/auth|app/api/auth)/}} (keep in step with `scantling/scenarios/AREAS.map`)

Status is the last real run, with the date and how it was run: manual on a
named device, an automated test, or reasoning only. "Reasoning only" is an
honest status and is better than a false pass.

### SC-{{AUTH}}-001 {{title}}
Persona: P-{{NAME}}
Given {{state}}
When {{action, including the bad conditions}}
Then {{observable outcome}}
Also check: {{the failure branch: timeout, double tap, back button, stale tab}}
Status: pass {{date}} ({{how}}) | fail {{date}} | untested
Covers: `{{path}}`
