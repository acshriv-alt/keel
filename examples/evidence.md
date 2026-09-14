# Evidence: F-0007 Gate 1

Collected by one agent before any voice speaks, so that five voices reason
independently instead of reading the same files five times.

Every line here is a command and what it printed. No judgement, no
recommendation. The voices get this file and the brief, and nothing else.

Date: 2026-09-08. Collected by: agent (Claude Code). Input: BRIEF.md.

## Prior art

- `grep -n "reminder" scantling/decisions/INDEX.md`
  - `D-0004 2026-04-02 accepted  SMS only for failed delivery, not for status updates`
  - `D-0011 2026-07-19 accepted  All outbound SMS goes through the queue, never inline`
- `grep -n "reminder\|notify" scantling/knowledge/REJECTED.md`
  - `R-003 Push notifications in the browser. Safari iOS support, and P-PRIYA uses an iPhone. Revisit when iOS push from PWAs is available to us without an App Store build.`
- `grep -n "SMS\|queue" scantling/knowledge/CONSTRAINTS.md` (quoted in full, the voices cannot open the file)
  - `C-007 2026-04-02 SMS costs INR 0.18 per message on our plan, billed monthly in arrears. Evidence: April invoice, 12,400 messages, INR 2,232.`
  - `C-012 2026-06-30 The SMS vendor rate-limits to 30/second per sender ID. Evidence: 429s in the 2026-06-29 batch, vendor confirmed by email.`
  - `C-015 2026-08-11 Delivery partners' phones are frequently on 2G in the outer zones. Median first-byte 2.9s measured on the partner app.`

## Code in scope

- `grep -rn "sendSms" lib app` -> 4 call sites:
  - `lib/sms/queue.ts:41` (the only sender)
  - `app/api/delivery/failed/route.ts:88`
  - `app/api/admin/broadcast/route.ts:120`
  - `lib/jobs/retry-failed.ts:33`
- `grep -rn "cron\|scheduler" lib app` -> 0 hits. There is no scheduled job
  runner in this repo today. This feature would add the first one.
- `lib/sms/queue.ts`: accepts a message and a recipient, writes to the
  `sms_outbox` table, and a Vercel function drains it on request. Nothing
  drains it on a timer.

## Data

- Tables touched: `deliveries` (read), `sms_outbox` (write), a new
  `delivery_windows` (create).
- Live rows: `deliveries` 41,882, counted by
  `psql -c "select count(*) from deliveries"` on 2026-09-08.
- Personal data in scope: recipient phone number, delivery address line 1.
  Already present in `sms_outbox`.
- Reversible? The table and the scheduler can be reverted. Messages already
  sent cannot be unsent, and they cost money at C-007 rates.

## Scenarios already covering this area

- `SC-NOTIF-009 failed delivery sends one SMS`
  Status: pass 2026-08-30 (automated)
- `SC-NOTIF-011 outbox drains without duplicating on retry`
  Status: pass 2026-08-30 (automated)
- No scenario covers anything time-triggered, because nothing in the product
  is time-triggered yet.

## Gaps

Filled by the chair after the first pass, from `Evidence gap:` lines.

- Raised by Operator: what does the platform charge for a cron invocation at
  this frequency? -> `vercel cron` is included on the current plan up to 2
  jobs; this would be the first. Source: plan page, read 2026-09-08.
- Raised by Adversary: can a recipient be enumerated by the reminder?
  -> `grep -rn "signToken" lib` -> `lib/links/sign.ts:12`, HMAC with a
  per-delivery salt. The existing failed-delivery SMS already uses it.
