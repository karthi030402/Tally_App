import SwiftUI
import TallyCore

/// One habit in the medium widget: its icon in a progress ring, the name and how far it got.
struct HabitWidgetCell: View {
    let row: TodaySummary.Row

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().stroke(row.habit.color.opacity(0.2), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: row.progress.fraction)
                    .stroke(row.habit.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: row.habit.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(row.habit.color)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.habit.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(row.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }
}
