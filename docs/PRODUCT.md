# Outlook Next Wave — product

## One line
An AI-first iPhone mail app for personal Outlook.com accounts that shows you **what you have committed to, what
you're owed, and what needs you** — instead of a pile of unread messages.

## Why it exists
The owner works on Outlook and is building Next Wave to prove a far better Outlook for iOS is possible:
lightweight, beautiful (full Liquid Glass), and organized around obligations rather than messages.
"Inbox clean" means **nothing needs you**, not "zero unread".

## Who it's for
People with a personal Microsoft mailbox (Outlook.com, Hotmail, Live) who use their iPhone as their
main mail client and lose track of who's waiting on what.

## Core concepts
| Concept | Meaning |
|---|---|
| **Commitment** | Something one person told another they would do, found in an email. It is either **yours** or **theirs**, and has a person, a one-line title, an optional due date, and the **exact quote** it came from. A request with a deadline counts even before you reply. |
| **Done** | Marking a commitment done (swipe right, or automatically when a reply fulfills it). Plays the signature *puff* animation. |
| **Follow-up** | An AI-drafted polite reminder for someone else's overdue commitment. The card shows its opening words; one tap sends it, with Undo. |
| **Triage bucket** | Every thread is in exactly one: **Needs you** (your move) · **Waiting** (their move) · **Updates** (written by a person, no action needed) · **Notifications** (automated: Teams, build results, receipts, newsletters). An update or notification can also be marked **important**. |
| **One-liner** | AI gist shown in the mail list instead of the raw preview text. |
| **Where this stands** | AI summary at the top of a thread: state, deadlines, who's waiting. |
| **Ask Outlook** | Natural-language questions over your mail and commitments, answered with source citations. |
| **Brief** | The card at the top of Today: greeting, three tiles (Needs you · Waiting · Updates) that switch the list below, the single most important next step, and the top update. |
| **Overdue / Due today** | The only two urgency words. Past its date is *overdue* on both sides; never "late". |
| **Estimate** | How long one of your commitments is expected to take: a range with its basis ("2–3 h, based on your last four board decks"). Left blank when there is no basis. Other people's commitments never get one. |
| **Booked / Held / Open** | The three states of working time. *Booked* is meetings. *Held* is time you set aside for a commitment; it is private and others see it as busy. *Open* is what is left. |
| **Planned** | Open time the planner would give to a commitment step. Shown pale with a dashed edge; becomes Held when you hold it. |
| **Steps** | The chain of work behind a commitment, in order: steps *before* (must finish by the due date, or by the start of the meeting the work is for), the meeting or due date itself, and steps *after* (cannot start until it has passed). |
| **At risk** | One of your commitments whose time does not exist before its due date, once commitments due earlier have theirs. Shown with the reason: what it needs and how much is open. |
| **Hold time** | Turn the open time planned for a commitment into held time. It protects time; it does not create any. |
| **Propose new date** | An AI-drafted note asking for a later date, giving the reason as a fact (time needed, time open). Sending it moves the due date. Never sent without a tap. |
| **Next action** | The one step each card on Today ends in, chosen in this order: **Propose new date** (at risk) → **send the drafted reply** (an approval, a confirmed time, a polite no; the card shows the exact words) → **Hold time** (work that fits) → **Reply** (opens a draft). Under Waiting, overdue items offer **Follow up**; under Updates, **Got it**. One tap does it, and anything sent can be undone from the confirmation. |

## Screens (as built in the prototype)
- **Today** (home tab, ✨ icon): brief card → one list. The brief's three tiles pick the list and carry
  the same names as the Mail chips:
  - **Needs you** and **Waiting**: commitments on that side merged with the emails in that bucket that
    have no commitment, so nothing is listed twice. Order: overdue, then soonest due, then undated,
    newest mail first. Overdue items under Waiting get a Follow up button.
  - **Updates**: only the *important* updates and notifications, unread first, with a link to all updates in Mail.
  Notifications as a whole appear only in Mail.
  Every card ends in its **next action** (see the concepts table); tapping the rest of the card opens the email.
  Your commitments show an estimate when there is one, and an **At risk** line with **Propose new date**
  when the time isn't there. A commitment with several steps says so ("2–3 h · 2 steps"). The brief has a week line ("13 h open, 12 h of commitments. 2 at risk.").
- **Calendar** (tab): the week at a glance as five columns (grey = booked, solid colour = held, pale
  colour = planned, blank = open), which doubles as the day picker; then one day hour by hour with
  meetings and the time for each commitment step; then the commitments at risk. Tapping a block opens
  the chain of steps for that commitment, with **Hold this time**, **Propose new date** and the email.
  The brief's week line on Today opens this tab.
