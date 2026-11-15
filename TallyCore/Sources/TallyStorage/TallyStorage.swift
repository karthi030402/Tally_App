import Foundation
import SwiftData

/// Sets up the database. The app, and later the widgets, build their container here,
/// so they all share one schema.
public enum TallyStorage {
    /// The record types the database holds.
    private static var models: [any PersistentModel.Type] { [HabitRecord.self, EntryRecord.self] }

    /// A container for the database. With no `url` it uses SwiftData's default location.
    /// Pass `inMemory: true` for previews and tests, or a `url` to choose the file.
    @MainActor
    public static func makeContainer(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(models)
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url)
        } else {
            // A named store keeps its own file instead of sharing SwiftData's "default.store".
            configuration = ModelConfiguration("Tally", schema: schema, isStoredInMemoryOnly: inMemory)
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
