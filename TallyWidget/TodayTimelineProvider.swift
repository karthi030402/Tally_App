import WidgetKit
import TallyCore
import TallyStorage

/// Reads the shared database and hands WidgetKit one entry for today. It asks to be refreshed at
/// midnight, when "today" changes. The app asks for earlier refreshes after it logs something.
struct TodayTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, summary: TodaySummary(habits: [], entries: [], on: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
		if context.isPreview {
			completion(TodayEntry(date: .now, summary: TodaySummary(habits: [], entries: [], on: .now)))      // instant, realistic fake data
			return
		}
		Task { @MainActor in
			completion(Self.currentEntry())
		}
	}

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        Task { @MainActor in
            let entry = Self.currentEntry()
            let midnight = Calendar.current.startOfDay(for: entry.date.addingTimeInterval(86_400))
            completion(Timeline(entries: [entry], policy: .after(midnight)))
        }
    }

    /// An unreadable database shows as "nothing due" rather than breaking the widget.
    @MainActor
    private static func currentEntry() -> TodayEntry {
        let now = Date.now
        do {
            let repository = SwiftDataHabitRepository(container: try WidgetContainer.shared())
            let summary = TodaySummary(habits: try repository.loadHabits(), entries: try repository.loadEntries(), on: now)
            return TodayEntry(date: now, summary: summary)
        } catch {
            return TodayEntry(date: now, summary: TodaySummary(habits: [], entries: [], on: now))
        }
    }
}
