import SwiftUI
import TallyCore

/// The Add Habit form. It's pushed onto the Habits stack; Save hands the new habit to `onSave`.
struct AddHabitScreen: View {
    @State private var viewModel: AddHabitViewModel
    @FocusState private var focus: HabitFormField?
    @Environment(\.dismiss) private var dismiss
    private let onSave: (HabitModel) -> Void

    init(onSave: @escaping (HabitModel) -> Void) {
        self.init(viewModel: AddHabitViewModel(), onSave: onSave)
    }

    /// Previews and tests can pass their own view model.
    init(viewModel: AddHabitViewModel, onSave: @escaping (HabitModel) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSave = onSave
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    nameField
                    typeGroup
                    if viewModel.isGoal { goalFields }
                    scheduleField
                    colorField
                    iconField
                }
                .padding(20)
                .animation(.easeInOut(duration: 0.2), value: viewModel.kind)
            }
            .scrollDismissesKeyboard(.interactively)
            .background { DawnBackground() }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back", systemImage: "chevron.left") { goBack() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(scrollingWith: proxy) }
                }
                // Number keyboards have no Return key, so this button moves on or finishes.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(keyboardButtonTitle) { advance(from: focus) }
                }
            }
        }
        .sheet(item: $viewModel.activeSheet) { sheet in
            sheetContent(for: sheet)
        }
        .alert("Step not set", isPresented: $viewModel.showsStepAlert) {
            Button("Save") { finish(with: viewModel.makeHabit()) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(viewModel.stepAlertMessage)
        }
        .alert("Discard changes?", isPresented: $viewModel.showsDiscardAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Going back will discard them.")
        }
        .task { focus = .name }
    }

    /// Back asks first if anything was entered; otherwise it just leaves.
    private func goBack() {
        focus = nil
        if viewModel.hasUnsavedChanges {
            viewModel.showsDiscardAlert = true
        } else {
            dismiss()
        }
    }

    // MARK: Fields
    private var nameField: some View {
        FormTextField(
            title: "Name",
            placeholder: "e.g. Drink water",
            text: $viewModel.name,
            isRequired: true,
            errorMessage: viewModel.nameError,
            submitLabel: submitLabel(for: .name),
            onSubmit: {
                advance(from: .name)
            },
            focus: $focus,
            fieldID: .name
        )
        .id(HabitFormField.name)
    }

    private var typeGroup: some View {
        RadioGroup(
            title: "Type",
            isRequired: true,
            options: HabitKind.allCases,
            selection: $viewModel.kind,
            optionTitle: \.title,
            optionDescription: {
                $0.summary
            }
        )
    }

    @ViewBuilder
    private var goalFields: some View {
        FormTextField(
            title: "Goal",
            placeholder: "2500",
            text: $viewModel.goalText,
            isRequired: true,
            description: "The amount to reach each day. Decimals are fine, like 1.5.",
            errorMessage: viewModel.goalError,
            keyboard: .decimalPad,
            focus: $focus,
            fieldID: .goal
        )
        .id(HabitFormField.goal)

        FormTextField(
            title: "Step",
            placeholder: "Same as the goal",
            text: $viewModel.stepText,
            description: "How much each tap adds. Leave empty to add the whole goal in one tap.",
            errorMessage: viewModel.stepError,
            keyboard: .decimalPad,
            focus: $focus,
            fieldID: .step
        )
        .id(HabitFormField.step)

        FormTextField(
            title: "Unit",
            placeholder: "e.g. ml, pages, glasses",
            text: $viewModel.unit,
            description: "Optional. Shown after numbers, like ml or pages.",
            submitLabel: submitLabel(for: .unit),
            onSubmit: {
                advance(from: .unit)
            },
            focus: $focus,
            fieldID: .unit
        )
    }

    private var scheduleField: some View {
        FormTextField(
            title: "Schedule",
            placeholder: "Choose days",
            text: .constant(viewModel.scheduleSummary),
            type: .dropdown,
            description: "The days this habit is due. Streaks only count these days.",
            action: {
                viewModel.activeSheet = .schedule
            },
            isActive: viewModel.activeSheet == .schedule,
            focus: $focus,
            fieldID: .schedule
        )
    }

    private var colorField: some View {
        FormTextField(
            title: "Color",
            placeholder: "Choose",
            text: .constant(viewModel.colorTitle),
            type: .dropdown,
            action: {
                viewModel.activeSheet = .color
            },
            isActive: viewModel.activeSheet == .color,
            focus: $focus,
            fieldID: .color
        )
    }

    private var iconField: some View {
        FormTextField(
            title: "Icon",
            placeholder: "Default",
            text: .constant(viewModel.iconTitle),
            type: .dropdown,
            description: "Optional. A default icon is used if you skip it.",
            action: {
                viewModel.activeSheet = .icon
            },
            isActive: viewModel.activeSheet == .icon,
            focus: $focus,
            fieldID: .icon
        )
    }

    @ViewBuilder
    private func sheetContent(for sheet: AddHabitSheet) -> some View {
        switch sheet {
        case .schedule:
            WeekdaySelectionSheet(selection: $viewModel.weekdays)
        case .color:
            ColorPickerSheet(selection: $viewModel.colorKey)
        case .icon:
            IconPickerSheet(selection: $viewModel.symbol, tint: HabitAppearance.color(forKey: viewModel.colorKey))
        }
    }

    // MARK: Focus and saving
    private func submitLabel(for field: HabitFormField) -> SubmitLabel {
        viewModel.nextField(after: field) == nil ? .done : .next
    }

    private var keyboardButtonTitle: String {
        guard let focus, viewModel.nextField(after: focus) != nil else { return "Done" }
        return "Next"
    }

    /// Moves to the next text field, or closes the keyboard after the last one.
    private func advance(from field: HabitFormField?) {
        guard let field, let next = viewModel.nextField(after: field) else {
            focus = nil
            return
        }
        focus = next
    }

    private func save(scrollingWith proxy: ScrollViewProxy) {
        focus = nil
        if let habit = viewModel.attemptSave() {
            finish(with: habit)
        } else if let field = viewModel.firstInvalidField {
            withAnimation {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }

    private func finish(with habit: HabitModel) {
        onSave(habit)
        dismiss()
    }
}

#Preview("Check-off") {
    NavigationStack { AddHabitScreen { _ in } }
}

/// A form set to Goal with nothing filled in and a failed Save, so the errors show.
private extension AddHabitViewModel {
    static func goalWithErrors() -> AddHabitViewModel {
        let viewModel = AddHabitViewModel()
        viewModel.kind = .counter
        _ = viewModel.attemptSave()
        return viewModel
    }
}

#Preview("Goal with errors") {
    NavigationStack { AddHabitScreen(viewModel: .goalWithErrors()) { _ in } }
}
