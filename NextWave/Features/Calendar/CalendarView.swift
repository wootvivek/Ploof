import SwiftUI

/// The calendar as time, not just meetings: what is booked, what you have held for commitments,
/// what the planner would use next, and what is still open. Tap a block to see the whole chain of
/// steps behind its commitment.
struct CalendarView: View {
    @Environment(NextWaveStore.self) private var store
    @State private var selectedDay: Date?
    @State private var chain: Commitment?
    @State private var compose: ComposeDraft?
    @State private var path = NavigationPath()

    var body: some View {
        let plan = store.weekPlan
        let day = selectedDay ?? plan.days.first?.day ?? AppClock.today
        let atRisk = store.commitments(atRiskIn: plan)
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(summary(plan))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    WeekGrid(plan: plan, events: store.events, selected: day,
                             riskDays: Set(atRisk.compactMap { $0.due.map { Calendar.current.startOfDay(for: $0) } }),
                             tint: tint) { picked in
                        withAnimation(.snappy) { selectedDay = picked }
                    }

                    DayTimeline(day: day, load: plan.days.first { $0.day == day }, events: store.events,
                                blocks: plan.blocks, anchors: anchors, tint: tint) { commitmentID in
                        chain = store.commitment(commitmentID)
                    }

                    if !atRisk.isEmpty {
                        SectionHeader(title: "At risk", symbol: "exclamationmark.triangle.fill", trailing: "\(atRisk.count)")
                        ForEach(atRisk) { commitment in
                            CommitmentCard(commitment: commitment, fit: plan.fit(commitment.id),
                                           action: CardAction(label: "Propose new date", symbol: "calendar.badge.clock",
                                                              tint: Theme.overdue) {
                                               compose = store.newDateDraft(for: commitment)
                                           })
                                .onTapGesture { chain = commitment }
                        }
                    }

                    Label("Held time is private. Other people see it as busy.", systemImage: "eye.slash")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            .background(NextWaveBackground())
            .navigationTitle("Calendar")
            .navigationDestination(for: ThreadRoute.self) { ThreadView(threadID: $0.id) }
            .sheet(item: $chain) { commitment in
                ChainSheet(commitmentID: commitment.id, tint: tint(commitment.id)) { action in
                    chain = nil
                    switch action {
                    case .openThread: path.append(ThreadRoute(id: commitment.threadID))
                    case .newDate: compose = store.newDateDraft(for: commitment)
                    }
                }
            }
            .sheet(item: $compose) { ComposeSheet(draft: $0) }
        }
    }

    private func summary(_ plan: WeekPlan) -> String {
        var text = "\(Effort.total(plan.openMinutes)) open and \(Effort.total(plan.neededMinutes)) of commitments over the next five working days."
        if !plan.atRisk.isEmpty { text += " \(plan.atRisk.count) at risk." }
        return text
    }

    /// One colour per commitment, spread around the wheel so neighbours on the grid never look alike.
    private func tint(_ commitmentID: String) -> Color {
        let index = store.commitments.firstIndex { $0.id == commitmentID } ?? 0
        let hue = (0.58 + Double(index) * 0.618034).truncatingRemainder(dividingBy: 1)
        return Color(hue: hue, saturation: 0.62, brightness: 0.82)
    }

    /// Meetings that a commitment's work is for, keyed by event id.
    private var anchors: [String: String] {
        Dictionary(store.commitments.compactMap { c in c.anchorEventID.map { ($0, c.id) } }, uniquingKeysWith: { a, _ in a })
    }
}

// MARK: - Week at a glance

