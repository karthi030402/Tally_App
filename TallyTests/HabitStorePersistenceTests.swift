import Testing
import Foundation
import TallyCore
import TallyStorage
@testable import Tally

@MainActor
struct HabitStorePersistenceTests {
    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)

    @Test func aStoreStartsFromWhatTheRepositoryHolds() {
        let entry = HabitEntry(habitID: water.id, date: .now, amount: 250)
        let store = HabitStore(repository: InMemoryHabitRepository(habits: [water], entries: [entry]))
        #expect(store.allHabits == [water])
        #expect(store.entries == [entry])
    }

    @Test func addingIsWrittenThrough() throws {
        let repository = InMemoryHabitRepository()
        let store = HabitStore(repository: repository)
        store.add(water)
        #expect(try repository.loadHabits() == [water])
    }

    @Test func editingIsWrittenThrough() throws {
        let repository = InMemoryHabitRepository(habits: [water])
        let store = HabitStore(repository: repository)
        store.update(HabitModel(id: water.id, name: "Hydration", colorName: "sky", kind: .counter, target: 2500, step: 250, unit: "ml"))
        #expect(try repository.loadHabits().first?.name == "Hydration")
    }

    @Test func archivingAndUnarchivingAreWrittenThrough() throws {
        let repository = InMemoryHabitRepository(habits: [water])
        let store = HabitStore(repository: repository)
        store.archive(water)
        #expect(try repository.loadHabits().first?.isArchived == true)
        store.unarchive(water)
        #expect(try repository.loadHabits().first?.isArchived == false)
    }

    @Test func deletingRemovesTheHabitAndItsLogsFromTheRepository() throws {
        let repository = InMemoryHabitRepository(
            habits: [water, vitamins],
            entries: [
                HabitEntry(habitID: water.id, date: .now, amount: 250),
                HabitEntry(habitID: vitamins.id, date: .now, amount: 1)
            ]
        )
        let store = HabitStore(repository: repository)
        store.delete(water)
        #expect(try repository.loadHabits().map(\.name) == ["Vitamins"])
        #expect(try repository.loadEntries().map(\.habitID) == [vitamins.id])
    }

    @Test func loggingUndoingAndClearingAreWrittenThrough() throws {
        let repository = InMemoryHabitRepository(habits: [water])
        let store = HabitStore(repository: repository)
        store.log(water)
        store.log(water)
        store.log(water)
        #expect(try repository.loadEntries().count == 3)
        store.undoLast(for: water)
        #expect(try repository.loadEntries().count == 2)
        store.clear(water)
        #expect(try repository.loadEntries().isEmpty)
    }

    @Test func aFailedWriteKeepsTheChangeAndRecordsTheError() {
        let store = HabitStore(repository: FailingRepository())
        store.add(water)
        #expect(store.habits == [water])
        #expect(store.lastError != nil)
    }

    @Test func aSecondStoreOnTheSameDatabaseSeesTheFirstOnesData() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tally-store-\(UUID().uuidString).store")
        defer {
            for suffix in ["", "-shm", "-wal"] {
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: url.path + suffix))
            }
        }
        do {
            let first = HabitStore(repository: SwiftDataHabitRepository(container: try TallyStorage.makeContainer(url: url)))
            first.add(water)
            first.log(water)
        }
        // A brand-new store and container on the same file, like the app starting again.
        let second = HabitStore(repository: SwiftDataHabitRepository(container: try TallyStorage.makeContainer(url: url)))
        #expect(second.allHabits == [water])
        #expect(second.entries.count == 1)
    }
}

/// A repository whose reads work and whose writes all fail, to test error handling.
@MainActor
private final class FailingRepository: HabitRepository {
    struct Failure: Error {}
    func loadHabits() throws -> [HabitModel] { [] }
    func loadEntries() throws -> [HabitEntry] { [] }
    func save(_ habit: HabitModel) throws { throw Failure() }
    func deleteHabit(id: UUID) throws { throw Failure() }
    func add(_ entry: HabitEntry) throws { throw Failure() }
    func add(contentsOf entries: [HabitEntry]) throws { throw Failure() }
    func deleteEntries(ids: [UUID]) throws { throw Failure() }
}
