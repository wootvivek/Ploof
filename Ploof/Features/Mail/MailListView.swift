import SwiftUI

struct MailListView: View {
    @Environment(PloofStore.self) private var store
    @State private var showFolders = false
    @State private var compose: ComposeDraft?

    var body: some View {
        @Bindable var store = store
        let folder = store.mailFolder
        NavigationStack {
            let items = store.threads(in: folder, bucket: folder == .inbox ? store.mailBucket : nil)
            List {
                if items.isEmpty {
                    ContentUnavailableView(
                        "All clear",
                        systemImage: "checkmark.circle",
                        description: Text("Nothing here right now.")
                    )
                    .listRowSeparator(.hidden)
                }
                ForEach(items) { thread in
                    NavRow(route: ThreadRoute(id: thread.id)) {
                        ThreadRow(thread: thread, promiseCount: store.openPromises(inThread: thread.id).count)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.delete(thread.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
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
                        Button {
                            store.toggleFlag(thread.id)
                        } label: {
                            Label(thread.isFlagged ? "Unflag" : "Flag", systemImage: "flag")
                        }
                        .tint(.orange)
                    }
                }
                Color.clear.frame(height: 60)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .animation(.snappy, value: items.map(\.id))
            .safeAreaBar(edge: .top, spacing: 0) {
                if folder == .inbox {
                    TriageChips(selection: $store.mailBucket)
                }
            }
            .navigationTitle(folder.title)
            .navigationDestination(for: ThreadRoute.self) { ThreadView(threadID: $0.id) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showFolders = true
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                    .accessibilityLabel("Folders")
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    compose = .new()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3.weight(.semibold))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .padding(.trailing, 20)
                .padding(.bottom, 12)
                .accessibilityLabel("New message")
            }
            .sheet(isPresented: $showFolders) {
                FoldersSheet(selection: $store.mailFolder)
                    .presentationDetents([.medium])
            }
            .sheet(item: $compose) { ComposeSheet(draft: $0) }
        }
    }
}

struct TriageChips: View {
    @Binding var selection: TriageBucket?
    @Environment(PloofStore.self) private var store

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(TriageBucket.allCases) { bucket in
                        FilterChip(
                            title: bucket.title,
                            symbol: bucket.symbol,
                            count: store.count(bucket),
                            isSelected: selection == bucket,
                            tint: bucket.tint
                        ) {
                            withAnimation(.snappy) { selection = bucket }
                        }
                    }
                    FilterChip(title: "All", symbol: "tray.full", isSelected: selection == nil, tint: .accentColor) {
                        withAnimation(.snappy) { selection = nil }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .scrollClipDisabled()
    }
}

struct FoldersSheet: View {
    @Binding var selection: Folder
    @Environment(PloofStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(Folder.allCases) { folder in
                Button {
                    selection = folder
                    dismiss()
                } label: {
                    HStack {
                        Label(folder.title, systemImage: folder.symbol)
                        Spacer()
                        if folder == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                        Text("\(store.count(in: folder))")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Folders")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MailListView()
        .environment(PloofStore())
}
