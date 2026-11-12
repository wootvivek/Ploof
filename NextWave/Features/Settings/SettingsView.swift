import SwiftUI

struct SettingsView: View {
    @Environment(NextWaveStore.self) private var store
    @Environment(SyncEngine.self) private var sync
    @AppStorage("hasOnboarded") private var hasOnboarded = true

    var body: some View {
        @Bindable var store = store
        @Bindable var sync = sync
        NavigationStack {
            Form {
                Section {
                    Button {
                        sync.reset()
                        store.selectedTab = .today
                    } label: {
                        Label(sync.phase == .idle ? "Reset and start demo" : "Reset demo", systemImage: "arrow.counterclockwise")
                    }
                    if sync.phase == .running, let started = sync.startedAt {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let elapsed = min(sync.runLength, max(0, context.date.timeIntervalSince(started)))
                            let left = Int((sync.runLength - elapsed).rounded(.up))
                            VStack(alignment: .leading, spacing: 6) {
                                ProgressView(value: elapsed, total: max(1, sync.runLength))
                                Text("\(sync.delivered) of \(sync.total) arrived · \(left / 60):\(String(format: "%02d", left % 60)) left")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                        Button("Stop", role: .destructive) { sync.stop() }
                    } else if sync.phase == .finished {
                        Label("Finished. Everything has arrived.", systemImage: "checkmark.circle")
                            .foregroundStyle(.secondary)
                    }
                    Picker(selection: $sync.minutes) {
                        Text("10 minutes").tag(10.0)
                        Text("3 minutes").tag(3.0)
                        Text("1 minute").tag(1.0)
                    } label: {
                        Label("Length", systemImage: "timer")
                    }
                    Toggle(isOn: $sync.startsAtNine) {
                        Label("Start the day at 9:00 AM", systemImage: "clock")
                    }
                } header: {
                    Text("Demo")
                } footer: {
                    Text("Reset puts the mailbox back to its starting point, then mail arrives over the chosen time. Dates, due labels and the calendar are worked out from the moment you reset. Turn on the 9:00 AM start to get the same story whatever time you run it.")
                }

                Section("Accounts") {
                    HStack(spacing: 12) {
                        AvatarView(person: MockPeople.me, size: 46)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(MockPeople.me.name)
                                .font(.headline)
                            Text(MockPeople.me.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Label("Add account", systemImage: "plus.circle")
                        .foregroundStyle(.tint)
                }

                Section {
                    Toggle(isOn: $store.smartTriage) {
                        Label("Smart triage", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    Toggle(isOn: $store.commitmentsOn) {
                        Label("Find commitments", systemImage: "checkmark.seal")
                    }
                    NavigationLink {
                        VoiceProfileView()
                    } label: {
                        Label("Your voice", systemImage: "waveform")
                    }
                } header: {
                    Text("Outlook AI")
                } footer: {
                    Text("Triage replaces Focused and Other with Needs you, Waiting, Updates and Notifications.")
                }

                Section("Notifications") {
                    Toggle(isOn: $store.buzzOnlyForNeedsYou) {
                        Label("Only buzz for Needs you", systemImage: "bell.badge")
                    }
                    Toggle(isOn: $store.morningBrief) {
                        Label("Morning brief", systemImage: "sun.max")
                    }
                }

                Section("Feel") {
                    Toggle(isOn: $store.doneSound) {
                        Label("Completion sound", systemImage: "speaker.wave.2")
                    }
                }

                Section("Privacy") {
                    Label {
                        Text("Outlook reads your mail to find commitments and write summaries. It keeps what it learns, not your mail.")
                            .font(.footnote)
                    } icon: {
                        Image(systemName: "lock.shield")
                    }
                    Label("Delete everything Outlook has learned", systemImage: "trash")
                        .foregroundStyle(.red)
                }

                Section {
                    Button("Replay onboarding") {
                        withAnimation { hasOnboarded = false }
                    }
                } footer: {
                    Text("Outlook Next Wave · proof of concept · synthetic data")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

private struct VoiceProfileView: View {
    var body: some View {
        List {
            Section {
                Text("Warm, brief, and direct. Opens with \u{201C}Hey\u{201D}, signs off \u{201C}Thanks!\u{201D}. Uses an emoji maybe once a week.")
            } header: {
                Text("How you write")
            } footer: {
                Text("With a real mailbox, Outlook learns this from a sample of your sent mail.")
            }
        }
        .navigationTitle("Your voice")
    }
}

#Preview {
    let store = NextWaveStore()
    SettingsView()
        .environment(store)
        .environment(SyncEngine(store: store))
}
