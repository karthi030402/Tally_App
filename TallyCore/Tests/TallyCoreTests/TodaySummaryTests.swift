import Testing
import Foundation
@testable import TallyCore

struct TodaySummaryTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    // 2026-03-09 is a Monday.
    private var monday: Date { calendar.date(from: DateComponents(year: 2026, month: 3, day: 9, hour: 12)) ?? .distantPast }

    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday, .friday])
    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
    private let gym = HabitModel(name: "Gym", colorName: "coral", kind: .checkOff, weekdays: [.tuesday])

    @Test func onlyHabitsDueThatDayAreListed() {
        let summary = TodaySummary(habits: [water, vitamins, gym], entries: [], on: monday, calendar: calendar)
        #expect(summary.rows.map(\.habit.name) == ["Water", "Vitamins"])
    }

    @Test func anArchivedHabitIsLeftOut() {
        let archived = vitamins.archiving(from: monday, calendar: calendar)
        let summary = TodaySummary(habits: [water, archived], entries: [], on: monday, calendar: calendar)
        #expect(summary.rows.map(\.habit.name) == ["Water"])
    }

    @Test func countsAndFractionFollowTheLogs() {
        let entries = [HabitEntry(habitID: vitamins.id, date: monday, amount: 1)]
        let summary = TodaySummary(habits: [water, vitamins], entries: entries, on: monday, calendar: calendar)
        #expect(summary.dueCount == 2)
        #expect(summary.doneCount == 1)
        #expect(summary.fraction == 0.5)
    }

    @Test func unfinishedHabitsComeFirst() {
        let entries = [HabitEntry(habitID: water.id, date: monday, amount: 2500)]
        let summary = TodaySummary(habits: [water, vitamins], entries: entries, on: monday, calendar: calendar)
        #expect(summary.rows.map(\.habit.name) == ["Vitamins", "Water"])
    }

    @Test func subtitlesReadDoneOrTheAmountAgainstTheGoal() {
        let entries = [HabitEntry(habitID: water.id, date: monday, amount: 1500)]
        let summary = TodaySummary(habits: [water, vitamins], entries: entries, on: monday, calendar: calendar)
        let subtitles = Dictionary(uniqueKeysWithValues: summary.rows.map { ($0.habit.name, $0.subtitle) })
        #expect(subtitles["Water"] == "1500 / 2500 ml")
        #expect(subtitles["Vitamins"] == "Not done")
    }

    @Test func noHabitsDueMeansAnEmptySummaryWithZeroFraction() {
        let summary = TodaySummary(habits: [gym], entries: [], on: monday, calendar: calendar)
        #expect(summary.rows.isEmpty)
        #expect(summary.fraction == 0)
    }
}
