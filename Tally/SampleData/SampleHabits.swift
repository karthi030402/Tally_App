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

    /// A store filled with the sample habits and today's sample logs.
    static func makeStore() -> HabitStore {
        HabitStore(habits: active, archivedHabits: archived, entries: todayEntries(), streaks: streaks)
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
