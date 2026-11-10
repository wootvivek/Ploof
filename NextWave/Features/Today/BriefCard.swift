import SwiftUI

/// The greeting, Today's three sections, and where to start.
/// The tiles carry the same names as the Mail chips and switch the list underneath.
struct BriefCard: View {
    let brief: Brief
    @Binding var section: TriageBucket
    @Environment(\.dynamicTypeSize) private var typeSize

    /// Tiles sit side by side normally, and stack at accessibility text sizes.
    private var tileLayout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(alignment: .top, spacing: 8))
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
                ForEach(TriageBucket.todaySections) { bucket in
                    SectionTile(value: count(bucket), label: bucket.title, detail: detail(bucket),
                                tint: bucket.tint, isSelected: section == bucket) {
                        withAnimation(.snappy) { section = bucket }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                line("sparkles", brief.headline)
                if let worthKnowing = brief.worthKnowing {
                    line(TriageBucket.updates.symbol, worthKnowing)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }

    private func line(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func count(_ bucket: TriageBucket) -> Int {
        switch bucket {
        case .needsYou: brief.needsYouCount
        case .waiting: brief.waitingCount
        case .updates: brief.updatesCount
        case .notifications: 0
        }
    }

    /// The urgent part of each count, in the same words the cards use: overdue, due today, unread.
    private func detail(_ bucket: TriageBucket) -> String {
        switch bucket {
        case .needsYou:
            var parts: [String] = []
            if brief.overdueCount > 0 { parts.append("\(brief.overdueCount) overdue") }
            if brief.dueTodayCount > 0 { parts.append("\(brief.dueTodayCount) due today") }
            return parts.isEmpty ? "Nothing due today" : parts.joined(separator: "\n")
        case .waiting:
            return brief.waitingOverdueCount > 0 ? "\(brief.waitingOverdueCount) overdue" : "None overdue"
        case .updates:
            return brief.unreadUpdatesCount > 0 ? "\(brief.unreadUpdatesCount) unread" : "All read"
        case .notifications:
            return ""
        }
    }
}

private struct SectionTile: View {
    let value: Int
    let label: String
    let detail: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(11)
            .background(tint.opacity(isSelected ? 0.18 : 0.07), in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(tint.opacity(isSelected ? 0.9 : 0), lineWidth: 1.5)
            }
            .contentShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(label), \(value). \(detail.replacingOccurrences(of: "\n", with: ", "))")
        .accessibilityHint("Shows this list")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
    @Previewable @State var section = TriageBucket.needsYou
    BriefCard(brief: NextWaveStore().brief, section: $section)
        .padding()
        .background(NextWaveBackground())
}
