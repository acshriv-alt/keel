# Hooks

Three POSIX sh scripts in `scantling/hooks/`, activated by
`git config core.hooksPath scantling/hooks`. Configured by `scantling/config.sh`.

## Behaviour

| Hook | Runs | Blocks when |
|---|---|---|
| `pre-commit` | before the message editor | em dash (U+2014) in any added line, if `SCANTLING_FORBID_EMDASH=1`; a staged file matches `SCANTLING_ARCHIVED_PATTERN` and `SCANTLING_ARCHIVE_STAMP` is not `1`; staged `scantling/STATE.md` exceeds `SCANTLING_STATE_MAX_WORDS`. Warns (does not block) when `SCANTLING_CRITICAL_PATTERN` is touched. |
| `commit-msg` | after the message is written | no tag among `[F-dddd] [fix] [hotfix] [chore] [docs] [scantling]`; a staged file matches `SCANTLING_CODE_PATTERN` or `SCANTLING_CRITICAL_PATTERN` and there is no `Tier:` line; the tier is not one of `trivial` `standard` `critical`; the tier is below the path-implied floor and there is no `Tier-reason:` line of 20+ characters (or `SCANTLING_ALLOW_TIER_DOWNGRADE` is `0`); tag is `[F-dddd]` and the brief is missing, or at tier `standard`+ `COUNCIL-1.md` has no line starting `Verdict: PROCEED` or `EVIDENCE.md` does not exist; at tier `standard`+ a code change stages no scenario for the area it touches; `SCANTLING_WAIVE_SCENARIOS=1` and no body line matching `Waiver: ` with ten or more characters; em dash in the message. |
| `pre-push` | before objects are sent | for each ref pushed to a branch in `SCANTLING_AUDITED_BRANCHES`: the commits being pushed do not touch `scantling/audits/AUDIT-LOG.md`, or do not touch `scantling/STATE.md`, or the last `## A-` block in the log does not have `Branch: <that branch>`; for `SCANTLING_PROTECTED_BRANCHES` additionally the last block lacks `Gate 2: PROCEED` or lacks a `Reality-check:` line of 10+ characters; `AUDIT-LOG.md` holds more than `SCANTLING_AUDIT_MAX_ENTRIES` entries; then for every push, each non-empty `SCANTLING_CHECK_n` command that exits non-zero. Prints `ratio.sh` output without blocking. |

### Why the scenario check lives in commit-msg

It depends on the declared tier, and the tier is in the commit message, which
`pre-commit` cannot read. The practical difference is that a missing scenario
is reported after the editor closes rather than before it opens. The commit is
refused either way, and `git commit` reruns against the same staged index.

### The tier floor

`commit-msg` computes a floor from the staged paths: `critical` if anything
matches `SCANTLING_CRITICAL_PATTERN`, else `standard` if anything matches
`SCANTLING_CODE_PATTERN`, else `trivial`. The floor is not the verdict. The commit
declares the tier, and may declare below the floor by carrying the evidence:

```
Tier: trivial
Tier-reason: drops donor_import_tmp; grep -rn donor_import_tmp app lib -> 0 hits
```

Set `SCANTLING_ALLOW_TIER_DOWNGRADE=0` to make the floor hard, which restores 1.0
behaviour: the path decides, and a dead-schema drop pays what a live migration
pays.

### Scenario areas

`scantling/scenarios/AREAS.map` is plain text, one line per area: the area name,
whitespace, then a `grep -E` pattern. If a staged path matches an area, the
hook requires `scantling/scenarios/areas/<AREA>.md` to be staged. If a staged code
path matches no area at all, it requires `scantling/scenarios/SCENARIOS.md`
instead, which is how a new path gets mapped rather than quietly escaping
coverage.

The map is named `AREAS.map`, not `AREAS`, because Windows and macOS default
to case-insensitive filesystems, where a file `AREAS` and a directory
`areas/` cannot coexist.

"Commits being pushed" is computed as the range from the remote's current
tip to the local tip. For a branch that does not exist on the remote yet, it
is every local commit not on any of that remote's refs. A fast-forward of an
already-pushed branch onto `main` therefore contains no new commits and is
blocked until an audit commit is made on `main` itself. That is intended:
every production push gets its own entry.

## config.sh

```sh
SCANTLING_PROTECTED_BRANCHES="main"          # Gate 2 PROCEED + Reality-check required
SCANTLING_AUDITED_BRANCHES="main develop"    # audit entry + STATE.md required
SCANTLING_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'
SCANTLING_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'
SCANTLING_DEFAULT_TIER=trivial               # when no code is touched and none is declared
SCANTLING_ALLOW_TIER_DOWNGRADE=1             # 0 = the path floor is hard
SCANTLING_STATE_MAX_WORDS=400                # 0 = no cap
SCANTLING_AUDIT_MAX_ENTRIES=20               # 0 = never demand an archive
SCANTLING_ARCHIVED_PATTERN=''                # files frozen by scantling/knowledge/SOURCES.md
SCANTLING_CHECK_1="npx tsc --noEmit"
SCANTLING_CHECK_2=""
SCANTLING_CHECK_3=""
SCANTLING_FORBID_EMDASH=1
```

