/// A day of the week a habit can be scheduled on.
/// Raw values match Calendar's weekday numbers (1 = Sunday ... 7 = Saturday).
/// Cases are declared Monday-first, so `allCases` is in display order.
public enum HabitWeekday: Int, Hashable, Sendable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1

    /// All seven days. "Every day" is this set, never an empty one.
    public static let everyDay: Set<HabitWeekday> = Set(allCases)
}
