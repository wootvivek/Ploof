import SwiftUI

/// The chain of steps behind one commitment, in order: the work before, the meeting or due date it
/// is for, and anything that follows. Each step shows when it is planned or held, or that it has no room.
struct ChainSheet: View {
    enum Action { case openThread, newDate }

    let commitmentID: String
    let tint: Color
    let onAction: (Action) -> Void
    @Environment(NextWaveStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let plan = store.weekPlan
        NavigationStack {
            ScrollView {
                if let commitment = store.commitment(commitmentID) {
                    content(commitment, plan: plan)
                        .padding(16)
                }
            }
            .background(NextWaveBackground(subtle: true))
            .navigationTitle("Time for this")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func content(_ commitment: Commitment, plan: WeekPlan) -> some View {
        let fit = plan.fit(commitment.id)
        let blocks = plan.blocks(for: commitment.id)
        let steps = commitment.steps.isEmpty
            ? [Step("Do the work", commitment.effort?.lowMinutes ?? 0)]
            : commitment.steps
        let anchor = commitment.anchorEventID.flatMap { id in store.events.first { $0.id == id } }

        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(person: commitment.person, size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(commitment.title)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        Text(commitment.person.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        DueBadge(commitment: commitment)
                    }
                    if let effort = commitment.effort {
                        Text("\(effort.label), based on \(effort.basis).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    if step.isAfter, index == steps.firstIndex(where: \.isAfter) {
                        marker(commitment, anchor: anchor)
                    }
                    StepRow(number: index + 1, step: step, tint: tint,
                            blocks: blocks.filter { $0.stepIndex == index },
                            shortMinutes: plan.shortfalls[commitment.id]?[index] ?? 0,
                            assessed: fit != .notAssessed)
                }
                if !steps.contains(where: \.isAfter) {
                    marker(commitment, anchor: anchor)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))

            if case let .atRisk(open, _) = fit, let effort = commitment.effort {
                AtRiskLine(effort: effort, openMinutes: open)
            }

            VStack(spacing: 10) {
                if fit.isAtRisk {
                    Button {
                        onAction(.newDate)
                    } label: {
                        Label("Propose new date", systemImage: "calendar.badge.clock")
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.overdue)
                }
                if store.canHoldTime(for: commitment, in: plan) {
                    Button {
                        store.holdTime(for: commitment.id)
                    } label: {
                        Label("Hold this time", systemImage: "lock.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                }
                Button {
                    onAction(.openThread)
                } label: {
                    Label("Open the email", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            .controlSize(.large)
        }
    }

    /// The point the chain turns on: the meeting the work is for, or the due date.
    private func marker(_ commitment: Commitment, anchor: CalendarEvent?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: anchor == nil ? "flag.fill" : "diamond.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(anchor?.title ?? "Due")
                    .font(.subheadline.weight(.bold))
                Text(anchor.map { WeekText.dayAndTimes($0.interval) }
                     ?? commitment.due?.formatted(.dateTime.weekday(.wide).hour().minute()) ?? "No date")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct StepRow: View {
    let number: Int
    let step: Step
    let tint: Color
    let blocks: [PlannedBlock]
    let shortMinutes: Int
    let assessed: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(tint, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(step.title)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Text(Effort.text(step.minutes))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ForEach(blocks) { block in
                    Label("\(WeekText.dayAndTimes(block.interval)) · \(block.isHeld ? "Held" : "Planned")",
                          systemImage: block.isHeld ? "lock.fill" : "circle.dashed")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if shortMinutes > 0 {
                    Label("\(Effort.text(shortMinutes)) with no room before it's needed", systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Theme.overdue)
                } else if blocks.isEmpty {
                    Text(assessed ? "Not placed yet" : "Beyond the next five working days")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
