import Testing
import Foundation
@testable import TallyCore

struct HabitInsightsTests {
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
    private let gym = HabitModel(name: "Gym", colorName: "coral", kind: .checkOff, weekdays: [.monday, .wednesday, .friday])

    private func log(_ habit: HabitModel, day: Int, amount: Double? = nil) -> HabitEntry {
        HabitEntry(habitID: habit.id, date: march(day), amount: amount ?? habit.goalAmount)
    }

    @Test func dayCountsOnlyHabitsDueThatDay() {
        // Tuesday: only water is due, and it was met.
        let day = HabitInsights.completion(on: march(10), habits: [water, gym], entries: [log(water, day: 10)], calendar: calendar)
        #expect(day.due == 1)
        #expect(day.met == 1)
        #expect(day.fraction == 1)
    }

    @Test func dayValueAveragesPartialProgress() {
        // Monday: water is half done (0.5), gym is done (1). Average 0.75, one of two met.
        let entries = [log(water, day: 9, amount: 1250), log(gym, day: 9)]
        let day = HabitInsights.completion(on: march(9), habits: [water, gym], entries: entries, calendar: calendar)
        #expect(day.fraction == 0.75)
        #expect(day.met == 1)
        #expect(day.due == 2)
    }

    @Test func dayWithNothingDueHasNoValue() {
        let day = HabitInsights.completion(on: march(9), habits: [], entries: [], calendar: calendar)
        #expect(day.fraction == nil)
        #expect(day.due == 0)
    }

    @Test func rateIgnoresDaysTheHabitWasNotDue() {
        // Gym is due Mon 9, Wed 11 and Fri 13 in this week. Done on two of the three.
        let entries = [log(gym, day: 9), log(gym, day: 13)]
        let rate = HabitInsights.rate(of: gym, entries: entries, from: march(9), through: march(15), calendar: calendar)
        #expect(rate?.met == 2)
        #expect(rate?.due == 3)
        #expect(rate?.rate == 2.0 / 3.0)
    }

    @Test func rateIsNilWhenNeverDue() {
        // Tuesday only: gym is not due.
        let rate = HabitInsights.rate(of: gym, entries: [], from: march(10), through: march(10), calendar: calendar)
        #expect(rate == nil)
    }

    @Test func bestAndWorstPickTheExtremes() {
        // Water done every day this week, gym done once of three.
        let waterEntries = (9...15).map { log(water, day: $0) }
        let entries = waterEntries + [log(gym, day: 9)]
        let rates = HabitInsights.rates(of: [water, gym], entries: entries, from: march(9), through: march(15), calendar: calendar)
        #expect(HabitInsights.best(in: rates)?.habitID == water.id)
        #expect(HabitInsights.worst(in: rates)?.habitID == gym.id)
    }

    @Test func ratesSkipHabitsThatWereNeverDue() {
        let rates = HabitInsights.rates(of: [water, gym], entries: [], from: march(10), through: march(10), calendar: calendar)
        #expect(rates.count == 1)
        #expect(rates.first?.habitID == water.id)
    }

    @Test func daysCoverTheWholeRangeInclusive() {
        #expect(HabitInsights.days(from: march(9), through: march(15), calendar: calendar).count == 7)
    }
}
