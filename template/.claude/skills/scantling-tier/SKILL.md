---
name: scantling-tier
description: Work out and justify the risk tier for a change before committing. Greps for call sites, checks live data and reversibility, and writes the Tier and Tier-reason lines for the commit body. Use before any commit that touches code, on /scantling-tier, "what tier is this", "is this trivial".
---
Read scantling/config.sh for SCANTLING_CODE_PATTERN and SCANTLING_CRITICAL_PATTERN, and SCANTLING.md rule 3.
Work out the path-implied floor from the staged files. Then work out the real blast radius, which is the actual answer:
1. Call sites: grep the repo for every symbol, table, route or key the change touches. Report the count and the files. Zero call sites is the single most common reason a critical path change is genuinely trivial.
2. Live data: does this read or write rows that exist in production right now? How many, and counted how?
3. Reversibility: what would a plain revert NOT undo? Dropped data, sent messages, charged money, rotated secrets, migrated schema.
4. Personas: would any persona in PERSONAS.md observe a difference?
Then state: trivial (nothing observable, fully reversible), standard (observable, reversible), critical (live data, money, auth, personal data, or not fully reversible).
Output the exact lines for the commit body. If the tier is below the floor, the Tier-reason must contain the command and its output, not an assertion:
  Tier: trivial
  Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
Never round the tier up "to be safe". Over-declaring is not free: it is what teaches a project to route around its own process.
