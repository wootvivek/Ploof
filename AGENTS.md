# AGENTS.md — start here

You are working on **Outlook Next Wave**, an internal proof of concept for an
AI-first Outlook on iOS. It is a full replacement for Outlook for iOS that leads with AI:
commitments (yours and other people's), AI triage, summaries, drafts in your voice, and "Ask Outlook".
Real sign-in (M1) targets **personal Outlook.com accounts** (Outlook.com, Hotmail, Live); the demo
runs on a synthetic enterprise mailbox.

**Naming.** The product is "Outlook Next Wave" everywhere a person can see it: on screen, in docs, in
commit messages about the product. The home-screen label is "Next Wave". In UI copy the assistant is
"Outlook" ("Ask Outlook", "Outlook has a follow-up ready"). In code the name is `NextWave`: the `NextWave/`
folder, `NextWave.xcodeproj`, scheme `NextWave`, bundle ID `com.vivek.nextwave`, types like `NextWaveStore`.
Marking a commitment done plays the `.puff()` animation. The app was first prototyped as "Ploof"; that name now survives only in
the GitHub repo name, the owner's local folder, the `v0.1-ux` tag's history and `docs/archive/`. Don't
reintroduce it in code, docs or UI text.

This file is the entry point for any coding agent (GitHub Copilot, OpenAI Codex/GPT, Claude, etc.).
Read it fully, then read the docs it points to before changing code.

## Read these, in order
1. `docs/PRODUCT.md` — what Next Wave is, the decisions that are already made, and non-goals.
2. `docs/DESIGN.md` — the UX and design system. The UX was iterated with the owner; preserve it.
3. `docs/ARCHITECTURE.md` — iOS app, Next Wave service (middle tier), Microsoft Graph, AI pipeline.
4. `docs/ROADMAP.md` — milestones, what is done, what is next.
5. `docs/tasks/` — the detailed spec for the task you have been given (start with the lowest-numbered open one).
6. `docs/SETUP-ENTRA.md` — the one-time Microsoft app registration (done by the owner, not by you).

## Current status (keep this section up to date)
- **Done — M0, UX prototype (tag `v0.1-ux`).** SwiftUI + Liquid Glass app running on fake data in
  `NextWave/MockData/`. No sign-in, no network, no AI. All screens work in the simulator.
- **Done — renamed to Outlook Next Wave, enterprise demo data (2026-11-10).** The mock mailbox is now
  a large synthetic one: 144 threads, 42 commitments, about 90 senders (see "Mock data" below).
- **Done — mailbox re-themed (2026-11-12).** It is now a fictional Outlook Mobile team at Microsoft shipping
  a fictional release, "Sandpiper", for internal demos. Same structure, ids and timing as before.
- **Done — Today reworked, one vocabulary (2026-11-10).** Today has three tiles named after the Mail
  chips: **Needs you · Waiting · Updates**. The first two merge commitments with waiting emails; Updates
  shows only the important ones. The words are fixed (commitment, overdue, due today, Done, Follow up,
  Updates, Notifications): see the concepts table in `docs/PRODUCT.md` before writing any UI text.
- **Done — time on Today (2026-11-10).** Estimates on your commitments, a mock calendar, **At risk**,
  **Hold time**, **Propose new date**, and a **Calendar tab** that draws booked, held and planned time.
  A commitment is a chain of steps around its due date or the meeting it is for. Every card on Today
  ends in one next action (send the drafted reply, hold time, propose a new date, follow up). The rule is in
  `docs/ARCHITECTURE.md` ("Time and fit").
- **Done — demo mode (2026-11-12).** A synthetic middle tier (`DemoService`) and a `SyncEngine`: Settings →
  Demo → Reset restarts the mailbox and delivers mail, commitments and calendar changes over ten minutes.
  One app clock (`AppClock`); the planner counts time from now.
- **Next — M1, Foundation:** real Microsoft sign-in through a new Next Wave service, and the real
  Outlook.com inbox in the existing screens. Spec: `docs/tasks/M1-foundation.md`.
- **Waiting on the owner:** Entra app registration (client ID + secret), hosting choice for the
  service, Apple Developer account (needed later for push/TestFlight).

## Repo map
| Path | What |
|---|---|
| `NextWave.xcodeproj` | Xcode project. Uses **synchronized folders**: any file under `NextWave/` is compiled automatically. Do not add file references to `project.pbxproj`. |
| `NextWave/NextWaveApp.swift`, `NextWave/RootTabs.swift` | App entry (onboarding gate) and the tab bar (Today · Mail · Calendar · Settings · Ask). |
| `NextWave/Models/Models.swift` | All model types (`Person`, `MailThread`, `Message`, `Commitment`, `TriageBucket`, `ComposeDraft`, …). |
| `NextWave/Models/WeekPlanner.swift` | Time types (`Effort`, `CalendarEvent`, `Hold`, `DayLoad`, `Fit`, `Step`, `PlannedBlock`) and the planner that places steps and decides what is at risk. Pure functions. |
| `NextWave/Models/AppClock.swift` | The one source of "now". Never read `Date.now` directly. |
| `NextWave/Models/Service.swift` | The contract with the middle tier: `MailboxSnapshot`, `ServiceEvent`, `Annotation`, and the pure `apply`. |
| `NextWave/Service/` | `MailService` protocol, `DemoService` (plays the script) and `SyncEngine` (applies events to the store, handles Reset). |
| `NextWave/Store/NextWaveStore.swift` | `@Observable` app state + actions (complete, archive, send…). Filled from mock data at launch, or from the service after a demo reset. |
| `NextWave/MockData/` | Synthetic mailbox of a fictional Outlook Mobile team: people, threads (one file per triage bucket), commitments, scripted Ask answers, `MockCalendar`, `MockClock`, and `DemoScenario` (the ten-minute demo script). |
| `scripts/check-mock-data/` | Stand-alone check for the mock data (run it after editing `NextWave/MockData/`). |
| `NextWave/DesignSystem/` | Theme colors, glass components, avatar, the "puff" animation, background. |
| `NextWave/Features/<Screen>/` | One folder per screen: Today, Mail, Calendar, Thread, Compose, Ask, Settings, Onboarding. |
| `docs/` | Product, design, architecture, roadmap, task specs. |
| `service/` | *(does not exist yet — created in M1)* the TypeScript Next Wave service. |

## Build, run, verify
```bash
# Build for the simulator (Xcode 26+; the owner uses Xcode 27.2)
xcodebuild -project NextWave.xcodeproj -scheme NextWave -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```
- Launch argument `-hasOnboarded YES` skips onboarding. Settings → "Replay onboarding" resets it.
- `-demo YES` resets and starts the demo at launch; `-demoMinutes 1` sets its length; `-demoAtNine YES`
  starts the app's day at 9:00 AM. Without `-demo`, the app shows the full mailbox with nothing arriving.
- A change is not done until it builds with **zero new warnings** and you have run the affected
  flow in the simulator (light mode, dark mode, and the largest accessibility text size for layout changes).
- If you cannot run the simulator, say so explicitly in your summary/PR — do not claim it was verified.

## Mock data
The demo mailbox belongs to "Vivek", who leads product for **Sandpiper**, a fictional release of Outlook
Mobile, on a **fictional Outlook Mobile team at Microsoft**. It is built for internal demos, so it has to
be relatable without being real.
- **Everything is invented:** the team, the roles, the release, its code name, its dates and every number.
  Feature areas may echo what Microsoft has announced publicly for Outlook Mobile (voice catch-up, shared and
  delegate mailboxes, drag to reschedule, send availability, app protection, S/MIME). Do not add anything
  from internal sources: no real code names, org names, people, customers, metrics or plans.
- **People and companies come from Microsoft's public fictitious set** (the Microsoft 365 sample users such
  as Megan Bowen and Patti Fernandez; Contoso, Fabrikam, Northwind Traders, Adventure Works, Woodgrove Bank…),
  so nobody is mistaken for a real colleague or customer. Team members use `first.last@microsoft.com`; these
  are not real mailboxes and the prototype cannot send mail.
