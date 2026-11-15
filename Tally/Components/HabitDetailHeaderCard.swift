import SwiftUI
import TallyCore

/// The top of a habit's page: its icon, name, goal and schedule, and an Archived badge if needed.
struct HabitDetailHeaderCard: View {
    let habit: HabitModel
    let detailText: String
    let isArchived: Bool

    var body: some View {
        AppCard {
            HStack(spacing: 14) {
                Image(systemName: habit.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(habit.color.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.title2.weight(.bold))
                    Text(detailText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if isArchived {
                        Label("Archived", systemImage: "archivebox.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 14) {
        HabitDetailHeaderCard(habit: SampleHabits.water, detailText: SampleHabits.water.detailText, isArchived: false)
        HabitDetailHeaderCard(habit: SampleHabits.meditation, detailText: SampleHabits.meditation.detailText, isArchived: true)
    }
    .padding()
    .background { DawnBackground() }
}
