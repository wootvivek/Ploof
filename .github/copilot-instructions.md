# Copilot instructions for Ploof

Read `AGENTS.md` at the repo root first — it is the source of truth for this project. Then read the
doc for your area in `docs/` (PRODUCT, DESIGN, ARCHITECTURE, ROADMAP, and the task spec in `docs/tasks/`).

Key rules (details in `AGENTS.md`):
- Ploof is an **iOS-only, native SwiftUI** mail app for **personal Outlook.com accounts only**, iOS 26+, Liquid Glass.
- Never reintroduce Focused/Other; triage buckets are Needs you · Waiting · FYI · Updates.
- Swift 6 with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; data types are `nonisolated` and `Sendable`.
- The Xcode project uses synchronized folders — add files under `Ploof/`, never edit `project.pbxproj` file lists.
- No third-party iOS dependencies. Reuse `Ploof/DesignSystem/` components; don't restyle existing screens.
- AI (Anthropic Claude) runs only in the Ploof service (`service/`, TypeScript), never in the app.
- Public Microsoft Graph APIs only. Never commit secrets; never log email content or tokens.
- Build must pass with zero new warnings:
  `xcodebuild -project Ploof.xcodeproj -scheme Ploof -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build`
