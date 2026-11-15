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
