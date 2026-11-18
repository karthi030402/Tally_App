import AppIntents
import SwiftUI
import TallyCore

/// The large widget: today's count, then up to six habits, each with a button that logs it.
struct LargeTodayView: View {
    let summary: TodaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                ForEach(summary.rows.prefix(6)) { row in
                    HStack {
                        cell(for: row)
                        Button(intent: LogHabitIntent(habitID: row.habit.id)) {
                            Image(systemName: icon(for: row))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(row.habit.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    /// A tap on the habit opens its page in the app.
    @ViewBuilder
    private func cell(for row: TodaySummary.Row) -> some View {
        if let url = DeepLink.habit(row.habit.id).url {
            Link(destination: url) { HabitWidgetCell(row: row) }
        } else {
            HabitWidgetCell(row: row)
        }
    }

    /// A check-off habit shows a check or an empty circle, and a goal habit shows a plus.
    private func icon(for row: TodaySummary.Row) -> String {
        switch row.habit.kind {
        case .checkOff: row.progress.isMet ? "checkmark.circle.fill" : "circle"
        case .counter: "plus.circle.fill"
        }
    }
}
