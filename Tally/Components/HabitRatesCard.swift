import SwiftUI

/// The completion rates for a habit, and how much of it has been logged in all.
struct HabitRatesCard: View {
    let summaries: [HabitRateSummary]
    let totalText: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Completion")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                ForEach(summaries) { summary in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.title).font(.subheadline.weight(.medium))
                            Text(summary.detail).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(summary.percentText)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                    }
                    .accessibilityElement(children: .combine)
                }

                Divider()

                HStack {
                    Text("Total logged").font(.subheadline.weight(.medium))
                    Spacer()
                    Text(totalText).font(.subheadline).foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#Preview {
    HabitRatesCard(
        summaries: [
            HabitRateSummary(title: "Last 7 days", percentText: "86%", detail: "6 of 7 due days"),
            HabitRateSummary(title: "Last 30 days", percentText: "73%", detail: "22 of 30 due days"),
            HabitRateSummary(title: "All time", percentText: "69%", detail: "58 of 84 due days")
        ],
        totalText: "62500 ml"
    )
    .padding()
    .background { DawnBackground() }
}
