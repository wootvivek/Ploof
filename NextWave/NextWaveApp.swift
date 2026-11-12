import SwiftUI

@main
struct NextWaveApp: App {
    @State private var store: NextWaveStore
    @State private var sync: SyncEngine
    /// Launch with `-hasOnboarded YES` to skip onboarding.
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    init() {
        let store = NextWaveStore()
        let sync = SyncEngine(store: store)
        _store = State(initialValue: store)
        _sync = State(initialValue: sync)
        // Launch with `-demo YES` to reset and start the demo straight away; `-demoMinutes 2` sets its length.
        let defaults = UserDefaults.standard
        if defaults.double(forKey: "demoMinutes") > 0 { sync.minutes = defaults.double(forKey: "demoMinutes") }
        if defaults.bool(forKey: "demoAtNine") { sync.startsAtNine = true }
        if defaults.bool(forKey: "demo") { sync.reset() }
    }

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
            .environment(sync)
        }
    }
}
