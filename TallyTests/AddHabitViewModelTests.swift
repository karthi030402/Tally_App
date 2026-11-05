import Testing
import Foundation
import TallyCore
@testable import Tally

@MainActor
struct AddHabitViewModelTests {
    private let water = HabitModel(
        name: "Water", symbol: "drop.fill", colorName: "indigo",
        kind: .counter, target: 2500, step: 250, unit: "ml", weekdays: [.monday, .friday]
    )

    @Test func editingFillsEveryField() {
        let viewModel = AddHabitViewModel(editing: water)
        #expect(viewModel.name == "Water")
        #expect(viewModel.kind == .counter)
        #expect(viewModel.goalText == "2500")
        #expect(viewModel.stepText == "250")
        #expect(viewModel.unit == "ml")
        #expect(viewModel.weekdays == [.monday, .friday])
        #expect(viewModel.colorKey == "indigo")
        #expect(viewModel.symbol == "drop.fill")
        #expect(viewModel.isEditing)
    }

    @Test func anUntouchedFormHasNoUnsavedChanges() {
        #expect(!AddHabitViewModel().hasUnsavedChanges)
        #expect(!AddHabitViewModel(editing: water).hasUnsavedChanges)
    }

    @Test func anyChangeCountsAsUnsaved() {
        let editing = AddHabitViewModel(editing: water)
        editing.name = "Hydration"
        #expect(editing.hasUnsavedChanges)
        let adding = AddHabitViewModel()
        adding.name = "Read"
        #expect(adding.hasUnsavedChanges)
    }

    @Test func renamingAloneSavesWithoutAsking() {
        let viewModel = AddHabitViewModel(editing: water)
        viewModel.name = "Hydration"
        #expect(!viewModel.changesGoalOrSchedule)
        let saved = viewModel.attemptSave()
        #expect(saved?.id == water.id)
        #expect(saved?.name == "Hydration")
        #expect(!viewModel.showsFromTodayAlert)
    }

    @Test func changingTheGoalAsksBeforeSaving() {
        let viewModel = AddHabitViewModel(editing: water)
        viewModel.goalText = "3000"
        #expect(viewModel.changesGoalOrSchedule)
        #expect(viewModel.attemptSave() == nil)
        #expect(viewModel.showsFromTodayAlert)
        #expect(viewModel.fromTodayAlertMessage.contains("new goal applies from today"))
        let saved = viewModel.confirmFromToday()
        #expect(saved?.id == water.id)
        #expect(saved?.target == 3000)
    }

    @Test func changingTheScheduleAsksAndNamesTheSchedule() {
        let viewModel = AddHabitViewModel(editing: water)
        viewModel.weekdays = [.tuesday]
        #expect(viewModel.changesGoalOrSchedule)
        #expect(viewModel.attemptSave() == nil)
        #expect(viewModel.fromTodayAlertMessage.contains("new schedule applies from today"))
    }

    @Test func changingBothNamesBoth() {
        let viewModel = AddHabitViewModel(editing: water)
        viewModel.goalText = "3000"
        viewModel.weekdays = [.tuesday]
        _ = viewModel.attemptSave()
        #expect(viewModel.fromTodayAlertMessage.contains("new goal and schedule apply from today"))
    }

    @Test func neitherGoalNorScheduleChangedMeansNoMessage() {
        let untouched = AddHabitViewModel(editing: water)
        #expect(!untouched.changesGoalOrSchedule)
        #expect(untouched.fromTodayAlertMessage.isEmpty)

        // Changing a value and putting it back is also "no change".
        untouched.goalText = "3000"
        untouched.goalText = "2500"
        #expect(!untouched.changesGoalOrSchedule)

        // Only the name, color or icon changed.
        let cosmetic = AddHabitViewModel(editing: water)
        cosmetic.name = "Hydration"
        cosmetic.colorKey = "sky"
        cosmetic.symbol = "cup.and.saucer.fill"
        #expect(!cosmetic.changesGoalOrSchedule)
        #expect(cosmetic.fromTodayAlertMessage.isEmpty)
    }

    @Test func addingNeverAsksAboutToday() {
        let viewModel = AddHabitViewModel()
        viewModel.name = "Stretch"
        #expect(!viewModel.changesGoalOrSchedule)
        #expect(viewModel.attemptSave() != nil)
        #expect(!viewModel.showsFromTodayAlert)
    }

    @Test func theStepAlertComesBeforeTheFromTodayAlert() {
        let viewModel = AddHabitViewModel(editing: water)
        viewModel.goalText = "3000"
        viewModel.stepText = ""
        #expect(viewModel.attemptSave() == nil)
        #expect(viewModel.showsStepAlert)
        #expect(!viewModel.showsFromTodayAlert)
        #expect(viewModel.confirmEmptyStep() == nil)
        #expect(viewModel.showsFromTodayAlert)
    }
}
