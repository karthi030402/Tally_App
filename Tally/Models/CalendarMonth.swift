import Foundation

/// One page of the month calendar: always six rows of seven, with nil where the grid is empty.
struct CalendarMonth: Identifiable {
    /// The first day of the month.
    let start: Date
    let weeks: [[CalendarDay?]]

    var id: Date { start }
}
