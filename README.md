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
| `docs/PLAN.md` | The product plan and later phases. |

The Xcode project uses synchronized folders: any file added under `Ploof/` is part of the app automatically.
