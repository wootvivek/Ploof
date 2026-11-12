import SwiftUI

/// Keeps the store in step with the service: loads the starting snapshot, then applies each event as it
/// arrives. For demos, `reset()` starts the mailbox over and plays the script again.
@Observable
final class SyncEngine {
    enum Phase: Equatable {
        case idle, running, finished
    }

    private(set) var phase: Phase = .idle
    private(set) var delivered = 0
    private(set) var total = 0
    /// When the current run started and how long it is set to take, for showing progress.
    private(set) var startedAt: Date?
    private(set) var runLength: TimeInterval = 0

    /// How long a run takes, in minutes.
    var minutes: Double = 10
    /// When on, every reset starts the app's day at 9:00 AM, so the demo is the same whenever you run it.
    /// When off, the demo is anchored to the real time.
    var startsAtNine = false

    private let store: NextWaveStore
    private let service = DemoService()
    private var task: Task<Void, Never>?

    init(store: NextWaveStore) {
        self.store = store
    }

    /// Starts the mailbox over, anchored to this moment, and plays the script.
    func reset() {
        task?.cancel()

        // Anchor the clock first: every relative date in the mailbox is worked out from it.
        if startsAtNine, let nine = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) {
            AppClock.offset = nine.timeIntervalSince(.now)
        } else {
            AppClock.offset = 0
        }

        service.duration = minutes * 60
        store.load(service.connect())
        store.isLive = true
        delivered = 0
        total = service.eventCount
        startedAt = .now
        runLength = service.duration
        phase = .running

        let stream = service.events()
        task = Task { [weak self] in
            for await event in stream {
                guard let self, !Task.isCancelled else { return }
                self.store.apply(event)
                self.delivered += 1
            }
            guard let self, !Task.isCancelled else { return }
            self.phase = .finished
            self.store.isLive = false
        }
    }

    /// Stops the script where it is. The mailbox stays as it is.
    func stop() {
        task?.cancel()
        task = nil
        store.isLive = false
        if phase == .running { phase = .idle }
    }
}
