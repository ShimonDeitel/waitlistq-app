import SwiftUI

/// Salon Queue Teal — the unique palette for Waitlist - Booking Queue.
enum Theme {
    static let accent = Color(red: 0.169, green: 0.549, blue: 0.510)
    static let accentDark = Color(red: 0.012, green: 0.392, blue: 0.353)
    static let background = Color(uiColor: .systemBackground)
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
}
