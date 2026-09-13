---
name: keel-audit
description: Prepare a push the Keel way. Runs the configured checks, collects real output, updates keel/STATE.md, appends an A- entry to keel/audits/AUDIT-LOG.md, commits as [keel], then stops and asks for push approval. Use for /keel-audit, "prepare push", "ready to push", "audit this".
---
Read keel/config.sh for the target branch rules. Determine the push range (remote branch tip to HEAD).
Run KEEL_CHECK_1..3 and any build command the project uses. Capture the actual output lines that matter (error counts, bundle sizes).
List scenarios touched in the range and their current Status lines.
For protected branches confirm COUNCIL-2.md exists with a PROCEED verdict; otherwise say so and stop.
Rewrite keel/STATE.md. Append the audit entry from keel/templates/AUDIT.md with the real evidence. Commit with "[keel] audit A-xxxx for <feature>".
Show the entry. Ask: "Push to <branch>? (yes/no)". Do not push without a yes in this conversation for this push.
