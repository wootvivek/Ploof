import SwiftUI

/// Emails waiting on you, opened from the brief's "Need you" tile.
struct NeedsYouView: View {
    @Environment(PloofStore.self) private var store

    var body: some View {
        let items = store.needsYou
        List {
            Text("Emails waiting on a reply or an action from you. Reply to one and it moves to Waiting.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .plainRow(top: 0, bottom: 8)

            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.settled)
                    Text("Nothing needs you. Nice.")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
                .plainRow()
            }

            ForEach(items) { thread in
                NavRow(route: ThreadRoute(id: thread.id)) {
                    ThreadRow(thread: thread, promiseCount: store.openPromises(inThread: thread.id).count)
                        .padding(14)
                        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
                }
                .plainRow()
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        store.archive(thread.id)
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .tint(.indigo)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        store.toggleRead(thread.id)
                    } label: {
                        Label(thread.isUnread ? "Read" : "Unread",
                              systemImage: thread.isUnread ? "envelope.open" : "envelope.badge")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(PloofBackground())
        .navigationTitle("Need you")
        .animation(.snappy, value: items.map(\.id))
    }
}

#Preview {
    NavigationStack {
        NeedsYouView()
    }
    .environment(PloofStore())
}
