---
name: keel-scenario
description: Add or update scenarios in keel/scenarios/SCENARIOS.md for the code being changed. Picks the area prefix and next ID, writes Given/When/Then against a persona including the failure branch, updates the coverage map. Use before committing code, or on /keel-scenario, "add scenario", "what should we test".
---
Look at the staged or described change. For each behaviour that a real persona would notice, write one scenario from keel/templates/SCENARIO.md with the next free ID in the right area. Always include the "Also check" failure branch (timeout, double tap, back button, stale tab, offline). Add the code path to the coverage map. Set Status to untested unless you actually exercised it, in which case record date and method.
