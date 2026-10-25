import SwiftUI

/// A circular progress ring with an icon in the middle.
struct HabitProgressRing: View {
    let progress: Double
    let color: Color
    let symbol: String

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.18), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: 52, height: 52)
        .animation(.easeOut(duration: 0.25), value: progress)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 20) {
        HabitProgressRing(progress: 0, color: .blue, symbol: "drop.fill")
        HabitProgressRing(progress: 0.6, color: .orange, symbol: "book.fill")
        HabitProgressRing(progress: 1, color: .green, symbol: "pills.fill")
    }
    .padding()
}
