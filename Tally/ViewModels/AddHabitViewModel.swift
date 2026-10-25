import Foundation
import Observation
import TallyCore

/// The state and rules behind the Add Habit form.
@MainActor
@Observable
final class AddHabitViewModel {
    // MARK: Fields
    var name = ""
    var kind: HabitKind = .checkOff
    var goalText = ""
    var stepText = ""
    var unit = ""
    var weekdays = HabitWeekday.everyDay
    var colorKey = AddHabitViewModel.defaultColorKey
    /// `nil` means no icon was chosen; the default icon is used.
    var symbol: String?

    // MARK: Screen state
    var activeSheet: AddHabitSheet?
    var showsStepAlert = false
    var showsDiscardAlert = false
    /// Errors stay hidden until the first Save attempt, then update as the user fixes things.
    private(set) var hasTriedToSave = false

    private static let maxNameLength = 40
    private static let defaultColorKey = "indigo"

    /// True when anything differs from a freshly opened form.
    var hasUnsavedChanges: Bool {
        !name.isEmpty ||
        kind != .checkOff ||
        !goalText.isEmpty ||
        !stepText.isEmpty ||
        !unit.isEmpty ||
        weekdays != HabitWeekday.everyDay ||
        colorKey != Self.defaultColorKey ||
        symbol != nil
    }

    var isGoal: Bool { kind == .counter }

    // MARK: Reading the fields
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    // The number fields only allow digits and one ".", so plain Double parsing is enough.
    private var goalValue: Double? { Double(goalText) }
    private var stepValue: Double? { Double(stepText) }

    // MARK: Errors
    var nameError: String? {
        guard hasTriedToSave else { return nil }
        if trimmedName.isEmpty { return "Enter a name." }
        if trimmedName.count > Self.maxNameLength { return "Use \(Self.maxNameLength) characters or fewer." }
        return nil
    }

    var goalError: String? {
        guard hasTriedToSave, isGoal else { return nil }
        guard let goal = goalValue, goal > 0 else { return "Enter a number above 0." }
        return nil
    }

    /// An empty step is allowed (it becomes the goal); a typed one must make sense.
    var stepError: String? {
        guard hasTriedToSave, isGoal, !stepText.isEmpty else { return nil }
        guard let step = stepValue, step > 0 else { return "Enter a number above 0." }
        if let goal = goalValue, step > goal { return "The step can't be larger than the goal." }
        return nil
    }

    var firstInvalidField: HabitFormField? {
        if nameError != nil { return .name }
        if goalError != nil { return .goal }
        if stepError != nil { return .step }
        return nil
    }

    // MARK: Text for the dropdown fields
    var scheduleSummary: String { HabitWeekday.summary(of: weekdays) }
    var colorTitle: String { colorKey.capitalized }
    var iconTitle: String { symbol.map(HabitAppearance.displayName(forSymbol:)) ?? "Default" }

    /// Shown when saving a goal habit without a step.
    var stepAlertMessage: String {
        let goal = goalValue?.habitAmountText ?? ""
        let unitText = unit.trimmingCharacters(in: .whitespaces)
        let amount = unitText.isEmpty ? goal : "\(goal) \(unitText)"
        return "No step was entered, so each tap will add the whole goal (\(amount)). Save anyway?"
    }

    // MARK: Moving between text fields
    /// The text fields currently on screen, in order.
    private var focusOrder: [HabitFormField] {
        isGoal ? [.name, .goal, .step, .unit] : [.name]
    }

    func nextField(after field: HabitFormField) -> HabitFormField? {
        guard let index = focusOrder.firstIndex(of: field), focusOrder.indices.contains(index + 1) else {
            return nil
        }
        return focusOrder[index + 1]
    }

    // MARK: Saving
    /// Called by Save. Returns the habit when it's ready to add. Otherwise it shows the errors,
    /// or the step alert, and returns nil.
    func attemptSave() -> HabitModel? {
        hasTriedToSave = true
        guard firstInvalidField == nil else { return nil }
        if isGoal && stepText.isEmpty {
            showsStepAlert = true
            return nil
        }
        return makeHabit()
    }

    /// Builds the habit from the current fields. An empty step becomes the goal inside the model.
    func makeHabit() -> HabitModel {
        HabitModel(
            name: trimmedName,
            symbol: symbol,
            colorName: colorKey,
            kind: kind,
            target: isGoal ? goalValue : nil,
            step: isGoal ? stepValue : nil,
            unit: isGoal ? unit : nil,
            weekdays: weekdays
        )
    }
}
