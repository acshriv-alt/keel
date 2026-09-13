# D-0013: notification text shows street name only

Date: 2026-09-10
Status: accepted
Feature: F-0007
Tags: notifications, privacy

## Context
Delivery reminders (F-0007) show on the lock screen. The Adversary and Domain
voices at Gate 1 pointed out that including the full address exposes the
house number to anyone holding or glancing at the phone, and that the privacy
policy says addresses are not displayed outside the app. C-006 (iOS push
only after Add to Home Screen) does not change this; Android lock screens
show full body text by default.

## Options considered
1. **Full address in the push body**: clearest for the recipient. Rejected: lock-screen exposure, contradicts the policy.
2. **Street name only, house number inside the app**: chosen. The recipient knows their own house number; the street is enough to recognise the delivery.
3. **No address at all, just "your parcel"**: rejected. Recipients with multiple addresses (home, office) cannot tell which delivery this is.

## Decision
Notification titles and bodies include the street name and the window. The
house number and any unit or floor appear only on the in-app or signed-link
page. This applies to every notification type, not only reminders.

## Consequences
- The notification composer needs a `shortAddress()` helper; one place.
- Privacy policy copy stays true without an edit.
- Recipients with two deliveries on the same street on the same day see two similar notifications; the window disambiguates.

## Revisit when
A recipient complaint or support ticket shows the street alone was not enough
to identify the delivery, or the platform offers a privacy-sensitive
notification mode we can rely on.

## Evidence
COUNCIL-1.md for F-0007, Adversary and Domain sections. Privacy policy
section 4 ("Where we show your address").
