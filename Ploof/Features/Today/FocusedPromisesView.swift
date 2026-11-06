import SwiftUI

/// A filtered promise list opened from the brief's "You owe" / "Late on you" tiles.
struct FocusedPromisesView: View {
    let focus: PromiseFocus
    @Environment(PloofStore.self) private var store
    @State private var compose: ComposeDraft?

    var body: some View {
        let items = store.promises(for: focus)
        List {
            Text(focus.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .plainRow(top: 0, bottom: 8)

            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.settled)
                    Text(focus == .oweToday ? "Nothing due. Nice." : "Nobody's late on you.")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
                .plainRow()
            }

            ForEach(items) { promise in
                NavRow(route: ThreadRoute(id: promise.threadID)) {
                    PromiseCard(promise: promise, isPloofing: store.ploofing.contains(promise.id))
                }
                .plainRow(top: 6, bottom: focus == .lateOnYou ? 2 : 6)
                .promiseSwipeActions(promise, store: store)

                if focus == .lateOnYou, !store.ploofing.contains(promise.id) {
                    HStack {
                        Spacer()
                        Button {
                            compose = store.nudgeDraft(for: promise)
                        } label: {
                            Label("Nudge \(promise.person.firstName)", systemImage: "hand.wave.fill")
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Theme.today)
                    }
                    .plainRow(top: 2, bottom: 12)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(PloofBackground())
        .navigationTitle(focus.title)
        .animation(.snappy, value: items.map(\.id))
        .sheet(item: $compose) { ComposeSheet(draft: $0) }
    }
}

extension View {
    /// Settle (swipe right), snooze or "not a promise" (swipe left).
    func promiseSwipeActions(_ promise: Promise, store: PloofStore) -> some View {
        self
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    store.settle(promise.id)
                } label: {
                    Label("Settle", systemImage: "checkmark")
                }
                .tint(Theme.settled)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    store.dismiss(promise.id)
                } label: {
                    Label("Not a promise", systemImage: "xmark")
                }
                .tint(.gray)
                Button {
                    store.snooze(promise.id)
                } label: {
                    Label("Snooze", systemImage: "moon.zzz")
                }
                .tint(.indigo)
            }
    }
}

#Preview {
    NavigationStack {
        FocusedPromisesView(focus: .lateOnYou)
    }
    .environment(PloofStore())
}
