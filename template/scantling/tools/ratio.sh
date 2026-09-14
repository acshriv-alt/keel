#!/bin/sh
# Process commits against code commits. If process has outrun code for a
# month, Scantling has become the project: cut ceremony and record the cut.
# Usage: sh scantling/tools/ratio.sh ["30 days ago"]
ROOT=$(git rev-parse --show-toplevel)
. "$ROOT/scantling/config.sh"
SINCE=${1:-30 days ago}

CODE=0
PROCESS=0
for sha in $(git log --since="$SINCE" --format=%H); do
  if git show --name-only --pretty=format: "$sha" | grep -qE "$SCANTLING_CODE_PATTERN"; then
    CODE=$((CODE + 1))
  else
    PROCESS=$((PROCESS + 1))
  fi
done

TOTAL=$((CODE + PROCESS))
if [ "$TOTAL" -eq 0 ]; then
  echo "scantling: no commits since $SINCE"
  exit 0
fi

echo "scantling: since $SINCE, $CODE of $TOTAL commits carry code, $PROCESS carry only process."
if [ "$CODE" -eq 0 ]; then
  echo "scantling: ratio is $PROCESS:0. Nothing shipped in this window."
  exit 0
fi
R=$((PROCESS * 10 / CODE))
echo "scantling: process:code is $((R / 10)).$((R % 10)):1 (target: at or below 1.0:1)."
if [ "$R" -gt 10 ]; then
  echo "scantling: above 1:1. If it stays here for a month, cut ceremony and record a D-."
  echo "scantling: usual causes: a tier floor set too wide, or two systems of record."
fi
exit 0
