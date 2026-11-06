import SwiftUI

struct PromiseCard: View {
    let promise: Promise
    var isPloofing = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(person: promise.person, size: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(promise.person.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 8)
                    DueBadge(promise: promise)
                }
                Text(promise.title)
                    .font(.body.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: 6) {
                    Rectangle()
                        .fill(.tint.opacity(0.5))
                        .frame(width: 2)
                    Text("\u{201C}\(promise.evidence)\u{201D} — \(promise.evidenceBy)")
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
            if promise.isOverdue {
                OverdueGlow()
            }
        }
        .ploof(isPloofing)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Swipe right to settle")
    }
}

/// A slow pulse around overdue promises.
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

#Preview {
    VStack {
        ForEach(MockPromises.all.prefix(3)) { PromiseCard(promise: $0) }
    }
    .padding()
    .background(PloofBackground())
}
