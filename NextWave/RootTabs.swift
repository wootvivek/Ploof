import SwiftUI

struct RootTabs: View {
    @Environment(NextWaveStore.self) private var store

    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.selectedTab) {
            Tab("Today", systemImage: "sparkles", value: AppTab.today) {
                TodayView()
            }
            Tab("Mail", systemImage: "tray", value: AppTab.mail) {
                MailListView()
            }
            .badge(store.unreadNeedsYou)
            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView()
            }
            Tab("Ask", systemImage: "sparkle.magnifyingglass", value: AppTab.ask, role: .search) {
                AskView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .sensoryFeedback(.success, trigger: store.doneTick)
        .overlay(alignment: .bottom) {
            if let toast = store.toast {
                ToastView(toast: toast) { store.undo($0) }
                    .padding(.bottom, 104)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: toast.id) {
                        try? await Task.sleep(for: .seconds(3))
                        if store.toast?.id == toast.id {
                            withAnimation(.snappy) { store.toast = nil }
                        }
                    }
            }
        }
    }
}

#Preview {
    RootTabs()
        .environment(NextWaveStore())
}
