import SwiftUI
import TallyCore

/// The Streaks card: each habit with its details on top, and its current and best streak below.
struct StreaksCard: View {
    let rows: [HabitStreakRow]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Streaks")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                ForEach(rows) { row in
                    streakRow(row)
                }
            }
        }
    }

    private func streakRow(_ row: HabitStreakRow) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: row.habit.iconName)
                .foregroundStyle(row.habit.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(row.habit.name)
                    .font(.subheadline.weight(.medium))
                // Each stat takes half the width, so "Best" starts in the same place in every row.
                HStack(spacing: 0) {
                    stat("Current", row.currentText)
                    stat("Best", row.bestText)
                }
            }
        }
        // One spoken line per habit, instead of a stop for every piece of text.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(row.habit.name), current streak \(row.currentText), best streak \(row.bestText)")
    }

    private func stat(_ title: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text(title).foregroundStyle(.secondary)
            Text(value).fontWeight(.semibold)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StreaksCard(rows: [
        HabitStreakRow(habit: SampleHabits.water, currentText: "12 days", bestText: "20 days"),
        HabitStreakRow(habit: SampleHabits.vitamins, currentText: "1 day", bestText: "9 days"),
        HabitStreakRow(habit: SampleHabits.gym, currentText: "0 days", bestText: "6 days")
    ])
    .padding()
    .background { DawnBackground() }
}
