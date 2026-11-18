import WidgetKit
import TallyCore

/// One snapshot of the widget: the date it was made for and today's summary.
struct TodayEntry: TimelineEntry {
    let date: Date
    let summary: TodaySummary
}