- **Automated senders** may use Microsoft 365 product names (Teams, SharePoint, Viva, Planner, Power BI,
  Azure DevOps); internal tools get generic names ("IT Service Desk", "Expenses", "eSign").
- **Dates are relative.** Use `MockClock.wd(n)` / `md(n)` / `biz(n)` (business days from today) in message
  text and commitment due dates, so "by Thursday" in an email always matches the due label on its commitment.
- **Commitment evidence must be an exact quote** from a message in the commitment's thread, said by the person named.
- **The demo script is cut from the mailbox, not written beside it.** `DemoScenario` holds threads and
  commitments back and delivers them later, so a new thread or commitment in the mock data is in the demo's
  starting mailbox unless you add it to the script. The check asserts the script ends with the whole mailbox
  delivered, starts with nothing at risk, peaks at two and ends with one (the FY27 budget).
- **One-tap replies are curated.** Give a thread a `quick:` reply only when the answer is short and
  predictable, only on Needs you mail, with a button label of 24 characters or fewer.
- **Steps add up.** When a commitment has `steps`, the ones before the deadline must total the low end of
  its estimate, and "after" steps come last. `anchorEventID` must name a meeting in `MockCalendar`.
- **Estimates need a basis.** Give a commitment an `effort` only with a reason for the range, and only on
  your own commitments. The mock calendar and estimates are tuned so exactly two commitments are at risk
  (the FY27 budget and the manager assessments); the check fails if that changes.
