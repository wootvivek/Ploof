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
| **Follow-up** | An AI-drafted polite reminder for someone else's overdue commitment. Never sent without a tap. |
| **Triage bucket** | Every thread is in exactly one: **Needs you** (your move) · **Waiting** (their move) · **Updates** (written by a person, no action needed) · **Notifications** (automated: Teams, build results, receipts, newsletters). An update or notification can also be marked **important**. |
| **One-liner** | AI gist shown in the mail list instead of the raw preview text. |
| **Where this stands** | AI summary at the top of a thread: state, deadlines, who's waiting. |
| **Ask Outlook** | Natural-language questions over your mail and commitments, answered with source citations. |
| **Brief** | The card at the top of Today: greeting, three tiles (Needs you · Waiting · Updates) that switch the list below, the single most important next step, and the top update. |
| **Overdue / Due today** | The only two urgency words. Past its date is *overdue* on both sides; never "late". |

## Screens (as built in the prototype)
- **Today** (home tab, ✨ icon): brief card → one list. The brief's three tiles pick the list and carry
  the same names as the Mail chips:
  - **Needs you** and **Waiting**: commitments on that side merged with the emails in that bucket that
    have no commitment, so nothing is listed twice. Order: overdue, then soonest due, then undated,
    newest mail first. Overdue items under Waiting get a Follow up button.
  - **Updates**: only the *important* updates and notifications, unread first, with a link to all updates in Mail.
  Notifications as a whole appear only in Mail.
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
