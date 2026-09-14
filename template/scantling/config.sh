# Scantling hook configuration. Sourced by every hook. Plain sh, no bashisms.

# Which Scantling this repo is running. Set at install, changed only by an
# upgrade. Scantling makes no network call and never checks for updates: this
# is here so that "what am I running" has an answer without one, and so an
# upgrade can tell which migration steps apply. See section 11.
SCANTLING_VERSION=2.0.0

# Branches that require Gate 2 PROCEED in the audit entry before push.
SCANTLING_PROTECTED_BRANCHES="main"

# Branches that require an audit entry and a STATE.md update before push.
SCANTLING_AUDITED_BRANCHES="main develop"

# Files matching this (grep -E) count as code. Code at tier standard or above
# ships with a scenario. Matching this sets the tier floor to standard.
SCANTLING_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'

# Paths whose tier floor is critical. A commit may still declare a lower tier,
# but must justify it on the record with a Tier-reason line.
SCANTLING_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'

# Tier assumed when a commit declares none and touches no code at all.
SCANTLING_DEFAULT_TIER=trivial

# 1 = a commit may declare a tier below its path-implied floor, with a
# Tier-reason line of 20 characters or more. 0 = the floor is hard.
# Turning this off brings back the 1.0 behaviour: path decides, and trivial
# changes on critical paths pay the full toll.
SCANTLING_ALLOW_TIER_DOWNGRADE=1

# Hard cap on scantling/STATE.md in words. The pre-commit hook refuses a bigger
# file. The cap is the mechanism: STATE.md is rewritten, not grown.
# 0 = no cap.
SCANTLING_STATE_MAX_WORDS=400

# Entries allowed in the live AUDIT-LOG.md before pre-push demands an archive
# into scantling/audits/archive/. Append-only is about integrity, not about one
# file growing forever. 0 = never demand.
SCANTLING_AUDIT_MAX_ENTRIES=20

# Dated archive files: superseded by scantling/, kept for history, never edited.
# The pre-commit hook refuses to stage a change to one. Set this when a file
# is marked "replaced" in scantling/knowledge/SOURCES.md. Empty = nothing archived.
SCANTLING_ARCHIVED_PATTERN=''

# Commands run by pre-push on every branch. Empty string = skip.
SCANTLING_CHECK_1="{{e.g. npx tsc --noEmit}}"
SCANTLING_CHECK_2=""
SCANTLING_CHECK_3=""

# Forbid the em dash (U+2014) in added lines and commit messages. 1 = on.
SCANTLING_FORBID_EMDASH=1
