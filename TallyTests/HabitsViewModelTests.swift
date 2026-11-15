import Testing
import Foundation
import TallyCore
@testable import Tally

@MainActor
struct HabitsViewModelTests {
    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
    private let archived = HabitModel(name: "Meditation", colorName: "gold", kind: .checkOff)

    private func viewModel() -> HabitsViewModel {
        HabitsViewModel(store: HabitStore(habits: [water], archivedHabits: [archived]))
    }

    @Test func lookupFindsAnActiveHabitById() {
        #expect(viewModel().habit(id: water.id)?.name == "Water")
    }

    @Test func lookupIgnoresArchivedAndUnknownIds() {
        let viewModel = viewModel()
        #expect(viewModel.habit(id: archived.id) == nil)
        #expect(viewModel.habit(id: UUID()) == nil)
    }

    @Test func updateSavesTheEditToTheStore() {
        let viewModel = viewModel()
        let edited = HabitModel(id: water.id, name: "Hydration", colorName: "sky", kind: .counter, target: 2500, step: 250, unit: "ml")
        viewModel.update(edited)
        #expect(viewModel.habit(id: water.id)?.name == "Hydration")
    }

    private func viewModelWithLogs(_ count: Int) -> HabitsViewModel {
        let entries = (0..<count).map { _ in HabitEntry(habitID: water.id, date: .now, amount: 250) }
        return HabitsViewModel(store: HabitStore(habits: [water], entries: entries))
    }

    @Test func archivingMovesAHabitToTheArchivedList() {
        let viewModel = viewModelWithLogs(0)
        viewModel.archive(water)
        #expect(viewModel.habits.isEmpty)
        #expect(viewModel.archivedHabits.map(\.name) == ["Water"])
    }

    @Test func unarchivingBringsItBack() {
        let viewModel = viewModelWithLogs(0)
        viewModel.archive(water)
        viewModel.unarchive(water)
        #expect(viewModel.habits.map(\.name) == ["Water"])
        #expect(viewModel.archivedHabits.isEmpty)
    }

    @Test func deletingRemovesTheHabit() {
        let viewModel = viewModelWithLogs(3)
        viewModel.delete(water)
        #expect(viewModel.habits.isEmpty)
        #expect(viewModel.archivedHabits.isEmpty)
    }

    @Test func theDeleteMessageSaysHowManyLogsGo() {
        #expect(viewModelWithLogs(0).deleteMessage(for: water) == "This permanently removes the habit. This can't be undone.")
        #expect(viewModelWithLogs(1).deleteMessage(for: water).contains("its 1 log,"))
        #expect(viewModelWithLogs(3).deleteMessage(for: water).contains("its 3 logs,"))
    }
}
