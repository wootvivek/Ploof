# Ploof: plan (v3, UX prototype first)

## Context
Vivek works on Outlook at Microsoft and wants to show he can build an iOS mail app that's far better than Outlook for iOS. **Ploof** is a native, AI-first, full replacement for Outlook on iPhone, for **personal Microsoft accounts only**. It leads with AI: promises (**I owe** / **Owed to me**), AI triage instead of Focused/Other, summaries, drafts in your voice, and Ask Ploof. The AI runs on a Ploof service tier between the app and Microsoft Graph.

**Vivek wants to nail the UX first.** So step one is a **clickable SwiftUI prototype with realistic fake data**: no Microsoft sign-in, no service, no AI calls. It runs in the iOS simulator and on his iPhone, so we can iterate quickly on look, feel and flow before building the real system behind it.

Current state: the Ploof folder (iCloud Drive) is empty and isn't a git repo. Xcode 27.2, the iOS 27.2 simulator and iPhone 18 Pro / 17 / Air simulators are installed. XcodeGen and Tuist are not installed.

---

## Phase 1: UX prototype (this is what we build now)

### Goal
Something Vivek can tap through on an iPhone and say "this already feels better than Outlook," and that we can rework fast as he gives UX direction.

### Scope: screens and interactions
| Screen | In the prototype |
|---|---|
| **Today** (home tab) | Daily brief card ("You owe 3 things today · 2 people are late on you · 4 emails need you"), then **Needs you**, then the **Promises** board with an *I owe* / *Owed to me* segmented control. Cards show the person's avatar, the promise, the due date, and an evidence quote. **Swipe right to settle**: the card shrinks into a puff with the *ploof* animation and a haptic. Swipe left: snooze or "not a promise." Overdue items glow and float to the top. |
| **Mail** | Triage chips in a glass row: **Needs you · Waiting · FYI · Updates · All**. Threads show a sender avatar, subject, an **AI one-liner** in place of the raw preview, and badges for promises. Swipe actions: archive, delete, flag, snooze. Folders drawer. |
| **Thread** | A glass **"Where this stands"** summary card at the top, promise chips, the messages, and **suggested replies** as glass pills above the reply bar. |
| **Compose** | Sheet with to/subject/body, a **"Rewrite in my voice"** button (swaps in canned text with a shimmer), and a "This settles: *send the deck*" chip that settles the promise on send. |
| **Ask** (search-role tab) | One input. Questions return a **canned answer streamed word by word** with citation chips that open the source thread. Keywords show classic results. Suggested questions as chips. |
| **Settings** | Placeholder rows only (accounts, notifications, voice, privacy), so the app feels complete. |
| **Onboarding** | 3 glass panels explaining Ploof, then a fake "Sign in with Microsoft" button that just enters the app. |

**Fake but believable data:** about 30 threads across all triage buckets, about 10 promises in both directions (some overdue), people with avatars, summaries, suggested replies and 5 scripted Ask answers. All of it lives in Swift files, so it's easy to edit.

**Design system:**
- Liquid Glass throughout: the system `TabView` with a search-role tab, `.glassEffect` on cards, chips and floating buttons, `GlassEffectContainer` so chips morph into each other, glass toolbars.
- The **ploof** moment: a particle/scale animation plus a haptic, with an optional soft sound (system sound for now, custom later).
- A small set of colors and fonts in one place (accent color, card styles, avatar colors), so the overall look can be retuned in one file.
- Light and dark mode and Dynamic Type supported from day one.

**Out of scope for the prototype:** Microsoft sign-in, Graph, the service, real AI, notifications, persistence beyond the running app.

### Project setup
- **iOS app, SwiftUI, Swift 6, deployment target iOS 26** (when Liquid Glass arrived). Bundle ID placeholder `com.vivek.ploof` (changeable).
- No XcodeGen, so I'll write a **minimal Xcode project by hand using Xcode's synchronized folders** (supported since Xcode 16). Any Swift file dropped into the `Ploof/` folder is part of the app automatically, which keeps the project file tiny and stops parallel agents from colliding later.
- Files:
```
Ploof/                          (this folder)
  Ploof.xcodeproj/
  Ploof/
    PloofApp.swift              app entry, onboarding gate
    RootTabs.swift              Today · Mail · Ask (search role) · Settings
    DesignSystem/               Theme.swift, GlassCard.swift, Chip.swift, Avatar.swift, PloofEffect.swift
    Models/                     Thread, Message, Person, Promise, TriageBucket, Brief
    MockData/                   MockPeople.swift, MockThreads.swift, MockPromises.swift, MockAsk.swift
    Features/
      Today/                    TodayView, BriefCard, PromiseBoard, PromiseCard
      Mail/                     MailListView, TriageChips, ThreadRow, FoldersDrawer
      Thread/                   ThreadView, StandsSummaryCard, SuggestedReplies
      Compose/                  ComposeSheet
      Ask/                      AskView, StreamingAnswer, CitationChip
      Settings/                 SettingsView
      Onboarding/               OnboardingView
    Assets.xcassets             app icon placeholder, accent color
  docs/
    PLAN.md                     this outline (later phases), for reference
```
- State: one `@Observable` mock store injected through the SwiftUI environment, so settling, snoozing and archiving change the screens live.

### Verification
- Build with `xcodebuild` for the **iPhone 18 Pro** simulator; zero warnings in the prototype code.
- Open the live simulator panel for Vivek, launch the app, and go through each flow myself: onboarding → Today → settle a promise (watch the ploof) → Mail chips → open a thread → suggested reply → compose → Ask question with citations. Screenshots of each screen in light and dark mode.
- Check Dynamic Type at the largest accessibility size on Today and Mail.
- Optional: install on Vivek's iPhone through Xcode (needs his Apple ID signed into Xcode).

### How we iterate
Vivek gives UX notes; I change the views or mock data and relaunch in the simulator, a few minutes per round. Once the UX is locked, the prototype screens become the real app's screens, with real data plugged in underneath.

---

## Later phases (unchanged direction, sequenced after the UX is locked)
1. **Foundation:** Ploof service (proposed: TypeScript, Postgres, job queue, Anthropic SDK) with Microsoft sign-in for personal accounts, encrypted token vault, Graph webhooks and delta sync. iOS app switches from mock data to Graph plus the service.
2. **Intake + AI triage:** fast-model (Claude Haiku 5.5) first pass with bucket and one-liner; test set measuring accuracy.
3. **Promises:** stronger-model (Claude Sonnet 5.5) extraction and settle detection; precision measured with a test set.
4. **Act:** full mail-client parity (compose, reply, forward, drafts, attachments, move, flag, multiple accounts) and drafts in your voice.
5. **Ask + notify:** Ask Ploof agent, smart push for "Needs you," daily brief, nudges.
6. **Delight + ship:** polish, widgets, privacy policy, TestFlight, App Store ("Ploof Mail").
7. **Agent team in Slack:** `#ploof-lead`, `#ploof-service`, `#ploof-ai`, `#ploof-ios`, `#ploof-qa`, each agent in its own git worktree.

## Risks and notes
- **iCloud Drive:** fine for the solo prototype, but git and agent worktrees in iCloud can corrupt or duplicate files. Recommend moving to `~/Code/Ploof` before git and the agent team come in.
- **Microsoft employment:** check the side-project and invention-ownership rules. Public Graph APIs only; no internal code, docs or roadmap knowledge.
- **Prototype code quality:** written cleanly enough to keep the views, but the mock store is throwaway.
