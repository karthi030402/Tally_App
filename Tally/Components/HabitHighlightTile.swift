import SwiftUI
import TallyCore

/// A tinted tile naming one habit, used for both "Best habit" and "Needs work".
struct HabitHighlightTile: View {
    let title: String
    let titleSymbol: String
    let tint: Color
    let highlight: HabitHighlight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: titleSymbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)

            HStack(spacing: 8) {
                Image(systemName: highlight.habit.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(highlight.habit.color.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(highlight.habit.name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
            }

            Text(highlight.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(tint.opacity(0.35), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(spacing: 14) {
        HabitHighlightTile(
            title: "BEST HABIT", titleSymbol: "star.fill", tint: CompletionPalette.daybreak.best,
            highlight: HabitHighlight(habit: SampleHabits.water, detail: "7 of 7 days met")
        )
        HabitHighlightTile(
            title: "NEEDS WORK", titleSymbol: "exclamationmark.triangle.fill", tint: CompletionPalette.daybreak.needsWork,
            highlight: HabitHighlight(habit: SampleHabits.gym, detail: "1 of 3 days met")
        )
    }
    .padding()
    .background { DawnBackground() }
}
