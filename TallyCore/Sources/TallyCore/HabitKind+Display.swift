/// How a habit kind is described to the user.
public extension HabitKind {
    /// The name shown in the form.
    var title: String {
        switch self {
        case .checkOff:
            "Check-off"
        case .counter:
            "Goal"
        }
    }

    /// A one-line explanation shown under the option.
    var summary: String {
        switch self {
        case .checkOff:
            "Mark it done once a day, like taking vitamins."
        case .counter:
            "Add up to a daily amount in steps, like 2500 ml of water."
        }
    }
}
