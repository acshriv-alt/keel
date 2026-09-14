# Running the council well

The protocol is in `template/scantling/council/COUNCIL.md` and lands in every
repo. This document is about doing it well.

## What the council is for

Finding the reason this will fail in the real world before a real person
does. It is not a style review, a lint pass, or a second opinion on
architecture taste. If a voice's paragraph could be pasted onto any other
feature unchanged, it is not a challenge.

## Good challenge, bad challenge

| Voice | Bad (generic) | Good (specific) |
|---|---|---|
| User | "Consider accessibility and mobile users." | "Step 3 asks for the hospital pincode. P-REQUESTOR-NIGHT does not know it and cannot leave the corridor to ask. They give up here. Pre-fill from the hospital name lookup or make it optional." |
| Adversary | "Validate inputs and add rate limiting." | "`POST /api/otp/send` is unauthenticated and keyed per phone at one per minute. From one IP I can send an OTP to every number in a leaked list at three a minute. Add a per-phone daily cap and a signed challenge." |
| Operator | "Monitor performance." | "Zone 5 pushes every donor nationwide for any request unanswered at 24 h. At 2,000 donors that is 2,000 pushes and 2,000 SMS per stale request. C-005 says SMS is blocked today, so this is a cost bomb the day it unblocks." |
| Skeptic | "Is this really needed?" | "R-004 rejected in-app i18n in June for encoding and maintenance cost. This brief re-introduces Hindi labels through the back door in `utils.ts`. Either reopen R-004 with new evidence or remove them." |
| Domain | "Ensure compliance." | "The brief says WHO 56-day interval. National guideline here is 90 days for men and 120 for women. Copy and cooldown both wrong. Cite the guideline in the brief." |

The difference: a file, a step, a number, an ID.

## Running it as one agent

Play the voices in order. Between voices, actually re-read the persona file.
The frame shift is the point; an agent that writes all five in one pass
produces one voice with five headings.

**Before any voice speaks**, one agent writes `EVIDENCE.md` in the feature
folder: every line a command and what it printed, no judgement. The voices
reason over that sheet plus the brief, and do not open the repository. A voice
that needs a missing fact writes `Evidence gap: <question>, answerable by
<command>`; the chair runs it once, appends the answer, and reruns the voices.

What the council costs is set by the tier the change declares:
`trivial` buys nothing, `standard` buys a solo pass (one agent, five voices in
sequence), `critical` buys the full parallel form. See [TIERS.md](TIERS.md).

Respect the caps: 150 words per voice, 200 for the chair. Under-length and
specific beats full-length and vague.

## Running it with subagents

Give each subagent: its persona file, the brief (and diff at Gate 2),
`CONSTRAINTS.md`, `REJECTED.md`, the mandatory questions for its gate, and
the word cap. Run in parallel. The chair (main agent) synthesises, resolves
conflicts between voices, and writes the verdict. Do not let subagents write
the verdict line.

## The verdict

Exactly one of:

- `Verdict: PROCEED` : rare at Gate 1. Means nobody found anything worth a
  required change.
- `Verdict: PROCEED WITH CHANGES` : the normal outcome. Every change is a
  checkbox, a required edit, not a suggestion. Gate 2 opens by checking them.
- `Verdict: REWORK` : the brief or the diff goes back. Two or three reasons.
- `Verdict: REJECT` : the feature should not be built. An `R-` entry is
  written in the same sitting with the revisit trigger.

The hooks grep for `^Verdict: PROCEED` in `COUNCIL-1.md` and
`^Gate 2: PROCEED` in the audit entry. Spelling matters.

## Pre-mortem

Gate 1 ends with each voice answering: "It is 90 days after ship and this
failed. What is the one most likely cause?" Five sentences. The chair picks
the one that appears twice or worries them most and adds a required change
or a scenario for it. This question finds failures the mandatory questions
miss because it inverts the frame from "will it work" to "how did it break".

## Reality check rule (at the merge gate)

For any brief estimating more than two days of work, the chair cannot write
PROCEED until the brief quotes one real person matching the persona. One
message to one user is enough. The agent flags this and stops; the owner
does the asking. Teams that skip this build features for imagined users.

## Domain voice

The template `domain.md` is a placeholder. Fill it on install with the laws,
regulators, standards and incumbents for your product. A health product in
India names the transfusion council, the data protection act, the telecom
regulator's SMS rules, and the government's own blood-bank portal. A fintech
names the payments regulator and the bank it depends on. Without this the
Domain voice has nothing to stand on.

## Cost

Five voices at 150 words plus a 200-word chair is under 1,000 words per gate.
Two gates per feature is under 2,000 words, roughly 3,000 tokens of output.
A feature killed at Gate 1 saves its entire build. A Gate 2 catch saves an
incident. The council is the cheapest part of the lifecycle.
