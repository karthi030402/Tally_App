import Foundation
import Observation
import os
import TallyCore
import TallyStorage
import WidgetKit

/// The source of truth for habits and their logs, shared by every tab. It keeps them in memory so
/// the screens and the Insights math stay fast, and writes every change through to a repository.
@MainActor
@Observable
final class HabitStore {
    /// Every habit, active and archived. Insights count an archived habit's past days, so the
    /// calculations use this list. Screens that list habits use `habits` and `archivedHabits`.
    private(set) var allHabits: [HabitModel] = []
    private(set) var entries: [HabitEntry] = []
    /// The most recent failed read or write, or nil. The change itself stays in memory.
    private(set) var lastError: (any Error)?

    private let repository: any HabitRepository
    private static let logger = Logger(subsystem: "com.sathappan.dev.Tally", category: "HabitStore")

    /// A store backed by `repository`, filled with what it already holds.
    init(repository: any HabitRepository) {
        self.repository = repository
        reload()
    }

    /// A store that keeps everything in memory, for previews and tests.
    /// Habits passed as archived are archived from the very beginning, so they were never due.
    convenience init(
        habits: [HabitModel] = [],
        archivedHabits: [HabitModel] = [],
        entries: [HabitEntry] = []
    ) {
        let all = habits + archivedHabits.map { $0.isArchived ? $0 : $0.archiving(from: .distantPast) }
        self.init(repository: InMemoryHabitRepository(habits: all, entries: entries))
    }

    /// Reads every habit and log from the repository again.
    func reload() {
        persist(refreshingWidgets: false) {
            allHabits = try repository.loadHabits()
            entries = try repository.loadEntries()
        }
    }

    /// Runs a read or write on the repository. A failure is logged and kept in `lastError`.
    /// The change that was already made in memory is left in place.
    /// After a write succeeds, the widgets are asked to refresh so they match the app.
    private func persist(refreshingWidgets: Bool = true, _ work: () throws -> Void) {
        do {
            try work()
            if refreshingWidgets {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            lastError = error
            Self.logger.error("Repository failure: \(error.localizedDescription)")
        }
    }

    /// The active habits, in the order they were added.
    var habits: [HabitModel] { allHabits.filter { !$0.isArchived } }

    /// The archived habits, in the order they were added.
    var archivedHabits: [HabitModel] { allHabits.filter(\.isArchived) }

    /// A habit's streak, counted from the first day it was logged. No logs means no streak.
    func streak(for habit: HabitModel, now: Date = .now, calendar: Calendar = .current) -> HabitStreak {
        guard let first = entries.filter({ $0.habitID == habit.id }).map(\.date).min() else {
            return HabitStreak(current: 0, best: 0)
        }
        return HabitStreaks.streak(of: habit, entries: entries, from: first, through: now, calendar: calendar)
    }

    /// Adds a new habit to the end of the active list.
    func add(_ habit: HabitModel) {
        allHabits.append(habit)
        persist { try repository.save(habit) }
    }

    /// Saves an edited habit, matched by its id.
    /// The name, color and icon apply to every day. The goal, step, unit and schedule apply from
    /// `date` onwards, so earlier days are still judged by the rules they had. The type is locked,
    /// and the logs are not touched. Only active habits can be edited, and an edit never changes
    /// whether a habit is archived.
    func update(_ edited: HabitModel, from date: Date = .now, calendar: Calendar = .current) {
        guard let index = allHabits.firstIndex(where: { $0.id == edited.id && !$0.isArchived }) else { return }
        var habit = allHabits[index]
        habit.name = edited.name
        habit.symbol = edited.symbol
        habit.colorName = edited.colorName
        let rule = edited.currentRule.settingActive(habit.currentRule.isActive)
        let updated = habit.changing(to: rule, from: date, calendar: calendar)
        allHabits[index] = updated
        persist { try repository.save(updated) }
    }

    /// Archives a habit from `date` onwards. Its logs stay, and earlier days still count it.
    func archive(_ habit: HabitModel, from date: Date = .now, calendar: Calendar = .current) {
        replace(habit) { $0.archiving(from: date, calendar: calendar) }
    }

    /// Brings an archived habit back from `date` onwards. The days it was archived stay not-due.
    func unarchive(_ habit: HabitModel, from date: Date = .now, calendar: Calendar = .current) {
        replace(habit) { $0.restoring(from: date, calendar: calendar) }
    }

    /// Permanently removes a habit and all of its logs.
    func delete(_ habit: HabitModel) {
        allHabits.removeAll { $0.id == habit.id }
        entries.removeAll { $0.habitID == habit.id }
        persist { try repository.deleteHabit(id: habit.id) }
    }

    /// How many logs a habit has, for the delete confirmation.
    func logCount(for habit: HabitModel) -> Int {
        entries.filter { $0.habitID == habit.id }.count
    }

    private func replace(_ habit: HabitModel, with change: (HabitModel) -> HabitModel) {
        guard let index = allHabits.firstIndex(where: { $0.id == habit.id }) else { return }
        let updated = change(allHabits[index])
        allHabits[index] = updated
        persist { try repository.save(updated) }
    }

    /// Records one tap for a habit, or a custom `amount`.
    func log(_ habit: HabitModel, amount: Double? = nil, at date: Date = .now) {
        let entry = HabitEntry(habitID: habit.id, date: date, amount: amount ?? habit.tapAmount)
        entries.append(entry)
        persist { try repository.add(entry) }
    }

    /// Removes the most recent entry for a habit on the day of `date`.
    func undoLast(for habit: HabitModel, on date: Date = .now, calendar: Calendar = .current) {
        guard let index = entries.lastIndex(where: {
            $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: date)
        }) else { return }
        let removed = entries.remove(at: index)
        persist { try repository.deleteEntries(ids: [removed.id]) }
    }

    /// Removes every entry for a habit on the day of `date`, such as un-checking a check-off habit.
    func clear(_ habit: HabitModel, on date: Date = .now, calendar: Calendar = .current) {
        let removed = entries.filter { $0.habitID == habit.id && calendar.isDate($0.date, inSameDayAs: date) }
        guard !removed.isEmpty else { return }
        entries.removeAll { entry in removed.contains { $0.id == entry.id } }
        persist { try repository.deleteEntries(ids: removed.map(\.id)) }
    }
}
