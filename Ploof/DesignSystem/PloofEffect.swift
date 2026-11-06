import SwiftUI

/// The signature "ploof": the view puffs away into a little cloud burst.
struct PloofEffect: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.82 : 1)
            .blur(radius: isActive ? 10 : 0)
            .opacity(isActive ? 0 : 1)
            .animation(.easeOut(duration: 0.38), value: isActive)
            .overlay {
                if isActive {
                    PuffBurst()
                }
            }
    }
}

extension View {
    func ploof(_ isActive: Bool) -> some View {
        modifier(PloofEffect(isActive: isActive))
    }
}

/// A ring of soft puffs that drift outward and fade.
struct PuffBurst: View {
    @State private var go = false
    private let count = 14

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) / Double(count) * 2 * .pi + (i.isMultiple(of: 2) ? 0.2 : 0)
                let distance: CGFloat = i.isMultiple(of: 3) ? 70 : 52
                let size: CGFloat = i.isMultiple(of: 2) ? 18 : 11
                Circle()
                    .fill(i.isMultiple(of: 3) ? AnyShapeStyle(.tint) : AnyShapeStyle(.white.opacity(0.95)))
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.08), radius: 3)
                    .offset(
                        x: go ? cos(angle) * distance * 1.6 : 0,
                        y: go ? sin(angle) * distance : 0
                    )
                    .scaleEffect(go ? 1.5 : 0.4)
                    .opacity(go ? 0 : 1)
            }
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white, Theme.settled)
                .scaleEffect(go ? 1.15 : 0.3)
                .opacity(go ? 0 : 1)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { go = true }
        }
    }
}

#Preview {
    @Previewable @State var active = false
    VStack(spacing: 40) {
        Text("Send the Q4 deck")
            .padding()
            .glassEffect()
            .ploof(active)
        Button("Ploof") { active.toggle() }
    }
}
