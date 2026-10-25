import Foundation
import Observation
import TallyCore

/// The single in-memory source of truth for habits and their logs, shared by every tab.
/// SwiftData will replace the arrays later without changing the code that calls these methods.
@MainActor
@Observable
final class HabitStore {
    private(set) var habits: [HabitModel]
    private(set) var archivedHabits: [HabitModel]
    private(set) var entries: [HabitEntry]
    /// Streak per habit. Placeholder values until the streak engine exists.
    let streaks: [UUID: Int]

    init(
        habits: [HabitModel] = [],
        archivedHabits: [HabitModel] = [],
        entries: [HabitEntry] = [],
        streaks: [UUID: Int] = [:]
    ) {
        self.habits = habits
        self.archivedHabits = archivedHabits
        self.entries = entries
        self.streaks = streaks
    }

    /// Adds a new habit to the end of the active list.
    func add(_ habit: HabitModel) {
        habits.append(habit)
    }

    /// Records one tap for a habit, or a custom `amount`.
    func log(_ habit: HabitModel, amount: Double? = nil, at date: Date = .now) {
        entries.append(HabitEntry(habitID: habit.id, date: date, amount: amount ?? habit.tapAmount))
    }

    /// Removes the most recent entry for a habit on the day of `date`.
    func undoLast(for habit: HabitModel, on date: Date = .now, calendar: Calendar = .current) {
        guard let index = entries.lastIndex(where: {
            $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: date)
        }) else { return }
        entries.remove(at: index)
    }

    /// Removes every entry for a habit on the day of `date`, such as un-checking a check-off habit.
    func clear(_ habit: HabitModel, on date: Date = .now, calendar: Calendar = .current) {
        entries.removeAll { $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: date) }
    }
}
