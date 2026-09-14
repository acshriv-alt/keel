## A-0023 2026-09-12T18:40+05:30
Branch: develop
Range: 4f2c9a1..b7e310d
Feature: F-0007 delivery-window-reminders
Tier: critical (sends real SMS, new scheduler, migration on a live table)
Gate 2: PROCEED WITH CHANGES (scantling/features/F-0007-delivery-window-reminders/COUNCIL-2.md, both changes done in b7e310d)
Reality-check: P-PRIYA, asked 2026-09-09: "I miss the window because the SMS comes while I'm on the bus and I can't act on it then, a reminder an hour before is the useful one"

Checks:
- `npx tsc --noEmit`: 0 errors
- `npm test`: 142 passed, 0 failed, 3 skipped (map tests, F-0006 blocked)
- `npm run build`: ok, no warnings
Scenarios run: SC-NOTIF-014 pass 2026-09-12 (automated), SC-NOTIF-015 pass 2026-09-11 (manual, Android 12 Chrome, signed link opened from SMS), SC-NOTIF-016 untested (needs a device with notifications denied; owner to test on iPhone before main), SC-NOTIF-017 pass 2026-09-12 (automated)
Migrations: db/007-delivery-windows.sql applied to staging 2026-09-11; prod pending, apply before the main merge, runbook apply-migration.md
Rollback: REMINDERS_ENABLED=false in env, or git revert b7e310d..4f2c9a1
Risk: medium: new scheduler process, SMS fallback path is real money; SC-NOTIF-016 unrun
Process ratio: since 30 days ago, 31 of 44 commits carry code, 13 carry only process. process:code is 0.4:1
Pushed by: agent (Claude Code) with approval from Priya at 18:42
