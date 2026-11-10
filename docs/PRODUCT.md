# Ploof — product

## One line
An AI-first iPhone mail app for personal Outlook.com accounts that shows you **what you owe, what
you're owed, and what needs you** — instead of a pile of unread messages.

## Why it exists
The owner works on Outlook and is building Ploof to prove a far better Outlook for iOS is possible:
lightweight, beautiful (full Liquid Glass), and organized around obligations rather than messages.
"Inbox clean" means **you owe nothing**, not "zero unread".

## Who it's for
People with a personal Microsoft mailbox (Outlook.com, Hotmail, Live) who use their iPhone as their
main mail client and lose track of who's waiting on what.

## Core concepts
| Concept | Meaning |
|---|---|
| **Promise** | A commitment found in an email. Has a direction (*I owe* / *Owed to me*), a person, a one-line title, an optional due date, and the **exact quote** it came from. |
| **Settle** | Marking a promise done (swipe right, or automatically when a reply fulfills it). Plays the signature *ploof* animation. |
| **Nudge** | An AI-drafted polite follow-up for something owed to you that's late. Never sent without a tap. |
| **Triage bucket** | Every thread is in exactly one: **Needs you** (ball in your court) · **Waiting** (ball in theirs) · **FYI** (human, no action) · **Updates** (automated: newsletters, receipts, notifications). Replaces Focused/Other. |
| **One-liner** | AI gist shown in the mail list instead of the raw preview text. |
| **Where this stands** | AI summary at the top of a thread: state, deadlines, who's waiting. |
| **Ask Ploof** | Natural-language questions over your mail and promises, answered with source citations. |
| **Brief** | The card at the top of Today: greeting, three tappable counts (You owe · Late on you · Need you), and the single most important next step. |

## Screens (as built in the prototype)
- **Today** (home tab, ✨ icon): brief card → Needs you (top 3) → Promises board (I owe / Owed to me).
  The three brief tiles each push a filtered screen: *You owe* (due today/overdue), *Late on you*
  (overdue owed-to-me, each with a Nudge button), *Need you* (Needs you threads).
- **Mail**: triage chips, AI one-liners, swipe actions (archive, delete, flag, read/unread), folders sheet, compose button.
- **Thread**: subject, bucket badge, "Where this stands", promise chips with settle, messages, suggested replies, Reply/Forward.
- **Compose**: To, Subject, body, "Rewrite in my voice", "This settles: …" toggle when replying to something you owe.
- **Ask** (search-role tab): suggested questions, streamed answer, source chips, related emails.
- **Settings**: account, AI toggles, notification prefs, privacy, replay onboarding.
- **Onboarding**: 3 panels → "Sign in with Microsoft".

## Product principles
1. **AI first, mail client always.** AI views are the front door, but every normal mail action works and nothing is hidden.
2. **The AI proposes, you decide.** No automatic sending, deleting or moving.
3. **Show the evidence.** Every promise shows the words it came from; every Ask answer cites emails.
4. **Lightweight.** Fast cold start, small app, native everything.
5. **Private by default.** The service keeps what it derives (promises, buckets, summaries), not your mail.

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
| 2026-11-05 | AI runs in a middle-tier **Ploof service**, not on the device. | Process mail as it arrives (even when the phone sleeps), smart push, one place for AI logic. |
| 2026-11-05 | AI provider: **Anthropic Claude** (fast model for triage, stronger model for promises/drafts/Ask). | Owner's choice. |
| 2026-11-05 | UX prototype first, on mock data, before any backend. | Owner wanted to lock UX first. Tagged `v0.1-ux`. |
| 2026-11-05 | Brief tiles each push their own screen with a back button; all three must look consistent. | Owner feedback. |
| 2026-11-05 | Today tab icon is `sparkles` (not `sun.max`, which read as a light/dark toggle). | Owner feedback. |
