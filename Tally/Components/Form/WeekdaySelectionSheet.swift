import SwiftUI
import TallyCore

/// The schedule sheet: pick the days a habit is due. "Every day" is a shortcut, not a setting:
/// it shows as checked whenever all seven days are, and tapping it selects all seven.
/// At least one day always stays selected.
struct WeekdaySelectionSheet: View {
    @Binding var selection: Set<HabitWeekday>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row(title: "Every day",
                        isSelected: selection == HabitWeekday.everyDay
                    ) {
                        selection = HabitWeekday.everyDay
                    }
                }

                Section {
                    ForEach(HabitWeekday.allCases, id: \.self) { day in
                        row(title: day.name,
                            isSelected: selection.contains(day)
                        ) {
                            toggle(day)
                        }
                    }
                } footer: {
                    Text("At least one day must stay selected.")
                }
            }
            .scrollContentBackground(.hidden)
            .background { DawnBackground() }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func row(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .contentShape(Rectangle())
        }
        // The plain style keeps the label in normal text color; a list button would tint it.
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// Adds or removes a day, but never lets the selection become empty.
    private func toggle(_ day: HabitWeekday) {
        if selection.contains(day) {
            guard selection.count > 1 else { return }
            selection.remove(day)
        } else {
            selection.insert(day)
        }
    }
}

private struct WeekdaySelectionSheetPreview: View {
    @State private var selection: Set<HabitWeekday> = [.monday, .wednesday, .friday]

    var body: some View {
        WeekdaySelectionSheet(selection: $selection)
    }
}

#Preview {
    WeekdaySelectionSheetPreview()
}
