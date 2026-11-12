import SwiftUI

struct CommitmentCard: View {
    let commitment: Commitment
    var isPuffing = false
    /// Whether the time for it exists before it's due. Only your own commitments are assessed.
    var fit: Fit = .notAssessed
    /// The one next step, shown at the foot of the card.
    var action: CardAction? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(person: commitment.person, size: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(commitment.person.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    DueBadge(commitment: commitment)
                }
                Text(commitment.title)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                if let effort = commitment.effort, commitment.direction == .yours {
                    EffortBadge(effort: effort, stepCount: commitment.steps.count)
                }
                HStack(alignment: .top, spacing: 6) {
                    Rectangle()
                        .fill(.tint.opacity(0.5))
                        .frame(width: 2)
                    Text("\u{201C}\(commitment.evidence)\u{201D} — \(commitment.evidenceBy)")
                        .font(.footnote)
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .fixedSize(horizontal: false, vertical: true)

                if case let .atRisk(open, _) = fit, let effort = commitment.effort {
                    AtRiskLine(effort: effort, openMinutes: open)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Swipe right to mark done")
        if let action { CardActionBar(action: action) }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
        .overlay {
            if commitment.isOverdue {
                OverdueGlow()
            }
        }
        .puff(isPuffing)
    }
}

/// How long it is expected to take, next to when it is due.
struct EffortBadge: View {
    let effort: Effort
    var stepCount = 0

    var body: some View {
        Label(stepCount > 1 ? "\(effort.label) · \(stepCount) steps" : effort.label, systemImage: "clock")
            .labelStyle(.titleAndIcon)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Takes about \(effort.label)")
    }
}

/// Says why a commitment is at risk: what it needs, the basis, and the open time before it's due.
struct AtRiskLine: View {
    let effort: Effort
    let openMinutes: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("At risk. Needs \(effort.label), based on \(effort.basis). \(openMinutes == 0 ? "No open time" : "\(Effort.text(openMinutes)) open") before it's due.")
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(Theme.overdue)
        .padding(.top, 2)
    }
}

/// The one next step a card offers: send the drafted reply, hold the time, propose a new date,
/// follow up, or dismiss. `preview` says what will happen (for a reply, the exact words that will be
/// sent). With no `run` there is nothing to tap and the preview stands as a note.
struct CardAction {
    var preview: String? = nil
    var label: String? = nil
    var symbol = "arrowshape.turn.up.left.fill"
    var tint: Color = .accentColor
    var run: (() -> Void)? = nil
}

/// The foot of a card. A real button inside the card, so it takes its own tap; the rest of the card
/// still opens the thread.
struct CardActionBar: View {
    let action: CardAction
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 10))
        layout {
            if let preview = action.preview {
                Text(preview)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer(minLength: 0)
            }
            if let label = action.label, let run = action.run {
                Button(action: run) {
                    Label(label, systemImage: action.symbol)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .buttonStyle(.glassProminent)
                .tint(action.tint)
                .controlSize(.small)
                .accessibilityHint(action.preview ?? "")
            }
        }
        .padding(.top, 2)
    }
}

/// A slow pulse around overdue commitments.
private struct OverdueGlow: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Theme.cardRadius)
            .strokeBorder(Theme.overdue, lineWidth: 1.5)
            .phaseAnimator([0.2, 0.75]) { view, phase in
                view.opacity(phase)
            } animation: { _ in
                .easeInOut(duration: 1.4)
            }
            .allowsHitTesting(false)
    }
}

/// An email that is waiting on a reply and has no commitment attached.
/// Same skeleton as `CommitmentCard`, with the mail's time where the due date would be.
struct MailCard: View {
    let thread: MailThread
    /// The one next step, shown at the foot of the card.
    var action: CardAction? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(person: thread.counterpart, size: 40)
                .overlay(alignment: .topLeading) {
                    if thread.isUnread {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                            .offset(x: -3, y: -2)
                    }
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(thread.counterpart.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Label(thread.lastDate.listLabel, systemImage: "envelope")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(thread.subject)
                    .font(.body.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(.tint)
                    Text(thread.oneLiner)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Swipe right to archive")
        if let action { CardActionBar(action: action) }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
    }
}

extension View {
    /// Mark done (swipe right). Swipe left: "not a commitment", then for your own commitments
    /// "New date" and, when there is planned open time, "Hold time"; for other people's, Snooze.
    func commitmentSwipeActions(_ commitment: Commitment, store: NextWaveStore,
                                canHold: Bool = false, onNewDate: (() -> Void)? = nil) -> some View {
        self
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    store.complete(commitment.id)
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .tint(Theme.done)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    store.dismiss(commitment.id)
                } label: {
                    Label("Not a commitment", systemImage: "xmark")
                }
                .tint(.gray)
                if commitment.direction == .theirs {
                    Button {
                        store.snooze(commitment.id)
                    } label: {
                        Label("Snooze", systemImage: "moon.zzz")
                    }
                    .tint(.indigo)
                } else {
                    if let onNewDate, commitment.due != nil {
                        Button(action: onNewDate) {
                            Label("New date", systemImage: "calendar.badge.clock")
                        }
                        .tint(.indigo)
                    }
                    if canHold {
                        Button {
                            store.holdTime(for: commitment.id)
                        } label: {
                            Label("Hold time", systemImage: "lock")
                        }
                        .tint(.accentColor)
                    }
                }
            }
    }

    /// Archive (swipe right), read or unread (swipe left). Right always means "handled" on Today.
    func mailSwipeActions(_ thread: MailThread, store: NextWaveStore) -> some View {
        self
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    store.archive(thread.id)
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .tint(Theme.done)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    store.toggleRead(thread.id)
                } label: {
                    Label(thread.isUnread ? "Read" : "Unread",
                          systemImage: thread.isUnread ? "envelope.open" : "envelope.badge")
                }
                .tint(.blue)
            }
    }
}

#Preview {
    VStack {
        ForEach(MockCommitments.all.prefix(2)) { CommitmentCard(commitment: $0) }
        MailCard(thread: MockThreads.needsYouPeople[4])
    }
    .padding()
    .background(NextWaveBackground())
}