- After editing, run the check (ids unique, evidence found verbatim, Ask citations exist, time data consistent):
  ```bash
  swiftc -o /tmp/check-mock-data NextWave/Models/*.swift NextWave/MockData/*.swift scripts/check-mock-data/main.swift && /tmp/check-mock-data
  ```

## Rules (must follow)
**Product**
- Do not reintroduce **Focused / Other**. Triage buckets are Needs you · Waiting · Updates · Notifications.
- **Personal Microsoft accounts only.** No Microsoft 365 / work accounts, no Gmail, no IMAP (for now).
- **iOS only, native SwiftUI.** No Android, no cross-platform frameworks, no web views for UI.
- The AI is proposal-only: Next Wave never sends, deletes or moves mail without a user tap. A one-tap reply
  counts only because the card shows the exact words being sent and the confirmation offers Undo; keep both.

**Code**
- Read the time from `AppClock.now` (and `AppClock.isToday`), never `Date.now` or `Calendar.isDateInToday`.
- Swift 6, SwiftUI, deployment target **iOS 26**. The project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`;
  plain data types are declared `nonisolated struct/enum … : Sendable` (see `Models.swift`). Follow that.
- **No third-party iOS dependencies** without the owner's approval. Use Apple frameworks.
- Reuse `NextWave/DesignSystem/` components; don't restyle existing screens. New screens follow the
  patterns in `docs/DESIGN.md` (e.g. pushed lists use title + one-line subtitle + glass cards + back button).
- Keep mock data working: the prototype must still run fully offline with mock data (see M1 spec).
- Use only **public Microsoft Graph APIs**. Never use Microsoft-internal code, docs or knowledge.
- AI provider is **Anthropic Claude**, called **only from the Next Wave service**, never from the iOS app.
  Do not switch providers without the owner's approval.

**Secrets & privacy**
- Never commit secrets. `.env`, keys and certificates are in `.gitignore`; keep it that way.
  Provide `.env.example` files with placeholder values instead.
- Never log email bodies, subjects or tokens. Log IDs and counts.
- Never paste or request the owner's client secret or tokens in chat/PRs; they put them in `.env` themselves.

**Git**
- One task per branch (`m1/service-skeleton`, `m1/ios-graph-repo`, …), small focused commits,
  imperative commit messages ("Add Graph mail repository").
- Do not rewrite history on `main`; do not force-push; do not delete tags.
- Update `docs/` when you change behavior or make a decision (add it to the decisions log in `docs/PRODUCT.md`).

## When something is unclear
Ask the owner (Vivek) rather than guessing on product or UX questions. For technical choices inside a
task's scope, pick the simplest option that matches these docs and note it in your summary.
