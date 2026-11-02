import SwiftUI

/// The "This week" card: date range, the big percentage, and what it is made of.
struct WeeklyReportCard: View {
    let rangeText: String
    let percentText: String
    let caption: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("This week").font(.headline)
                    Spacer()
                    Text(rangeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(percentText)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text(caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WeeklyReportCard(rangeText: "Oct 26 – Nov 1", percentText: "83%", caption: "15 of 18 scheduled days met")
        .padding()
        .background { DawnBackground() }
}
