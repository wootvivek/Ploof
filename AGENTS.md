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
  a Contoso one: 144 threads, 42 commitments, about 90 senders (see "Mock data" below).
- **Done — Today reworked, one vocabulary (2026-11-10).** Today has three tiles named after the Mail
  chips: **Needs you · Waiting · Updates**. The first two merge commitments with waiting emails; Updates
  shows only the important ones. The words are fixed (commitment, overdue, due today, Done, Follow up,
  Updates, Notifications): see the concepts table in `docs/PRODUCT.md` before writing any UI text.
- **Next — M1, Foundation:** real Microsoft sign-in through a new Next Wave service, and the real
  Outlook.com inbox in the existing screens. Spec: `docs/tasks/M1-foundation.md`.
- **Waiting on the owner:** Entra app registration (client ID + secret), hosting choice for the
  service, Apple Developer account (needed later for push/TestFlight).

## Repo map
| Path | What |
|---|---|
| `NextWave.xcodeproj` | Xcode project. Uses **synchronized folders**: any file under `NextWave/` is compiled automatically. Do not add file references to `project.pbxproj`. |
| `NextWave/NextWaveApp.swift`, `NextWave/RootTabs.swift` | App entry (onboarding gate) and the tab bar (Today · Mail · Settings · Ask). |
| `NextWave/Models/Models.swift` | All model types (`Person`, `MailThread`, `Message`, `Commitment`, `TriageBucket`, `ComposeDraft`, …). |
| `NextWave/Store/NextWaveStore.swift` | `@Observable` app state + actions (complete, archive, send…). Today it holds mock data. |
| `NextWave/MockData/` | Synthetic Contoso mailbox: people, threads (one file per triage bucket), commitments, scripted Ask answers, `MockClock`. |
| `scripts/check-mock-data/` | Stand-alone check for the mock data (run it after editing `NextWave/MockData/`). |
| `NextWave/DesignSystem/` | Theme colors, glass components, avatar, the "puff" animation, background. |
| `NextWave/Features/<Screen>/` | One folder per screen: Today, Mail, Thread, Compose, Ask, Settings, Onboarding. |
| `docs/` | Product, design, architecture, roadmap, task specs. |
| `service/` | *(does not exist yet — created in M1)* the TypeScript Next Wave service. |

## Build, run, verify
```bash
# Build for the simulator (Xcode 26+; the owner uses Xcode 27.2)
xcodebuild -project NextWave.xcodeproj -scheme NextWave -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```
- Launch argument `-hasOnboarded YES` skips onboarding. Settings → "Replay onboarding" resets it.
- A change is not done until it builds with **zero new warnings** and you have run the affected
  flow in the simulator (light mode, dark mode, and the largest accessibility text size for layout changes).
- If you cannot run the simulator, say so explicitly in your summary/PR — do not claim it was verified.

## Mock data
The demo mailbox belongs to "Vivek", Director of Product for the Mark 8 at Contoso, in the weeks before launch.
- **Use only Microsoft's public fictitious companies and sample people** (Contoso, Fabrikam, Northwind Traders,
  Adventure Works, Woodgrove Bank, the Microsoft 365 sample users such as Megan Bowen and Patti Fernandez, …).
  No real people, customers or internal data. Automated senders may use Microsoft 365 product names
  (Teams, SharePoint, Viva, Planner, Power BI, Azure DevOps); other tools get generic "Contoso …" names.
- **Dates are relative.** Use `MockClock.wd(n)` / `md(n)` / `biz(n)` (business days from today) in message
  text and commitment due dates, so "by Thursday" in an email always matches the due label on its commitment.
- **Commitment evidence must be an exact quote** from a message in the commitment's thread, said by the person named.
- After editing, run the check (ids unique, evidence found verbatim, Ask citations exist):
  ```bash
  swiftc -o /tmp/check-mock-data NextWave/Models/Models.swift NextWave/MockData/*.swift scripts/check-mock-data/main.swift && /tmp/check-mock-data
  ```

## Rules (must follow)
**Product**
- Do not reintroduce **Focused / Other**. Triage buckets are Needs you · Waiting · Updates · Notifications.
- **Personal Microsoft accounts only.** No Microsoft 365 / work accounts, no Gmail, no IMAP (for now).
- **iOS only, native SwiftUI.** No Android, no cross-platform frameworks, no web views for UI.
- The AI is proposal-only: Next Wave never sends, deletes or moves mail without a user tap.

**Code**
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
