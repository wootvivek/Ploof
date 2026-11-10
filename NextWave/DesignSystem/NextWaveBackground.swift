import SwiftUI

/// Soft mesh-gradient backdrop that gives Liquid Glass something to refract.
struct NextWaveBackground: View {
    /// Tones the gradient down behind reading-heavy screens.
    var subtle = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.45], [0.62, 0.5], [1, 0.4],
                [0, 1], [0.45, 1], [1, 1],
            ],
            colors: scheme == .dark ? dark : light
        )
        .overlay {
            if subtle {
                Color(.systemBackground).opacity(scheme == .dark ? 0.55 : 0.6)
            }
        }
        .ignoresSafeArea()
    }

    private var light: [Color] {
        [
            Color(hex: 0xE9E8FF), Color(hex: 0xF4ECFF), Color(hex: 0xFFE9F1),
            Color(hex: 0xE3F0FF), Color(hex: 0xF7F5FF), Color(hex: 0xFFF1E6),
            Color(hex: 0xE6FAF4), Color(hex: 0xEFEAFF), Color(hex: 0xFDE8F3),
        ]
    }

    private var dark: [Color] {
        [
            Color(hex: 0x15142B), Color(hex: 0x1D1838), Color(hex: 0x2A1630),
            Color(hex: 0x111A2E), Color(hex: 0x17162A), Color(hex: 0x261A26),
            Color(hex: 0x0E1F22), Color(hex: 0x1A1631), Color(hex: 0x24142A),
        ]
    }
}

#Preview {
    NextWaveBackground()
}
