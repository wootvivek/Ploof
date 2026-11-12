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
        let plan = store.weekPlan
        NavigationStack {
            List {
                BriefCard(brief: store.brief, section: $section, onWeek: { store.selectedTab = .calendar }, isLive: store.isLive)
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
                    row(item, plan: plan)
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
    private func row(_ item: TodayItem, plan: WeekPlan) -> some View {
        let next = action(for: item, plan: plan)
        if let commitment = item.commitment {
            let puffing = store.puffing.contains(commitment.id)
            let fit = section == .needsYou ? plan.fit(commitment.id) : .notAssessed
            NavRow(route: ThreadRoute(id: item.thread.id)) {
                CommitmentCard(commitment: commitment, isPuffing: puffing, fit: fit, action: puffing ? nil : next)
            }
            .plainRow()
            .commitmentSwipeActions(commitment, store: store,
                                    canHold: store.canHoldTime(for: commitment, in: plan)) {
                compose = store.newDateDraft(for: commitment)
            }
        } else {
            NavRow(route: ThreadRoute(id: item.thread.id)) {
                MailCard(thread: item.thread, action: next)
            }
            .plainRow()
            .mailSwipeActions(item.thread, store: store)
        }
    }

    /// The most likely next step for an item, in this order: fix a date that can't be met, send the
    /// reply that's already drafted, protect the time, or start a reply.
    private func action(for item: TodayItem, plan: WeekPlan) -> CardAction? {
        let thread = item.thread
        switch section {
        case .needsYou:
            if let commitment = item.commitment, plan.fit(commitment.id).isAtRisk {
                return CardAction(label: "Propose new date", symbol: "calendar.badge.clock", tint: Theme.overdue) {
                    compose = store.newDateDraft(for: commitment)
                }
            }
            if let quick = thread.quickReply {
                let finishes = quick.completes ? item.commitment?.id : nil
                return CardAction(preview: "\u{201C}\(quick.text)\u{201D}", label: quick.label, symbol: "paperplane.fill") {
                    store.quickSend(quick.text, on: thread.id, completing: finishes)
                }
            }
            if let commitment = item.commitment, store.canHoldTime(for: commitment, in: plan),
               let first = plan.slots(for: commitment.id).first {
                let more = plan.slots(for: commitment.id).count - 1
                return CardAction(preview: "Planned: \(WeekText.dayAndTimes(first))\(more > 0 ? " and \(more) more" : "")",
                                  label: "Hold time", symbol: "lock.fill") {
                    store.holdTime(for: commitment.id)
                }
            }
            return CardAction(label: "Reply", symbol: "arrowshape.turn.up.left.fill") {
                compose = .reply(to: thread, body: thread.suggestedReplies.first ?? "", completes: item.commitment?.id)
            }
        case .waiting:
            guard let commitment = item.commitment else { return nil }
            if store.followedUp.contains(commitment.id) {
                return CardAction(preview: "You followed up just now.")
            }
            guard commitment.isOverdue else { return nil }
            let draft = store.followUpDraft(for: commitment)?.body ?? ""
            return CardAction(preview: "\u{201C}\(draft)\u{201D}", label: "Follow up", symbol: "paperplane.fill", tint: Theme.today) {
                store.sendFollowUp(for: commitment)
            }
        case .updates, .notifications:
            return CardAction(label: "Got it", symbol: "checkmark", tint: TriageBucket.updates.tint) {
                store.archive(thread.id)
            }
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
