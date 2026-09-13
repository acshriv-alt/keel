# Hooks

Three POSIX sh scripts in `keel/hooks/`, activated by
`git config core.hooksPath keel/hooks`. Configured by `keel/config.sh`.

## Behaviour

| Hook | Runs | Blocks when |
|---|---|---|
| `pre-commit` | before the message editor | em dash (U+2014) in any added line, if `KEEL_FORBID_EMDASH=1`; a staged file matches `KEEL_CODE_PATTERN` and `keel/scenarios/SCENARIOS.md` is not staged and `KEEL_WAIVE_SCENARIOS` is not `1`. Warns (does not block) when `KEEL_CRITICAL_PATTERN` is touched. |
| `commit-msg` | after the message is written | no tag among `[F-dddd] [fix] [hotfix] [chore] [docs] [keel]`; tag is `[F-dddd]` and `keel/features/F-dddd-*/BRIEF.md` is missing or `COUNCIL-1.md` has no line starting `Verdict: PROCEED`; `KEEL_WAIVE_SCENARIOS=1` and no body line matching `Waiver: ` with ten or more characters; em dash in the message. |
| `pre-push` | before objects are sent | for each ref pushed to a branch in `KEEL_AUDITED_BRANCHES`: the commits being pushed do not touch `keel/audits/AUDIT-LOG.md`, or do not touch `keel/STATE.md`, or the last `## A-` block in the log does not have `Branch: <that branch>`; for `KEEL_PROTECTED_BRANCHES` additionally the last block lacks `Gate 2: PROCEED`; then for every push, each non-empty `KEEL_CHECK_n` command that exits non-zero. |

"Commits being pushed" is computed as the range from the remote's current
tip to the local tip. For a branch that does not exist on the remote yet, it
is every local commit not on any of that remote's refs. A fast-forward of an
already-pushed branch onto `main` therefore contains no new commits and is
blocked until an audit commit is made on `main` itself. That is intended:
every production push gets its own entry.

## config.sh

```sh
KEEL_PROTECTED_BRANCHES="main"          # Gate 2 PROCEED required
KEEL_AUDITED_BRANCHES="main develop"    # audit entry + STATE.md required
KEEL_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'
KEEL_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'
KEEL_CHECK_1="npx tsc --noEmit"
KEEL_CHECK_2=""
KEEL_CHECK_3=""
KEEL_FORBID_EMDASH=1
```

Patterns are `grep -E` regexes against repo-relative paths. Monorepos set
`KEEL_CODE_PATTERN` to their package roots.

## Verification matrix

Run 2026-09-11 in a throwaway repo under Git for Windows sh. Every case
behaved as designed.

| # | Case | Expected | Result |
|---|---|---|---|
| 1 | untagged commit | block | block |
| 2 | `[keel]` commit | allow | allow |
| 3 | code without `SCENARIOS.md` | block | block |
| 4 | code with `SCENARIOS.md` | allow | allow |
| 5 | `[F-0001]` without brief | block | block |
| 6 | `[F-0001]` with `Verdict: REWORK` | block | block |
| 7 | `[F-0001]` with `Verdict: PROCEED WITH CHANGES` | allow | allow |
| 8 | em dash in added line | block | block |
| 9 | waiver env, no `Waiver:` line | block | block |
| 10 | waiver env with reason | allow | allow |
| 11 | first push to new remote branch, no audit | block | block |
| 12 | first push with audit + STATE | allow | allow |
| 13 | second push, no new entry | block | block |
| 14 | push to `main`, last entry for `develop` | block | block |
| 15 | push to `main`, `Gate 2: REWORK` | block | block |
| 16 | push to `main`, `Gate 2: PROCEED` | allow | allow |
| 17 | failing `KEEL_CHECK_1` | block | block |

## Smoke test (reproduce it)

```sh
T=$(mktemp -d); mkdir "$T/remote" "$T/repo"
git -C "$T/remote" init -q --bare
cd "$T/repo" && git init -q -b develop && git remote add origin "$T/remote"
git config user.email t@t; git config user.name t
cp -r /path/to/keel/template/. .
sed -i 's|KEEL_CHECK_1=.*|KEEL_CHECK_1=""|' keel/config.sh
sh keel/hooks/install.sh
git add -A && git commit -m "install"            # expect: block, no tag
git commit -m "[keel] install"                   # expect: allow
echo x > src/a.ts && git add -A && git commit -m "[fix] a"   # expect: block, no scenario
```

Continue down the matrix. Each refusal prints a `keel:` line saying what is
missing.

## Bypass

`--no-verify` works on commit and push. Keel does not fight it. Using it is
a decision: record a `D-` or an `R-` line saying why. Agents must not bypass
without the owner's explicit instruction for that specific commit or push.

## Chaining existing hooks

If the repo had hooks before, add to the end of each Keel hook:

```sh
[ -x "$ROOT/.githooks/pre-commit" ] && exec "$ROOT/.githooks/pre-commit" "$@"
```

Or move the old logic in. Record the choice.

## CI mirror

`ci/keel-check.yml` is an optional GitHub Action that re-runs the pre-push
checks on pull requests into protected branches. Useful when more than one
machine pushes, or when someone might use `--no-verify`. Copy it to
`.github/workflows/`.

## Windows

Hooks run under Git for Windows' sh. Line endings must be LF. If a hook fails
with "bad interpreter" or `\r: command not found`, run
`git config core.autocrlf false` and re-save the hooks with LF endings.
The template files in this repository are LF.

## Regenerating template/ from the bootstrap

`KEEL_BOOTSTRAP.md` is the source; `template/` is extracted from its fenced
blocks. Any block that follows a line consisting only of a backticked path
(or a `### 3.x \`path\`` heading) is written to that path. If you edit the
bootstrap, re-extract so the two never drift. The extractor used for 1.0 is
a 25-line awk script; a maintainer can find it in the git history of this
file's first commit or rewrite it from that description.
