
import SwiftUI

enum RoboSupportConfiguration {
    static let telegramUsername = "robomods"
    static let telegramURL = URL(string: "https://t.me/robomods")!

    // International format, digits only. Do not include + or spaces.
    static let adminWhatsAppNumber = "923062768314"
    static let whatsappURL = URL(string: "https://wa.me/923062768314")!
}

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "headset")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Admin Support")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Need help with your account, orders or payments? Contact our admin.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .background(RoboTheme.navy)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                // Admin contact buttons
                VStack(alignment: .leading, spacing: 14) {
                    Text("Contact the Admin")
                        .font(.title3.bold())
                        .foregroundStyle(RoboTheme.text)

                    Link(destination: RoboSupportConfiguration.telegramURL) {
                        contactRow(
                            title: "Telegram Support",
                            subtitle: "@\(RoboSupportConfiguration.telegramUsername)",
                            symbol: "paperplane.fill"
                        )
                    }

                    Divider()

                    Link(destination: RoboSupportConfiguration.whatsappURL) {
                        contactRow(
                            title: "WhatsApp Support",
                            subtitle: "+\(RoboSupportConfiguration.adminWhatsAppNumber)",
                            symbol: "message.fill"
                        )
                    }

                    Text("Tap a contact option to open the relevant app or website.")
                        .font(.caption)
                        .foregroundStyle(RoboTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Common help
                VStack(alignment: .leading, spacing: 14) {
                    Text("Common Help")
                        .font(.title3.bold())
                        .foregroundStyle(RoboTheme.text)

                    helpRow(
                        "Orders",
                        "Open the Orders tab to review your orders and their current status.",
                        symbol: "shippingbox"
                    )

                    Divider()

                    helpRow(
                        "Payment Proof",
                        "Open your order and submit the transaction reference and payment screenshot when requested.",
                        symbol: "doc.text.image"
                    )

                    Divider()

                    helpRow(
                        "Login or Password",
                        "If you cannot access your account, contact the admin through Telegram or WhatsApp.",
                        symbol: "lock.shield"
                    )
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("ROBO SHOP · Admin Support")
                    .font(.caption)
                    .foregroundStyle(RoboTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoboTheme.background.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func contactRow(
        title: String,
        subtitle: String,
        symbol: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(RoboTheme.blue)
                .frame(width: 44, height: 44)
                .background(RoboTheme.paleBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(RoboTheme.text)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(RoboTheme.secondaryText)
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.up.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RoboTheme.blue)
        }
        .contentShape(Rectangle())
    }

    private func helpRow(
        _ title: String,
        _ detail: String,
        symbol: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(RoboTheme.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(RoboTheme.text)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(RoboTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
