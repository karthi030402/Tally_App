import Foundation
import Observation
import TallyCore

/// Drives the Habits tab: holds the habits and turns them into the text the cards show.
/// No SwiftUI here, so it stays easy to unit test.
@MainActor
@Observable
final class HabitsViewModel {
    private let store: HabitStore

    init(store: HabitStore) {
        self.store = store
    }

    var habits: [HabitModel] { store.habits }
    var archivedHabits: [HabitModel] { store.archivedHabits }

    func add(_ habit: HabitModel) {
        store.add(habit)
    }

    // MARK: - Card text

    /// "Check-off · Daily" or "Goal 2500 ml · Mon Wed Fri".
    func detailText(for habit: HabitModel) -> String {
        let kind: String
        switch habit.kind {
        case .checkOff:
            kind = "Check-off"
        case .counter:
            // "Goal 2500 ml", "Goal 20 pages". Missing parts are simply left out.
            let amount = habit.target?.habitAmountText
            kind = ["Goal", amount, habit.unit].compactMap { $0 }.joined(separator: " ")
        }
        return "\(kind) · \(scheduleText(for: habit))"
    }

    /// "Daily", or the due weekdays in Monday-first order, such as "Mon Wed Fri".
    func scheduleText(for habit: HabitModel) -> String {
        guard !habit.isEveryDay else { return "Daily" }
        let symbols = Calendar.current.shortWeekdaySymbols // index 0 is Sunday
        // allCases is declared Monday-first, which is the display order.
        return HabitWeekday.allCases
            .filter { habit.weekdays.contains($0) }
            .map { symbols[$0.rawValue - 1] }
            .joined(separator: " ")
    }

    func streak(for habit: HabitModel) -> Int {
        store.streaks[habit.id] ?? 0
    }

    func streakText(for habit: HabitModel) -> String {
        "\(streak(for: habit)) day streak"
    }
}
