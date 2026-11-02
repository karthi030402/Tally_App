import Foundation

/// One day in the month calendar, with everything its cell needs already worked out.
struct CalendarDay: Identifiable {
    let date: Date
    /// The day of the month, as shown in the cell.
    let number: Int
    /// 0 to 1, or nil when nothing was due that day, so no ring is drawn.
    let fraction: Double?
    let isSelected: Bool
    let isFuture: Bool

    var id: Date { date }
}
