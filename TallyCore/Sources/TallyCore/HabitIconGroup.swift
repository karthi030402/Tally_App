/// A themed group of icons in the icon picker.
public struct HabitIconGroup: Identifiable, Hashable, Sendable {
    public let title: String
    public let symbols: [String]
    public var id: String { title }

    public init(title: String, symbols: [String]) {
        self.title = title
        self.symbols = symbols
    }
}
