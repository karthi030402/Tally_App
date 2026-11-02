import SwiftUI

/// One day in the month calendar: its number inside a progress ring colored by how the day went.
struct DayCell: View {
    static let size: CGFloat = 40

    let day: CalendarDay
    var palette: CompletionPalette = .daybreak
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                if let fraction = day.fraction {
                    Circle().stroke(palette.track(fraction), lineWidth: 3.5)
                    Circle()
                        .trim(from: 0, to: fraction)
                        .stroke(palette.color(fraction), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }
                if day.isSelected {
                    Circle()
                        .fill(Color.primary.opacity(0.12))
                        .padding(5)
                }
                Text("\(day.number)")
                    .font(.footnote.weight(day.isSelected ? .bold : .medium))
                    .foregroundStyle(day.isFuture ? .tertiary : (day.fraction == nil ? .secondary : .primary))
            }
            .frame(width: Self.size, height: Self.size)
        }
        .buttonStyle(.plain)
        .disabled(day.isFuture)
        .accessibilityLabel(day.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
        .accessibilityValue(day.fraction.map { "\(Int(($0 * 100).rounded())) percent" } ?? "Nothing scheduled")
        .accessibilityAddTraits(day.isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack(spacing: 8) {
        DayCell(day: CalendarDay(date: .now, number: 1, fraction: 1, isSelected: false, isFuture: false)) {}
        DayCell(day: CalendarDay(date: .now, number: 2, fraction: 0.6, isSelected: true, isFuture: false)) {}
        DayCell(day: CalendarDay(date: .now, number: 3, fraction: 0, isSelected: false, isFuture: false)) {}
        DayCell(day: CalendarDay(date: .now, number: 4, fraction: nil, isSelected: false, isFuture: false)) {}
        DayCell(day: CalendarDay(date: .now, number: 5, fraction: nil, isSelected: false, isFuture: true)) {}
    }
    .padding()
}
