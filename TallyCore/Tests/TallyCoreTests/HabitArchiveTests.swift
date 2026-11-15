import Testing
import Foundation
@testable import TallyCore

struct HabitArchiveTests {
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

    @Test func aNewHabitIsNotArchived() {
        #expect(!water.isArchived)
    }

    @Test func archivingStopsTheHabitFromThatDay() {
        let habit = water.archiving(from: march(11), calendar: calendar)
        #expect(habit.isArchived)
        #expect(habit.isDue(on: march(10), calendar: calendar))
        #expect(!habit.isDue(on: march(11), calendar: calendar))
        #expect(!habit.isDue(on: march(20), calendar: calendar))
    }

    @Test func archivingKeepsTheGoalAndSchedule() {
        let habit = water.archiving(from: march(11), calendar: calendar)
        #expect(habit.target == 2500)
        #expect(habit.step == 250)
        #expect(habit.unit == "ml")
        #expect(habit.weekdays == water.weekdays)
    }

    @Test func pastDaysStillCountAnArchivedHabit() {
        let habit = water.archiving(from: march(11), calendar: calendar)
        let entries = [HabitEntry(habitID: habit.id, date: march(9), amount: 2500)]
        let day = HabitInsights.completion(on: march(9), habits: [habit], entries: entries, calendar: calendar)
        #expect(day.due == 1)
        #expect(day.met == 1)
        let later = HabitInsights.completion(on: march(12), habits: [habit], entries: entries, calendar: calendar)
        #expect(later.due == 0)
    }

    @Test func restoringResumesFromTheRestoreDay() {
        let archived = water.archiving(from: march(11), calendar: calendar)
        let restored = archived.restoring(from: march(15), calendar: calendar)
        #expect(!restored.isArchived)
        #expect(restored.isDue(on: march(10), calendar: calendar))
        #expect(!restored.isDue(on: march(12), calendar: calendar))
        #expect(!restored.isDue(on: march(14), calendar: calendar))
        #expect(restored.isDue(on: march(15), calendar: calendar))
    }

    @Test func archivingAndRestoringOnTheSameDayLeavesNoTrace() {
        let habit = water.archiving(from: march(11), calendar: calendar).restoring(from: march(11), calendar: calendar)
        #expect(habit.changes.isEmpty)
        #expect(!habit.isArchived)
    }

    @Test func aStreakContinuesAcrossTheArchivedGap() {
        // Met 9 and 10, archived 11 to 13, restored 14, met 14 and 15 (today).
        let habit = vitamins
            .archiving(from: march(11), calendar: calendar)
            .restoring(from: march(14), calendar: calendar)
        let entries = [9, 10, 14, 15].map { HabitEntry(habitID: habit.id, date: march($0), amount: 1) }
        let streak = HabitStreaks.streak(of: habit, entries: entries, from: march(9), through: march(15), calendar: calendar)
        #expect(streak == HabitStreak(current: 4, best: 4))
    }
}
