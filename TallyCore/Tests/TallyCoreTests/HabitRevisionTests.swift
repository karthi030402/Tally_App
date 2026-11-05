import Testing
import Foundation
@testable import TallyCore

struct HabitRevisionTests {
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

    private func raisedGoal() -> HabitModel {
        let rule = HabitRule(kind: .counter, target: 3000, step: 250, unit: "ml")
        return water.changing(to: rule, from: march(11), calendar: calendar)
    }

    @Test func aNewHabitUsesTheSameRuleOnEveryDay() {
        #expect(water.rule(on: march(9), calendar: calendar) == water.currentRule)
        #expect(water.rule(on: .distantPast, calendar: calendar) == water.currentRule)
    }

    @Test func currentValuesFollowTheLatestChange() {
        #expect(raisedGoal().target == 3000)
        #expect(raisedGoal().step == 250)
    }

    @Test func daysBeforeTheChangeKeepTheOldGoal() {
        let habit = raisedGoal()
        #expect(habit.goalAmount(on: march(10), calendar: calendar) == 2500)
        #expect(habit.goalAmount(on: march(11), calendar: calendar) == 3000)
        #expect(habit.goalAmount(on: march(20), calendar: calendar) == 3000)
    }

    @Test func aPastDayStaysMetAfterTheGoalIsRaised() {
        let habit = raisedGoal()
        let entries = [
            HabitEntry(habitID: habit.id, date: march(9), amount: 2500),
            HabitEntry(habitID: habit.id, date: march(11), amount: 2500)
        ]
        #expect(habit.progress(from: entries, on: march(9), calendar: calendar).isMet)
        #expect(!habit.progress(from: entries, on: march(11), calendar: calendar).isMet)
    }

    @Test func aScheduleChangeOnlyAppliesFromItsDate() {
        // Gym moves from Mon/Wed/Fri to Tue/Thu, starting Thursday 12.
        let rule = HabitRule(kind: .checkOff, weekdays: [.tuesday, .thursday])
        let habit = gym.changing(to: rule, from: march(12), calendar: calendar)
        #expect(habit.isDue(on: march(9), calendar: calendar))    // Monday, old schedule
        #expect(!habit.isDue(on: march(10), calendar: calendar))  // Tuesday, old schedule
        #expect(!habit.isDue(on: march(16), calendar: calendar))  // Monday, new schedule
        #expect(habit.isDue(on: march(17), calendar: calendar))   // Tuesday, new schedule
    }

    @Test func aStreakKeepsItsPastWhenTheGoalIsRaised() {
        let habit = raisedGoal()
        let entries = (9...11).map { HabitEntry(habitID: habit.id, date: march($0), amount: 2500) }
        // 9 and 10 were met at the old goal. 11 is today and isn't met at the new goal yet.
        let streak = HabitStreaks.streak(of: habit, entries: entries, from: march(9), through: march(11), calendar: calendar)
        #expect(streak == HabitStreak(current: 2, best: 2))
    }

    @Test func aSecondChangeOnTheSameDayReplacesTheFirst() {
        let first = water.changing(to: HabitRule(kind: .counter, target: 3000, step: 250, unit: "ml"), from: march(11), calendar: calendar)
        let second = first.changing(to: HabitRule(kind: .counter, target: 2000, step: 250, unit: "ml"), from: march(11), calendar: calendar)
        #expect(second.changes.count == 1)
        #expect(second.target == 2000)
    }

    @Test func aChangeThatMatchesTheCurrentRuleIsNotRecorded() {
        let same = water.changing(to: water.currentRule, from: march(11), calendar: calendar)
        #expect(same.changes.isEmpty)
    }
}
