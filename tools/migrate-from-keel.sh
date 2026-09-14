#!/bin/sh
# Migrate a Keel 1.0 install to Scantling 2.0.
#
# Does the mechanical half: renames the tree, rewrites identifiers, installs
# the 2.0 hooks and templates, keeps your config values, writes the version.
# Stages everything and STOPS. It never commits and never pushes: you read the
# diff first.
#
# The judgement half is yours and is listed at the end: splitting scenarios by
# area, filling SOURCES.md, trimming STATE.md, archiving audits, declaring
# tiers on in-flight briefs. See section 11 of SCANTLING_BOOTSTRAP.md.
#
# Usage:
#   sh tools/migrate-from-keel.sh --dry-run /path/to/your/repo
#   sh tools/migrate-from-keel.sh           /path/to/your/repo
set -e

DRY=0
TARGET=""
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    -*) echo "migrate: unknown option $a" >&2; exit 2 ;;
    *)  TARGET=$a ;;
  esac
done

HERE=$(cd "$(dirname "$0")/.." && pwd)
[ -n "$TARGET" ] || { echo "migrate: give the path to the repo to migrate" >&2; exit 2; }
[ -d "$TARGET" ] || { echo "migrate: $TARGET is not a directory" >&2; exit 2; }
TARGET=$(cd "$TARGET" && pwd)

say() { if [ "$DRY" = "1" ]; then echo "  would $*"; else echo "  $*"; fi; }
run() { if [ "$DRY" = "1" ]; then :; else sh -c "$*"; fi; }

# ---------------------------------------------------------------- sanity
git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1 || {
  echo "migrate: $TARGET is not a git repository" >&2; exit 1; }

if [ ! -d "$TARGET/keel" ] && [ ! -f "$TARGET/KEEL.md" ]; then
  if [ -d "$TARGET/scantling" ]; then
    echo "migrate: $TARGET already looks like Scantling. Nothing to do."; exit 0
  fi
  echo "migrate: no keel/ or KEEL.md in $TARGET. Is this a Keel install?" >&2; exit 1
fi

if [ "$DRY" != "1" ]; then
  DIRTY=$(git -C "$TARGET" status --porcelain)
  if [ -n "$DIRTY" ]; then
    echo "migrate: $TARGET has uncommitted changes. Commit or stash first, so the" >&2
    echo "migrate: migration diff is the only thing in your working tree." >&2
    exit 1
  fi
fi

echo "migrate: Keel 1.0 -> Scantling 2.0 in $TARGET"
[ "$DRY" = "1" ] && echo "migrate: DRY RUN, nothing will be written"

# ------------------------------------------------- 1. preserve config values
OLDCFG="$TARGET/keel/config.sh"
KEEP=""
if [ -f "$OLDCFG" ]; then
  KEEP=$(sed -n 's/^KEEL_\(PROTECTED_BRANCHES\|AUDITED_BRANCHES\|CODE_PATTERN\|CRITICAL_PATTERN\|CHECK_1\|CHECK_2\|CHECK_3\|FORBID_EMDASH\)=/SCANTLING_\1=/p' "$OLDCFG")
  echo "  carrying over $(printf '%s\n' "$KEEP" | grep -c '=') settings from keel/config.sh"
fi

# --------------------------------------------------------- 2. rename the tree
if [ -d "$TARGET/keel" ]; then
  say "git mv keel scantling"
  run "git -C '$TARGET' mv keel scantling"
fi
if [ -f "$TARGET/KEEL.md" ]; then
  say "git mv KEEL.md SCANTLING.md"
  run "git -C '$TARGET' mv KEEL.md SCANTLING.md"
fi
for d in "$TARGET"/.claude/skills/keel-*; do
  [ -d "$d" ] || continue
  n=$(basename "$d"); new="scantling-${n#keel-}"
  say "git mv .claude/skills/$n .claude/skills/$new"
  run "git -C '$TARGET' mv '.claude/skills/$n' '.claude/skills/$new'"
done

# ------------------------------------- 3. drop in the 2.0 files that replace
# Hooks and templates are code, not content: they are replaced wholesale.
# Content files (STATE, BACKLOG, decisions, knowledge, scenarios, audits,
# features) are YOURS and are only rewritten for identifiers, below.
for f in hooks/pre-commit hooks/commit-msg hooks/pre-push hooks/install.sh \
         templates/EVIDENCE.md templates/AUDIT.md templates/BRIEF.md \
         templates/COUNCIL.md council/COUNCIL.md tools/ratio.sh; do
  src="$HERE/template/scantling/$f"
  [ -f "$src" ] || continue
  say "install 2.0 scantling/$f"
  if [ "$DRY" != "1" ]; then
    mkdir -p "$(dirname "$TARGET/scantling/$f")"
    cp "$src" "$TARGET/scantling/$f"
  fi
done

for f in knowledge/SOURCES.md scenarios/AREAS.map scenarios/areas/AUTH.md; do
  src="$HERE/template/scantling/$f"
  [ -f "$src" ] || continue
  if [ -e "$TARGET/scantling/$f" ]; then
    say "keep existing scantling/$f"
  else
    say "add scantling/$f (placeholder, you fill it)"
    if [ "$DRY" != "1" ]; then
      mkdir -p "$(dirname "$TARGET/scantling/$f")"
      cp "$src" "$TARGET/scantling/$f"
    fi
  fi
done

[ "$DRY" != "1" ] && mkdir -p "$TARGET/scantling/audits/archive"

