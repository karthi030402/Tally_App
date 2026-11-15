import SwiftUI
import TallyCore

/// One row in the Habits tab: icon, name, goal and schedule, and the current streak.
/// Tapping the row does `onTap`, and the "more" button on the right does `onMore`.
struct HabitListCard: View {
    let habit: HabitModel
    let detailText: String
    let streakText: String
    let hasActiveStreak: Bool
    /// What VoiceOver says after the row, such as "Opens the habit to edit".
    let tapHint: String
    let onTap: () -> Void
    let onMore: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onTap) {
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

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(tapHint)

            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More options for \(habit.name)")
        }
        .padding(.vertical, 16)
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    let viewModel = HabitsViewModel(
        store: HabitStore(habits: SampleHabits.active, entries: SampleHabits.historyEntries() + SampleHabits.todayEntries())
    )
    VStack(spacing: 14) {
        ForEach(viewModel.habits) { habit in
            HabitListCard(
                habit: habit,
                detailText: viewModel.detailText(for: habit),
                streakText: viewModel.streakText(for: habit),
                hasActiveStreak: viewModel.streak(for: habit) > 0,
                tapHint: "Opens the habit to edit",
                onTap: {},
                onMore: {}
            )
        }
    }
    .padding()
    .background { DawnBackground() }
}
