# Keel hook configuration. Sourced by every hook. Plain sh, no bashisms.

# Branches that require Gate 2 PROCEED in the audit entry before push.
KEEL_PROTECTED_BRANCHES="main"

# Branches that require an audit entry and a STATE.md update before push.
KEEL_AUDITED_BRANCHES="main develop"

# Files matching this (grep -E) count as code. Code changes need a scenario.
KEEL_CODE_PATTERN='^(src|app|lib|components|db|server|packages|api)/'

# Fixes touching these need Gate 2 even on non-protected branches (advisory:
# the hook warns, the council protocol requires it).
KEEL_CRITICAL_PATTERN='^(app/api|lib/auth|db/|server/auth)'

# Commands run by pre-push on every branch. Empty string = skip.
KEEL_CHECK_1="{{e.g. npx tsc --noEmit}}"
KEEL_CHECK_2=""
KEEL_CHECK_3=""

# Forbid the em dash (U+2014) in added lines and commit messages. 1 = on.
KEEL_FORBID_EMDASH=1
