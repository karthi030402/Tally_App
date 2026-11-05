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
}
