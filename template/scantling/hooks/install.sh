#!/bin/sh
# Point git at Scantling's hooks. Idempotent. Run from anywhere inside the repo.
set -e
ROOT=$(git rev-parse --show-toplevel)
chmod +x "$ROOT"/scantling/hooks/pre-commit "$ROOT"/scantling/hooks/commit-msg "$ROOT"/scantling/hooks/pre-push
chmod +x "$ROOT"/scantling/tools/*.sh 2>/dev/null || true
git config core.hooksPath scantling/hooks
echo "scantling: hooks installed (core.hooksPath = scantling/hooks)"
echo "scantling: if this repo had other hooks, chain them from scantling/hooks/* (see SCANTLING_BOOTSTRAP section 7.3)"
