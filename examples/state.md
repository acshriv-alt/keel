# State

_Rewritten at the end of every session. Last updated: 2026-09-12 by agent (Claude Code)._

## Now
- Branch: `develop` at `4f2c9a1`. Production: `v1.8.0` live since 2026-09-05.
- Pending migrations: `db/007-delivery-windows.sql` applied to staging 2026-09-11, prod pending.
- Env drift: `SMS_PROVIDER_KEY` present in staging, unconfirmed in prod (see B-031).

## In flight
- F-0007 delivery-window-reminders: Gate 1 passed with changes 2026-09-10, code done, scenarios SC-NOTIF-014..017 written, SC-NOTIF-015 run on Android Chrome. Gate 2 not yet run.

## Next (max 3, in order)
1. Gate 2 on F-0007, then audit A-0023 and push to develop.
2. B-029 P1: reminder fires twice when the courier edits the window (found during F-0007, not fixed).
3. Outcome review for F-0005 due 2026-09-19.

## Blocked
- F-0006 live-map: blocked on map vendor quote since 2026-09-03 (C-004 says free tier caps at 1,000 loads/day).

## Last session
Finished the reminder scheduler and the opt-out link. Decided D-0014 (reminders
go 30 minutes before the window, not 60; user persona said 60 is "too early to
act on"). Found B-029 while testing edits; logged, not fixed. Did not get to
Gate 2. `SC-NOTIF-016` still untested: needs a device with notifications
denied.
