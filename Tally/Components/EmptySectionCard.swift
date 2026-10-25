import SwiftUI

/// A fixed-height placeholder shown in place of a section's cards when it has nothing to show.
struct EmptySectionCard: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1))
            }
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    EmptySectionCard(message: "No data available")
        .padding()
        .background { DawnBackground() }
}
