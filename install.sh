#!/bin/sh
# Keel installer. Copies the template tree into a target repository without
# overwriting anything that already exists, installs the git hooks, and adds
# the entry-point pointer to whatever agent instruction file the repo uses.
#
# Usage:
#   sh install.sh /path/to/repo            template + hooks + pointer
#   sh install.sh /path/to/repo --skills   also copy the Claude Code skills
#   sh install.sh /path/to/repo --no-hooks copy files only, do not touch git config
#
# Run from a clone of the Keel repository. POSIX sh, works in Git Bash on Windows.

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
  echo "keel: $TARGET is not a git repository" >&2
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

echo "keel: installing into $TARGET"
copy_tree "$HERE/template"

# Pointer line for agent instruction files. Add to every one that exists;
# AGENTS.md was created by the template if none existed.
POINTER="Read KEEL.md first. It is the entry point for state, decisions and the push gates."
for f in CLAUDE.md AGENTS.md .cursorrules GEMINI.md .github/copilot-instructions.md; do
  p="$TARGET/$f"
  [ -f "$p" ] || continue
  if ! grep -qF "Read KEEL.md first" "$p"; then
    printf '\n%s\n' "$POINTER" >> "$p"
    echo "  append pointer -> $f"
  fi
done

if [ "$HOOKS" = "1" ]; then
  chmod +x "$TARGET"/keel/hooks/* 2>/dev/null || true
  existing=$(git -C "$TARGET" config --get core.hooksPath || true)
  if [ -n "$existing" ] && [ "$existing" != "keel/hooks" ]; then
    echo "keel: core.hooksPath is already '$existing'. Not changing it."
    echo "keel: chain the old hooks from keel/hooks/* or move their logic, then run: git config core.hooksPath keel/hooks"
  else
    git -C "$TARGET" config core.hooksPath keel/hooks
    echo "  hooks  core.hooksPath = keel/hooks"
  fi
fi

cat <<EOF

keel: done. Next:
  1. Fill the {{PLACEHOLDERS}} in KEEL.md and keel/config.sh.
  2. Seed keel/knowledge/CONSTRAINTS.md, REJECTED.md and keel/decisions/ with
     what you already know. Thirty minutes now saves every future session.
  3. Write keel/STATE.md from the current branch.
  4. git add KEEL.md AGENTS.md keel && git commit -m "[keel] install Keel"
     (the commit-msg hook is already active: the [keel] tag is required)
EOF
