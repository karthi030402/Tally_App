import Foundation
import TallyCore

/// Dummy data for previews and the first version of the app, until real storage exists.
enum SampleHabits {
    static let water = HabitModel(
        name: "Water", symbol: "drop.fill", colorName: "indigo",
        kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday, .friday]
    )
    static let vitamins = HabitModel(
        name: "Vitamins", symbol: "pills.fill", colorName: "gold",
        kind: .checkOff
    )
    static let gym = HabitModel(
        name: "Gym", symbol: "dumbbell.fill", colorName: "coral",
        kind: .checkOff, weekdays: [.monday, .friday]
    )
    static let reading = HabitModel(
        name: "Reading", symbol: "book.fill", colorName: "orchid",
        kind: .counter, target: 20, step: 5, unit: "pages"
    )
    static let meditation = HabitModel(
        name: "Meditation", colorName: "indigo",
        kind: .checkOff
    )

    static let active = [water, vitamins, gym, reading]
    static let archived = [meditation]

    /// Logs for today so Today looks lived-in: water 1500 ml, vitamins done, 5 pages read.
    static func todayEntries(now: Date = .now) -> [HabitEntry] {
        let waterTaps = (0..<6).map { _ in HabitEntry(habitID: water.id, date: now, amount: 250) }
        return waterTaps + [
            HabitEntry(habitID: vitamins.id, date: now, amount: 1),
            HabitEntry(habitID: reading.id, date: now, amount: 5)
        ]
    }

    /// How many days before today the sample history covers. Real storage should keep a year or more.
    static let historyDays = 84

    /// How much of its goal a habit reaches, cycling through perfect days, partial days and misses.
    private static let completionPattern: [Double] = [1, 1, 1, 0.8, 1, 0.6, 1, 0.4, 0.2, 1, 1, 0]

    /// Earlier logs so the Insights charts and calendar have data. It is the same on every launch,
    /// and a habit is only logged on the days it is due.
    static func historyEntries(now: Date = .now, calendar: Calendar = .current) -> [HabitEntry] {
        let today = calendar.startOfDay(for: now)
        var entries: [HabitEntry] = []
        for offset in 1...historyDays {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today),
                  let noon = calendar.date(byAdding: .hour, value: 12, to: day) else { continue }
            for (index, habit) in active.enumerated() where habit.isDue(on: day, calendar: calendar) {
                let share = completionPattern[(offset * 7 + index * 5) % completionPattern.count]
                entries += logs(for: habit, share: share, at: noon)
            }
        }
        return entries
    }

    /// The taps that add up to `share` of the habit's goal, rounded down to whole steps.
    private static func logs(for habit: HabitModel, share: Double, at date: Date) -> [HabitEntry] {
        switch habit.kind {
        case .checkOff:
            return share >= 1 ? [HabitEntry(habitID: habit.id, date: date, amount: habit.tapAmount)] : []
        case .counter:
            let taps = Int((habit.goalAmount * share / habit.tapAmount).rounded(.down))
            return (0..<taps).map { _ in HabitEntry(habitID: habit.id, date: date, amount: habit.tapAmount) }
        }
    }

    /// A store filled with the sample habits, their history, and today's sample logs.
    static func makeStore() -> HabitStore {
        HabitStore(
            habits: active, archivedHabits: archived,
            entries: historyEntries() + todayEntries(), streaks: streaks
        )
    }

    /// Placeholder streaks until the streak engine exists.
    static let streaks: [UUID: Int] = [
        water.id: 12,
        vitamins.id: 5,
        gym.id: 2,
        reading.id: 0,
        meditation.id: 3
    ]
}
