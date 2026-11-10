import SwiftUI

struct SettingsView: View {
    @Environment(NextWaveStore.self) private var store
    @AppStorage("hasOnboarded") private var hasOnboarded = true

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
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
    SettingsView()
        .environment(NextWaveStore())
}
