import Foundation

/// How many due days in a row a habit was met, now and at its best.
public struct HabitStreak: Hashable, Sendable {
    public let current: Int
    public let best: Int

    public init(current: Int, best: Int) {
        self.current = current
        self.best = best
    }
}

/// Streak counting. Pure functions, so they are easy to test.
public enum HabitStreaks {
    /// The streak of `habit` from `start` through `today`.
    /// Only days the habit is due count. A due day is met when that day's total reaches the goal.
    /// Today stays pending until it is met, so an unfinished today doesn't reset the streak.
    public static func streak(
        of habit: HabitModel, entries: [HabitEntry], from start: Date, through today: Date,
        calendar: Calendar = .current
    ) -> HabitStreak {
        // One pass over the logs gives each day's total, instead of scanning them for every day.
        var totals: [Date: Double] = [:]
        for entry in entries where entry.habitID == habit.id {
            totals[calendar.startOfDay(for: entry.date), default: 0] += entry.amount
        }

        let todayStart = calendar.startOfDay(for: today)
        var run = 0
        var best = 0
        for day in HabitInsights.days(from: start, through: today, calendar: calendar)
        where habit.isDue(on: day, calendar: calendar) {
            if HabitProgress(total: totals[day] ?? 0, goal: habit.goalAmount(on: day, calendar: calendar)).isMet {
                run += 1
                best = max(best, run)
            } else if day != todayStart {
                run = 0
            }
        }
        return HabitStreak(current: run, best: best)
    }
}
