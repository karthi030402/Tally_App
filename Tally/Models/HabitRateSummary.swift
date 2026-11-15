import Foundation

/// One line of the rates card: a period, its completion rate, and what it is made of.
struct HabitRateSummary: Identifiable {
    /// For example "Last 7 days".
    let title: String
    /// For example "83%", or "–" when there is nothing to measure.
    let percentText: String
    /// For example "5 of 6 due days", or "No logs yet".
    let detail: String

    var id: String { title }
}
