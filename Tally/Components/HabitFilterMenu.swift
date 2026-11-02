import SwiftUI
import TallyCore

/// The "All habits" menu used by the bar chart and the calendar. A nil selection means all habits.
struct HabitFilterMenu: View {
    let habits: [HabitModel]
    @Binding var selection: UUID?

    private var selectedName: String {
        habits.first { $0.id == selection }?.name ?? "All habits"
    }

    var body: some View {
        Menu {
            Picker("Habit", selection: $selection) {
                Text("All habits")
                    .tag(UUID?.none)
                
                ForEach(habits) { habit in
                    Label(habit.name, systemImage: habit.iconName)
                        .tag(UUID?.some(habit.id))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedName)
                Image(systemName: "chevron.up.chevron.down").font(.caption2)
            }
            .font(.subheadline)
        }
        .accessibilityLabel("Filter by habit")
        .accessibilityValue(selectedName)
    }
}

#Preview {
    HabitFilterMenu(habits: SampleHabits.active, selection: .constant(nil))
        .padding()
}
