import Testing
import Foundation
import SwiftData
import TallyCore
@testable import TallyStorage

@MainActor
struct SwiftDataHabitRepositoryTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let water = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday, .friday])
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
    private let reading = HabitModel(name: "Reading", colorName: "orchid", kind: .counter, target: 20, step: 5, unit: "pages")

    private func makeRepository() throws -> SwiftDataHabitRepository {
        SwiftDataHabitRepository(container: try TallyStorage.makeContainer(inMemory: true))
    }

    @Test func aSavedHabitComesBackUnchanged() throws {
        let repository = try makeRepository()
        try repository.save(water)
        #expect(try repository.loadHabits() == [water])
    }

    @Test func dateChangesAndArchivingSurviveSaving() throws {
        let edited = water
            .changing(to: HabitRule(kind: .counter, target: 3000, step: 250, unit: "ml", weekdays: [.monday, .friday]), from: march(11), calendar: calendar)
            .archiving(from: march(15), calendar: calendar)
        let repository = try makeRepository()
        try repository.save(edited)
        let loaded = try #require(try repository.loadHabits().first)
        #expect(loaded == edited)
        #expect(loaded.goalAmount(on: march(10), calendar: calendar) == 2500)
        #expect(loaded.isArchived)
    }

    @Test func savingAgainUpdatesInsteadOfDuplicating() throws {
        let repository = try makeRepository()
        try repository.save(water)
        var renamed = water
        renamed.name = "Hydration"
        try repository.save(renamed)
        let loaded = try repository.loadHabits()
        #expect(loaded.count == 1)
        #expect(loaded.first?.name == "Hydration")
    }

    @Test func habitsComeBackInTheOrderTheyWereAdded() throws {
        let repository = try makeRepository()
        try repository.save(water)
        try repository.save(vitamins)
        try repository.save(reading)
        try repository.deleteHabit(id: vitamins.id)
        let extra = HabitModel(name: "Gym", colorName: "coral", kind: .checkOff)
        try repository.save(extra)
        #expect(try repository.loadHabits().map(\.name) == ["Water", "Reading", "Gym"])
    }

    @Test func logsComeBackOldestFirst() throws {
        let repository = try makeRepository()
        try repository.add(HabitEntry(habitID: water.id, date: march(10), amount: 250))
        try repository.add(HabitEntry(habitID: water.id, date: march(9), amount: 500))
        let entries = try repository.loadEntries()
        #expect(entries.map(\.amount) == [500, 250])
        #expect(entries.first?.date == march(9))
    }

    @Test func addingManyLogsAtOnceSavesThemAll() throws {
        let repository = try makeRepository()
        let entries = (1...20).map { HabitEntry(habitID: water.id, date: march($0), amount: 250) }
        try repository.add(contentsOf: entries)
        #expect(try repository.loadEntries().count == 20)
    }

    @Test func deletingEntriesRemovesOnlyTheGivenOnes() throws {
        let repository = try makeRepository()
        let first = HabitEntry(habitID: water.id, date: march(9), amount: 250)
        let second = HabitEntry(habitID: water.id, date: march(9), amount: 250)
        try repository.add(first)
        try repository.add(second)
        try repository.deleteEntries(ids: [first.id])
        #expect(try repository.loadEntries().map(\.id) == [second.id])
    }

    @Test func deletingAHabitRemovesItsLogsOnly() throws {
        let repository = try makeRepository()
        try repository.save(water)
        try repository.save(vitamins)
        try repository.add(HabitEntry(habitID: water.id, date: march(9), amount: 250))
        try repository.add(HabitEntry(habitID: vitamins.id, date: march(9), amount: 1))
        try repository.deleteHabit(id: water.id)
        #expect(try repository.loadHabits().map(\.name) == ["Vitamins"])
        #expect(try repository.loadEntries().map(\.habitID) == [vitamins.id])
    }

    @Test func dataSurvivesANewContainerOnTheSameFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tally-test-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-shm", "-wal"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }
        do {
            let first = SwiftDataHabitRepository(container: try TallyStorage.makeContainer(url: url))
            try first.save(water)
            try first.add(HabitEntry(habitID: water.id, date: march(9), amount: 2500))
        }
        // A brand-new container on the same file, like the app starting again.
        let second = SwiftDataHabitRepository(container: try TallyStorage.makeContainer(url: url))
        #expect(try second.loadHabits() == [water])
        #expect(try second.loadEntries().count == 1)
    }
}
