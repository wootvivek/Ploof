import SwiftUI

struct ComposeSheet: View {
    @State var draft: ComposeDraft
    @Environment(NextWaveStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var isRewriting = false
    @State private var completeOn = true
    @FocusState private var bodyFocused: Bool

    private var completesCommitment: Commitment? {
        draft.completes.flatMap { store.commitment($0) }
    }

    private var canSend: Bool {
        !draft.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isRewriting
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                field("To", text: $draft.to)
                Divider().padding(.leading, 16)
                field("Subject", text: $draft.subject)
                Divider().padding(.leading, 16)
                TextEditor(text: $draft.body)
                    .focused($bodyFocused)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .overlay {
                        if isRewriting { Shimmer() }
                    }
                    .overlay(alignment: .topLeading) {
                        if draft.body.isEmpty {
                            Text("Write something, or tap a suggestion…")
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 17)
                                .padding(.top, 14)
                                .allowsHitTesting(false)
                        }
                    }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    if let commitment = completesCommitment {
                        Toggle(isOn: $completeOn) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Theme.done)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("This completes")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    Text(commitment.title)
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                        }
                        .tint(Theme.done)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(.regular.tint(Theme.done.opacity(0.12)), in: .rect(cornerRadius: 18))
                    }
                    if let newDue = draft.newDue {
                        Label("Sending moves the due date to \(newDue.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))",
                              systemImage: "calendar.badge.clock")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    }
                    Button(action: rewrite) {
                        Label(isRewriting ? "Rewriting in your voice…" : "Rewrite in my voice",
                              systemImage: "wand.and.sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .disabled(isRewriting)
                }
                .padding(16)
            }
            .navigationTitle(draft.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: send) {
                        Image(systemName: "arrow.up")
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!canSend)
                    .accessibilityLabel("Send")
                }
            }
            .onAppear { bodyFocused = draft.body.isEmpty }
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(.secondary)
            TextField("", text: text)
        }
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func rewrite() {
        isRewriting = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.smooth) {
                draft.body = MockAsk.rewrite(draft.body, to: draft.to)
                isRewriting = false
            }
        }
    }

    private func send() {
        var outgoing = draft
        if completesCommitment == nil || !completeOn { outgoing.completes = nil }
        store.send(outgoing)
        dismiss()
    }
}

#Preview {
    ComposeSheet(draft: .reply(to: MockThreads.needsYouLaunch[0], body: "On track. You'll have it by 4.", completes: "p-board"))
        .environment(NextWaveStore())
}