- **Settings → Demo**: Reset demo, progress, Stop, length (10 / 3 / 1 minutes), and "Start the day at 9:00 AM".
- **Mail**: triage chips, AI one-liners, swipe actions (archive, delete, flag, read/unread), folders sheet, compose button.
- **Thread**: subject, bucket badge, "Where this stands", commitment chips with a Done button, messages, suggested replies, Reply/Forward.
- **Compose**: To, Subject, body, "Rewrite in my voice", "This completes: …" toggle when replying on one of your commitments.
- **Ask** (search-role tab): suggested questions, streamed answer, source chips, related emails.
- **Settings**: account, AI toggles, notification prefs, privacy, replay onboarding.
- **Onboarding**: 3 panels → "Sign in with Microsoft".

## Product principles
1. **AI first, mail client always.** AI views are the front door, but every normal mail action works and nothing is hidden.
2. **The AI proposes, you decide.** No automatic sending, deleting or moving.
3. **Show the evidence.** Every commitment shows the words it came from; every Ask answer cites emails.
4. **Lightweight.** Fast cold start, small app, native everything.
5. **Private by default.** The service keeps what it derives (commitments, buckets, summaries), not your mail.

## Non-goals (for now)
- Microsoft 365 / work or school accounts, Gmail, IMAP.
- Android, iPad-optimized layout, Mac app, web app.
- Calendar and contacts (later milestone).
- Focused / Other (permanently — replaced by triage).

## Decisions log
Add a row whenever a product or technical decision is made. Newest at the bottom.

