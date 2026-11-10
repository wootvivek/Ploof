# Outlook Next Wave — roadmap

Each milestone ends with something the owner can try on a phone. Detailed specs live in `docs/tasks/`.
Update the status column when a milestone's "done when" is met and verified.

| # | Milestone | Status | Done when |
|---|---|---|---|
| M0 | **UX prototype** | ✅ Done (`v0.1-ux`) | All screens clickable on mock data; owner approved the UX. |
| M1 | **Foundation: sign-in + real inbox** | ⏭ Next — `docs/tasks/M1-foundation.md` | Owner signs in with a personal Microsoft account in the simulator and reads, replies to, archives and flags real mail in the existing screens. Mock mode still works. |
| M2 | **Intake + AI triage** | Planned | Service receives new mail in real time (webhooks + delta sync); every thread gets a bucket, one-liner and "where this stands" from Claude; triage eval set exists and meets the agreed accuracy; app shows real buckets. |
| M3 | **Commitments** | Planned | Commitment extraction + completion detection with verbatim-evidence check; Today (brief, Needs you, Waiting, Updates) runs on real data; commitment eval set meets the agreed precision; feedback (not a commitment, snooze, bucket changes) is stored. |
| M4 | **Act: full mail parity + voice** | Planned | Compose/reply/forward with attachments, drafts, folders, search, multiple accounts, signatures; "rewrite in my voice" and suggested replies from the model. Parity with Outlook for iOS mail basics. |
| M5 | **Ask + notify** | Planned | Ask Outlook agent with citations; push relay + APNs for Needs you; morning brief; follow-ups drafted by the model. |
| M6 | **Delight + ship** | Planned | Polish, widgets, privacy policy, hosting in production, TestFlight, distribution (internal first; a public name is undecided, "Outlook Next Wave" is internal only). |
| Later | Calendar, contacts, Apple Watch, iPad | — | — |

## Owner-only tasks (agents can't do these)
| Task | Needed by | Status |
|---|---|---|
| Register the app in Microsoft Entra, "Personal Microsoft accounts only" (`docs/SETUP-ENTRA.md`) | M1 | ⏳ In progress |
| Put `MS_CLIENT_ID` / `MS_CLIENT_SECRET` into `service/.env` (never in git) | M1 | ⏳ |
| Choose hosting for the service (Azure, Fly.io, Render, …) | M2 (webhooks need a public HTTPS URL) | Open |
| Anthropic API key in `service/.env` | M2 | Open |
| Paid Apple Developer account (push, TestFlight) | M5 | Open |
| Confirm the ground rules for an internal proof of concept: where the repo and service may live (the repo is personal and private today), which accounts may sign in, and which AI provider may see mail | Before real mail flows through the service | Open |
| Pick and clear a public name, if it ever ships outside the company ("Ploof" was the earlier pick) | M6 | Open |

## How to work through a milestone
- Each milestone spec is split into **numbered sub-tasks** sized for one branch + one PR each.
- Do them in order unless the spec says they're independent.
- A sub-task is done only when its acceptance criteria pass and the PR description says how you verified them.
