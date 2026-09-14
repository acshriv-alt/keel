# Scantling changelog

Scantling was called **Keel** through 1.0.0. Releases before 2.0.0 shipped
under that name.

## 2.0.0 (2026-09-14)

**Renamed from Keel to Scantling.** "Keel" is a common English word and
already names several developer tools, so it was neither searchable nor
distinctive. A scantling is the set of structural dimensions a hull must meet;
classification societies publish minimum scantling requirements that a vessel
is certified against before it sails. That is what this framework does.

The rename is mechanical and total: `KEEL.md` becomes `SCANTLING.md`, `keel/`
becomes `scantling/`, every `KEEL_*` variable becomes `SCANTLING_*`, the
`[keel]` commit tag becomes `[scantling]`, and the skills become
`scantling-*`. Existing installs are unaffected until they choose to migrate,
because Scantling is installed by copying files and has no dependency on this
repository. `tools/migrate-from-keel.sh` performs the migration in one pass.

**Installs now record their version.** `SCANTLING_VERSION` in `config.sh` and
a `scantling/VERSION` file answer "what am I running", which Keel 1.0 could
not. Section 11 of the bootstrap carries the upgrade notes per version. There
is still no network call and no update check: the framework stays plain
markdown and sh.

The rest of 2.0.0 is the response to the first adopter's measurements.

Keel 1.0 priced every change at the cost of its most dangerous change. The
first adopter measured it after one working session: 8 of 10 commits carried
no application code, markdown had overtaken application code (109,580 words
against 102,655), the mandated session-start read was 8,317 words and growing,
and one Gate 1 pass cost 322,122 tokens against roughly 1,200 for the grep
that found the same defect. The rule that required interviewing a real user
had been invoked twice and waived twice, the second waiver citing the first as
precedent.

None of that means the framework was wrong. In the same session it caught a
production bug that would have blanked a requestor's phone number mid
donation, and killed a weeks-long feature carrying legal exposure. 2.0 keeps
the value and moves the cost to where the value is.

**Risk tiers replace path matching as the price list.** Every commit touching
code declares `Tier: trivial | standard | critical` in the body. Paths set a
floor, not a verdict; declaring below the floor is allowed and costs one
`Tier-reason:` line carrying the evidence, typically the grep that found zero
call sites. A claim on the record can be audited later. An inference cannot.
Only `critical` pulls the full council.

**Evidence is split from judgement.** One cheap pass writes `EVIDENCE.md`:
every line a command and its output. The five voices then reason over that
sheet and the brief, and never read the repository. Five independent
judgements was always the point; five independent reads of the same files was
a tax that recurred on every gate forever. A voice that needs a missing fact
writes `Evidence gap:` and the chair fills it once.

**Everything that grows now has a compaction path.** `STATE.md` is capped at
400 words by the hook. `AUDIT-LOG.md` is archived per release into
`scantling/audits/archive/`, unchanged, once past `SCANTLING_AUDIT_MAX_ENTRIES`. A
session loads the current gate file, not the whole feature folder.
`SCENARIOS.md` is now an index and coverage map; scenarios live in
`scantling/scenarios/areas/AREA.md`, and the hook asks only for the area a change
touches.

**The reality check moved to the merge gate.** It no longer blocks Gate 1,
where it only ever produced waivers. It blocks the push to a protected branch,
which is when the work reaches users, and the audit entry carries a
`Reality-check:` line the pre-push hook requires. A waiver may not cite an
earlier waiver as its reason, and three in a row means the rule needs changing
rather than waiving again.

**One system of record, settled at install.** Install step 5 now forces a
disposition for every pre-existing tracking doc: replaced, kept or deferred,
written into `scantling/knowledge/SOURCES.md`. Replaced files get an archive banner
and go into `SCANTLING_ARCHIVED_PATTERN`, after which the pre-commit hook refuses
to stage them. Keel 1.0's advice to "map them and migrate later" is
withdrawn: it produced two systems of record by default, and later never
arrived.

**Scantling measures its own drag.** `scantling/tools/ratio.sh` reports process commits
against code commits, pre-push prints it without blocking, and the audit entry
records it. If it stays above 1:1 for a month, the framework has become the
project.

Also: new `scantling-tier` skill; `scantling-council`, `scantling-scenario`, `scantling-audit` and
`scantling-session` skills rewritten for the above; scenario coverage moved from
pre-commit to commit-msg, because it depends on a tier that only the commit
message carries. Verified with 27 cases in Git for Windows sh.

Migrating from Keel 1.0.0: run `sh tools/migrate-from-keel.sh` in the target
repo, or follow section 11 of `SCANTLING_BOOTSTRAP.md` by hand. In-flight
features keep their existing verdicts and do not rerun Gate 1.

## 1.0.0 (2026-09-13)

First public release, under the name **Keel**.

- Single-file agent install (`SCANTLING_BOOTSTRAP.md`) and a copyable `template/`
  tree with `install.sh`.
- Five mechanisms: state, decisions and rejections, knowledge (constraints,
  assumptions), council at two gates, scenarios plus per-push audit.
- Git hooks: `commit-msg` (tags, Gate 1 verdict, waiver reason), `pre-commit`
  (scenario coverage, em dash guard), `pre-push` (audit entry, STATE update,
  Gate 2 on protected branches, configured checks). Verified with 13 cases in
  Git for Windows sh.
- Optional Claude Code skills: brief, council, decide, scenario, audit,
  session.
- Optional GitHub Action mirroring the pre-push gate for pull requests.
- Docs: concepts, workflow, council guide, hooks, agent pointers, FAQ.
- Examples: filled decision, brief, council verdict, audit entry, state file,
  and a scrubbed real adoption plan.
