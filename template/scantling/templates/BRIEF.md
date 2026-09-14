# F-{{0001}}: {{title}}

Date: {{YYYY-MM-DD}}. Owner: {{name}}. Status: brief | gate-1 | building | gate-2 | shipped | reviewed | killed

## Tier
{{trivial | standard | critical}}, because {{the blast radius in one line: what
is irreversible, what live data or money is touched, what a revert would not
undo. Not the line count.}}

Estimated at {{n}} days, so the reality check {{applies at the merge gate |
does not apply}}.

## Problem
{{Two to four lines. What goes wrong for whom, today. No solution words.}}

## Who and when
Persona: P-{{NAME}} (see `scantling/scenarios/PERSONAS.md`).
Moment: {{the exact real-world moment this is used: time, place, device, state of mind}}

## The one scenario
{{Given / When / Then, in the persona's own words. If you cannot write this,
the feature is not ready for Gate 1.}}

## Prior art in this repo
Decisions: {{D-xxxx, D-xxxx or "none found, searched for: keywords"}}
Rejected: {{R-xxx or "none found"}}
Constraints that apply: {{C-xxx}}
Assumptions this depends on: {{AS-xxx, with status}}

## Non-goals
- {{what this deliberately does not do}}

## Success metric
{{One number, where it is measured, current value, target, by when.}}

## Kill criteria
{{What result at the outcome review means we remove or rework it.}}

## Cost check
Compute / API / SMS / storage per use: {{estimate}}. Monthly at 10x current usage: {{estimate}}.

## Rollback
{{How to turn it off or revert. Feature flag, revert commit, migration down.}}

## Scenarios to add
{{SC-IDs to create before code is written.}}
