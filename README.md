# Ploof

An AI-first iOS mail app for personal Outlook.com accounts. It leads with what matters:
**promises** (I owe / Owed to me), **AI triage** (Needs you · Waiting · FYI · Updates),
summaries, drafts in your voice, and **Ask Ploof**.

This is the **UX prototype**: SwiftUI + Liquid Glass with fake data. No sign-in, no network, no AI calls.

## Run it
Open `Ploof.xcodeproj` in Xcode 26+ and run on an iPhone simulator (iOS 26+), or:

```bash
xcodebuild -project Ploof.xcodeproj -scheme Ploof -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```

Tip: launch with the argument `-hasOnboarded YES` to skip onboarding. Settings → "Replay onboarding" brings it back.

## Where things live
| Path | What |
|---|---|
| `Ploof/MockData/` | The fake mailbox, promises and Ask answers. Edit freely. |
| `Ploof/DesignSystem/` | Colors (`Theme.swift`), glass components, the ploof animation, background. |
| `Ploof/Features/` | One folder per screen: Today, Mail, Thread, Compose, Ask, Settings, Onboarding. |
| `Ploof/Store/PloofStore.swift` | In-memory app state (throwaway; replaced by Graph + the Ploof service later). |
| `docs/` | Product, design, architecture, roadmap and task specs (see below). |

The Xcode project uses synchronized folders: any file added under `Ploof/` is part of the app automatically.

## For coding agents
Start with [`AGENTS.md`](AGENTS.md) (GitHub Copilot also reads [`.github/copilot-instructions.md`](.github/copilot-instructions.md)).

| Doc | What it covers |
|---|---|
| [`docs/PRODUCT.md`](docs/PRODUCT.md) | Vision, concepts, screens, principles, non-goals, decisions log |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Design system, components, interaction patterns, copy, accessibility |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | iOS app, Ploof service, sign-in flow, AI pipeline, security |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Milestones M0–M6 and owner-only tasks |
| [`docs/tasks/M1-foundation.md`](docs/tasks/M1-foundation.md) | The next milestone, split into PR-sized sub-tasks |
| [`docs/SETUP-ENTRA.md`](docs/SETUP-ENTRA.md) | Microsoft app registration (owner task) |
