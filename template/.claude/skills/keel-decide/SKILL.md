---
name: keel-decide
description: Record a decision or a rejection in Keel. Writes keel/decisions/D-xxxx-slug.md plus its INDEX.md line, or appends an R- entry to keel/knowledge/REJECTED.md. Use when a choice was just made, when the user says "let's go with", "we won't do", "decide", or /keel-decide.
---
Determine whether this is a decision (something chosen) or a rejection (something declined with no replacement). Grep INDEX.md and REJECTED.md for prior entries on the topic; if one exists, the new record must reference it and, for decisions, mark the old one superseded.
Decision: next free D- number, file from keel/templates/DECISION.md, all sections filled including "Revisit when" as a concrete trigger. Add the INDEX.md line.
Rejection: next free R- number appended to REJECTED.md with why and a revisit trigger.
Never edit an existing record. Show the file and stop.
