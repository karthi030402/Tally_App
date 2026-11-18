import Foundation

/// The places a `tally://` link can open. The widgets build these links and the app reads them.
public enum DeepLink: Equatable, Sendable {
    /// The Today tab.
    case today
    /// One habit's page.
    case habit(UUID)

    public static let scheme = "tally"

    /// The link for this place. Always valid, so `nil` only guards against a future bad case.
    public var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        switch self {
        case .today:
            components.host = "today"
        case .habit(let id):
            components.host = "habit"
            components.path = "/" + id.uuidString
        }
        return components.url
    }

    /// Reads a link. Anything that isn't a Tally link to a known place gives `nil`.
    public init?(url: URL) {
        guard url.scheme == Self.scheme else { return nil }
        switch url.host {
        case "today":
            self = .today
        case "habit":
            guard let id = UUID(uuidString: String(url.path.dropFirst())) else { return nil }
            self = .habit(id)
        default:
            return nil
        }
    }
}
