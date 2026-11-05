import Foundation
import Observation
import TallyCore

/// The state and rules behind the Add Habit form. It also drives the edit form, which opens
/// with an existing habit's values filled in.
@MainActor
@Observable
final class AddHabitViewModel {
    // MARK: Editing
    /// The habit being edited, or nil when adding a new one.
    private let original: HabitModel?
    /// What the fields held when the form opened, to tell whether anything changed.
    private let initialValues: FormValues

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
    var showsFromTodayAlert = false
    var showsDiscardAlert = false
    /// Errors stay hidden until the first Save attempt, then update as the user fixes things.
    private(set) var hasTriedToSave = false

    private static let maxNameLength = 40
    private static let defaultColorKey = "indigo"

    /// The fields as they were when the form opened.
    private struct FormValues: Equatable {
        var name = ""
        var kind: HabitKind = .checkOff
        var goalText = ""
        var stepText = ""
        var unit = ""
        var weekdays = HabitWeekday.everyDay
        var colorKey = AddHabitViewModel.defaultColorKey
        var symbol: String?

        /// A blank form.
        init() {}

        /// The fields of an existing habit, as the form shows them.
        init(habit: HabitModel) {
            name = habit.name
            kind = habit.kind
            goalText = habit.target?.habitAmountText ?? ""
            stepText = habit.step?.habitAmountText ?? ""
            unit = habit.unit ?? ""
            weekdays = habit.weekdays
            colorKey = habit.colorName
            symbol = habit.symbol
        }
    }

    /// A blank form for a new habit.
    init() {
        original = nil
        initialValues = FormValues()
    }

    /// A form filled in from an existing habit. The type can't be changed.
    init(editing habit: HabitModel) {
        let values = FormValues(habit: habit)
        original = habit
        initialValues = values
        name = values.name
        kind = values.kind
        goalText = values.goalText
        stepText = values.stepText
        unit = values.unit
        weekdays = values.weekdays
        colorKey = values.colorKey
        symbol = values.symbol
    }

    private var currentValues: FormValues {
        var values = FormValues()
        values.name = name
        values.kind = kind
        values.goalText = goalText
        values.stepText = stepText
        values.unit = unit
        values.weekdays = weekdays
        values.colorKey = colorKey
        values.symbol = symbol
        return values
    }

    /// True when anything differs from how the form opened.
    var hasUnsavedChanges: Bool { currentValues != initialValues }

    var isEditing: Bool { original != nil }
    var screenTitle: String { isEditing ? "Edit Habit" : "New Habit" }

    /// Shown at the bottom of the form when editing.
    var editNote: String? {
        isEditing ? "Changes to the goal, step, unit or schedule apply from today. Past days keep what they had." : nil
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
    /// Called by Save. Returns the habit when it's ready to save. Otherwise it shows the errors
    /// or an alert, and returns nil.
    func attemptSave() -> HabitModel? {
        hasTriedToSave = true
        return proceed(stepConfirmed: false, dateConfirmed: false)
    }

    /// The "step not set" alert's Save button. It moves on to the next check.
    func confirmEmptyStep() -> HabitModel? {
        proceed(stepConfirmed: true, dateConfirmed: false)
    }

    /// The "from today" alert's Save button.
    func confirmFromToday() -> HabitModel? {
        proceed(stepConfirmed: true, dateConfirmed: true)
    }

    /// Runs the remaining checks in order: errors, then the step alert, then the from-today alert.
    private func proceed(stepConfirmed: Bool, dateConfirmed: Bool) -> HabitModel? {
        guard firstInvalidField == nil else { return nil }
        if isGoal && stepText.isEmpty && !stepConfirmed {
            showsStepAlert = true
            return nil
        }
        if changesGoalOrSchedule && !dateConfirmed {
            showsFromTodayAlert = true
            return nil
        }
        return makeHabit()
    }

    /// The goal and schedule the fields describe.
    private var currentRule: HabitRule {
        HabitRule(
            kind: kind,
            target: isGoal ? goalValue : nil,
            step: isGoal ? stepValue : nil,
            unit: isGoal ? unit : nil,
            weekdays: weekdays
        )
    }

    /// What the edit changed about the goal and schedule, or nil when it changed neither:
    /// a rename, a new color or icon, no change at all, or a new habit being added.
    private var ruleChange: HabitRuleChange? {
        guard let original else { return nil }
        let old = original.currentRule
        let new = currentRule
        let goalChanged = new.target != old.target || new.step != old.step || new.unit != old.unit
        let scheduleChanged = new.weekdays != old.weekdays
        switch (goalChanged, scheduleChanged) {
        case (true, true): return .goalAndSchedule
        case (true, false): return .goal
        case (false, true): return .schedule
        case (false, false): return nil
        }
    }

    /// True when editing and the goal, step, unit or schedule now differ from the habit's.
    var changesGoalOrSchedule: Bool { ruleChange != nil }

    /// The from-today alert text. Empty when nothing about the goal or schedule changed.
    var fromTodayAlertMessage: String {
        guard let ruleChange else { return "" }
        return "The new \(ruleChange.name) \(ruleChange.verb) from today. "
            + "Past days keep the \(ruleChange.name) they had, so your history and streaks stay as they were."
    }

    /// Builds the habit from the current fields. An empty step becomes the goal inside the model.
    /// When editing, it keeps the original's id so the store can find it.
    func makeHabit() -> HabitModel {
        HabitModel(
            id: original?.id ?? UUID(),
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
