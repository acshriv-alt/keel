# Council protocol

The council is five voices that challenge a proposal. **Gate 1** asks whether
this is the right thing, on the brief. **Gate 2** asks whether it was built
right, on the diff.

The council exists to find the reason this will fail in the real world
before a real person does. It is not a style review.

It is also the most expensive thing Scantling does, so it is priced.

## Cost by tier

The gates a change pays for are set by the tier its commit declares (see
`SCANTLING.md` rule 3), not by the directory the change lands in.

| Tier | Gate 1 | Gate 2 | Form |
|---|---|---|---|
| `trivial` | none | none | The `Tier-reason:` line is the whole record |
| `standard` | required for features | only on a critical path | Solo: one agent, five voices in sequence |
| `critical` | required | required | Full: five independent reasoners |

A tier is a claim about blast radius, not line count. Two things follow:

- A one line change to a live column is `critical` and buys the full council.
- A 400 line deletion of code nothing calls is `trivial` and buys nothing.
  Paying for a council there does not make it safer. It teaches the next
  session that the council is a tax to be routed around, and that is how the
  audit trail dies.

## Evidence first, then judgement

**The voices do not read the repository.** Before any voice speaks, one agent
runs a single evidence pass and writes `EVIDENCE.md` into the feature folder
from `scantling/templates/EVIDENCE.md`. Every line in it is a command and what the
command printed. No judgement, no recommendation, no prose.

The voices then reason over `EVIDENCE.md`, the brief, and the previous gate's
verdict. Nothing else.

Five independent *judgements* is the point of the council. Five independent
*reads of the same files* is waste, and because it is structural it recurs on
every gate of every feature forever. One measured Gate 1 pass cost 322,122
tokens, three voices independently reported the same defect, and a single
`grep -rn` surfaced it for about 1,200. The finding was worth having. The
mechanism was not.

If a voice needs a fact the sheet lacks, it writes one line:

