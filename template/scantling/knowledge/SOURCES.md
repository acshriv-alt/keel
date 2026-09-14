# Sources of record

One fact, one home. This file says which file owns what, so that closing a
backlog item is one edit and not two, and so an agent reading one file is not
reading a stale copy of another.

Running two systems of record is the most expensive state available: every
fact costs two writes, the two drift, and nothing tells you which is current.

Last reviewed: {{YYYY-MM-DD}}.

## Scantling owns

| Fact | File | Replaced |
|---|---|---|
| Current state, in flight, next | `scantling/STATE.md` | {{HANDOFF.md sections 1-3}} |
| Bugs and backlog | `scantling/BACKLOG.md` | {{ISSUES.md}} |
| Release notes | `scantling/CHANGELOG.md` | {{RELEASES.md}} |
| Why we did X | `scantling/decisions/` | {{nothing, new}} |
| What must keep working | `scantling/scenarios/` | {{nothing, new}} |

## Kept, outside Scantling

| File | Owns | Why it stays |
|---|---|---|
| {{docs/API.md}} | {{endpoint reference}} | {{generated from code, Scantling does not cover it}} |

Scantling must never write these facts. If a council or an audit wants to state one,
it links instead.

## Archived (never edited, listed in SCANTLING_ARCHIVED_PATTERN)

| File | Frozen at | Where the live version is |
|---|---|---|
| {{HANDOFF.md}} | {{2026-09-13, v0.32.0}} | {{scantling/STATE.md}} |

Every archived file carries this banner at the top:

    > ARCHIVED {{YYYY-MM-DD}}. Superseded by {{scantling/STATE.md}}.
    > Kept for history. Do not edit: the pre-commit hook refuses changes.
    > Anything still true about the project today lives in scantling/.

## Deferred (a known cost, with a date)

| File | Why not yet | Trigger to finish | Owner |
|---|---|---|---|
| {{CODING_STANDARDS.md}} | {{1,400 lines, not urgent}} | {{next time it is edited at all}} | {{name}} |

A deferred file is a decision to run two records for a while. Say so out loud
here rather than letting it be the default.

## Agent instruction files

Files that tell agents where to look ({{CLAUDE.md}}, `AGENTS.md`,
`.cursorrules`) must not point at an archived file. Checked on
{{YYYY-MM-DD}}: {{what was found and fixed}}.
