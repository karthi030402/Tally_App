import SwiftUI
import TallyCore

/// The medium widget: today's count, then up to four habits in two columns.
struct MediumTodayView: View {
    let summary: TodaySummary

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Today").font(.headline)
                Spacer()
                if !summary.rows.isEmpty {
                    Text("\(summary.doneCount) of \(summary.dueCount) done")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if summary.rows.isEmpty {
                Spacer()
                Text("Nothing due today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                    ForEach(summary.rows.prefix(4)) { row in
                        cell(for: row)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    /// A tap on a habit opens its page in the app.
    @ViewBuilder
    private func cell(for row: TodaySummary.Row) -> some View {
        if let url = DeepLink.habit(row.habit.id).url {
            Link(destination: url) { HabitWidgetCell(row: row) }
        } else {
            HabitWidgetCell(row: row)
        }
    }
}
