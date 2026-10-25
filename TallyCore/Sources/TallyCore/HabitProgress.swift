import Foundation

/// How far a habit got on one day.
public struct HabitProgress: Hashable, Sendable {
    /// Everything logged that day. Can exceed the goal.
    public let total: Double
    public let goal: Double

    public init(total: Double, goal: Double) {
        self.total = total
        self.goal = goal
    }

    /// 0 to 1, for rings and bars. Going over the goal still reads 1.
    public var fraction: Double {
        guard goal > 0 else { return 0 }
        return min(max(total / goal, 0), 1)
    }

    /// Doubles can't hold 0.2 exactly, so a tiny shortfall still counts as reaching the goal.
    public var isMet: Bool { total >= goal - 1e-9 }
}

public extension HabitModel {
    /// The daily goal. A check-off habit counts as a goal of 1.
    var goalAmount: Double { target ?? 1 }

    /// What one tap adds. A check-off habit adds 1.
    var tapAmount: Double { step ?? goalAmount }

    /// Whether the habit is due on the weekday of `date`.
    func isDue(on date: Date, calendar: Calendar = .current) -> Bool {
        guard let weekday = HabitWeekday(rawValue: calendar.component(.weekday, from: date)) else { return false }
        return isScheduled(on: weekday)
    }

    /// This habit's progress on the day of `date`, from a list of everyone's entries.
    func progress(from entries: [HabitEntry], on date: Date, calendar: Calendar = .current) -> HabitProgress {
        let total = entries
            .filter { $0.habitID == id && calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amount }
        return HabitProgress(total: total, goal: goalAmount)
    }
}
