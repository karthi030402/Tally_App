import SwiftUI
import WidgetKit
import TallyCore

/// The lock screen widgets. They are drawn in the system's tint, so they use
/// no custom colours.
struct LockScreenTodayView: View {
    @Environment(\.widgetFamily) private var family
    let summary: TodaySummary

    var body: some View {
        switch family {
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        default:
            inline
        }
    }

    /// A gauge ring with the done count in the middle.
    private var circular: some View {
        Gauge(value: summary.fraction) {
            Text("Habits")
        } currentValueLabel: {
            Text("\(summary.doneCount)")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    /// A title, a progress bar and the next unfinished habit.
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Today \(summary.doneCount)/\(summary.dueCount)")
                .font(.headline)
            ProgressView(value: summary.fraction)
            Text(detail)
                .font(.caption)
                .lineLimit(1)
        }
    }

    private var inline: some View {
        Label("\(summary.doneCount)/\(summary.dueCount) habits done", systemImage: "checkmark.circle")
    }

    /// The first unfinished habit (rows are sorted unfinished first).
    private var detail: String {
        if summary.rows.isEmpty { return "Nothing due today" }
        guard let next = summary.rows.first, !next.progress.isMet else { return "All done" }
        return next.habit.name
    }
}
