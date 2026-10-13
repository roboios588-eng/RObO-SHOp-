
import SwiftUI

// Add the official admin contact details here.
// Leave a value empty until you have the correct contact information.
enum RoboSupportConfiguration {
    static let adminEmail = ""
    // International digits only, e.g. 923001234567
    static let adminWhatsAppNumber = ""
}

struct SupportView: View {
    private var emailURL: URL? {
        let value = RoboSupportConfiguration.adminEmail
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty,
              value.contains("@"),
              let encoded = value.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
              ) else {
            return nil
        }

        return URL(string: "mailto:\(encoded)")
    }

    private var whatsappURL: URL? {
        let digits = RoboSupportConfiguration.adminWhatsAppNumber
            .filter(\.isNumber)

        guard !digits.isEmpty else { return nil }
        return URL(string: "https://wa.me/\(digits)")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "headset")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Admin Support")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Help with your account, orders and payments.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .background(RoboTheme.navy)
                .clipShape(RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Contact the admin")
                        .font(.title3.bold())
                        .foregroundStyle(RoboTheme.text)

                    supportLink(
                        title: "Email Support",
                        subtitle: emailURL == nil
                            ? "Admin email has not been configured"
                            : RoboSupportConfiguration.adminEmail,
                        symbol: "envelope.fill",
                        url: emailURL
                    )

                    Divider()

                    supportLink(
                        title: "WhatsApp Support",
                        subtitle: whatsappURL == nil
                            ? "Admin WhatsApp number has not been configured"
                            : "Open a chat with the admin",
                        symbol: "message.fill",
                        url: whatsappURL
                    )
                }
                .padding(18)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Common help")
                        .font(.title3.bold())
                        .foregroundStyle(RoboTheme.text)

                    helpRow(
                        "Orders",
                        "Open the Orders tab to review your order and payment status.",
                        symbol: "shippingbox"
                    )

                    Divider()

                    helpRow(
                        "Payment proof",
                        "Open an order and submit the transaction reference and payment screenshot if requested.",
                        symbol: "doc.text.image"
                    )

                    Divider()

                    helpRow(
                        "Login or password",
                        "Use your registered username or email and password. Password reset requires a working backend reset endpoint.",
                        symbol: "lock.shield"
                    )
                }
                .padding(18)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("Configure the official admin email or WhatsApp number in SupportView.swift to activate the contact links.")
                    .font(.caption)
                    .foregroundStyle(RoboTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(RoboTheme.background.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func supportLink(
        title: String,
        subtitle: String,
        symbol: String,
        url: URL?
    ) -> some View {
        if let url {
            Link(destination: url) {
                supportLinkLabel(
                    title: title,
                    subtitle: subtitle,
                    symbol: symbol,
                    enabled: true
                )
            }
        } else {
            supportLinkLabel(
                title: title,
                subtitle: subtitle,
                symbol: symbol,
                enabled: false
            )
        }
    }

    private func supportLinkLabel(
        title: String,
        subtitle: String,
        symbol: String,
        enabled: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(RoboTheme.blue)
                .frame(width: 42, height: 42)
                .background(RoboTheme.paleBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(RoboTheme.text)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(RoboTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: enabled ? "arrow.up.right" : "minus.circle")
                .foregroundStyle(RoboTheme.secondaryText)
        }
        .padding(.vertical, 5)
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
    }
}
