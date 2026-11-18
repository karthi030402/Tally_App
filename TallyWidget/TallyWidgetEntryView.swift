import SwiftUI
import WidgetKit
import TallyCore

/// Picks the layout for the widget's size. A tap anywhere opens the Today tab,
/// except on a habit in the medium widget, which opens that habit.
struct TallyWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayEntry

    var body: some View {
        layout
            .widgetURL(DeepLink.today.url)
    }

    @ViewBuilder
    private var layout: some View {
        switch family {
        case .systemMedium:
            MediumTodayView(summary: entry.summary)
        case .systemLarge:
            LargeTodayView(summary: entry.summary)
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            LockScreenTodayView(summary: entry.summary)
        default:
            SmallTodayView(summary: entry.summary)
        }
    }
}
