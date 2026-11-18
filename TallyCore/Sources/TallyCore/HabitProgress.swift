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

    /// The daily goal that applied on `date`.
    func goalAmount(on date: Date, calendar: Calendar = .current) -> Double {
        rule(on: date, calendar: calendar).target ?? 1
    }

    /// What one tap adds. A check-off habit adds 1.
    var tapAmount: Double { step ?? goalAmount }

    /// Whether the habit was due on the weekday of `date`, by the rules that applied that day.
    /// An archived habit isn't due on any day, and no habit is due before the day it was created.
    func isDue(on date: Date, calendar: Calendar = .current) -> Bool {
        guard calendar.startOfDay(for: date) >= calendar.startOfDay(for: createdAt) else { return false }
        guard let weekday = HabitWeekday(rawValue: calendar.component(.weekday, from: date)) else { return false }
        let dayRule = rule(on: date, calendar: calendar)
        return dayRule.isActive && dayRule.weekdays.contains(weekday)
    }

    /// This habit's progress on the day of `date`, from a list of everyone's entries.
    func progress(from entries: [HabitEntry], on date: Date, calendar: Calendar = .current) -> HabitProgress {
        let total = entries
            .filter { $0.habitID == id && calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amount }
        return HabitProgress(total: total, goal: goalAmount(on: date, calendar: calendar))
    }
}
