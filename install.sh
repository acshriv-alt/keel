#!/bin/sh
# Scantling installer. Copies the template tree into a target repository without
# overwriting anything that already exists, installs the git hooks, and adds
# the entry-point pointer to whatever agent instruction file the repo uses.
#
# Usage:
#   sh install.sh /path/to/repo            template + hooks + pointer
#   sh install.sh /path/to/repo --skills   also copy the Claude Code skills
#   sh install.sh /path/to/repo --no-hooks copy files only, do not touch git config
#
# Run from a clone of the Scantling repository. POSIX sh, works in Git Bash on Windows.

set -e

HERE=$(cd "$(dirname "$0")" && pwd)
TARGET=${1:-}
SKILLS=0
HOOKS=1
for a in "$@"; do
  case "$a" in
    --skills) SKILLS=1 ;;
    --no-hooks) HOOKS=0 ;;
  esac
done

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
  echo "usage: sh install.sh /path/to/repo [--skills] [--no-hooks]" >&2
  exit 1
fi
if ! git -C "$TARGET" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "scantling: $TARGET is not a git repository" >&2
  exit 1
fi
TARGET=$(git -C "$TARGET" rev-parse --show-toplevel)

copied=0
skipped=0
copy_tree() {
  src=$1
  (cd "$src" && find . -type f) | while IFS= read -r rel; do
    rel=${rel#./}
    case "$rel" in
      .claude/*) [ "$SKILLS" = "1" ] || continue ;;
    esac
    dest="$TARGET/$rel"
    if [ -e "$dest" ]; then
      echo "  skip   $rel (exists)"
    else
      mkdir -p "$(dirname "$dest")"
      cp "$src/$rel" "$dest"
      echo "  create $rel"
    fi
  done
}

echo "scantling: installing into $TARGET"
copy_tree "$HERE/template"

# Pointer line for agent instruction files. Add to every one that exists;
# AGENTS.md was created by the template if none existed.
POINTER="Read SCANTLING.md first. It is the entry point for state, decisions and the push gates."
for f in CLAUDE.md AGENTS.md .cursorrules GEMINI.md .github/copilot-instructions.md; do
  p="$TARGET/$f"
  [ -f "$p" ] || continue
  if ! grep -qF "Read SCANTLING.md first" "$p"; then
    printf '\n%s\n' "$POINTER" >> "$p"
    echo "  append pointer -> $f"
  fi
done

if [ "$HOOKS" = "1" ]; then
  chmod +x "$TARGET"/scantling/hooks/* "$TARGET"/scantling/tools/*.sh 2>/dev/null || true
  existing=$(git -C "$TARGET" config --get core.hooksPath || true)
  if [ -n "$existing" ] && [ "$existing" != "scantling/hooks" ]; then
    echo "scantling: core.hooksPath is already '$existing'. Not changing it."
    echo "scantling: chain the old hooks from scantling/hooks/* or move their logic, then run: git config core.hooksPath scantling/hooks"
  else
    git -C "$TARGET" config core.hooksPath scantling/hooks
    echo "  hooks  core.hooksPath = scantling/hooks"
  fi
fi

cat <<EOF

scantling: done. Next:
  1. Fill the {{PLACEHOLDERS}} in SCANTLING.md and scantling/config.sh.
  2. Seed scantling/knowledge/CONSTRAINTS.md, REJECTED.md and scantling/decisions/ with
     what you already know. Thirty minutes now saves every future session.
  3. Settle the system of record: fill scantling/knowledge/SOURCES.md. For every
     doc that already tracks state, issues or releases, say replaced, kept or
     deferred. Replaced files get the archive banner and go into
     SCANTLING_ARCHIVED_PATTERN, after which the hook refuses edits to them.
     Running two records is the most expensive state available.
  4. Map the scenario areas in scantling/scenarios/AREAS.map, and create the
     matching scantling/scenarios/areas/*.md files.
  5. Write scantling/STATE.md from the current branch, inside 400 words.
  6. git add SCANTLING.md AGENTS.md scantling && git commit -m "[scantling] install Scantling"
     (the commit-msg hook is already active: the [scantling] tag is required, and
     a commit touching code also needs a "Tier:" line in the body)
EOF
