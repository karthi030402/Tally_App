import Testing
import Foundation
import TallyCore
@testable import Tally

struct HabitDayDetailTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    /// March 2026 at noon UTC. 9 March 2026 is a Monday.
    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday])
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)

    @Test func aDayTheHabitIsNotDueIsNotScheduled() {
        let detail = HabitDayDetail(habit: water, entries: [], day: march(10), calendar: calendar) // Tuesday
        #expect(detail.fraction == nil)
        #expect(detail.text == "Not scheduled")
    }

    @Test func aCheckOffReadsDoneOrNotDone() {
        let entries = [HabitEntry(habitID: vitamins.id, date: march(9), amount: 1)]
        #expect(HabitDayDetail(habit: vitamins, entries: entries, day: march(9), calendar: calendar).text == "Done")
        #expect(HabitDayDetail(habit: vitamins, entries: entries, day: march(10), calendar: calendar).text == "Not done")
    }

    @Test func aGoalShowsTheAmountAgainstTheGoal() {
        let entries = [HabitEntry(habitID: water.id, date: march(9), amount: 1500)]
        let detail = HabitDayDetail(habit: water, entries: entries, day: march(9), calendar: calendar)
        #expect(detail.text == "1500 / 2500 ml")
        #expect(detail.fraction == 0.6)
    }

    @Test func aPastDayKeepsTheUnitItHad() {
        let renamed = water.changing(
            to: HabitRule(kind: .counter, target: 2.5, step: 0.25, unit: "L", weekdays: [.monday]),
            from: march(16), calendar: calendar
        )
        let entries = [HabitEntry(habitID: water.id, date: march(9), amount: 1500)]
        let detail = HabitDayDetail(habit: renamed, entries: entries, day: march(9), calendar: calendar)
        #expect(detail.text == "1500 / 2500 ml")
    }
}
