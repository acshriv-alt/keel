# Agent and editor pointers

Keel needs one thing from the agent runtime: that it reads `KEEL.md` at the
start of a session. Every runtime has a file it reads automatically. Add the
pointer line there.

The line:

```
Read KEEL.md first. It is the entry point for state, decisions and the push gates.
```

| Runtime | File it reads | Notes |
|---|---|---|
| Claude Code | `CLAUDE.md` (project) | Also supports `.claude/skills/*/SKILL.md`; Keel ships six under `--skills` |
| OpenAI Codex CLI | `AGENTS.md` | The template creates this file if absent |
| Cursor | `.cursorrules` or `.cursor/rules/*.mdc` | Put the line in a rule with `alwaysApply: true` |
| GitHub Copilot | `.github/copilot-instructions.md` | |
| Gemini CLI | `GEMINI.md` | |
| Aider | `.aider.conf.yml` -> `read:` list | Add `KEEL.md` and `keel/STATE.md` to `read:` |
| Windsurf | `.windsurfrules` | |
| Cline / Roo | `.clinerules` | |
| Any other | its rules file, or paste `KEEL.md` as the first message | |

`install.sh` appends the line to `CLAUDE.md`, `AGENTS.md`, `.cursorrules`,
`GEMINI.md` and `.github/copilot-instructions.md` when they exist, and the
template creates `AGENTS.md` when nothing exists.

## Without skills

The Claude Code skills are conveniences. Every workflow step is a plain
instruction in `KEEL.md` and `keel/council/COUNCIL.md`. Any agent that can
read files and run git can do all of it. Prompts that work with any agent:

- "Open a Keel session." : reads `KEEL.md`, `STATE.md`, in-flight feature; ten-line summary.
- "Brief this as F-xxxx: <idea>." : grep, persona, `BRIEF.md`.
- "Run Gate 1 on F-xxxx." / "Run Gate 2 on F-xxxx against develop." : council.
- "Record that decision." : `D-` file and index line.
- "Add scenarios for this change." : `SCENARIOS.md`.
- "Prepare the push to develop." : checks, `STATE.md`, audit entry, stop.
- "Close the session." : `STATE.md` rewrite, backlog, unrecorded decisions.

## Subagents

Runtimes that can spawn parallel agents (Claude Code's Agent tool, for
instance) run the five council voices in parallel with their persona files
as system context. Runtimes that cannot play the voices in sequence. Output
format is identical.

## Humans

Everything in Keel is readable and writable by a person with an editor. The
hooks apply to humans too. The only step Keel reserves for humans is the
reality check: asking a real user before Gate 1 passes on a large feature.
