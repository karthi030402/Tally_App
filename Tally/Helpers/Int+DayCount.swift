import Foundation

extension Int {
    /// "1 day", "2 days", "0 days".
    var dayCountText: String {
        "\(self) \(self == 1 ? "day" : "days")"
    }
}
