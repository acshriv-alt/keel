---
name: keel-council
description: Run the Keel council on a feature. Argument "1" runs Gate 1 on the brief, "2" runs Gate 2 on the diff. Plays the five voices from keel/council/personas, writes COUNCIL-1.md or COUNCIL-2.md with a Verdict line. Use for /keel-council, "challenge this", "council", "gate 1", "gate 2".
---
Read keel/council/COUNCIL.md fully. Identify the feature (argument or the in-flight item in keel/STATE.md).
Gate 1: input is BRIEF.md. Gate 2: input is the diff since the branch point plus BRIEF.md and COUNCIL-1.md (verify every Gate 1 checkbox first).
Read keel/knowledge/CONSTRAINTS.md and keel/knowledge/REJECTED.md before speaking.
If subagents are available, run the five voices in parallel, each with its persona file, the input, and the mandatory questions; then synthesise. Otherwise play them in sequence. Respect the word caps.
Write the verdict file from keel/templates/COUNCIL.md. The Verdict line must be one of the four exact strings. List required changes as checkboxes. List decisions and rejections to record, then record them (/keel-decide).
