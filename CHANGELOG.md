# Keel changelog

## 1.0.0 (2026-09-13)

First public release.

- Single-file agent install (`KEEL_BOOTSTRAP.md`) and a copyable `template/`
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
