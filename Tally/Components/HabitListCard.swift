import SwiftUI
import TallyCore

/// One row in the Habits tab: icon, name, goal and schedule, and the current streak.
struct HabitListCard: View {
    let habit: HabitModel
    let detailText: String
    let streakText: String
    let hasActiveStreak: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: habit.iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(habit.color.gradient, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.headline)
                Text(detailText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label(streakText, systemImage: "flame.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(hasActiveStreak ? .orange : .secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let viewModel = HabitsViewModel(
        store: HabitStore(habits: SampleHabits.active, streaks: SampleHabits.streaks)
    )
    VStack(spacing: 14) {
        ForEach(viewModel.habits) { habit in
            HabitListCard(
                habit: habit,
                detailText: viewModel.detailText(for: habit),
                streakText: viewModel.streakText(for: habit),
                hasActiveStreak: viewModel.streak(for: habit) > 0
            )
        }
    }
    .padding()
    .background { DawnBackground() }
}
