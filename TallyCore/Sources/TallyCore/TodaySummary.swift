import Foundation

/// What a "today" view needs: the habits due on one day and how far each got.
/// The app's Today tab and the widgets can both build their screens from this.
public struct TodaySummary: Equatable, Sendable {
    public struct Row: Equatable, Sendable, Identifiable {
        public let habit: HabitModel
        public let progress: HabitProgress

        public var id: UUID { habit.id }

        /// "Done" / "Not done", or "1500 / 2500 ml".
        public var subtitle: String {
            switch habit.kind {
            case .checkOff:
                return progress.isMet ? "Done" : "Not done"
            case .counter:
                let unit = habit.unit.map { " \($0)" } ?? ""
                return "\(progress.total.habitAmountText) / \(progress.goal.habitAmountText)\(unit)"
            }
        }
    }

    /// Every active habit due that day, unfinished ones first. Each group keeps its own order.
    public let rows: [Row]

    public init(habits: [HabitModel], entries: [HabitEntry], on date: Date, calendar: Calendar = .current) {
        let due = habits
            .filter { $0.isDue(on: date, calendar: calendar) }
            .map { Row(habit: $0, progress: $0.progress(from: entries, on: date, calendar: calendar)) }
        rows = due.filter { !$0.progress.isMet } + due.filter { $0.progress.isMet }
    }

    public var dueCount: Int { rows.count }
    public var doneCount: Int { rows.filter { $0.progress.isMet }.count }
    /// 0 to 1: how many due habits are done.
    public var fraction: Double { rows.isEmpty ? 0 : Double(doneCount) / Double(dueCount) }
}
