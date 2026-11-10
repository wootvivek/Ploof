# Ploof — design system and UX rules

The UX was iterated screen by screen with the owner and approved. **Preserve it.** When adding
something new, copy an existing pattern from this doc rather than inventing a new one.

## Look and feel
- **Liquid Glass everywhere it belongs** (iOS 26 APIs): the system tab bar and toolbars, `.glassEffect`
  on cards, chips and floating buttons, `.buttonStyle(.glass)` / `.glassProminent`, `GlassEffectContainer`
  for groups of chips so they merge and morph.
- **A soft mesh-gradient backdrop** (`PloofBackground`) behind AI screens so glass has something to refract.
  Use `PloofBackground(subtle: true)` behind reading-heavy screens (Thread).
- **Plain system background** for the Mail list (dense reading).
- **Scroll-edge effects:** bars that sit over scrolling content use `.safeAreaBar(edge:)` (e.g. triage chips,
  thread reply bar), not `.safeAreaInset`, so content blurs under them instead of clashing.
- **Light and dark mode** both supported; never hard-code white/black text on glass.
- **Dynamic Type** to the largest accessibility size; layouts must reflow (see `BriefCard`'s
  `tileLayout`, which stacks tiles at accessibility sizes).

## Tokens (`Ploof/DesignSystem/Theme.swift`)
| Token | Use |
|---|---|
| `AccentColor` (asset catalog) | Brand periwinkle; tint for icons, selected states, primary buttons. |
| `Theme.overdue` (#F0506E) | Overdue badges, overdue glow, Needs you. |
| `Theme.today` (#F59E0B) | Due today, Late on you, Nudge buttons. |
| `Theme.soon` (#6C6AF4) | Due in 1–2 days. |
| `Theme.settled` (#22C55E) | Settle actions and confirmations. |
| `TriageBucket.tint` | Needs you (rose), Waiting (amber), FYI (teal), Updates (gray). |
| `Theme.cardRadius` = 22 | Standard card corner radius. Brief card uses 28. |

## Components (`Ploof/DesignSystem/`)
| Component | File | Use |
|---|---|---|
| `PloofBackground` | `PloofBackground.swift` | Mesh gradient backdrop (light/dark variants, `subtle`). |
| `AvatarView` | `Avatar.swift` | Gradient circle with initials; color from `Person.hue`. |
| `.ploof(_:)` / `PuffBurst` | `PloofEffect.swift` | The signature settle animation (shrink + blur + puff particles). |
| `.plainRow(top:bottom:)` | `Components.swift` | Transparent, separator-free `List` row so glass cards float. |
| `NavRow` | `Components.swift` | Tap-to-push wrapper without the list chevron. |
| `SectionHeader` | `Components.swift` | Icon + title + optional trailing count, used inside lists. |
| `FilterChip` | `Components.swift` | Glass chip; prominent + tinted when selected. |
| `DueBadge`, `BucketBadge` | `Components.swift` | Capsule badges for due dates and triage buckets. |
| `GlassSegmented` | `Components.swift` | Glass capsule segmented control with sliding selection. |
| `ToastView` | `Components.swift` | Glass capsule toast with optional Undo; shown by `RootTabs`. |
| `Shimmer` | `Components.swift` | "AI is working" sweep over text. |
| `PressScaleStyle` | `Features/Today/BriefCard.swift` | Gentle squish for custom tappable cards. |
| `promiseSwipeActions` | `Features/Today/FocusedPromisesView.swift` | Settle (right) / Snooze + Not a promise (left). Reuse for any promise list. |

## Interaction patterns
- **Promises:** swipe right = settle (full swipe allowed) → `.ploof` animation, success haptic,
  optional sound, toast with Undo. Swipe left = Snooze / Not a promise. Overdue promises pulse a red border.
- **Mail rows:** swipe left = Delete (full swipe) / Archive; swipe right = Read/Unread, Flag.
- **Pushed filtered lists** (You owe, Late on you, Need you): large title + one-line secondary subtitle +
  glass cards on `PloofBackground` + standard back button. **All three must stay visually consistent.**
- **Replying** to a Needs you thread moves it to Waiting, clears suggested replies and updates its summary.
- **Every AI claim is traceable:** promise cards show the quote and who said it; Ask answers show source chips.
- **Haptics:** `.sensoryFeedback(.success, trigger: store.settleTick)` on settle. Don't add haptics elsewhere without reason.
- **Toasts** auto-dismiss after 3 s; destructive or AI actions offer Undo when possible.

## Copy style
- Short, warm, plain. Sentence case. No exclamation marks in UI chrome (fine in mock email content).
- Speak to the user as "you"; refer to the AI as "Ploof".
- Examples: "You owe nothing. Enjoy it." · "Got it. Ploof will learn from this." · "Swipe right to settle · left to snooze".

## Tab bar
Today (`sparkles`) · Mail (`tray`, badge = unread Needs you) · Settings (`gearshape`) · Ask (search role,
`sparkle.magnifyingglass`). Tab bar minimizes on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`).
Thread view hides the tab bar.

## Accessibility checklist for any UI change
- Works at the largest accessibility text size without truncating key info.
- Combined accessibility elements for cards, with a hint for swipe actions.
- Selected chips/segments expose `.isSelected`.
- Icon-only buttons have `accessibilityLabel`.
