import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private struct Page {
        let symbol: String
        let title: String
        let body: String
    }

    private let pages = [
        Page(symbol: "sparkles",
             title: "Mail that leads with what matters",
             body: "Ploof reads your inbox and shows what needs you first, so you don't have to dig."),
        Page(symbol: "checkmark.seal",
             title: "Every promise, kept",
             body: "Ploof finds what you owe and what you're owed inside your email. Settle them with a swipe."),
        Page(symbol: "bubble.left.and.text.bubble.right",
             title: "Ask your inbox anything",
             body: "When's my flight? What did Sam say? Just ask, and Ploof shows its sources."),
    ]

    var body: some View {
        ZStack {
            PloofBackground()

            VStack(spacing: 20) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        panel(pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Group {
                    if page == pages.count - 1 {
                        Button(action: onFinish) {
                            Label("Sign in with Microsoft", systemImage: "person.crop.circle.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                            withAnimation(.snappy) { page += 1 }
                        } label: {
                            Text("Next")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glass)
                    }
                }
                .controlSize(.extraLarge)
                .padding(.horizontal, 24)

                Text("Works with Outlook.com, Hotmail and Live accounts")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
        }
    }

    private func panel(_ page: Page) -> some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: page.symbol)
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 150, height: 150)
                .glassEffect(.regular.interactive(), in: .circle)
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                Text(page.body)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView {}
}