| Date | Decision | Why |
|---|---|---|
| 2026-11-05 | Name: **Ploof** (App Store listing will need a suffix, e.g. "Ploof Mail" — plain "Ploof" is taken). | Owner's pick; US trademark search showed no live software mark. |
| 2026-11-05 | Personal Microsoft accounts only. | Avoids enterprise consent/MDM hurdles; owner's focus. |
| 2026-11-05 | iOS only, native SwiftUI, iOS 26 minimum, full Liquid Glass. | Lightweight, best-in-class UX. |
| 2026-11-05 | Full mail-client replacement, not read-only. | Must replace Outlook for iOS. |
| 2026-11-05 | Lead with AI; drop Focused/Other for AI triage buckets. | Owner dislikes Focused/Other. |
| 2026-11-05 | AI runs in a middle-tier **Next Wave service**, not on the device. | Process mail as it arrives (even when the phone sleeps), smart push, one place for AI logic. |
| 2026-11-05 | AI provider: **Anthropic Claude** (fast model for triage, stronger model for promises/drafts/Ask). | Owner's choice. |
| 2026-11-05 | UX prototype first, on mock data, before any backend. | Owner wanted to lock UX first. Tagged `v0.1-ux`. |
| 2026-11-05 | Brief tiles each push their own screen with a back button; all three must look consistent. *(Superseded 2026-11-10.)* | Owner feedback. |
| 2026-11-05 | Today tab icon is `sparkles` (not `sun.max`, which read as a light/dark toggle). | Owner feedback. |
| 2026-11-10 | Product name is **Outlook Next Wave**; the earlier name "Ploof" is retired. Code was renamed the same day: `NextWave/`, `NextWave.xcodeproj`, scheme `NextWave`, bundle ID `com.vivek.nextwave`, `NextWaveStore`, `.puff()`; only the GitHub repo and the owner's local folder still say Ploof. Home-screen label "Next Wave"; the assistant is called "Outlook" in UI copy. | Owner wants to use it internally as a proof of concept. |
| 2026-11-10 | Demo data is a large synthetic **enterprise** mailbox (Contoso, 144 threads, 41 promises) using only Microsoft's public fictitious companies and sample users. | A work-style inbox makes the case for an internal audience. |
| 2026-11-10 | **Open:** real-account scope is unchanged (personal Microsoft accounts only, M1). Whether an internal proof of concept should target work accounts, and which AI provider and hosting it may use, is the owner's call. | The rename changed the audience, not the plan. |
| 2026-11-10 | Today is split one way only: **On you** / **Waiting on others**. Promises and waiting emails are merged per side and never listed twice; the three count tiles, the Needs you section, the Promises board and the pushed filter screens are gone. | Owner found the tiles + Needs you + I owe / Owed to me to be too many overlapping concepts. |
| 2026-11-10 | A request with a deadline counts as a promise even when the user hasn't replied (e.g. "approve within the hour"). | Otherwise the most urgent email sorts below every dated promise. |
| 2026-11-10 | **One vocabulary for Today and Mail.** "Promise" → **commitment** (yours / theirs). Buckets: Needs you · Waiting · **Updates** (was FYI) · **Notifications** (was Updates). Urgency: **overdue**, **due today**. "Settle" → **Done**, "Nudge" → **Follow up**. Supersedes the "On you / Waiting on others" names from earlier the same day. | Owner: "promises" and "FYI" are too casual, and Today and Mail used different words for the same thing. |
| 2026-11-10 | Today has three tiles named after the first three Mail chips. The Updates tile lists only **important** updates and notifications (an AI judgement, `MailThread.isImportant`); the brief also shows the top one. | Owner wants the most important updates on Today, not only commitments. |
| 2026-11-10 | **Today knows about time.** Your commitments carry an estimate (a range with its basis, or nothing), a mock calendar gives Booked / Held / Open time, and a commitment with no room before its due date is **At risk**. Shown on the card, in one brief line, and on a pushed **Your week** screen. No new tab and no fourth tile. | Owner direction: the question is not only "what needs me?" but "do I have the time?", and you should find out days before the deadline. |
| 2026-11-10 | The two ways to act on time: **Hold time** (swipe left on a commitment that fits) and **Propose new date** (button on an at-risk commitment; also swipe left). On your own commitments these replace Snooze, which stays for other people's. | Snoozing your own commitment hides the problem; moving the date with the other person's agreement solves it. |
| 2026-11-10 | Estimates lean low and are omitted when there is no basis. Only the low end is used to decide what is at risk. | A confident wrong number costs more trust than a blank; better to say there is more room than there is. |
| 2026-11-10 | Prototype shortcut: the whole of today counts as available, whatever the time of day, so the demo is stable. The real service must plan from the current time. *(Superseded 2026-11-12: planning now starts from the current time.)* | Demo predictability. |
| 2026-11-10 | **A commitment is a chain of steps around a point in time.** Work before must finish by the due date or by the start of the meeting it is for; the meeting itself; then work after, which cannot start until the meeting is over. Steps are placed in order. A commitment with no steps is a chain of one. | Owner: you chain blocks of time before something is due, the thing happens (an exec review, say), and there may be work after. Without this the planner would put part of a summary after the meeting it was for. |
| 2026-11-10 | **Calendar is a tab** (Today · Mail · Calendar · Settings · Ask) and shows time, not only meetings: Booked, Held, **Planned** (what the planner would use, not yet held) and Open. It replaces the pushed "Your week" screen from earlier the same day. | Owner asked to see time on the calendar. Supersedes "no new tab" in the first version of the time feature. |
| 2026-11-10 | The chain is not given a product name in the UI. The calendar shows "step 1 of 2" and a sheet titled "Time for this"; code and docs say "steps". | The chain should explain a suggestion, not become a new thing to learn. |
| 2026-11-10 | **Every card on Today ends in one next action**, inside the card. A drafted reply is sent in one tap only when it is short and predictable, the exact text is shown on the card, and the confirmation offers Undo. Decisions that deserve thought get Hold time or Reply, not a one-tap answer. | Owner direction: each item should lead to what you can do about it, not to more reading. Keeps "nothing is sent without a tap": the tap is on the words being sent. |
| 2026-11-12 | **Demo mode with a synthetic middle tier.** Settings → Demo → Reset puts the mailbox back to a starting point and a scripted service delivers 32 events over ten minutes (or 3, or 1): new mail, replies, commitments found a few seconds after their mail, commitments delivered by other people, a meeting added and a meeting canceled. A "Live" badge shows on Today while it runs. | Owner wants to demo mail arriving and the app reacting, not a static mailbox. The fake service uses the same contract the real one will. |
| 2026-11-12 | **Everything is anchored to the moment of reset, and time already gone is not open.** One app clock; the planner counts from now; the Calendar shows a now line. An optional "Start the day at 9:00 AM" shifts the app clock so the demo tells the same story at any hour (default off: real time). | Owner: the calendar must stay accurate from the time of reset. A fixed 9:00 start makes rehearsed demos repeatable, at the cost of the app's time differing from the phone's. |
| 2026-11-12 | **Demo mailbox re-themed: a fictional Outlook Mobile team at Microsoft** shipping a fictional release ("Sandpiper"), with `@microsoft.com` addresses. Feature areas follow what is public about Outlook Mobile; the team, people, projects, dates and numbers are invented. Names stay from Microsoft's public fictitious set. Structure, ids and timing are unchanged, so the demo script and the at-risk tuning still hold. | Owner will demo to Microsoft executives and wants data they recognize. Using the public fictitious names avoids anyone being mistaken for a real colleague; nothing internal is used. |
