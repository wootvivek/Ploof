import SwiftUI

struct AvatarView: View {
    let person: Person
    var size: CGFloat = 40

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(hue: person.hue, saturation: 0.45, brightness: 0.98),
                        Color(hue: (person.hue + 0.06).truncatingRemainder(dividingBy: 1), saturation: 0.7, brightness: 0.78),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Text(person.initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        AvatarView(person: MockPeople.megan)
        AvatarView(person: MockPeople.patti, size: 56)
        AvatarView(person: MockPeople.teams, size: 32)
    }
}
