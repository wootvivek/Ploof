import SwiftUI

/// Today shows three of the four triage buckets, under the same names Mail uses:
/// Needs you and Waiting (commitments merged with the emails waiting on that side, so nothing is
/// listed twice), and Updates (only the important ones). Notifications stay in Mail.
struct TodayView: View {
    @Environment(NextWaveStore.self) private var store
    @State private var section: TriageBucket = .needsYou
    @State private var compose: ComposeDraft?

    var body: some View {
        let items = store.todayItems(section)
        NavigationStack {
            List {
                BriefCard(brief: store.brief, section: $section)
                    .plainRow(top: 4, bottom: 10)

                SectionHeader(title: section.title, symbol: section.symbol, trailing: "\(items.count)")
                    .plainRow(top: 8, bottom: 0)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .plainRow(top: 2, bottom: 6)

                if items.isEmpty {
                    EmptySection(section: section)
                        .plainRow()
                }

                ForEach(items) { item in
                    row(item)
                }

                if section == .updates {
                    Button {
                        store.openMail(.updates)
                    } label: {
                        Label("All updates in Mail", systemImage: "tray")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .plainRow(top: 10, bottom: 4)
                }

                Text(section == .updates ? "Swipe right to archive" : "Swipe right when it's done · left for more")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .plainRow(top: 12, bottom: 40)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(NextWaveBackground())
            .navigationTitle("Today")
            .navigationDestination(for: ThreadRoute.self) { ThreadView(threadID: $0.id) }
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

    private var subtitle: String {
        switch section {
        case .needsYou: "Replies and commitments that are yours. Most urgent first."
        case .waiting: "Replies and commitments you're waiting on. Overdue ones have a follow-up ready."
        case .updates, .notifications: "The updates that matter most today. The rest are in Mail."
        }
    }

    @ViewBuilder
    private func row(_ item: TodayItem) -> some View {
        if let commitment = item.commitment {
            let puffing = store.puffing.contains(commitment.id)
            let showFollowUp = section == .waiting && commitment.isOverdue && !puffing
            NavRow(route: ThreadRoute(id: item.thread.id)) {
                CommitmentCard(commitment: commitment, isPuffing: puffing)
            }
            .plainRow(top: 6, bottom: showFollowUp ? 2 : 6)
            .commitmentSwipeActions(commitment, store: store)

            if showFollowUp {
                HStack {
                    Spacer()
                    Button {
                        compose = store.followUpDraft(for: commitment)
                    } label: {
                        Label("Follow up with \(commitment.person.firstName)", systemImage: "arrowshape.turn.up.right.fill")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.today)
                }
                .plainRow(top: 2, bottom: 12)
            }
        } else {
            NavRow(route: ThreadRoute(id: item.thread.id)) {
                MailCard(thread: item.thread)
            }
            .plainRow()
            .mailSwipeActions(item.thread, store: store)
        }
    }
}

private struct EmptySection: View {
    let section: TriageBucket

    private var message: String {
        switch section {
        case .needsYou: "Nothing needs you. Enjoy it."
        case .waiting: "You're not waiting on anyone."
        case .updates, .notifications: "No important updates right now."
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.tint)
            Text(message)
                .font(.headline)
            if section != .updates {
                Text("Outlook keeps watching your mail for new commitments.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(28)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
    }
}

#Preview {
    TodayView()
        .environment(NextWaveStore())
}
