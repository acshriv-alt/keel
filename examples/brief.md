# F-0007: delivery-window reminders

Date: 2026-09-09. Owner: Priya. Status: gate-2

## Problem
Recipients miss deliveries because they forget the two-hour window they chose
the day before. Missed deliveries are 18% of attempts (ops dashboard, August)
and each costs a re-delivery trip. Support gets "where is my parcel" messages
inside the window from people who are not home.

## Who and when
Persona: P-RECIPIENT-WORK.
Moment: a weekday, at their desk, phone face down, 25 minutes before the
courier arrives at a home 40 minutes away.

## The one scenario
Given I chose the 2 pm to 4 pm window yesterday
When it is 1:30 pm and I am at work
Then my phone shows "Parcel arriving 2 pm to 4 pm at 12 Lake Road. Not home? Tap to move it."
And tapping "move" lets me pick tomorrow's window in two taps without logging in.

## Prior art in this repo
Decisions: D-0009 (push is the primary channel, SMS is fallback), D-0011 (no login for recipients; signed links only).
Rejected: R-003 (email reminders: 4% open rate in the 2025 pilot). Searched for: reminder, notify, window, email.
Constraints that apply: C-002 (SMS costs 0.12 per message and needs template pre-approval), C-006 (push on iOS only after Add to Home Screen).
Assumptions this depends on: AS-012 (most recipients allowed push at booking), status unverified. AS-013 (30 minutes is enough lead time to move a delivery), verified by asking two recipients on 2026-09-10; both said 60 is too early, 30 is right.
Real person asked: R. Mehta, recipient, 2026-09-10: "If it pinged me half an hour before I would just move it to the evening. Right now I find out when the card is on the door."

## Non-goals
- Live courier location (F-0006, blocked).
- Reminders to the sender.
- Anything requiring the recipient to log in.

## Success metric
Missed-delivery rate for recipients who received a reminder, measured in the ops dashboard weekly. Current 18%. Target under 12% within four weeks of ship.

## Kill criteria
If the reminded cohort's missed rate is not at least 3 points below the unreminded cohort after four weeks, remove the scheduler and record why.

## Cost check
One push per delivery, zero marginal cost. SMS fallback only when push fails: estimated 15% of deliveries, 0.12 each. At 10x current volume (20,000 deliveries a month): about 360 a month in SMS.

## Rollback
Feature flag `REMINDERS_ENABLED` read at scheduler start. Off stops new reminders within one minute; queued ones drain.

## Scenarios to add
SC-NOTIF-014 reminder fires 30 minutes before window start.
SC-NOTIF-015 tapping "move" works from a signed link without login.
SC-NOTIF-016 push denied: SMS fallback fires once, not twice.
SC-NOTIF-017 window edited by courier: exactly one reminder for the new window.

## Gate 1 required changes (from COUNCIL-1.md)
- [x] 1. Add SC-NOTIF-017 for courier edits (done in 9be12c0)
- [x] 2. Cap SMS fallback at one per delivery (done in c41d7f3)
- [x] 3. Signed link expires 24 h after the window ends (done in c41d7f3)
