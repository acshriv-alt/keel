# Scenarios

What must keep working, written as Given / When / Then against a persona.
Every code change adds or updates one. Status is the last real run, with
date and how (manual on device, automated test, reasoning only).

IDs: SC-AREA-000. Areas are short caps (AUTH, REQ, NOTIF, PAY, ADMIN).

## Coverage map
| Code path | Scenarios |
|---|---|
| `{{path}}` | SC-AREA-001, SC-AREA-002 |

## Scenarios

### SC-{{AREA}}-001 {{title}}
Persona: P-{{NAME}}
Given {{state}}
When {{action, including the bad conditions}}
Then {{observable outcome}}
Also check: {{the failure branch: timeout, double tap, back button, stale tab}}
Status: pass {{date}} ({{how}}) | fail {{date}} | untested
Covers: `{{path}}`
