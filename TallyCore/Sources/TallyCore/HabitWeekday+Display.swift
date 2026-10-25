import Foundation

/// How weekdays are described to the user.
public extension HabitWeekday {
    /// "Monday", in the user's language.
    var name: String {
        Calendar.current.weekdaySymbols[rawValue - 1] // index 0 is Sunday
    }

    /// "Mon", in the user's language.
    var shortName: String {
        Calendar.current.shortWeekdaySymbols[rawValue - 1]
    }

    /// "Every day" when all seven are selected, otherwise "Mon, Wed, Fri" in Monday-first order.
    static func summary(of days: Set<HabitWeekday>) -> String {
        guard days != everyDay else { return "Every day" }
        return allCases
            .filter { days.contains($0) }
            .map(\.shortName)
            .joined(separator: ", ")
    }
}
