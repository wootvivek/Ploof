import SwiftUI

struct ThreadView: View {
    let threadID: String
    @Environment(PloofStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var compose: ComposeDraft?

    var body: some View {
        if let thread = store.thread(threadID) {
            content(thread)
        } else {
            ContentUnavailableView("Conversation not found", systemImage: "envelope")
        }
    }

    private func content(_ thread: MailThread) -> some View {
        let promises = store.openPromises(inThread: thread.id)
        let settleable = promises.first { $0.direction == .iOwe }?.id

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(thread.subject)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    BucketBadge(bucket: thread.bucket)
                    if thread.hasAttachment {
                        Label("Attachment", systemImage: "paperclip")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                StandsCard(text: thread.stands)

                if !promises.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(promises) { promise in
                            PromiseChip(promise: promise, isPloofing: store.ploofing.contains(promise.id)) {
                                store.settle(promise.id)
                            }
                        }
                    }
                }

                ForEach(thread.messages) { message in
                    MessageCard(message: message)
                }
            }
            .padding(16)
        }
        .background(PloofBackground(subtle: true))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    store.toggleFlag(thread.id)
                } label: {
                    Image(systemName: thread.isFlagged ? "flag.fill" : "flag")
                }
                .accessibilityLabel(thread.isFlagged ? "Unflag" : "Flag")
                Button {
                    store.archive(thread.id)
                    dismiss()
                } label: {
                    Image(systemName: "archivebox")
                }
                .accessibilityLabel("Archive")
            }
        }
        .safeAreaBar(edge: .bottom) {
            ReplyBar(thread: thread) { body in
                compose = .reply(to: thread, body: body, settles: settleable)
            } onForward: {
                compose = .forward(thread)
            }
        }
        .sheet(item: $compose) { ComposeSheet(draft: $0) }
        .sensoryFeedback(.success, trigger: store.settleTick)
        .onAppear { store.markRead(thread.id) }
    }
}

private struct StandsCard: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Where this stands", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.tint)
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(Color.accentColor.opacity(0.12)), in: .rect(cornerRadius: Theme.cardRadius))
    }
}

private struct PromiseChip: View {
    let promise: Promise
    let isPloofing: Bool
    let settle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: promise.direction == .iOwe ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .font(.title3)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 1) {
                Text(promise.direction.shortLabel)
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Text(promise.title)
                    .font(.subheadline.weight(.semibold))
            }
            Spacer(minLength: 8)
            DueBadge(promise: promise)
            Button(action: settle) {
                Image(systemName: "checkmark")
                    .font(.subheadline.weight(.bold))
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Settle \(promise.title)")
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .ploof(isPloofing)
    }
}

private struct MessageCard: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                AvatarView(person: message.from, size: 32)
                VStack(alignment: .leading, spacing: 0) {
                    Text(message.from.displayName)
                        .font(.subheadline.weight(.semibold))
                    Text(message.date.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text(message.body)
                .font(.body)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.opacity(0.85), in: .rect(cornerRadius: 20))
    }
}

private struct ReplyBar: View {
    let thread: MailThread
    let onReply: (String) -> Void
    let onForward: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            if !thread.suggestedReplies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.tint)
                            ForEach(thread.suggestedReplies, id: \.self) { reply in
                                Button(reply) { onReply(reply) }
                                    .buttonStyle(.glass)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .scrollClipDisabled()
            }
            HStack(spacing: 10) {
                Button {
                    onReply("")
                } label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                Button(action: onForward) {
                    Image(systemName: "arrowshape.turn.up.right")
                }
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityLabel("Forward")
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

#Preview {
    NavigationStack {
        ThreadView(threadID: "q4-deck")
    }
    .environment(PloofStore())
}
