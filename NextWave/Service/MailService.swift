import Foundation

/// The middle tier, as the app sees it: a starting snapshot, then a stream of events.
/// `DemoService` is the only implementation today. The real service (M1 onward) will sit behind the
/// same two calls, fed by Microsoft Graph notifications and the AI pipeline.
protocol MailService {
    /// Everything the service holds for the mailbox right now.
    func connect() -> MailboxSnapshot
    /// What changes after that, in order, until the stream ends.
    func events() -> AsyncStream<ServiceEvent>
}

/// A synthetic middle tier. It owns the scripted mailbox and plays `DemoScenario` in real time,
/// scaled to `duration` seconds.
final class DemoService: MailService {
    /// How long the whole script takes to play.
    var duration: TimeInterval = DemoScenario.length
    private var beats: [DemoScenario.Beat] = []

    var eventCount: Int { beats.count }

    func connect() -> MailboxSnapshot {
        let scenario = DemoScenario.build()
        beats = scenario.beats
        return scenario.start
    }

    func events() -> AsyncStream<ServiceEvent> {
        let beats = beats
        let scale = duration / DemoScenario.length
        return AsyncStream { continuation in
            let task = Task {
                var last: TimeInterval = 0
                for beat in beats {
                    try? await Task.sleep(for: .seconds(max(0, (beat.at - last) * scale)))
                    if Task.isCancelled { break }
                    continuation.yield(beat.event)
                    last = beat.at
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
