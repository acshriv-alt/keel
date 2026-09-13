---
name: keel-session
description: Open or close a Keel session. "open" reads KEEL.md, STATE.md and the in-flight feature and summarises in ten lines. "close" rewrites STATE.md, files unfinished findings into BACKLOG.md, and lists decisions made this session that are not yet recorded. Use at the start and end of work, or /keel-session open|close.
---
open: read KEEL.md, keel/STATE.md, and every file in the in-flight F- folder. Report in at most ten lines: where we are, what is next, what is blocked, which Gate the feature is at. Ask nothing unless STATE.md is stale by more than seven days.
close: scan the conversation for choices made and not recorded; run /keel-decide for each or list them for the user. Move any bug or gap found but not fixed into keel/BACKLOG.md with an ID, date and source. Rewrite keel/STATE.md completely. Do not commit unless asked.
