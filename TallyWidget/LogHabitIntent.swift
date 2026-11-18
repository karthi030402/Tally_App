import AppIntents
import TallyCore
import TallyStorage
import WidgetKit

/// Logs one tap for a habit from the widget, the same way the Today tab does:
/// a goal habit adds one step, a check-off habit toggles between done and not done.
struct LogHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Habit"
    static let isDiscoverable = false

    @Parameter(title: "Habit ID")
    var habitID: String

    init() {}

    init(habitID: UUID) {
        self.habitID = habitID.uuidString
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: habitID) else { return .result() }
        let repository = SwiftDataHabitRepository(container: try WidgetContainer.shared())
        guard let habit = try repository.loadHabit(id: id) else { return .result() }

        let today = Date.now
        let todays = try repository.loadEntries(forHabit: id, on: today, calendar: .current)
        if habit.kind == .checkOff, habit.progress(from: todays, on: today).isMet {
            try repository.deleteEntries(ids: todays.map(\.id))
        } else {
            try repository.add(HabitEntry(habitID: id, date: today, amount: habit.tapAmount))
        }
        WidgetCenter.shared.reloadTimelines(ofKind: TallyWidget.kind)
        return .result()
    }
}
