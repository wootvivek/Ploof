import SwiftUI

struct ThreadRow: View {
    let thread: MailThread
    var promiseCount = 0
    var compact = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(person: thread.counterpart, size: compact ? 36 : 42)
                .overlay(alignment: .topLeading) {
                    if thread.isUnread {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                            .offset(x: -3, y: -2)
                    }
                }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(thread.counterpart.name)
                        .font(.subheadline.weight(thread.isUnread ? .bold : .semibold))
                        .lineLimit(1)
                    if thread.messages.count > 1 {
                        Text("\(thread.messages.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 6)
                    if thread.isFlagged {
                        Image(systemName: "flag.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    Text(thread.lastDate.listLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(thread.subject)
                    .font(.subheadline.weight(thread.isUnread ? .semibold : .regular))
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(.tint)
                    Text(thread.oneLiner)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(compact ? 1 : 2)
                }

                if !compact && (promiseCount > 0 || thread.hasAttachment) {
                    HStack(spacing: 8) {
                        if promiseCount > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.seal.fill")
                                Text(promiseCount == 1 ? "1 promise" : "\(promiseCount) promises")
                            }
                            .foregroundStyle(.tint)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                        }
                        if thread.hasAttachment {
                            HStack(spacing: 3) {
                                Image(systemName: "paperclip")
                                Text("Attachment")
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .font(.caption2.weight(.semibold))
                    .padding(.top, 3)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List(MockThreads.all.prefix(5)) { ThreadRow(thread: $0, promiseCount: 1) }
        .listStyle(.plain)
}
