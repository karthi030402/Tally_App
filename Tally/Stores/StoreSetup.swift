import Foundation
import os
import TallyCore
import TallyStorage

/// Builds the app's store on the real database. In Debug builds a brand-new database is filled
/// with the sample habits once, so there is something to look at while developing.
@MainActor
enum StoreSetup {
    private static let seededKey = "hasSeededSampleData"
    private static let logger = Logger(subsystem: "com.sathappan.dev.Tally", category: "StoreSetup")

    static func makeStore(defaults: UserDefaults = .standard) -> HabitStore {
        do {
            let repository = SwiftDataHabitRepository(container: try TallyStorage.makeContainer())
            #if DEBUG
            try seedSampleData(into: repository, defaults: defaults)
            #endif
            return HabitStore(repository: repository)
        } catch {
            logger.fault("Could not open the database: \(error.localizedDescription)")
            #if DEBUG
            fatalError("Could not open the database: \(error)")
            #else
            // Better to launch than to crash. Changes made this session won't be saved.
            return HabitStore()
            #endif
        }
    }

    /// Writes the sample habits and their history into an empty repository, once.
    /// If the repository already has habits, or this was done before, nothing is written,
    /// so deleting the samples later never brings them back.
    static func seedSampleData(into repository: any HabitRepository, defaults: UserDefaults) throws {
        guard !defaults.bool(forKey: seededKey) else { return }
        if try repository.loadHabits().isEmpty {
            for habit in SampleHabits.seedHabits {
                try repository.save(habit)
            }
            // One save for the whole history.
            try repository.add(contentsOf: SampleHabits.historyEntries() + SampleHabits.todayEntries())
        }
        defaults.set(true, forKey: seededKey)
    }
}
