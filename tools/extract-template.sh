#!/bin/sh
# Regenerate template/ from SCANTLING_BOOTSTRAP.md so the two never drift.
#
# Every fenced block in the bootstrap that follows either a heading of the
# form "### 3.x `path`" or a line consisting only of a backticked path
# (starting with scantling/, SCANTLING.md or .claude/) is written to template/<path>.
# Four-backtick fences are honoured so SCANTLING.md, which contains three-backtick
# fences of its own, extracts intact.
#
# Usage:  sh tools/extract-template.sh            writes into ./template
#         sh tools/extract-template.sh /tmp/out   writes elsewhere, for diffing
#
# After running, `git diff --stat template/` should be empty unless you
# changed the bootstrap on purpose.

set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$HERE/template}
SRC="$HERE/SCANTLING_BOOTSTRAP.md"

[ -f "$SRC" ] || { echo "extract-template: $SRC not found" >&2; exit 1; }
mkdir -p "$OUT"

awk -v out_root="$OUT" '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
BEGIN { path = ""; fence = ""; out = "" }
{
  line = $0; sub(/\r$/, "", line)
  if (fence != "") {
    if (line == fence) { close(out); fence = ""; out = ""; next }
    print line >> out; next
  }
  t = trim(line)
  if (match(t, /^### [0-9.]+ `[^`]+`/)) {
    p = t; sub(/^### [0-9.]+ `/, "", p); sub(/`.*$/, "", p); path = p; next
  }
  if (match(t, /^`[^`]+`$/)) {
    p = t; gsub(/`/, "", p)
    if (p ~ /^(scantling\/|SCANTLING.md$|\.claude\/)/) path = p
    next
  }
  if (path != "" && (t == "```sh" || t == "```markdown" || t == "````markdown" || t == "```")) {
    fence = (substr(t, 1, 4) == "````") ? "````" : "```"
    out = out_root "/" path
    dir = out; sub(/\/[^\/]+$/, "", dir)
    system("mkdir -p \"" dir "\"")
    printf "" > out
    path = ""; next
  }
  if (t !~ /^`/ && t ~ /^### /) path = ""
}' "$SRC"

# Files the bootstrap describes but does not fence.
mkdir -p "$OUT/scantling/features" "$OUT/scantling/incidents"
: > "$OUT/scantling/features/.gitkeep"
: > "$OUT/scantling/incidents/.gitkeep"
[ -f "$OUT/AGENTS.md" ] || printf 'Read SCANTLING.md first. It is the entry point for state, decisions and the push gates.\n' > "$OUT/AGENTS.md"

chmod +x "$OUT"/scantling/hooks/* "$OUT"/scantling/tools/*.sh 2>/dev/null || true
echo "extract-template: wrote $(find "$OUT" -type f | wc -l | tr -d ' ') files to $OUT"
