# FAQ

**Is this overkill for a one-person project?**
It was built for one. The overhead per feature is a brief (under 120 lines),
two council verdicts (under 150 each), and an audit entry per push (about 12
lines). The saving is every session that does not start with "let me read
the handoff" and every idea that does not get rebuilt after being rejected.

**Why not just a good CLAUDE.md?**
A single instruction file grows until it costs more to load than it saves,
and it has no structure for decisions, evidence or challenge. Scantling keeps the
always-loaded part small by moving everything else into files with a known
location and a rule for when to open them.

**Why hooks? My agent follows instructions.**
Until it does not, at the end of a long session, under a vague prompt. Hooks
fail loudly with a message that names the missing file. They also apply to
you at 11 pm.

**Can I skip the council for small things?**
Yes, and that is what tiers are for. Declare `Tier: trivial` and there is no
council and no scenario. `[fix]`, `[chore]` and `[docs]` never see Gate 1 at
any tier. The full parallel council is only bought by `Tier: critical`.

**Is the tier just paperwork then?**
It is the opposite: it is what stops the paperwork being charged where it is
worthless. Keel 1.0, this project's previous name, priced by file path, so deleting a table nothing
referenced cost a scenario, a Gate 2 council, an audit entry and a `STATE.md`
rewrite, because the file lived in `db/`. A regex knows where a change landed
and cannot know what depends on it. See [TIERS.md](TIERS.md).

**What stops me declaring everything trivial?**
Nothing mechanical, and that is deliberate. Going below the path floor costs a
`Tier-reason:` line that has to carry a command and its output, and that line
is quoted verbatim in the audit entry and read again at the outcome review and
after any incident. A hook cannot tell a true claim from a false one; a
written claim can at least be checked later, which an inference never can.

**The scenario requirement is annoying for refactors.**
First check the tier: a refactor no persona can observe is `trivial` and needs
no scenario. If it really is `standard`, use the waiver:
`SCANTLING_WAIVE_SCENARIOS=1` plus a `Waiver: <reason>` line. The reason lands in
the commit. If you waive every commit, your code pattern is too broad; narrow
`SCANTLING_CODE_PATTERN`.

**How do I know Scantling is still worth it?**
Run `sh scantling/tools/ratio.sh`. It counts commits carrying code against commits
carrying only process. Above 1:1 for a month means the framework has become
the project: cut ceremony and record the cut as a `D-`. The first adopter was
at 8 to 2 after one day, which is what produced Scantling 1.1.

**Does Scantling need a specific agent?**
No. Markdown and sh. See `docs/AGENTS.md` for where each runtime reads its
pointer. The Claude Code skills are optional.

**What about teams?**
Same files. Decisions get an author field in practice (add it to the
template). The audit entry's "Pushed by ... with approval from ..." becomes
meaningful. The CI action in `ci/` mirrors the pre-push gate for pull
requests so `--no-verify` on one laptop does not bypass it.

**How is this different from ADRs?**
Decision records are ADRs. Scantling adds the rejected register (ADRs rarely
record what was not built), the constraints and assumptions ledgers, the
council, the scenarios, and the hooks that make the habit stick.

**Does it work on Windows?**
Yes, under Git for Windows. Hooks are POSIX sh. Keep LF line endings. The
verification matrix in `docs/HOOKS.md` was run on Windows 11.

**How do I measure the token saving for my project?**
Count the characters of everything your agent loads at session start today
and divide by four. Do the same for `SCANTLING.md` plus `STATE.md` plus the
in-flight brief. The example project went from about 18,800 to about 2,500.

**What if the owner is the one who skips steps?**
Then the framework records that too: `--no-verify` is a decision. Scantling makes
skipping visible, it does not make it impossible.

**Can I add a sixth voice?**
Yes, in `scantling/council/personas/`. Accessibility, Finance, Legal are common.
Keep at least four.

**Where do meeting notes go?**
Nowhere, unless they produce a decision, a rejection, a constraint, a brief
or a backlog item. Then they go there. Notes that produce none of those are
not worth a file.
