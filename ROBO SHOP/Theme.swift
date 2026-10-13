
import SwiftUI

enum RoboTheme {
    static let navy = Color(red: 0.035, green: 0.075, blue: 0.16)
    static let blue = Color(red: 0.10, green: 0.38, blue: 0.95)
    static let background = Color(red: 0.96, green: 0.975, blue: 0.995)
    static let paleBlue = Color(red: 0.90, green: 0.94, blue: 1.00)
    static let text = Color(red: 0.10, green: 0.14, blue: 0.22)
    static let secondaryText = Color(red: 0.43, green: 0.48, blue: 0.57)
    static let card = Color.white
    static let success = Color(red: 0.08, green: 0.55, blue: 0.34)
    static let danger = Color(red: 0.80, green: 0.18, blue: 0.22)
}

struct RoboPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoboTheme.blue.opacity(configuration.isPressed ? 0.75 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