Patterns are `grep -E` regexes against repo-relative paths. Monorepos set
`SCANTLING_CODE_PATTERN` to their package roots.

## Verification matrix

Run 2026-09-14 in a throwaway repo under Git for Windows sh, against the 1.1
hooks. Every case behaved as designed.

| # | Case | Expected | Result |
|---|---|---|---|
| 1 | untagged commit | block | block |
| 2 | `[scantling]` commit, no code staged | allow | allow |
| 3 | code change with no `Tier:` line | block | block |
| 4 | `Tier: medium` | block | block |
| 5 | `Tier: standard` on `src/`, no scenario staged | block | block |
| 6 | `Tier: trivial` on `src/`, no `Tier-reason:` | block | block |
| 7 | `Tier: trivial` on `src/` with `Tier-reason:` | allow | allow |
| 8 | `Tier: standard` on `db/` (floor is `critical`), no reason | block | block |
| 9 | `Tier: trivial` on `db/` with `Tier-reason:` citing 0 call sites | allow | allow |
| 10 | `Tier: critical` on `db/`, no area scenario | block | block |
| 11 | same, with `scantling/scenarios/areas/DB.md` staged | allow | allow |
| 12 | code in no area, `SCENARIOS.md` not staged | block | block |
| 13 | `[F-0001]` without brief | block | block |
| 14 | `[F-0001]` standard, brief but no `Verdict: PROCEED` | block | block |
| 15 | `[F-0001]` standard, verdict but no `EVIDENCE.md` | block | block |
| 16 | `[F-0001]` standard, brief + verdict + evidence + area scenario | allow | allow |
| 17 | `[F-0002]` at `Tier: trivial`, brief only, no council | allow | allow |
| 18 | `STATE.md` at 450 words (cap 400) | block | block |
| 19 | `STATE.md` at 50 words | allow | allow |
| 20 | editing a file in `SCANTLING_ARCHIVED_PATTERN` | block | block |
| 21 | same edit with `SCANTLING_ARCHIVE_STAMP=1` | allow | allow |
| 22 | later edit to the frozen file | block | block |
| 23 | push to protected `main` with no audit entry | block | block |
| 24 | push with `Gate 2: PROCEED` but no `Reality-check:` | block | block |
| 25 | push with both | allow | allow |
| 26 | `AUDIT-LOG.md` at 25 entries (max 20) | block | block |
| 27 | em dash in added line | block | block |

## Smoke test (reproduce it)

```sh
T=$(mktemp -d); mkdir "$T/remote" "$T/repo"
git -C "$T/remote" init -q --bare
cd "$T/repo" && git init -q -b develop && git remote add origin "$T/remote"
git config user.email t@t; git config user.name t
cp -r /path/to/scantling/template/. .
sed -i 's|SCANTLING_CHECK_1=.*|SCANTLING_CHECK_1=""|' scantling/config.sh
sh scantling/hooks/install.sh
git add -A && git commit -m "install"            # expect: block, no tag
git commit -m "[scantling] install"                   # expect: allow
echo x > src/a.ts && git add -A
git commit -m "[fix] a"                          # expect: block, no Tier line

git commit -F - <<'EOF'                          # expect: block, below the floor
[fix] a

Tier: trivial
EOF

git commit -F - <<'EOF'                          # expect: allow
[fix] a

Tier: trivial
Tier-reason: new file, grep -rn a.ts src app -> 0 importers anywhere
EOF
```

Continue down the matrix. Each refusal prints a `scantling:` line saying what is
missing.

## Bypass

`--no-verify` works on commit and push. Scantling does not fight it. Using it is
a decision: record a `D-` or an `R-` line saying why. Agents must not bypass
without the owner's explicit instruction for that specific commit or push.

## Chaining existing hooks

If the repo had hooks before, add to the end of each Scantling hook:

```sh
[ -x "$ROOT/.githooks/pre-commit" ] && exec "$ROOT/.githooks/pre-commit" "$@"
```

Or move the old logic in. Record the choice.

## CI mirror

`ci/scantling-check.yml` is an optional GitHub Action that re-runs the pre-push
checks on pull requests into protected branches. Useful when more than one
machine pushes, or when someone might use `--no-verify`. Copy it to
`.github/workflows/`.

## Windows

Hooks run under Git for Windows' sh. Line endings must be LF. If a hook fails
with "bad interpreter" or `\r: command not found`, run
`git config core.autocrlf false` and re-save the hooks with LF endings.
The template files in this repository are LF.

## Regenerating template/ from the bootstrap

`SCANTLING_BOOTSTRAP.md` is the source; `template/` is extracted from its fenced
blocks. Any block that follows a line consisting only of a backticked path
(or a `### 3.x \`path\`` heading) is written to that path. If you edit the
bootstrap, run `sh tools/extract-template.sh` and check `git diff --stat template/`
is empty unless the change was intended.
