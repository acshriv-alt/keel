---
name: scantling-brief
description: Start a feature the Scantling way. Greps decisions and rejected ideas, picks a persona, writes scantling/features/F-xxxx-slug/BRIEF.md from the template, and lists assumptions. Use when the user says "new feature", "let's build", "brief this", or /scantling-brief.
---
Read SCANTLING.md and scantling/STATE.md. Take the idea from the user's message.
1. Grep scantling/decisions/INDEX.md, scantling/knowledge/REJECTED.md, scantling/BACKLOG.md for the idea's keywords. Quote every hit with its ID before anything else.
2. Pick the next free F- number from scantling/features/. Pick a persona from scantling/scenarios/PERSONAS.md or propose a new one.
3. Write BRIEF.md from scantling/templates/BRIEF.md. Do not leave placeholders; ask the user for anything you cannot infer.
4. Add assumptions to scantling/knowledge/ASSUMPTIONS.md with IDs and reference them in the brief.
5. Stop and show the brief. Do not write code. Suggest /scantling-council 1.
