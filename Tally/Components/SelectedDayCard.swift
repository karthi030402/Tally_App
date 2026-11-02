import SwiftUI
import TallyCore

/// The card under the calendar: how the selected day went overall, then habit by habit.
struct SelectedDayCard: View {
    let title: String
    /// 0 to 1, or nil when nothing was scheduled that day.
    let fraction: Double?
    let rows: [HabitDayDetail]
    var palette: CompletionPalette = .daybreak

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title).font(.headline)
                    Spacer()
                    if let fraction {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(palette.color(fraction))
                                .frame(width: 12, height: 12)
                            Text("\(Int((fraction * 100).rounded()))%")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                        }
                    } else {
                        Text("Nothing scheduled")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(rows) { row in
                    detailRow(row)
                }
            }
        }
    }

    private func detailRow(_ row: HabitDayDetail) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.habit.iconName)
                .foregroundStyle(row.habit.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(row.habit.name)
						.font(.subheadline.weight(.medium))
                    Spacer()
                    Text(row.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let fraction = row.fraction {
                    ProgressView(value: fraction)
                        .tint(palette.color(fraction))
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SelectedDayCard(
        title: "Monday, Oct 26",
        fraction: 0.8,
        rows: [
            HabitDayDetail(habit: SampleHabits.water, fraction: 0.6, text: "1500 / 2500 ml"),
            HabitDayDetail(habit: SampleHabits.vitamins, fraction: 1, text: "Done"),
            HabitDayDetail(habit: SampleHabits.gym, fraction: nil, text: "Not scheduled")
        ]
    )
    .padding()
    .background { DawnBackground() }
}
