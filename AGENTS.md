# AGENTS.md — start here

You are working on **Ploof**, an AI-first iOS mail app for **personal Outlook.com accounts**
(Outlook.com, Hotmail, Live). It is a full replacement for Outlook for iOS that leads with AI:
promises ("I owe" / "Owed to me"), AI triage, summaries, drafts in your voice, and "Ask Ploof".

This file is the entry point for any coding agent (GitHub Copilot, OpenAI Codex/GPT, Claude, etc.).
Read it fully, then read the docs it points to before changing code.

## Read these, in order
1. `docs/PRODUCT.md` — what Ploof is, the decisions that are already made, and non-goals.
2. `docs/DESIGN.md` — the UX and design system. The UX was iterated with the owner; preserve it.
3. `docs/ARCHITECTURE.md` — iOS app, Ploof service (middle tier), Microsoft Graph, AI pipeline.
4. `docs/ROADMAP.md` — milestones, what is done, what is next.
5. `docs/tasks/` — the detailed spec for the task you have been given (start with the lowest-numbered open one).
6. `docs/SETUP-ENTRA.md` — the one-time Microsoft app registration (done by the owner, not by you).

## Current status (keep this section up to date)
- **Done — M0, UX prototype (tag `v0.1-ux`).** SwiftUI + Liquid Glass app running on fake data in
  `Ploof/MockData/`. No sign-in, no network, no AI. All screens work in the simulator.
- **Next — M1, Foundation:** real Microsoft sign-in through a new Ploof service, and the real
  Outlook.com inbox in the existing screens. Spec: `docs/tasks/M1-foundation.md`.
- **Waiting on the owner:** Entra app registration (client ID + secret), hosting choice for the
  service, Apple Developer account (needed later for push/TestFlight).

## Repo map
| Path | What |
|---|---|
| `Ploof.xcodeproj` | Xcode project. Uses **synchronized folders**: any file under `Ploof/` is compiled automatically. Do not add file references to `project.pbxproj`. |
| `Ploof/PloofApp.swift`, `Ploof/RootTabs.swift` | App entry (onboarding gate) and the tab bar (Today · Mail · Settings · Ask). |
| `Ploof/Models/Models.swift` | All model types (`Person`, `MailThread`, `Message`, `Promise`, `TriageBucket`, `ComposeDraft`, …). |
| `Ploof/Store/PloofStore.swift` | `@Observable` app state + actions (settle, archive, send…). Today it holds mock data. |
| `Ploof/MockData/` | Fake mailbox, promises and scripted Ask answers. |
| `Ploof/DesignSystem/` | Theme colors, glass components, avatar, the "ploof" animation, background. |
| `Ploof/Features/<Screen>/` | One folder per screen: Today, Mail, Thread, Compose, Ask, Settings, Onboarding. |
| `docs/` | Product, design, architecture, roadmap, task specs. |
| `service/` | *(does not exist yet — created in M1)* the TypeScript Ploof service. |

## Build, run, verify
```bash
# Build for the simulator (Xcode 26+; the owner uses Xcode 27.2)
xcodebuild -project Ploof.xcodeproj -scheme Ploof -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```
- Launch argument `-hasOnboarded YES` skips onboarding. Settings → "Replay onboarding" resets it.
- A change is not done until it builds with **zero new warnings** and you have run the affected
  flow in the simulator (light mode, dark mode, and the largest accessibility text size for layout changes).
- If you cannot run the simulator, say so explicitly in your summary/PR — do not claim it was verified.

## Rules (must follow)
**Product**
- Do not reintroduce **Focused / Other**. Triage buckets are Needs you · Waiting · FYI · Updates.
- **Personal Microsoft accounts only.** No Microsoft 365 / work accounts, no Gmail, no IMAP (for now).
- **iOS only, native SwiftUI.** No Android, no cross-platform frameworks, no web views for UI.
- The AI is proposal-only: Ploof never sends, deletes or moves mail without a user tap.

**Code**
- Swift 6, SwiftUI, deployment target **iOS 26**. The project sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`;
  plain data types are declared `nonisolated struct/enum … : Sendable` (see `Models.swift`). Follow that.
- **No third-party iOS dependencies** without the owner's approval. Use Apple frameworks.
- Reuse `Ploof/DesignSystem/` components; don't restyle existing screens. New screens follow the
  patterns in `docs/DESIGN.md` (e.g. pushed lists use title + one-line subtitle + glass cards + back button).
- Keep mock data working: the prototype must still run fully offline with mock data (see M1 spec).
- Use only **public Microsoft Graph APIs**. Never use Microsoft-internal code, docs or knowledge.
- AI provider is **Anthropic Claude**, called **only from the Ploof service**, never from the iOS app.
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
