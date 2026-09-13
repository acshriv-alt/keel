# Installing Keel

Takes about ten minutes to install and thirty to seed. Skip the seeding and
you have a form nobody fills in.

## Path 1: agent install

1. Copy `KEEL_BOOTSTRAP.md` into the target repository root, or paste its
   content as the first message.
2. Tell the agent:
   > Install Keel following KEEL_BOOTSTRAP.md. Stop after the install commit.
3. The agent creates every file, installs the hooks, appends the pointer line
   to your existing agent instruction file, and asks you for seed facts.
4. Review the commit. Delete `KEEL_BOOTSTRAP.md` from the repo if you copied
   it there; the repo's own `KEEL.md` is now the entry point.

## Path 2: installer script

```sh
git clone https://github.com/acshriv-alt/keel
cd keel
sh install.sh /path/to/your/repo            # template + hooks + pointer
sh install.sh /path/to/your/repo --skills   # also .claude/skills for Claude Code
sh install.sh /path/to/your/repo --no-hooks # files only
```

The script never overwrites an existing file. It prints `skip` for each one
it left alone.

## Path 3: manual

Copy `template/` into the repository root. Run `sh keel/hooks/install.sh`.
Add `Read KEEL.md first.` to your agent instruction file.

## After install, in this order

### 1. Fill placeholders

- `KEEL.md`: project name, and the "Project specifics" block (stack, branch
  model, the three things a new agent always gets wrong here). Under 20 lines.
- `keel/config.sh`: protected branches, audited branches, code path pattern,
  critical path pattern, check commands. Defaults are sensible for a
  `src/`-style repo with `main` as production.
- `keel/council/personas/domain.md`: replace the placeholder paragraph with
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
  IDs.
- **Runbooks**: deploy, rollback, apply a migration, rotate a secret.

### 3. Write STATE.md

From the current branch: where production is, what is in flight, next three
things, what is blocked, what happened last session.

### 4. First commit

```sh
git add KEEL.md AGENTS.md keel .claude 2>/dev/null
git commit -m "[keel] install Keel v1.0"
```

The commit-msg hook is already live, so the tag is required. If the commit
is refused, read the message: it says exactly what is missing.

### 5. First push

The pre-push hook wants an audit entry and a `STATE.md` change in the pushed
range for audited branches. Append `A-0001` to `keel/audits/AUDIT-LOG.md`
using `keel/templates/AUDIT.md`, commit `[keel] audit A-0001`, push. That
push is the first test of the gate.

## Existing projects with their own tracking docs

Do not migrate content on day one. Link from `KEEL.md` to the existing
handoff, release notes and issues list. New entries go to Keel. Move old
content when a file is next rewritten anyway. A worked plan is in
`examples/adopters/BLOODKONNECT.md`.

## Existing git hooks

If `core.hooksPath` is already set, the installer leaves it alone and tells
you. Either move the old hooks' logic into `keel/hooks/*`, or add at the end
of each Keel hook:

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
git rm -r keel KEEL.md
```

Remove the pointer line from your agent file. Keep `keel/decisions/` and
`REJECTED.md` somewhere: they are the part that was worth having.
