import Foundation
import SwiftData
import TallyCore

/// The repository that keeps habits and logs in a SwiftData database on disk.
@MainActor
public final class SwiftDataHabitRepository: HabitRepository {
    /// Held so the context stays valid for as long as this repository lives.
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    public init(container: ModelContainer) {
        self.container = container
    }

    public func loadHabits() throws -> [HabitModel] {
        let descriptor = FetchDescriptor<HabitRecord>(sortBy: [SortDescriptor(\.sortIndex)])
        return try context.fetch(descriptor).compactMap { $0.habit() }
    }

    public func loadHabit(id: UUID) throws -> HabitModel? {
        var descriptor = FetchDescriptor<HabitRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.habit()
    }

    public func loadEntries() throws -> [HabitEntry] {
        let descriptor = FetchDescriptor<EntryRecord>(sortBy: [SortDescriptor(\.date)])
        return try context.fetch(descriptor).map(\.entry)
    }

    public func loadEntries(forHabit habitID: UUID, on date: Date, calendar: Calendar) throws -> [HabitEntry] {
        guard let day = calendar.dateInterval(of: .day, for: date) else { return [] }
        let start = day.start
        let end = day.end
        let descriptor = FetchDescriptor<EntryRecord>(
            predicate: #Predicate { $0.habitID == habitID && $0.date >= start && $0.date < end },
            sortBy: [SortDescriptor(\.date)]
        )
        return try context.fetch(descriptor).map(\.entry)
    }

    public func save(_ habit: HabitModel) throws {
        let id = habit.id
        var existing = FetchDescriptor<HabitRecord>(predicate: #Predicate { $0.id == id })
        existing.fetchLimit = 1
        if let record = try context.fetch(existing).first {
            record.apply(habit)
        } else {
            var last = FetchDescriptor<HabitRecord>(sortBy: [SortDescriptor(\.sortIndex, order: .reverse)])
            last.fetchLimit = 1
            let next = (try context.fetch(last).first?.sortIndex ?? -1) + 1
            context.insert(HabitRecord(habit: habit, sortIndex: next))
        }
        try context.save()
    }

    public func deleteHabit(id: UUID) throws {
        try context.delete(model: HabitRecord.self, where: #Predicate { $0.id == id })
        try context.delete(model: EntryRecord.self, where: #Predicate { $0.habitID == id })
        try context.save()
    }

    public func add(_ entry: HabitEntry) throws {
        context.insert(EntryRecord(entry))
        try context.save()
    }

    public func add(contentsOf entries: [HabitEntry]) throws {
        for entry in entries {
            context.insert(EntryRecord(entry))
        }
        try context.save()
    }

    public func deleteEntries(ids: [UUID]) throws {
        try context.delete(model: EntryRecord.self, where: #Predicate { ids.contains($0.id) })
        try context.save()
    }
}
