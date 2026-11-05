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

    init(
        habits: [HabitModel] = [],
        archivedHabits: [HabitModel] = [],
        entries: [HabitEntry] = []
    ) {
        self.habits = habits
        self.archivedHabits = archivedHabits
        self.entries = entries
    }

    /// A habit's streak, counted from the first day it was logged. No logs means no streak.
    func streak(for habit: HabitModel, now: Date = .now, calendar: Calendar = .current) -> HabitStreak {
        guard let first = entries.filter({ $0.habitID == habit.id }).map(\.date).min() else {
            return HabitStreak(current: 0, best: 0)
        }
        return HabitStreaks.streak(of: habit, entries: entries, from: first, through: now, calendar: calendar)
    }

    /// Adds a new habit to the end of the active list.
    func add(_ habit: HabitModel) {
        habits.append(habit)
    }

    /// Saves an edited habit, matched by its id.
    /// The name, color and icon apply to every day. The goal, step, unit and schedule apply from
    /// `date` onwards, so earlier days are still judged by the rules they had. The type is locked,
    /// and the logs are not touched.
    func update(_ edited: HabitModel, from date: Date = .now, calendar: Calendar = .current) {
        guard let index = habits.firstIndex(where: { $0.id == edited.id }) else { return }
        var habit = habits[index]
        habit.name = edited.name
        habit.symbol = edited.symbol
        habit.colorName = edited.colorName
        habits[index] = habit.changing(to: edited.currentRule, from: date, calendar: calendar)
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
