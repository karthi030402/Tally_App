import Foundation
import SwiftData

/// Sets up the database. The app, and later the widgets, build their container here,
/// so they all share one schema.
public enum TallyStorage {
    /// The App Group the app and its widgets share. It must match the entitlements of both targets.
    public static let appGroupID = "group.com.sathappan.dev.Tally"

    /// The record types the database holds.
    private static var models: [any PersistentModel.Type] { [HabitRecord.self, EntryRecord.self] }

    /// A container for the database. With no `url` it uses the shared App Group container, so the
    /// app and the widgets read the same file. The first time, the store the app kept in its own
    /// folder before widgets existed is moved there.
    /// Pass `inMemory: true` for previews and tests, or a `url` to choose the file.
    @MainActor
    public static func makeContainer(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(models)
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url)
        } else if inMemory {
            configuration = ModelConfiguration("Tally", schema: schema, isStoredInMemoryOnly: true)
        } else {
            let sharedURL = try sharedStoreURL()
            try moveStore(from: legacyStoreURL(), to: sharedURL)
            configuration = ModelConfiguration(schema: schema, url: sharedURL)
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Where the shared database lives, inside the App Group container.
    private static func sharedStoreURL() throws -> URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw StorageError.appGroupUnavailable(appGroupID)
        }
        let folder = container.appending(path: "Library/Application Support", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appending(path: "Tally.store")
    }

    /// Where the app kept its store before the App Group: its own Application Support folder.
    /// Built by hand, because a named `ModelConfiguration` resolves into the App Group container
    /// as soon as the app has that entitlement.
    private static func legacyStoreURL() -> URL {
        URL.applicationSupportDirectory.appending(path: "Tally.store")
    }

    /// Moves a SQLite store and its `-wal` and `-shm` files. Does nothing when there is no old
    /// store, or when the new location already has one, so it never overwrites newer data.
    static func moveStore(from oldURL: URL, to newURL: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: oldURL.path), !fileManager.fileExists(atPath: newURL.path) else { return }
        for suffix in ["", "-wal", "-shm"] {
            let source = URL(fileURLWithPath: oldURL.path + suffix)
            let destination = URL(fileURLWithPath: newURL.path + suffix)
            if fileManager.fileExists(atPath: source.path) {
                try fileManager.moveItem(at: source, to: destination)
            }
        }
    }
}

/// Why the database couldn't be opened.
public enum StorageError: Error, Equatable {
    case appGroupUnavailable(String)
}
