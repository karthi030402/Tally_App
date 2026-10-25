import Testing
@testable import TallyCore

struct HabitModelTests {
    @Test func checkOffHasNoTargetStepOrUnit() {
        let habit = HabitModel(name: "Vitamins", symbol: "pills.fill", colorName: "gold",
                               kind: .checkOff, target: 5, step: 3, unit: "pills")
        #expect(habit.target == nil)
        #expect(habit.step == nil)
        #expect(habit.unit == nil)
    }

    @Test func counterAllowsFractionalTargetAndStep() {
        let habit = HabitModel(name: "Fruit", symbol: "leaf.fill", colorName: "coral",
                               kind: .counter, target: 1, step: 0.2, unit: "kg")
        #expect(habit.target == 1)
        #expect(habit.step == 0.2)
    }

    @Test func counterStepMustBePositiveAndNotExceedTarget() {
        let tooBig = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo",
                                kind: .counter, target: 2500, step: 5000, unit: "ml")
        let zero = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo",
                              kind: .counter, target: 2500, step: 0, unit: "ml")
        let negative = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo",
                                  kind: .counter, target: 2500, step: -5, unit: "ml")
        #expect(tooBig.step == 2500)
        #expect(zero.step == 2500)
        #expect(negative.step == 2500)
    }

    @Test func counterWithoutAValidTargetFallsBackToOne() {
        let missing = HabitModel(name: "Reading", symbol: "book.fill", colorName: "orchid", kind: .counter)
        let zero = HabitModel(name: "Reading", symbol: "book.fill", colorName: "orchid",
                              kind: .counter, target: 0)
        #expect(missing.target == 1)
        #expect(zero.target == 1)
    }

    @Test func blankUnitBecomesNil() {
        let habit = HabitModel(name: "Reading", symbol: "book.fill", colorName: "orchid",
                               kind: .counter, target: 20, step: 5, unit: "   ")
        #expect(habit.unit == nil)
    }

    @Test func missingOrBlankSymbolBecomesNil() {
        let missing = HabitModel(name: "Walk", colorName: "indigo", kind: .checkOff)
        let blank = HabitModel(name: "Walk", symbol: "  ", colorName: "indigo", kind: .checkOff)
        let chosen = HabitModel(name: "Walk", symbol: "figure.walk", colorName: "indigo", kind: .checkOff)
        #expect(missing.symbol == nil)
        #expect(blank.symbol == nil)
        #expect(chosen.symbol == "figure.walk")
    }

    @Test func displaySymbolFallsBackWhenNoSymbolChosen() {
        let none = HabitModel(name: "Walk", colorName: "indigo", kind: .checkOff)
        let chosen = HabitModel(name: "Walk", symbol: "figure.walk", colorName: "indigo", kind: .checkOff)
        #expect(none.displaySymbol == HabitModel.fallbackSymbol)
        #expect(chosen.displaySymbol == "figure.walk")
    }

    @Test func defaultAndEmptyWeekdaysBothMeanEveryDay() {
        let byDefault = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo", kind: .checkOff)
        let fromEmpty = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo",
                                   kind: .checkOff, weekdays: [])
        #expect(byDefault.isEveryDay)
        #expect(fromEmpty.isEveryDay)
        #expect(HabitWeekday.allCases.allSatisfy { fromEmpty.isScheduled(on: $0) })
    }

    @Test func selectedWeekdaysAreTheOnlyScheduledDays() {
        let gym = HabitModel(name: "Gym", symbol: "dumbbell.fill", colorName: "coral",
                             kind: .checkOff, weekdays: [.monday, .wednesday, .friday])
        #expect(!gym.isEveryDay)
        #expect(gym.isScheduled(on: .monday))
        #expect(!gym.isScheduled(on: .tuesday))
        #expect(!gym.isScheduled(on: .sunday))
    }

    @Test func weekdayRawValuesMatchCalendarNumbering() {
        #expect(HabitWeekday.sunday.rawValue == 1)
        #expect(HabitWeekday.monday.rawValue == 2)
        #expect(HabitWeekday.saturday.rawValue == 7)
        #expect(HabitWeekday.allCases.first == .monday)
        #expect(HabitWeekday.everyDay.count == 7)
    }
}
