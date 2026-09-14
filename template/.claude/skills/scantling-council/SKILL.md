---
name: scantling-council
description: Run the Scantling council on a feature. Argument "1" runs Gate 1 on the brief, "2" runs Gate 2 on the diff. Gathers evidence once, then plays the five voices from scantling/council/personas over that evidence, and writes COUNCIL-1.md or COUNCIL-2.md with a Verdict line. Use for /scantling-council, "challenge this", "council", "gate 1", "gate 2".
---
Read scantling/council/COUNCIL.md fully. Identify the feature (argument or the in-flight item in scantling/STATE.md) and its declared tier from BRIEF.md.
Tier trivial: say so and stop. There is no council at trivial; the Tier-reason line in the commit is the record.
Step 1, evidence, once: write EVIDENCE.md in the feature folder from scantling/templates/EVIDENCE.md. Grep decisions, REJECTED, CONSTRAINTS and the code in scope; record each command and its output; quote what the voices will need in full, because they will not be able to open anything else. Count call sites explicitly.
Step 2, voices: give them EVIDENCE.md, the brief, and the prior verdict. Do NOT give them repository access and do not let them re-read files the evidence pass already covered. Tier standard: solo form, five voices in sequence, one pass. Tier critical: full form, five subagents in parallel, each with only its persona file plus that input. Respect the 150 word cap.
If a voice raises "Evidence gap:", run those commands once, append the answers to EVIDENCE.md, rerun the voices. At most once per gate.
Gate 2 first verifies every Gate 1 checkbox is ticked with a commit reference.
Write the verdict file from scantling/templates/COUNCIL.md including the Tier and Form lines. The Verdict line must be one of the four exact strings. List required changes as checkboxes. List decisions and rejections to record, then record them (/scantling-decide).