/// Five columns, 9 to 5. Grey is booked, solid colour is held, pale colour is planned, blank is open.
/// Doubles as the day picker.
private struct WeekGrid: View {
    let plan: WeekPlan
    let events: [CalendarEvent]
    let selected: Date
    let riskDays: Set<Date>
    let tint: (String) -> Color
    let onPick: (Date) -> Void
    @ScaledMetric(relativeTo: .caption) private var columnHeight: CGFloat = 132

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 6) {
                ForEach(plan.days) { load in
                    Button {
                        onPick(load.day)
                    } label: {
                        column(load)
                    }
                    .buttonStyle(PressScaleStyle())
                    .accessibilityLabel(label(load))
                    .accessibilityAddTraits(load.day == selected ? .isSelected : [])
                }
            }
            HStack(spacing: 14) {
                key("Booked", Color.secondary.opacity(0.45))
                key("Held", Color.accentColor)
                key("Planned", Color.accentColor.opacity(0.35))
                key("Open", Color.secondary.opacity(0.10))
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
    }

    private func column(_ load: DayLoad) -> some View {
        let isSelected = load.day == selected
        let window = WeekPlanner.workWindow(load.day)
        return VStack(spacing: 6) {
            VStack(spacing: 0) {
                Text(AppClock.isToday(load.day) ? "Today" : load.day.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                HStack(spacing: 3) {
                    Text(load.day.formatted(.dateTime.day()))
                        .font(.subheadline.weight(.bold))
                    if riskDays.contains(load.day) {
                        Circle().fill(Theme.overdue).frame(width: 6, height: 6)
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            GeometryReader { geo in
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.08))
                    ForEach(events.filter { window.intersects($0.interval) }) { event in
                        bar(event.interval, in: window, height: geo.size.height, color: Color.secondary.opacity(0.45))
                    }
                    ForEach(plan.blocks.filter { window.intersects($0.interval) }) { block in
                        bar(block.interval, in: window, height: geo.size.height,
                            color: tint(block.commitmentID).opacity(block.isHeld ? 1 : 0.38))
                    }
                }
            }
            .frame(height: columnHeight)
            .clipShape(.rect(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.accentColor.opacity(isSelected ? 0.9 : 0), lineWidth: 1.5)
            }

            Text(Effort.text(load.openMinutes))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private func bar(_ interval: DateInterval, in window: DateInterval, height: CGFloat, color: Color) -> some View {
        let total = window.duration
        let start = max(0, interval.start.timeIntervalSince(window.start))
        let end = min(total, interval.end.timeIntervalSince(window.start))
        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(height: max(2, height * (end - start) / total - 1))
            .padding(.horizontal, 3)
            .offset(y: height * start / total)
    }

    private func key(_ name: String, _ color: Color) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 10, height: 10)
            Text(name)
        }
    }

    private func label(_ load: DayLoad) -> String {
        let name = AppClock.isToday(load.day) ? "Today" : load.day.formatted(.dateTime.weekday(.wide).month().day())
        return "\(name): booked \(Effort.text(load.bookedMinutes)), held \(Effort.text(load.heldMinutes)), open \(Effort.text(load.openMinutes))"
    }
}

// MARK: - One day, hour by hour

private struct DayTimeline: View {
    let day: Date
    let load: DayLoad?
    let events: [CalendarEvent]
    let blocks: [PlannedBlock]
    /// event id → commitment id, for meetings that some commitment's work is for.
    let anchors: [String: String]
    let tint: (String) -> Color
    let onTap: (String) -> Void
    @ScaledMetric(relativeTo: .caption) private var hourHeight: CGFloat = 72
    @ScaledMetric(relativeTo: .caption2) private var gutter: CGFloat = 44

