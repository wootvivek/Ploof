import SwiftUI

struct TodayView: View {
    @Environment(PloofStore.self) private var store
    @State private var direction: PromiseDirection = .iOwe
    @State private var compose: ComposeDraft?
    @State private var focus: PromiseFocus?
    @State private var showNeedsYou = false

    var body: some View {
        NavigationStack {
            List {
                BriefCard(brief: store.brief) { tile in
                    switch tile {
                    case .owe: focus = .oweToday
                    case .late: focus = .lateOnYou
                    case .need: showNeedsYou = true
                    }
                }
                .plainRow(top: 4, bottom: 10)

                SectionHeader(title: "Needs you", symbol: "bolt.fill", trailing: "\(store.needsYou.count)")
                    .plainRow(top: 8, bottom: 0)
                ForEach(store.needsYou.prefix(3)) { thread in
                    NavRow(route: ThreadRoute(id: thread.id)) {
                        ThreadRow(thread: thread, promiseCount: store.openPromises(inThread: thread.id).count, compact: true)
                            .padding(14)
                            .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
                    }
                    .plainRow(top: 4, bottom: 4)
                }

                SectionHeader(title: "Promises", symbol: "checkmark.seal.fill")
                    .plainRow(top: 16, bottom: 4)
                GlassSegmented(
                    options: PromiseDirection.allCases,
                    selection: $direction,
                    title: \.title,
                    count: { store.openPromises($0).count }
                )
                .plainRow(top: 4, bottom: 8)

                let items = store.openPromises(direction)
                if items.isEmpty {
                    EmptyBoard(direction: direction)
                        .plainRow()
                }
                ForEach(items) { promise in
                    NavRow(route: ThreadRoute(id: promise.threadID)) {
                        PromiseCard(promise: promise, isPloofing: store.ploofing.contains(promise.id))
                    }
                    .plainRow()
                    .promiseSwipeActions(promise, store: store)
                }

                Text("Swipe right to settle · left to snooze")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .plainRow(top: 12, bottom: 40)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(PloofBackground())
            .navigationTitle("Today")
            .navigationDestination(for: ThreadRoute.self) { ThreadView(threadID: $0.id) }
            .navigationDestination(item: $focus) { FocusedPromisesView(focus: $0) }
            .navigationDestination(isPresented: $showNeedsYou) { NeedsYouView() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        compose = .new()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New message")
                }
            }
            .sheet(item: $compose) { ComposeSheet(draft: $0) }
        }
    }
}

private struct EmptyBoard: View {
    let direction: PromiseDirection

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text(direction == .iOwe ? "You owe nothing. Enjoy it." : "Nobody owes you anything.")
                .font(.headline)
            Text("Ploof keeps watching your mail for new promises.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(28)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
    }
}

#Preview {
    TodayView()
        .environment(PloofStore())
}
