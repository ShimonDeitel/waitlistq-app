import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
            Text("WaitlistBookingQueue Pro")
                .font(Theme.titleFont)
            Text("Multiple waitlists and one-tap notify-next")
                .font(Theme.bodyFont)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 32)

            if let product = purchases.product {
                Button(action: {
                    Task {
                        isPurchasing = true
                        await purchases.purchase()
                        isPurchasing = false
                        if purchases.isPurchased { dismiss() }
                    }
                }) {
                    Text(isPurchasing ? "Processing..." : "Unlock for \(product.displayPrice)")
                        .font(Theme.bodyFont.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
                .accessibilityIdentifier("paywallPurchaseButton")
                .padding(.horizontal, 32)
                .disabled(isPurchasing)
            } else {
                ProgressView()
            }

            Button("Restore Purchases") {
                Task { await purchases.restore() }
            }
            .font(Theme.captionFont)

            Button("Not Now") {
                dismiss()
            }
            .accessibilityIdentifier("paywallDismissButton")
            .font(Theme.captionFont)
            .foregroundStyle(Theme.textSecondary)

            Spacer()
        }
        .padding()
    }
}
