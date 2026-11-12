# Copilot instructions for Outlook Next Wave

Read `AGENTS.md` at the repo root first — it is the source of truth for this project. Then read the
doc for your area in `docs/` (PRODUCT, DESIGN, ARCHITECTURE, ROADMAP, and the task spec in `docs/tasks/`).

Key rules (details in `AGENTS.md`):
- Outlook Next Wave is an **iOS-only, native SwiftUI** mail app, iOS 26+, Liquid Glass. Real sign-in targets **personal Outlook.com accounts only**; the demo data is a synthetic mailbox for a fictional Outlook Mobile team at Microsoft (everything in it is invented).
- UI text says "Outlook" / "Outlook Next Wave"; code uses `NextWave` (`NextWaveStore`, scheme `NextWave`). The old name "Ploof" is retired; don't reintroduce it.
- Never reintroduce Focused/Other; triage buckets are Needs you · Waiting · Updates · Notifications.
- Swift 6 with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; data types are `nonisolated` and `Sendable`.
- The Xcode project uses synchronized folders — add files under `NextWave/`, never edit `project.pbxproj` file lists.
- No third-party iOS dependencies. Reuse `NextWave/DesignSystem/` components; don't restyle existing screens.
- AI (Anthropic Claude) runs only in the Next Wave service (`service/`, TypeScript), never in the app.
- Public Microsoft Graph APIs only. Never commit secrets; never log email content or tokens.
- Build must pass with zero new warnings:
  `xcodebuild -project NextWave.xcodeproj -scheme NextWave -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build`
