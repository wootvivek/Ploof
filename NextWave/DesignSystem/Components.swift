import SwiftUI

// MARK: - List helpers

extension View {
    /// A transparent, separator-free list row so glass cards float on the background.
    func plainRow(top: CGFloat = 6, bottom: CGFloat = 6) -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: top, leading: 16, bottom: bottom, trailing: 16))
    }
}

/// Navigates on tap without the list's disclosure chevron.
struct NavRow<Route: Hashable, Content: View>: View {
    let route: Route
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            NavigationLink(value: route) { EmptyView() }.opacity(0)
            content
        }
    }
}

struct SectionHeader: View {
    let title: String
    let symbol: String
    var trailing: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            Text(title)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.title3.weight(.bold))
        .padding(.top, 10)
    }
}

// MARK: - Chips & badges

struct FilterChip: View {
    let title: String
    let symbol: String
    var count: Int? = nil
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        if isSelected {
            button.buttonStyle(.glassProminent).tint(tint)
        } else {
            button.buttonStyle(.glass)
        }
    }

    private var button: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
                if let count {
                    Text("\(count)")
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? AnyShapeStyle(.white.opacity(0.85)) : AnyShapeStyle(.secondary))
                }
            }
            .font(.subheadline.weight(.semibold))
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct DueBadge: View {
    let commitment: Commitment

    var body: some View {
        Text(commitment.dueLabel)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(commitment.tone.color)
            .background(commitment.tone.color.opacity(0.14), in: Capsule())
    }
}

struct BucketBadge: View {
    let bucket: TriageBucket

    var body: some View {
        Label(bucket.title, systemImage: bucket.symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .foregroundStyle(bucket.tint)
            .background(bucket.tint.opacity(0.14), in: Capsule())
    }
}

// MARK: - Glass segmented control

struct GlassSegmented<Option: Hashable & Identifiable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String
    var count: (Option) -> Int? = { _ in nil }
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options) { option in
                let selected = option == selection
                Button {
                    withAnimation(.snappy(duration: 0.3)) { selection = option }
                } label: {
                    HStack(spacing: 6) {
                        Text(title(option))
                        if let n = count(option) {
                            Text("\(n)")
                                .font(.caption.weight(.bold))
                                .monospacedDigit()
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(selected ? AnyShapeStyle(.white.opacity(0.25)) : AnyShapeStyle(.quaternary), in: Capsule())
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selected {
                            Capsule()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "selection", in: ns)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4)
        .glassEffect(.regular, in: .capsule)
    }
}

// MARK: - Toast

struct ToastView: View {
    let toast: Toast
    let undo: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.symbol)
                .foregroundStyle(.tint)
            Text(toast.text)
                .lineLimit(1)
            if toast.canUndo {
                Button("Undo") { undo() }
                    .fontWeight(.bold)
            }
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 24)
    }
}

// MARK: - Shimmer (fake "AI is working")

struct Shimmer: View {
    @State private var phase: CGFloat = -0.6

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, Color.accentColor.opacity(0.28), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.6)
            .offset(x: phase * geo.size.width)
            .onAppear {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                    phase = 1.1
                }
            }
        }
        .allowsHitTesting(false)
        .clipped()
    }
}
