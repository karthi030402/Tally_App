import Testing
import Foundation
import TallyCore
import TallyStorage
@testable import Tally

@MainActor
struct StoreSetupTests {
    /// A throwaway UserDefaults, so tests never touch the app's real settings.
    private func makeDefaults() -> UserDefaults {
        let name = "tally-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func anEmptyRepositoryIsFilledWithTheSampleData() throws {
        let repository = InMemoryHabitRepository()
        try StoreSetup.seedSampleData(into: repository, defaults: makeDefaults())
        let habits = try repository.loadHabits()
        #expect(habits.count == 5)
        #expect(habits.filter(\.isArchived).map(\.name) == ["Meditation"])
        #expect(try repository.loadEntries().count > 100)
    }

    @Test func seedingHappensOnlyOnce() throws {
        let repository = InMemoryHabitRepository()
        let defaults = makeDefaults()
        try StoreSetup.seedSampleData(into: repository, defaults: defaults)
        let firstCount = try repository.loadEntries().count
        try repository.deleteHabit(id: try #require(try repository.loadHabits().first).id)
        try StoreSetup.seedSampleData(into: repository, defaults: defaults)
        #expect(try repository.loadHabits().count == 4)
        #expect(try repository.loadEntries().count <= firstCount)
    }

    @Test func aRepositoryThatAlreadyHasHabitsIsLeftAlone() throws {
        let mine = HabitModel(name: "Mine", colorName: "gold", kind: .checkOff)
        let repository = InMemoryHabitRepository(habits: [mine])
        try StoreSetup.seedSampleData(into: repository, defaults: makeDefaults())
        #expect(try repository.loadHabits() == [mine])
    }
}
