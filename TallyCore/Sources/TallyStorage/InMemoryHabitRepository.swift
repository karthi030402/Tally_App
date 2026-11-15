import Foundation
import TallyCore

/// A repository that keeps everything in memory and forgets it on exit. For previews and tests.
@MainActor
public final class InMemoryHabitRepository: HabitRepository {
    private var habits: [HabitModel]
    private var entries: [HabitEntry]

    public init(habits: [HabitModel] = [], entries: [HabitEntry] = []) {
        self.habits = habits
        self.entries = entries
    }

    public func loadHabits() throws -> [HabitModel] { habits }

    public func loadEntries() throws -> [HabitEntry] { entries.sorted { $0.date < $1.date } }

    public func save(_ habit: HabitModel) throws {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        } else {
            habits.append(habit)
        }
    }

    public func deleteHabit(id: UUID) throws {
        habits.removeAll { $0.id == id }
        entries.removeAll { $0.habitID == id }
    }

    public func add(_ entry: HabitEntry) throws {
        entries.append(entry)
    }

    public func add(contentsOf newEntries: [HabitEntry]) throws {
        entries.append(contentsOf: newEntries)
    }

    public func deleteEntries(ids: [UUID]) throws {
        entries.removeAll { ids.contains($0.id) }
    }
}
