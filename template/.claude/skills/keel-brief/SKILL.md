---
name: keel-brief
description: Start a feature the Keel way. Greps decisions and rejected ideas, picks a persona, writes keel/features/F-xxxx-slug/BRIEF.md from the template, and lists assumptions. Use when the user says "new feature", "let's build", "brief this", or /keel-brief.
---
Read KEEL.md and keel/STATE.md. Take the idea from the user's message.
1. Grep keel/decisions/INDEX.md, keel/knowledge/REJECTED.md, keel/BACKLOG.md for the idea's keywords. Quote every hit with its ID before anything else.
2. Pick the next free F- number from keel/features/. Pick a persona from keel/scenarios/PERSONAS.md or propose a new one.
3. Write BRIEF.md from keel/templates/BRIEF.md. Do not leave placeholders; ask the user for anything you cannot infer.
4. Add assumptions to keel/knowledge/ASSUMPTIONS.md with IDs and reference them in the brief.
5. Stop and show the brief. Do not write code. Suggest /keel-council 1.
