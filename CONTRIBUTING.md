# Contributing to Scantling

Scantling changes through its own rules. A change to the framework is a decision
about how projects should work, so it needs a reason that survives a Skeptic.

## Before opening a pull request

1. Search `CHANGELOG.md` and closed issues for the idea.
2. Open an issue describing the problem a real project hit. Not the solution.
3. If it touches the hooks, run the smoke test in `docs/HOOKS.md` and paste
   the output in the PR.
4. If it touches `SCANTLING_BOOTSTRAP.md`, run `sh tools/extract-template.sh` so
   `template/` never drifts, and commit both.

## Rules for the repository itself

- Plain markdown and POSIX sh only. No build step, no dependencies.
- No em dashes (U+2014). Use a hyphen, colon or comma.
- Absolute dates.
- `SCANTLING.md` template stays under 120 lines. `STATE.md` template under 60.
- Every file that lands in a user's repo must have a reason to be loaded.
  If an agent would never need to read it, it does not belong in `template/`.

## What will not be merged

- Anything that requires a specific agent, editor or cloud service to work.
- Dashboards, web UIs, databases. Scantling is files in a repo.
- A sixth default council voice. Projects add their own in `personas/`.
- Removing the search-before-propose rule, the audit entry on push, or the
  verdict line format.
