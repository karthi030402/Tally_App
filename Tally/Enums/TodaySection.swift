/// The groups on the Today screen.
enum TodaySection {
    case due
    case notScheduled

    func title(count: Int) -> String {
        switch self {
        case .due: "DUE TODAY (\(count))"
        case .notScheduled: "NOT SCHEDULED TODAY (\(count))"
        }
    }

    /// Shown in place of the cards when nothing is due.
    var emptyMessage: String {
        "Nothing is due today"
    }
}
