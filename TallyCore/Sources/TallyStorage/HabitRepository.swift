import Foundation
import TallyCore

/// Where habits and their logs are kept. The store talks to this, so it doesn't care whether the
/// data lives in SwiftData, or only in memory for previews and tests.
@MainActor
public protocol HabitRepository {
    /// Every habit, active and archived, in the order they were added.
    func loadHabits() throws -> [HabitModel]
    /// One habit by id, or nil if there is none. Cheaper than `loadHabits()` when only one is needed.
    func loadHabit(id: UUID) throws -> HabitModel?
    /// Every log, oldest first.
    func loadEntries() throws -> [HabitEntry]
    /// One habit's logs on the day of `date`, oldest first. Cheaper than `loadEntries()` when
    /// only that day matters, such as logging from a widget.
    func loadEntries(forHabit habitID: UUID, on date: Date, calendar: Calendar) throws -> [HabitEntry]
    /// Adds a new habit at the end of the list, or updates the one with the same id.
    func save(_ habit: HabitModel) throws
    /// Removes a habit and every log it has.
    func deleteHabit(id: UUID) throws
    func add(_ entry: HabitEntry) throws
    /// Adds many logs with a single save, for seeding or importing.
    func add(contentsOf entries: [HabitEntry]) throws
    func deleteEntries(ids: [UUID]) throws
}

public extension HabitRepository {
    /// Loads every habit and picks one. Repositories with a real query override this.
    func loadHabit(id: UUID) throws -> HabitModel? {
        try loadHabits().first { $0.id == id }
    }

    /// Loads every log and keeps the matching ones. Repositories with a real query override this.
    func loadEntries(forHabit habitID: UUID, on date: Date, calendar: Calendar) throws -> [HabitEntry] {
        try loadEntries().filter { $0.habitID == habitID && calendar.isDate($0.date, inSameDayAs: date) }
    }
}
