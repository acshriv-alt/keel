---
name: scantling-audit
description: Prepare a push the Scantling way. Runs the configured checks, collects real output, updates scantling/STATE.md, appends an A- entry to scantling/audits/AUDIT-LOG.md, commits as [scantling], then stops and asks for push approval. Use for /scantling-audit, "prepare push", "ready to push", "audit this".
---
Read scantling/config.sh for the target branch rules. Determine the push range (remote branch tip to HEAD).
Run SCANTLING_CHECK_1..3 and any build command the project uses. Capture the actual output lines that matter (error counts, bundle sizes).
Collect the declared Tier of every commit in the range. The entry records the highest one, and quotes any Tier-reason verbatim: a downgrade is exactly what a later reader needs to see.
List scenarios touched in the range and their current Status lines.
For protected branches confirm COUNCIL-2.md exists with a PROCEED verdict; otherwise say so and stop.
For protected branches write the Reality-check line. If the feature was estimated over two days, it needs a real person quoted, or an explicit waiver plus a new AS- entry. Check scantling/audits/ for the two previous entries: if both waived, say so out loud, because three in a row means the rule needs changing rather than waiving again. A waiver may never cite an earlier waiver as its reason.
Run sh scantling/tools/ratio.sh and put the output in the Process ratio line.
If AUDIT-LOG.md is over SCANTLING_AUDIT_MAX_ENTRIES, move the shipped entries unchanged into scantling/audits/archive/AUDIT-LOG-<version>.md and leave a pointer line, before appending.
Rewrite scantling/STATE.md inside its word cap. Append the audit entry from scantling/templates/AUDIT.md with the real evidence. Commit with "[scantling] audit A-xxxx for <feature>" and a Tier line.
Show the entry. Ask: "Push to <branch>? (yes/no)". Do not push without a yes in this conversation for this push.
