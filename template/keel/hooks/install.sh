#!/bin/sh
# Point git at Keel's hooks. Idempotent. Run from anywhere inside the repo.
set -e
ROOT=$(git rev-parse --show-toplevel)
chmod +x "$ROOT"/keel/hooks/pre-commit "$ROOT"/keel/hooks/commit-msg "$ROOT"/keel/hooks/pre-push
git config core.hooksPath keel/hooks
echo "keel: hooks installed (core.hooksPath = keel/hooks)"
echo "keel: if this repo had other hooks, chain them from keel/hooks/* (see KEEL_BOOTSTRAP section 7.3)"
