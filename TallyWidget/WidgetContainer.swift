import SwiftData
import TallyStorage

/// One database container for the whole widget process. Opening it is the slow part, so the
/// timeline provider and the log intent share it instead of opening it again on every tap.
@MainActor
enum WidgetContainer {
    private static var cached: ModelContainer?

    static func shared() throws -> ModelContainer {
        if let cached { return cached }
        let container = try TallyStorage.makeContainer()
        cached = container
        return container
    }
}