# ------------------------------------------ 4. rewrite identifiers in content
# Order matters: specific before general, exactly as the repo rename did.
#
# Append-only records are SKIPPED, deliberately. Rule 9 says AUDIT-LOG.md,
# REJECTED.md, decision records and incidents are never edited in place, and
# they are statements about what was true at the time. A decision record that
# says "we put this in keel/" is a correct account of a decision taken when
# the framework was called Keel. Rewriting it would make the record false, in
# a framework whose entire claim is that its records can be trusted. They keep
# their Keel-era wording and the rename note at the top of AUDIT-LOG.md
# explains it.
say "rewrite identifiers in operational files (append-only records are left as history)"
if [ "$DRY" != "1" ]; then
  git -C "$TARGET" ls-files -z -- 'scantling/*' 'SCANTLING.md' '.claude/*' \
      'CLAUDE.md' 'AGENTS.md' '.cursorrules' '*.md' 2>/dev/null \
  | while IFS= read -r -d '' rel; do
      p="$TARGET/$rel"
      [ -f "$p" ] || continue
      case "$rel" in *.png|*.jpg|*.ico|*.pdf) continue ;; esac
      case "$rel" in
        # Append-only records: history, left exactly as written (see above).
        scantling/audits/*|scantling/decisions/*|scantling/incidents/*|scantling/knowledge/REJECTED.md)
          continue ;;
        # Files this script just installed from the 2.0 template. They already
        # use the new names, and they mention "Keel" on purpose: the pre-push
        # advisory that detects a stale config has to be able to say the word.
        scantling/hooks/*|scantling/tools/*|scantling/templates/*|scantling/council/COUNCIL.md|scantling/config.sh)
          continue ;;
      esac
      sed -i \
        -e 's/KEEL_BOOTSTRAP/SCANTLING_BOOTSTRAP/g' \
        -e 's/KEEL\.md/SCANTLING.md/g' \
        -e 's/KEEL_\([A-Z]\)/SCANTLING_\1/g' \
        -e 's#\bkeel/#scantling/#g' \
        -e 's/\bkeel-/scantling-/g' \
        -e 's/\[keel\]/[scantling]/g' \
        -e 's/\bkeel:/scantling:/g' \
        -e 's/\bKeel\b/Scantling/g' \
        -e 's/\bkeel\b/scantling/g' \
        "$p"
    done
fi

# --------------------------- 4b. explain the untouched history, append-only
say "add a rename note to the top of the audit log"
if [ "$DRY" != "1" ] && [ -f "$TARGET/scantling/audits/AUDIT-LOG.md" ]; then
  LOG="$TARGET/scantling/audits/AUDIT-LOG.md"
  if ! grep -q 'renamed from Keel' "$LOG"; then
    TMP="$LOG.tmp.$$"
    {
      head -1 "$LOG"
      cat <<'NOTE'

> Note, added on migration: this project was renamed from Keel to Scantling.
> Entries below the rename keep their original wording, including `keel/`
> paths and `[keel]` commit tags. They are append-only records of what was
> true when they were written and are not rewritten. Paths named in them
> resolve to `scantling/` today.
NOTE
      tail -n +2 "$LOG"
    } > "$TMP"
    mv "$TMP" "$LOG"
  fi
fi

# --------------------------------------------- 5. config: version + carryover
say "write SCANTLING_VERSION=2.0.0 into scantling/config.sh"
if [ "$DRY" != "1" ]; then
  CFG="$TARGET/scantling/config.sh"
  cp "$HERE/template/scantling/config.sh" "$CFG"
  if [ -n "$KEEP" ]; then
    printf '%s\n' "$KEEP" | while IFS= read -r line; do
      [ -n "$line" ] || continue
      key=${line%%=*}
      # Replace the template default with the value this repo already used.
      esc=$(printf '%s' "$line" | sed 's/[&|]/\\&/g')
      sed -i "s|^$key=.*|$esc|" "$CFG"
    done
  fi
fi

# ------------------------------------------------------------- 6. hooks path
say "git config core.hooksPath scantling/hooks"
if [ "$DRY" != "1" ]; then
  chmod +x "$TARGET"/scantling/hooks/* "$TARGET"/scantling/tools/*.sh 2>/dev/null || true
  cur=$(git -C "$TARGET" config --get core.hooksPath || true)
  if [ -z "$cur" ] || [ "$cur" = "keel/hooks" ]; then
    git -C "$TARGET" config core.hooksPath scantling/hooks
  else
    echo "  core.hooksPath is '$cur', not changing it. Point it at scantling/hooks yourself."
  fi
fi

# ----------------------------------------------------------------- 7. stage
if [ "$DRY" != "1" ]; then
  git -C "$TARGET" add -A
fi

cat <<'EOF'

migrate: mechanical half done, staged, NOT committed. Read the diff:

    git -C <repo> diff --cached --stat

Then commit (the commit-msg hook is already the 2.0 one, so it wants a tier):

    git commit -F - <<'MSG'
    [scantling] migrate from Keel 1.0 to Scantling 2.0

    Tier: standard
    MSG

Still yours to do, because none of it can be scripted honestly:

  1. scantling/scenarios/AREAS.map   map your real code paths to areas
  2. scantling/scenarios/areas/*.md  move scenarios out of SCENARIOS.md,
                                     keeping every SC- ID unchanged; leave the
                                     index and coverage map behind
  3. scantling/knowledge/SOURCES.md  replaced / kept / deferred for every old
                                     tracking doc, then freeze the replaced
                                     ones via SCANTLING_ARCHIVED_PATTERN
  4. scantling/STATE.md              trim under 400 words (the hook enforces)
  5. scantling/audits/archive/       move shipped audit entries across
  6. in-flight briefs                add a Tier: line to each

Steps 2 and 3 are where the value is. They are the two findings that cost the
first adopter the most.

Your first push will want a Reality-check: line in the newest audit entry.
Write one fresh entry for this migration and the gate opens.
EOF
