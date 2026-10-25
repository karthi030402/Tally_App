import Testing
import Foundation
@testable import TallyCore

struct HabitProgressTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    /// March 2026 at noon UTC. 9 March 2026 is a Monday.
    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)

    @Test func totalCountsOnlyThatHabitOnThatDay() {
        let entries = [
            HabitEntry(habitID: water.id, date: march(9), amount: 250),
            HabitEntry(habitID: water.id, date: march(9), amount: 250),
            HabitEntry(habitID: water.id, date: march(8), amount: 500),
            HabitEntry(habitID: vitamins.id, date: march(9), amount: 1)
        ]
        let progress = water.progress(from: entries, on: march(9), calendar: calendar)
        #expect(progress.total == 500)
        #expect(!progress.isMet)
    }

    @Test func overshootingKeepsTheTotalButCapsTheFraction() {
        let entries = [HabitEntry(habitID: water.id, date: march(9), amount: 3000)]
        let progress = water.progress(from: entries, on: march(9), calendar: calendar)
        #expect(progress.total == 3000)
        #expect(progress.fraction == 1)
        #expect(progress.isMet)
    }

    @Test func checkOffIsMetByOneEntry() {
        let none = vitamins.progress(from: [], on: march(9), calendar: calendar)
        let one = vitamins.progress(
            from: [HabitEntry(habitID: vitamins.id, date: march(9), amount: vitamins.tapAmount)],
            on: march(9), calendar: calendar
        )
        #expect(!none.isMet)
        #expect(one.isMet)
    }

    @Test func fractionalStepsStillReachTheGoal() {
        let fruit = HabitModel(name: "Fruit", colorName: "coral", kind: .counter, target: 1, step: 0.2, unit: "kg")
        let entries = (0..<5).map { _ in HabitEntry(habitID: fruit.id, date: march(9), amount: fruit.tapAmount) }
        #expect(fruit.progress(from: entries, on: march(9), calendar: calendar).isMet)
    }

    @Test func tapAmountIsTheStepAndFallsBackToTheGoal() {
        #expect(water.tapAmount == 250)
        #expect(vitamins.tapAmount == 1)
        #expect(vitamins.goalAmount == 1)
    }

    @Test func dueDependsOnTheWeekdayOfTheDate() {
        let gym = HabitModel(name: "Gym", colorName: "coral", kind: .checkOff, weekdays: [.monday, .wednesday, .friday])
        #expect(gym.isDue(on: march(9), calendar: calendar))   // Monday
        #expect(!gym.isDue(on: march(10), calendar: calendar)) // Tuesday
        #expect(water.isDue(on: march(10), calendar: calendar)) // every day
    }
}
