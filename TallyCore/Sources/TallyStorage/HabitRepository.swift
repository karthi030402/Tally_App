import Foundation
import TallyCore

/// Where habits and their logs are kept. The store talks to this, so it doesn't care whether the
/// data lives in SwiftData, or only in memory for previews and tests.
@MainActor
public protocol HabitRepository {
    /// Every habit, active and archived, in the order they were added.
    func loadHabits() throws -> [HabitModel]
    /// Every log, oldest first.
    func loadEntries() throws -> [HabitEntry]
    /// Adds a new habit at the end of the list, or updates the one with the same id.
    func save(_ habit: HabitModel) throws
    /// Removes a habit and every log it has.
    func deleteHabit(id: UUID) throws
    func add(_ entry: HabitEntry) throws
    /// Adds many logs with a single save, for seeding or importing.
    func add(contentsOf entries: [HabitEntry]) throws
    func deleteEntries(ids: [UUID]) throws
}
