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

    /// The active habit with this id, or nil if it is no longer there.
    func habit(id: UUID) -> HabitModel? {
        store.habits.first { $0.id == id }
    }

    /// Saves an edit. The name, color and icon apply to every day, and the goal and schedule
    /// apply from today.
    func update(_ habit: HabitModel) {
        store.update(habit)
    }

    /// Archives a habit from today. Its past days and logs stay.
    func archive(_ habit: HabitModel) {
        store.archive(habit)
    }

    /// Brings an archived habit back from today.
    func unarchive(_ habit: HabitModel) {
        store.unarchive(habit)
    }

    /// Permanently removes a habit and its logs.
    func delete(_ habit: HabitModel) {
        store.delete(habit)
    }

    /// The delete confirmation text, saying how many logs will go.
    func deleteMessage(for habit: HabitModel) -> String {
        HabitDeleteMessage.text(logCount: store.logCount(for: habit))
    }

    // MARK: - Card text

    /// "Check-off · Daily" or "Goal 2500 ml · Mon Wed Fri".
    func detailText(for habit: HabitModel) -> String {
        habit.detailText
    }

    /// "Daily", or the due weekdays in Monday-first order, such as "Mon Wed Fri".
    func scheduleText(for habit: HabitModel) -> String {
        habit.scheduleText
    }

    func streak(for habit: HabitModel) -> Int {
        store.streak(for: habit).current
    }

    func streakText(for habit: HabitModel) -> String {
        "\(streak(for: habit)) day streak"
    }
}
