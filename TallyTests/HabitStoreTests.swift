import Testing
import Foundation
import TallyCore
@testable import Tally

@MainActor
struct HabitStoreTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }

    /// March 2026 at noon UTC. 9 March 2026 is a Monday.
    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let water = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")

    private func editedWater(target: Double = 3000) -> HabitModel {
        HabitModel(id: water.id, name: "Hydration", symbol: "cup.and.saucer.fill", colorName: "sky",
                   kind: .counter, target: target, step: 250, unit: "ml")
    }

    private func storeWithOneLoggedDay() -> HabitStore {
        HabitStore(habits: [water], entries: [HabitEntry(habitID: water.id, date: march(9), amount: 2500)])
    }

    @Test func updateChangesNameIconAndColorEverywhere() {
        let store = storeWithOneLoggedDay()
        store.update(editedWater(), from: march(11), calendar: calendar)
        #expect(store.habits.first?.name == "Hydration")
        #expect(store.habits.first?.symbol == "cup.and.saucer.fill")
        #expect(store.habits.first?.colorName == "sky")
    }

    @Test func updateKeepsPastDaysOnTheOldGoal() throws {
        let store = storeWithOneLoggedDay()
        store.update(editedWater(), from: march(11), calendar: calendar)
        let habit = try #require(store.habits.first)
        #expect(habit.progress(from: store.entries, on: march(9), calendar: calendar).isMet)
        #expect(habit.goalAmount(on: march(11), calendar: calendar) == 3000)
    }

    @Test func updateKeepsTheLogs() {
        let store = storeWithOneLoggedDay()
        store.update(editedWater(), from: march(11), calendar: calendar)
        #expect(store.entries.count == 1)
    }

    @Test func updateIgnoresAHabitThatIsNotInTheStore() {
        let store = storeWithOneLoggedDay()
        store.update(HabitModel(name: "Other", colorName: "gold", kind: .checkOff), from: march(11), calendar: calendar)
        #expect(store.habits.count == 1)
        #expect(store.habits.first?.name == "Water")
    }
}
