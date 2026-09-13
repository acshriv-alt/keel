# Council: F-0007 Gate 1

Date: 2026-09-10. Input: BRIEF.md. Chair: agent (Claude Code).

## User
P-RECIPIENT-WORK has the phone face down at a desk. A push with a normal
priority may sit unseen; the brief should ask for high urgency so it
vibrates. The "move" flow says two taps: window picker then confirm. On the
old Android in the persona file the picker must not be a native date input,
those are three screens deep. Step where they give up: if "move" opens the
app and asks them to log in. D-0011 forbids that, the brief honours it. Fine.
Severity: medium

## Adversary
The signed link is the attack surface. If it never expires, a forwarded
message lets anyone move the delivery for weeks. Require expiry 24 h after
the window ends. Also: the link reveals the address in the push body; on a
locked screen that is visible to anyone holding the phone. Consider showing
the street only, not the number, in the notification text.
Severity: high

## Operator
Cost is fine per the brief. The risk is the fallback: if push "fails" is
judged by a timeout, slow devices will get push and SMS both. C-002 makes
every duplicate cost 0.12. Define failure as an explicit push rejection
(410 or 404), not a timeout, and cap SMS at one per delivery. Add a metric:
reminders sent, by channel, per day, on the ops dashboard.
Severity: high

## Skeptic
R-003 rejected email for this exact problem; the brief cites it, good. The
simpler alternative is a reminder at booking time ("we will arrive 2 to 4
tomorrow, add to calendar"). That costs nothing and needs no scheduler. The
brief should say why it is not enough. Success metric is measurable today.
Severity: low

## Domain
Courier reminders in this market commonly show the window and a one-tap
reschedule; the incumbent does exactly that and adds "leave with neighbour".
Nothing regulatory here beyond the address-in-notification point the
Adversary raised, which touches the privacy policy's "we do not display your
address outside the app" line. Either change the copy or the policy.
Severity: medium

## Pre-mortem
- User: reminder came while they were commuting and they could not act; 30 minutes was right for desk workers, wrong for others.
- Adversary: a forwarded link let a stranger redirect a parcel.
- Operator: duplicate SMS bill doubled the cost estimate.
- Skeptic: the metric moved because of the calendar add, not the reminder, and nobody could tell.
- Domain: address shown on lock screens, one complaint became a policy incident.

## Chair synthesis
The idea is sound and the persona evidence is real. Three things must change
before code: link expiry, one SMS cap with explicit failure criteria, and a
scenario for courier edits (the Operator's duplicate concern applies there
too). The address-on-lock-screen point becomes a decision: show street only.
The Skeptic's calendar alternative is cheap enough to ship alongside and
would confound the metric, so it is deferred and recorded.

Verdict: PROCEED WITH CHANGES

## Required changes
- [ ] 1. Add SC-NOTIF-017 for courier edits (one reminder for the new window).
- [ ] 2. SMS fallback only on explicit push rejection, capped at one per delivery.
- [ ] 3. Signed link expires 24 h after the window ends.

## Decisions to record
- D-0013: notification text shows street name only, never the house number.
- D-0014: reminder lead time 30 minutes (persona evidence in brief).
## Rejected to record
- R-008: calendar add at booking as the reminder mechanism. Deferred, not rejected outright: revisit after F-0007 outcome review so the metric is clean.
## Constraints or assumptions learned
- AS-013 verified (30 minutes lead time) by two recipients 2026-09-10.
