/// How a habit is completed each day.
public enum HabitKind: String, Hashable, Sendable, CaseIterable {
    /// Done or not done.
    case checkOff
    /// Adds up toward a daily target in steps, such as 250 ml at a time.
    case counter
}
