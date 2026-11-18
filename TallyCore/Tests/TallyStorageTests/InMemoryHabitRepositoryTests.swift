import Testing
import Foundation
import TallyCore
@testable import TallyStorage

@MainActor
struct InMemoryHabitRepositoryTests {
    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)

    @Test func savingAddsThenUpdates() throws {
        let repository = InMemoryHabitRepository()
        try repository.save(water)
        try repository.save(vitamins)
        var renamed = water
        renamed.name = "Hydration"
        try repository.save(renamed)
        #expect(try repository.loadHabits().map(\.name) == ["Hydration", "Vitamins"])
    }

    @Test func loadingOneHabitsDayReturnsOnlyThoseLogs() throws {
        let calendar = Calendar(identifier: .gregorian)
        let noon = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 12)) ?? .distantPast
        let yesterday = calendar.date(byAdding: .day, value: -1, to: noon) ?? .distantPast
        let repository = InMemoryHabitRepository(
            habits: [water, vitamins],
            entries: [
                HabitEntry(habitID: water.id, date: noon, amount: 250),
                HabitEntry(habitID: water.id, date: yesterday, amount: 500),
                HabitEntry(habitID: vitamins.id, date: noon, amount: 1)
            ]
        )
        let entries = try repository.loadEntries(forHabit: water.id, on: noon, calendar: calendar)
        #expect(entries.map(\.amount) == [250])
    }

    @Test func deletingAHabitRemovesItsLogs() throws {
        let repository = InMemoryHabitRepository(
            habits: [water, vitamins],
            entries: [
                HabitEntry(habitID: water.id, date: .now, amount: 250),
                HabitEntry(habitID: vitamins.id, date: .now, amount: 1)
            ]
        )
        try repository.deleteHabit(id: water.id)
        #expect(try repository.loadHabits().map(\.name) == ["Vitamins"])
        #expect(try repository.loadEntries().map(\.habitID) == [vitamins.id])
    }
}
