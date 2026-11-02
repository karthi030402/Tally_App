import Foundation

/// How one day went across every habit that was due.
public struct DayCompletion: Hashable, Sendable {
    public let date: Date
    /// How many habits were due that day.
    public let due: Int
    /// How many of them reached their goal.
    public let met: Int
    /// The average progress of the due habits, 0 to 1. A half-finished goal counts as 0.5.
    /// Nil when nothing was due, so the day has no value at all (not even 0%).
    public let fraction: Double?

    public init(date: Date, due: Int, met: Int, fraction: Double?) {
        self.date = date
        self.due = due
        self.met = met
        self.fraction = fraction
    }
}

/// How one habit did over a range, counting only the days it was due.
public struct HabitRate: Hashable, Sendable {
    public let habitID: UUID
    public let met: Int
    public let due: Int

    public init(habitID: UUID, met: Int, due: Int) {
        self.habitID = habitID
        self.met = met
        self.due = due
    }

    /// The share of due days that were met, 0 to 1. Only built for habits that were due at least once.
    public var rate: Double { Double(met) / Double(due) }
}

/// Numbers for the Insights tab. Pure functions, so they are easy to test.
public enum HabitInsights {
    /// Every day from `start` through `end`, as start-of-day dates.
    public static func days(from start: Date, through end: Date, calendar: Calendar = .current) -> [Date] {
        var days: [Date] = []
        var day = calendar.startOfDay(for: start)
        let last = calendar.startOfDay(for: end)
        while day <= last {
            days.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }

    /// How `date` went across the habits due that day.
    public static func completion(
        on date: Date, habits: [HabitModel], entries: [HabitEntry], calendar: Calendar = .current
    ) -> DayCompletion {
        let progresses = habits
            .filter { $0.isDue(on: date, calendar: calendar) }
            .map { $0.progress(from: entries, on: date, calendar: calendar) }
        let average = progresses.isEmpty ? nil : progresses.map(\.fraction).reduce(0, +) / Double(progresses.count)
        return DayCompletion(
            date: calendar.startOfDay(for: date),
            due: progresses.count,
            met: progresses.filter(\.isMet).count,
            fraction: average
        )
    }

    /// One `DayCompletion` per day from `start` through `end`.
    public static func completions(
        from start: Date, through end: Date, habits: [HabitModel], entries: [HabitEntry],
        calendar: Calendar = .current
    ) -> [DayCompletion] {
        days(from: start, through: end, calendar: calendar).map {
            completion(on: $0, habits: habits, entries: entries, calendar: calendar)
        }
    }

    /// How `habit` did from `start` through `end`. Nil when it was never due in that range.
    public static func rate(
        of habit: HabitModel, entries: [HabitEntry], from start: Date, through end: Date,
        calendar: Calendar = .current
    ) -> HabitRate? {
        let dueDays = days(from: start, through: end, calendar: calendar)
            .filter { habit.isDue(on: $0, calendar: calendar) }
        guard !dueDays.isEmpty else { return nil }
        let met = dueDays.filter { habit.progress(from: entries, on: $0, calendar: calendar).isMet }.count
        return HabitRate(habitID: habit.id, met: met, due: dueDays.count)
    }

    /// A rate for every habit that was due at least once in the range, in the order given.
    public static func rates(
        of habits: [HabitModel], entries: [HabitEntry], from start: Date, through end: Date,
        calendar: Calendar = .current
    ) -> [HabitRate] {
        habits.compactMap { rate(of: $0, entries: entries, from: start, through: end, calendar: calendar) }
    }

    /// The highest rate. When rates tie, the one listed first wins.
    public static func best(in rates: [HabitRate]) -> HabitRate? {
        rates.max { $0.rate < $1.rate }
    }

    /// The lowest rate. When rates tie, the one listed first wins.
    public static func worst(in rates: [HabitRate]) -> HabitRate? {
        rates.min { $0.rate < $1.rate }
    }
}
