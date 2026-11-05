import Testing
import Foundation
@testable import TallyCore

struct HabitStreaksTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    /// March 2026 at noon UTC. 9 March 2026 is a Monday.
    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
    private let gym = HabitModel(name: "Gym", colorName: "coral", kind: .checkOff, weekdays: [.monday, .wednesday, .friday])

    private func done(_ habit: HabitModel, _ days: Int..., amount: Double? = nil) -> [HabitEntry] {
        days.map { HabitEntry(habitID: habit.id, date: march($0), amount: amount ?? habit.goalAmount) }
    }

    private func streak(_ habit: HabitModel, _ entries: [HabitEntry], from start: Int = 9, through today: Int) -> HabitStreak {
        HabitStreaks.streak(of: habit, entries: entries, from: march(start), through: march(today), calendar: calendar)
    }

    @Test func consecutiveDaysBuildTheStreak() {
        #expect(streak(vitamins, done(vitamins, 9, 10, 11), through: 11) == HabitStreak(current: 3, best: 3))
    }

    @Test func aMissedDayResetsCurrentButKeepsBest() {
        // Met 9, 10, 11, missed 12, met 13, 14.
        let entries = done(vitamins, 9, 10, 11, 13, 14)
        #expect(streak(vitamins, entries, through: 14) == HabitStreak(current: 2, best: 3))
    }

    @Test func anUnfinishedTodayDoesNotBreakTheStreak() {
        // Met 9 and 10, and today (11) isn't done yet.
        #expect(streak(vitamins, done(vitamins, 9, 10), through: 11) == HabitStreak(current: 2, best: 2))
    }

    @Test func aMissedDayBeforeTodayStillBreaksIt() {
        // Met 9, missed 10, and today (11) isn't done yet.
        #expect(streak(vitamins, done(vitamins, 9), through: 11) == HabitStreak(current: 0, best: 1))
    }

    @Test func daysTheHabitIsNotDueNeitherCountNorBreak() {
        // Gym is due Mon 9, Wed 11 and Fri 13. Tuesday and Thursday are skipped, not missed.
        #expect(streak(gym, done(gym, 9, 11, 13), through: 15) == HabitStreak(current: 3, best: 3))
    }

    @Test func logsOnUnscheduledDaysAreIgnored() {
        // Met Mon 9, also logged Tue 10 (not due), then missed Wed 11. The Tuesday log adds nothing.
        let entries = done(gym, 9, 10)
        #expect(streak(gym, entries, through: 12) == HabitStreak(current: 0, best: 1))
    }

    @Test func aPartialGoalDoesNotCount() {
        // Water: full on 9, half on 10, full on 11 (today).
        let entries = done(water, 9, 11) + done(water, 10, amount: 1250)
        #expect(streak(water, entries, through: 11) == HabitStreak(current: 1, best: 1))
    }

    @Test func daysBeforeTheStartAreIgnored() {
        // Met 9 to 11, but counting starts on the 10th.
        #expect(streak(vitamins, done(vitamins, 9, 10, 11), from: 10, through: 11) == HabitStreak(current: 2, best: 2))
    }

    @Test func noLogsMeansNoStreak() {
        #expect(streak(vitamins, [], through: 11) == HabitStreak(current: 0, best: 0))
    }
}
