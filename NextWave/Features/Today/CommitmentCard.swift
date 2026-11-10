import SwiftUI

struct CommitmentCard: View {
    let commitment: Commitment
    var isPuffing = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(person: commitment.person, size: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(commitment.person.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    DueBadge(commitment: commitment)
                }
                Text(commitment.title)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
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
            }
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
        .accessibilityElement(children: .combine)
        .accessibilityHint("Swipe right to mark done")
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

    var body: some View {
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
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Swipe right to archive")
    }
}

extension View {
    /// Mark done (swipe right), snooze or "not a commitment" (swipe left).
    func commitmentSwipeActions(_ commitment: Commitment, store: NextWaveStore) -> some View {
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
                Button {
                    store.snooze(commitment.id)
                } label: {
                    Label("Snooze", systemImage: "moon.zzz")
                }
                .tint(.indigo)
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
