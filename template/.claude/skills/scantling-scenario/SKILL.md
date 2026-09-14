---
name: scantling-scenario
description: Add or update scenarios for the code being changed, in the right area file under scantling/scenarios/areas/. Picks the area and next ID, writes Given/When/Then against a persona including the failure branch, updates the coverage map. Use before committing code, or on /scantling-scenario, "add scenario", "what should we test".
---
Look at the staged or described change. Read scantling/scenarios/AREAS.map and find the area whose pattern matches the changed paths; open only that area file, not the whole corpus.
If no area matches, that is the finding: add a pattern to scantling/scenarios/AREAS.map and a row to the coverage map in scantling/scenarios/SCENARIOS.md in this commit, then create scantling/scenarios/areas/<AREA>.md.
For each behaviour a real persona would notice, write one scenario from scantling/templates/SCENARIO.md with the next free ID in that area. Always include the "Also check" failure branch (timeout, double tap, back button, stale tab, offline).
Update the coverage map row with the specific scenario IDs. Never write "all scenarios in the affected area": a row that cannot be acted on is not a row.
Set Status to untested unless you actually exercised it, in which case record date and method. "Reasoning only" is an honest status; a false pass is not.
