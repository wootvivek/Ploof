import SwiftUI

struct AskView: View {
    @Environment(PloofStore.self) private var store
    @State private var query = ""
    @State private var answer: AskAnswer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let answer {
                        AnswerCard(answer: answer)
                        let matches = store.search(answer.question)
                            .filter { !answer.citations.contains($0.id) }
                            .prefix(5)
                        if !matches.isEmpty {
                            Text("Related emails")
                                .font(.headline)
                                .padding(.top, 4)
                            VStack(spacing: 0) {
                                ForEach(Array(matches)) { thread in
                                    NavigationLink(value: ThreadRoute(id: thread.id)) {
                                        ThreadRow(thread: thread, compact: true)
                                            .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)
                                    if thread.id != matches.last?.id { Divider() }
                                }
                            }
                            .padding(.horizontal, 14)
                            .glassEffect(.regular, in: .rect(cornerRadius: Theme.cardRadius))
                        }
                    } else {
                        intro
                    }
                }
                .padding(16)
            }
            .background(PloofBackground())
            .navigationTitle("Ask Ploof")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Ask anything about your mail")
            .onSubmit(of: .search) { ask(query) }
            .onChange(of: query) { _, new in
                if new.isEmpty { withAnimation(.snappy) { answer = nil } }
            }
            .navigationDestination(for: ThreadRoute.self) { ThreadView(threadID: $0.id) }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text("Ask your inbox anything.")
                    .font(.title2.weight(.bold))
                Text("Ploof answers from your mail and your promises, and shows where every answer came from.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 6)

            Text("Try")
                .font(.headline)
            GlassEffectContainer(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(MockAsk.suggestions, id: \.self) { suggestion in
                        Button {
                            query = suggestion
                            ask(suggestion)
                        } label: {
                            Label(suggestion, systemImage: "arrow.up.right")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.large)
                    }
                }
            }
        }
    }

    private func ask(_ question: String) {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation(.snappy) { answer = MockAsk.answer(for: trimmed) }
    }
}

private struct AnswerCard: View {
    let answer: AskAnswer
    @Environment(PloofStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ploof", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.tint)
            Text(answer.question)
                .font(.headline)
            StreamingText(text: answer.text)
                .id(answer.id)

            if !answer.citations.isEmpty {
                Text("Sources")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.top, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(answer.citations, id: \.self) { id in
                            if let thread = store.thread(id) {
                                NavigationLink(value: ThreadRoute(id: id)) {
                                    Label(thread.subject, systemImage: "envelope")
                                        .lineLimit(1)
                                        .font(.footnote.weight(.semibold))
                                }
                                .buttonStyle(.glass)
                            }
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
    }
}

/// Reveals text word by word, like a model streaming its answer.
private struct StreamingText: View {
    let text: String
    @State private var shown = ""
    @State private var done = false

    var body: some View {
        Text(done ? shown : shown + " ▍")
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .task {
                let words = text.split(separator: " ")
                for word in words {
                    shown += (shown.isEmpty ? "" : " ") + word
                    try? await Task.sleep(for: .milliseconds(32))
                }
                done = true
            }
    }
}

#Preview {
    AskView()
        .environment(PloofStore())
}
