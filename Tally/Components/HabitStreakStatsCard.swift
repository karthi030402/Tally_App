import SwiftUI

/// The current streak and the best streak, side by side.
struct HabitStreakStatsCard: View {
    let currentText: String
    let bestText: String

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: 16) {
                stat(title: "CURRENT STREAK", value: currentText, symbol: "flame.fill", tint: .orange)
                Divider()
                stat(title: "BEST STREAK", value: bestText, symbol: "star.fill", tint: CompletionPalette.daybreak.best)
            }
        }
    }

    private func stat(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HabitStreakStatsCard(currentText: "4 days", bestText: "20 days")
        .padding()
        .background { DawnBackground() }
}
