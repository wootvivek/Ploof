# Outlook Next Wave — design system and UX rules

The UX was iterated screen by screen with the owner and approved. **Preserve it.** When adding
something new, copy an existing pattern from this doc rather than inventing a new one.

## Look and feel
- **Liquid Glass everywhere it belongs** (iOS 26 APIs): the system tab bar and toolbars, `.glassEffect`
  on cards, chips and floating buttons, `.buttonStyle(.glass)` / `.glassProminent`, `GlassEffectContainer`
  for groups of chips so they merge and morph.
- **A soft mesh-gradient backdrop** (`NextWaveBackground`) behind AI screens so glass has something to refract.
  Use `NextWaveBackground(subtle: true)` behind reading-heavy screens (Thread).
- **Plain system background** for the Mail list (dense reading).
- **Scroll-edge effects:** bars that sit over scrolling content use `.safeAreaBar(edge:)` (e.g. triage chips,
  thread reply bar), not `.safeAreaInset`, so content blurs under them instead of clashing.
- **Light and dark mode** both supported; never hard-code white/black text on glass.
- **Dynamic Type** to the largest accessibility size; layouts must reflow (see `BriefCard`'s
  `tileLayout`, which stacks tiles at accessibility sizes).

## Tokens (`NextWave/DesignSystem/Theme.swift`)
| Token | Use |
|---|---|
| `AccentColor` (asset catalog) | Brand periwinkle; tint for icons, selected states, primary buttons. |
| `Theme.overdue` (#F0506E) | Overdue badges, overdue glow, Needs you. |
| `Theme.today` (#F59E0B) | Due today, Follow up buttons. |
| `Theme.soon` (#6C6AF4) | Due in 1–2 days. |
| `Theme.done` (#22C55E) | Done actions and confirmations. |
| `TriageBucket.tint` | Needs you (rose), Waiting (amber), Updates (teal), Notifications (gray). Today's tiles use the same tints as the Mail chips. |
| `Theme.cardRadius` = 22 | Standard card corner radius. Brief card uses 28. |

## Components (`NextWave/DesignSystem/`)
| Component | File | Use |
|---|---|---|
| `NextWaveBackground` | `NextWaveBackground.swift` | Mesh gradient backdrop (light/dark variants, `subtle`). |
| `AvatarView` | `Avatar.swift` | Gradient circle with initials; color from `Person.hue`. |
| `.puff(_:)` / `PuffBurst` | `PuffEffect.swift` | The signature animation for marking a commitment done (shrink + blur + puff particles). |
| `.plainRow(top:bottom:)` | `Components.swift` | Transparent, separator-free `List` row so glass cards float. |
| `NavRow` | `Components.swift` | Tap-to-push wrapper without the list chevron. |
| `SectionHeader` | `Components.swift` | Icon + title + optional trailing count, used inside lists. |
| `FilterChip` | `Components.swift` | Glass chip; prominent + tinted when selected. |
| `DueBadge`, `BucketBadge` | `Components.swift` | Capsule badges for due dates and triage buckets. |
| `GlassSegmented` | `Components.swift` | Glass capsule segmented control with sliding selection. |
| `ToastView` | `Components.swift` | Glass capsule toast with optional Undo; shown by `RootTabs`. |
| `Shimmer` | `Components.swift` | "AI is working" sweep over text. |
| `PressScaleStyle` | `Features/Today/BriefCard.swift` | Gentle squish for custom tappable cards. |
| `commitmentSwipeActions` | `Features/Today/CommitmentCard.swift` | Done (right) / Snooze + Not a commitment (left). Reuse for any commitment list. |
| `MailCard` / `mailSwipeActions` | `Features/Today/CommitmentCard.swift` | Email with no commitment, in the same skeleton as `CommitmentCard` (time where the due badge would be). Archive (right) / Read-Unread (left). |
| `EffortBadge` / `AtRiskLine` | `Features/Today/CommitmentCard.swift` | The estimate under a commitment's title; the at-risk reason inside the card. |
| `CardAction` / `CardActionBar` | `Features/Today/CommitmentCard.swift` | The foot of a card: a one- or two-line preview of what will happen (for a reply, the exact words) and one prominent button. Used by `CommitmentCard` and `MailCard`. |
| `CalendarView` | `Features/Calendar/CalendarView.swift` | The Calendar tab: `WeekGrid` (five columns, also the day picker), `DayTimeline` (hour grid with `MeetingBlock` and `WorkBlock`), then At risk. |
| `ChainSheet` | `Features/Calendar/ChainSheet.swift` | "Time for this": a commitment's steps in order around its meeting or due date, each Held, Planned or short, with Hold this time / Propose new date / Open the email. |

## Interaction patterns
- **Commitments:** swipe right = done (full swipe allowed) → `.puff` animation, success haptic,
  optional sound, toast with Undo. Swipe left on your own = Hold time (when it fits) / New date / Not a commitment;
  on other people's = Snooze / Not a commitment. Overdue commitments pulse a red border.
- **Mail rows:** swipe left = Delete (full swipe) / Archive; swipe right = Read/Unread, Flag.
- **Today mirrors Mail:** three tiles, Needs you · Waiting · Updates, with the same names, symbols and tints
  as the Mail chips (`TriageBucket.todaySections`). The tiles are the switch for the one list below; the
  selected tile has a tinted fill and outline. Don't add a second selector or separate sections for emails
  and commitments: an item appears once. On Today, swipe right always means "handled".
- **Calendar colours:** booked is grey; each commitment gets its own colour, solid with a lock when held and
  pale with a dashed edge when only planned. A meeting that some commitment's work is for carries that
  commitment's colour as a bar and a diamond. Colour is never the only signal: every block also has an icon
  and the words Held or Planned.
- **Time:** an estimate is plain secondary text under the title, never a coloured badge. "At risk" uses the
  overdue colour and always states its reason (needs, basis, open time).
- **Arrivals:** new mail slides into the lists; only mail that needs you raises a toast and a tap on the
  wrist. Calendar changes always raise a toast. A small pulsing "Live" badge sits on Today's brief while the
  service is delivering. The Calendar's day view has a thin line in the overdue colour at the current time.
- **One action per card, inside the card.** The button is a real button with its own tap; the rest of the card
  opens the email. Show what the tap will do before it is tapped: the reply text in quotes, or the planned
  time for a hold. Button labels are two or three words ("Approve", "Hold time", "Follow up", "Got it").
  Anything that sends confirms with a toast that has Undo. Don't add a second button to a card; other
  choices live in the swipe actions and in the thread.
- **One vocabulary** (see the concepts table in `docs/PRODUCT.md`): commitment, yours / theirs, overdue,
  due today, at risk, Booked / Held / Open, Hold time, Propose new date, Done, Follow up, Updates, Notifications. Don't use promise, owe, late, settle, nudge or FYI in UI text.
- **Pushed lists** (when a screen needs one): large title + one-line secondary subtitle + glass cards on
  `NextWaveBackground` + standard back button.
- **Replying** to a Needs you thread moves it to Waiting, clears suggested replies and updates its summary.
- **Every AI claim is traceable:** commitment cards show the quote and who said it; Ask answers show source chips.
- **Haptics:** `.sensoryFeedback(.success, trigger: store.doneTick)` when a commitment is marked done. Don't add haptics elsewhere without reason.
- **Toasts** auto-dismiss after 3 s; destructive or AI actions offer Undo when possible.

## Copy style
- Short, warm, plain. Sentence case. No exclamation marks in UI chrome (fine in mock email content).
- Speak to the user as "you"; refer to the AI as "Outlook".
- Examples: "Nothing needs you. Enjoy it." · "Got it. Outlook will learn from this." · "Swipe right when it's done · left for more".

## Tab bar
Today (`sparkles`) · Mail (`tray`, badge = unread Needs you) · Calendar (`calendar`) · Settings (`gearshape`) · Ask (search role,
`sparkle.magnifyingglass`). Tab bar minimizes on scroll (`.tabBarMinimizeBehavior(.onScrollDown)`).
Thread view hides the tab bar.

## Accessibility checklist for any UI change
- Works at the largest accessibility text size without truncating key info.
- Combined accessibility elements for cards, with a hint for swipe actions.
- Selected chips/segments expose `.isSelected`.
- Icon-only buttons have `accessibilityLabel`.
