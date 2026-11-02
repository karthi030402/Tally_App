import SwiftUI
import TallyCore

/// The month calendar card: a ring per day, months paged sideways, with a habit filter.
struct MonthCalendarCard: View {
    let months: [CalendarMonth]
    let weekdayLabels: [String]
    let habits: [HabitModel]
    @Binding var habitFilter: UUID?
    /// The first day of the month on screen. Optional because a paging scroll view needs that.
    @Binding var visibleMonth: Date?
    let onSelectDay: (Date) -> Void
    var palette: CompletionPalette = .daybreak

    private static let rowSpacing: CGFloat = 8

    private var visibleIndex: Int? {
		months.firstIndex {
			$0.start == visibleMonth
		}
    }

    private func canShift(by step: Int) -> Bool {
        guard let visibleIndex else { return false }
        return months.indices.contains(visibleIndex + step)
    }

    private func shift(by step: Int) {
        guard canShift(by: step), let visibleIndex else { return }
        withAnimation {
			visibleMonth = months[visibleIndex + step].start
		}
    }

    var body: some View {
        AppCard {
			VStack(alignment: .leading, spacing: 12) {
				header
				weekdayHeader
				pages
                CompletionLegend(palette: palette)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            if let visibleMonth {
                Text(visibleMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)
            }
            Button("Previous month", systemImage: "chevron.left") { shift(by: -1) }
                .disabled(!canShift(by: -1))
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            Button("Next month", systemImage: "chevron.right") { shift(by: 1) }
                .disabled(!canShift(by: 1))
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            Spacer()
            HabitFilterMenu(habits: habits, selection: $habitFilter)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        // Each day announces its own full date, so the letters would only be noise.
        .accessibilityHidden(true)
    }

    /// One page per month, swiped sideways. Plain stacks (not lazy) keep the cell sizes stable.
    private var pages: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(months) { month in
                    monthPage(month)
                        .containerRelativeFrame(.horizontal)
                        .id(month.start)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $visibleMonth)
        .defaultScrollAnchor(.trailing)
        .frame(height: 6 * DayCell.size + 5 * Self.rowSpacing)
    }

    private func monthPage(_ month: CalendarMonth) -> some View {
        VStack(spacing: Self.rowSpacing) {
            ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 4) {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                        Group {
                            if let day {
                                DayCell(day: day, palette: palette) {
									onSelectDay(day.date)
								}
                            } else {
                                Color.clear
									.frame(width: DayCell.size, height: DayCell.size)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    MonthCalendarCardPreview()
}

/// Wires the calendar to sample data so the preview shows real rings.
private struct MonthCalendarCardPreview: View {
    @State private var viewModel = InsightsViewModel(store: SampleHabits.makeStore())

    var body: some View {
        ScrollView {
            MonthCalendarCard(
                months: viewModel.calendarPages,
                weekdayLabels: viewModel.weekdayLabels,
                habits: viewModel.habits,
                habitFilter: $viewModel.calendarHabitID,
                visibleMonth: $viewModel.visibleMonth,
                onSelectDay: { viewModel.selectedDay = $0 }
            )
            .padding()
        }
        .background { DawnBackground() }
    }
}
