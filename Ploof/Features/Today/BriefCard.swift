import SwiftUI

enum BriefTile {
    case owe, late, need
}

struct BriefCard: View {
    let brief: Brief
    var onTap: (BriefTile) -> Void = { _ in }
    @Environment(\.dynamicTypeSize) private var typeSize

    /// Tiles sit side by side normally, and stack at accessibility text sizes.
    private var tileLayout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(brief.dateLine)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(brief.greeting)
                    .font(.title2.weight(.bold))
            }

            tileLayout {
                StatTile(value: brief.oweCount, label: "You owe", tint: .accentColor) { onTap(.owe) }
                StatTile(value: brief.lateCount, label: "Late on you", tint: Theme.today) { onTap(.late) }
                StatTile(value: brief.needCount, label: "Need you", tint: TriageBucket.needsYou.tint) { onTap(.need) }
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.tint)
                Text(brief.headline)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

private struct StatTile: View {
    let value: Int
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(value)")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(tint)
                        .contentTransition(.numericText())
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(tint.opacity(0.6))
                }
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(tint.opacity(0.12), in: .rect(cornerRadius: 16))
            .contentShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(value) \(label)")
        .accessibilityHint("Shows them")
    }
}

/// A gentle squish on press, for custom tappable cards.
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    BriefCard(brief: PloofStore().brief)
        .padding()
        .background(PloofBackground())
}
