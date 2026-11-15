import Testing
import TallyCore
@testable import Tally

struct HabitModelTextTests {
    @Test func aDailyCheckOffReadsCheckOffDaily() {
        let habit = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
        #expect(habit.detailText == "Check-off · Daily")
        #expect(habit.scheduleText == "Daily")
    }

    @Test func aGoalNamesItsAmountAndUnit() {
        let habit = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday, .friday])
        #expect(habit.detailText.hasPrefix("Goal 2500 ml · "))
    }

    @Test func aGoalWithoutAUnitLeavesItOut() {
        let habit = HabitModel(name: "Read", colorName: "orchid", kind: .counter, target: 20, step: 5)
        #expect(habit.detailText == "Goal 20 · Daily")
    }
}

struct DayCountTextTests {
    @Test func oneIsSingularAndTheRestArePlural() {
        #expect(0.dayCountText == "0 days")
        #expect(1.dayCountText == "1 day")
        #expect(12.dayCountText == "12 days")
    }
}
