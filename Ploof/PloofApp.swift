import SwiftUI

@main
struct PloofApp: App {
    @State private var store = PloofStore()
    /// Launch with `-hasOnboarded YES` to skip onboarding.
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    RootTabs()
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(.smooth(duration: 0.5)) { hasOnboarded = true }
                    }
                    .transition(.opacity)
                }
            }
            .environment(store)
        }
    }
}