    private var window: DateInterval { WeekPlanner.workWindow(day) }
    private var hours: [Int] { Array(WeekPlanner.workdayStartHour...WeekPlanner.workdayEndHour) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(AppClock.isToday(day) ? "Today" : day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.title3.weight(.bold))
                Spacer(minLength: 8)
                if let load {
                    Text("\(Effort.text(load.openMinutes)) open")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            GeometryReader { geo in
                let width = max(0, geo.size.width - gutter - 4)
                ZStack(alignment: .topLeading) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(spacing: 4) {
                            Text(hourLabel(hour))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: gutter - 4, alignment: .trailing)
                            Rectangle()
                                .fill(Color.secondary.opacity(0.18))
                                .frame(height: 0.5)
                        }
                        .offset(y: CGFloat(hour - WeekPlanner.workdayStartHour) * hourHeight - 6)
                    }

                    ForEach(events.filter { window.intersects($0.interval) }) { event in
                        let anchorFor = anchors[event.id]
                        MeetingBlock(event: event, accent: anchorFor.map(tint))
                            .frame(width: width, height: height(event.interval))
                            .offset(x: gutter + 4, y: y(event.interval))
                            .onTapGesture { if let anchorFor { onTap(anchorFor) } }
                    }

                    ForEach(blocks.filter { window.intersects($0.interval) }) { block in
                        Button {
                            onTap(block.commitmentID)
                        } label: {
                            WorkBlock(block: block, color: tint(block.commitmentID), compact: block.minutes < 30)
                                .frame(width: width, height: height(block.interval))
                        }
                        .buttonStyle(PressScaleStyle())
                        .offset(x: gutter + 4, y: y(block.interval))
                    }

                    // Where the day has got to. Time above this line is gone and is not counted as open.
                    TimelineView(.periodic(from: .now, by: 30)) { _ in
                        let now = AppClock.now
                        if window.contains(now) {
                            HStack(spacing: 0) {
                                Circle().fill(Theme.overdue).frame(width: 8, height: 8)
                                Rectangle().fill(Theme.overdue).frame(height: 1.5)
                            }
                            .frame(width: width + 8)
                            .offset(x: gutter - 4, y: CGFloat(now.timeIntervalSince(window.start) / 3600) * hourHeight - 4)
                            .allowsHitTesting(false)
                            .accessibilityLabel("Now, \(now.formatted(date: .omitted, time: .shortened))")
                        }
                    }
                }
            }
            .frame(height: CGFloat(hours.count - 1) * hourHeight + 8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
    }

    private func y(_ interval: DateInterval) -> CGFloat {
        CGFloat(max(0, interval.start.timeIntervalSince(window.start)) / 3600) * hourHeight
    }

    private func height(_ interval: DateInterval) -> CGFloat {
        let start = max(interval.start, window.start), end = min(interval.end, window.end)
        return max(14, CGFloat(end.timeIntervalSince(start) / 3600) * hourHeight - 2)
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
        return date.formatted(.dateTime.hour())
    }
}

/// A meeting. When some commitment's work is for this meeting, it carries that commitment's colour.
private struct MeetingBlock: View {
    let event: CalendarEvent
    let accent: Color?

    var body: some View {
        HStack(spacing: 6) {
            if let accent {
                Capsule().fill(accent).frame(width: 4)
            }
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    if accent != nil {
                        Image(systemName: "diamond.fill").font(.caption2).foregroundStyle(accent ?? .secondary)
                    }
                    Text(event.title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }
                Text(WeekText.times(event.interval))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.secondary.opacity(0.16), in: .rect(cornerRadius: 8))
        .clipShape(.rect(cornerRadius: 8))
        .contentShape(.rect(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Meeting: \(event.title), \(WeekText.times(event.interval))")
    }
}

/// Time for one step of a commitment. Solid when held, pale with a dashed edge when only planned.
private struct WorkBlock: View {
    let block: PlannedBlock
    let color: Color
    let compact: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: block.isHeld ? "lock.fill" : (block.isAfter ? "arrow.turn.down.right" : "circle.dashed"))
                .font(.caption2.weight(.bold))
            VStack(alignment: .leading, spacing: 1) {
                Text(block.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                if !compact {
                    Text(detail)
                        .font(.caption2)
                        .opacity(0.8)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(block.isHeld ? Color.white : Color.primary)
        .padding(.horizontal, 8)
        .padding(.vertical, compact ? 0 : 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: compact ? .leading : .topLeading)
        .background(color.opacity(block.isHeld ? 0.92 : 0.18), in: .rect(cornerRadius: 8))
        .overlay {
            if !block.isHeld {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(color, style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
            }
        }
        .clipShape(.rect(cornerRadius: 8))
        .contentShape(.rect(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(block.isHeld ? "Held" : "Planned"): \(block.title), \(WeekText.times(block.interval))")
        .accessibilityHint("Shows the steps for this commitment")
    }

    private var detail: String {
        let state = block.isHeld ? "Held" : "Planned"
        return block.stepCount > 1 ? "\(state) · step \(block.stepIndex + 1) of \(block.stepCount)" : state
    }
}

enum WeekText {
    /// "2:00 – 3:30 PM"
    static func times(_ interval: DateInterval) -> String {
        "\(interval.start.formatted(date: .omitted, time: .shortened)) – \(interval.end.formatted(date: .omitted, time: .shortened))"
    }

    /// "Today 2:00 – 3:30 PM", "Thu 9:00 – 9:30 AM"
    static func dayAndTimes(_ interval: DateInterval) -> String {
        let day = AppClock.isToday(interval.start) ? "Today" : interval.start.formatted(.dateTime.weekday(.abbreviated))
        return "\(day) \(times(interval))"
    }
}

#Preview {
    CalendarView()
        .environment(NextWaveStore())
}
