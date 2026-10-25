import SwiftUI
import TallyCore

/// One habit on the Today screen: progress ring, name, progress text, and a logging control.
struct TodayHabitCard: View {
    let habit: HabitModel
    let progress: HabitProgress
    let subtitle: String
    /// The label on a goal habit's button, such as "+250 ml".
    let buttonTitle: String
    let canUndo: Bool
    let onTap: () -> Void
    let onCustomAmount: () -> Void
    let onUndoLast: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            HabitProgressRing(progress: progress.fraction, color: habit.color, symbol: habit.iconName)

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            control
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var control: some View {
        switch habit.kind {
        case .checkOff:
            Button(action: onTap) {
                Image(systemName: progress.isMet ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(progress.isMet ? habit.color : habit.color.opacity(0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(progress.isMet ? "Mark \(habit.name) not done" : "Mark \(habit.name) done")
        case .counter:
            Menu {
                Button("Custom amount…", systemImage: "keyboard", action: onCustomAmount)
                Button("Undo last entry", systemImage: "arrow.uturn.backward", action: onUndoLast)
                    .disabled(!canUndo)
            } label: {
                Text(buttonTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(habit.color, in: Capsule())
            } primaryAction: {
                onTap()
            }
            .accessibilityLabel("Log \(buttonTitle) for \(habit.name)")
        }
    }
}
