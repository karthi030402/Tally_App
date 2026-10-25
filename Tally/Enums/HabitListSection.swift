/// The two groups on the Habits screen.
enum HabitListSection: CaseIterable {
    case active
    case archived

    private var name: String {
        switch self {
        case .active:
            "ACTIVE"
        case .archived:
            "ARCHIVED"
        }
    }

    /// The section header, with a count only when there's something to count.
    func title(count: Int) -> String {
        count == 0 ? name : "\(name) (\(count))"
    }

    /// Shown in place of the cards when the section has nothing to show.
    var emptyMessage: String {
        switch self {
        case .active:
            "No active habits"
        case .archived:
            "No archived habits"
        }
    }
}
