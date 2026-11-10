# Outlook Next Wave

An internal proof of concept for an AI-first Outlook on iOS (first prototyped under the name Ploof). It leads with what matters:
**commitments** (yours and other people's), **AI triage** (Needs you · Waiting · Updates · Notifications),
summaries, drafts in your voice, and **Ask Outlook**.

This is the **UX prototype**: SwiftUI + Liquid Glass on a synthetic Contoso mailbox (144 threads, 42 commitments),
built from Microsoft's public fictitious companies and sample users. No sign-in, no network, no AI calls.

## Run it
Open `NextWave.xcodeproj` in Xcode 26+ and run on an iPhone simulator (iOS 26+), or:

```bash
xcodebuild -project NextWave.xcodeproj -scheme NextWave -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
```

Tip: launch with the argument `-hasOnboarded YES` to skip onboarding. Settings → "Replay onboarding" brings it back.

## Where things live
| Path | What |
|---|---|
| `NextWave/MockData/` | The synthetic mailbox, commitments and Ask answers. Edit freely, then run the check in `AGENTS.md`. |
| `NextWave/DesignSystem/` | Colors (`Theme.swift`), glass components, the puff animation, background. |
| `NextWave/Features/` | One folder per screen: Today, Mail, Thread, Compose, Ask, Settings, Onboarding. |
| `NextWave/Store/NextWaveStore.swift` | In-memory app state (throwaway; replaced by Graph + the Next Wave service later). |
| `docs/` | Product, design, architecture, roadmap and task specs (see below). |

The Xcode project uses synchronized folders: any file added under `NextWave/` is part of the app automatically.

## For coding agents
Start with [`AGENTS.md`](AGENTS.md) (GitHub Copilot also reads [`.github/copilot-instructions.md`](.github/copilot-instructions.md)).

| Doc | What it covers |
|---|---|
| [`docs/PRODUCT.md`](docs/PRODUCT.md) | Vision, concepts, screens, principles, non-goals, decisions log |
| [`docs/DESIGN.md`](docs/DESIGN.md) | Design system, components, interaction patterns, copy, accessibility |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | iOS app, Next Wave service, sign-in flow, AI pipeline, security |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Milestones M0–M6 and owner-only tasks |
| [`docs/tasks/M1-foundation.md`](docs/tasks/M1-foundation.md) | The next milestone, split into PR-sized sub-tasks |
| [`docs/SETUP-ENTRA.md`](docs/SETUP-ENTRA.md) | Microsoft app registration (owner task) |
