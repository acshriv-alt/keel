# Installing Scantling

Takes about ten minutes to install and thirty to seed. Skip the seeding and
you have a form nobody fills in.

## Path 1: agent install

1. Copy `SCANTLING_BOOTSTRAP.md` into the target repository root, or paste its
   content as the first message.
2. Tell the agent:
   > Install Scantling following SCANTLING_BOOTSTRAP.md. Stop after the install commit.
3. The agent creates every file, installs the hooks, appends the pointer line
   to your existing agent instruction file, and asks you for seed facts.
4. Review the commit. Delete `SCANTLING_BOOTSTRAP.md` from the repo if you copied
   it there; the repo's own `SCANTLING.md` is now the entry point.

## Path 2: installer script

```sh
git clone https://github.com/acshriv-alt/scantling
cd scantling
sh install.sh /path/to/your/repo            # template + hooks + pointer
sh install.sh /path/to/your/repo --skills   # also .claude/skills for Claude Code
sh install.sh /path/to/your/repo --no-hooks # files only
```

The script never overwrites an existing file. It prints `skip` for each one
it left alone.

## Path 3: manual

Copy `template/` into the repository root. Run `sh scantling/hooks/install.sh`.
Add `Read SCANTLING.md first.` to your agent instruction file.

## After install, in this order

### 1. Fill placeholders

- `SCANTLING.md`: project name, and the "Project specifics" block (stack, branch
  model, the three things a new agent always gets wrong here). Under 20 lines.
- `scantling/config.sh`: protected branches, audited branches, code path pattern,
  critical path pattern, check commands. Defaults are sensible for a
  `src/`-style repo with `main` as production.
- `scantling/council/personas/domain.md`: replace the placeholder paragraph with
  your domain's laws, standards and incumbents.

### 2. Seed knowledge (the thirty minutes that matter)

Sit with whoever knows the project. Write:

- **Constraints, 5 to 10**: every "we found out the hard way" fact. Hosting
  limits, vendor blocks, device quirks, regulations, data residency, that
  one library that breaks on Windows.
- **Decisions, 5 to 10**: every choice you have re-explained to an agent.
  Status `accepted`, today's date, Context starts with "Recorded
  retroactively."
- **Rejected, 3 to 5**: every idea that keeps coming back. Write the revisit
  trigger honestly. "Never" is allowed.
- **Personas, 2 to 4**: real users with their real devices and the moment
  they use the product.
- **Scenarios**: import existing test scenarios if you have any. Keep their
  IDs. Put them in `scantling/scenarios/areas/AREA.md` and map each area's code
  paths in `scantling/scenarios/AREAS.map`.
- **Runbooks**: deploy, rollback, apply a migration, rotate a secret.
- **Sources of record**: the one nobody wants to do and the one that costs
  most to skip. For every doc that already tracks state, issues, releases or
  standards, write `replaced`, `kept` or `deferred` into
  `scantling/knowledge/SOURCES.md`. Replaced files get the archive banner and go
  into `SCANTLING_ARCHIVED_PATTERN`, after which the hook refuses edits to them.
  Then grep your `CLAUDE.md` or `AGENTS.md` for references to anything you
  replaced: an instruction pointing at a frozen file is how a half-migration
  teaches the next agent to write to the wrong place.

### 3. Write STATE.md

From the current branch: where production is, what is in flight, next three
things, what is blocked, what happened last session.

### 4. First commit

```sh
git add SCANTLING.md AGENTS.md scantling .claude 2>/dev/null
git commit -F - <<'EOF'
[scantling] install Scantling v1.1

Tier: trivial
EOF
```

The commit-msg hook is already live, so the tag is required, and any commit
touching code also needs a `Tier:` line. If the commit is refused, read the
message: it says exactly what is missing.

If this install also froze an existing doc, that one commit needs
`SCANTLING_ARCHIVE_STAMP=1` in front of it, because it is the last commit allowed
to touch the file it is archiving.

### 5. First push

The pre-push hook wants an audit entry and a `STATE.md` change in the pushed
range for audited branches. Append `A-0001` to `scantling/audits/AUDIT-LOG.md`
using `scantling/templates/AUDIT.md`, commit `[scantling] audit A-0001`, push. That
push is the first test of the gate.

## Existing projects with their own tracking docs

Do not migrate content on day one. Link from `SCANTLING.md` to the existing
handoff, release notes and issues list. New entries go to Scantling. Move old
content when a file is next rewritten anyway. A worked plan is in
`examples/adopters/BLOODKONNECT.md`.

## Existing git hooks

If `core.hooksPath` is already set, the installer leaves it alone and tells
you. Either move the old hooks' logic into `scantling/hooks/*`, or add at the end
of each Scantling hook:

```sh
[ -x "$ROOT/.githooks/pre-commit" ] && exec "$ROOT/.githooks/pre-commit" "$@"
```

Record the choice as a decision.

## Windows

Hooks are POSIX sh and run in Git for Windows' bundled shell. Files must be
LF. If a hook reports "bad interpreter", set `git config core.autocrlf false`
for the repo and re-save the hook files with LF endings.

## Uninstall

```sh
git config --unset core.hooksPath
git rm -r scantling SCANTLING.md
```

Remove the pointer line from your agent file. Keep `scantling/decisions/` and
`REJECTED.md` somewhere: they are the part that was worth having.
