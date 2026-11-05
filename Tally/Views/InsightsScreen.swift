import SwiftUI
import TallyCore

/// The Insights tab: this week's report, best and worst habits, the daily chart,
/// the month calendar, and how the selected day went.
struct InsightsScreen: View {
    @State private var viewModel: InsightsViewModel
    private let palette = CompletionPalette.daybreak

    init(store: HabitStore) {
        self.init(viewModel: InsightsViewModel(store: store))
    }

    init(viewModel: InsightsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    WeeklyReportCard(
                        rangeText: viewModel.weekRangeText,
                        percentText: viewModel.weekPercentText,
                        caption: viewModel.weekCaption
                    )
                    
                    highlights
                    
                    DailyCompletionChart(
                        completions: viewModel.chartCompletions,
                        habits: viewModel.habits,
                        habitFilter: $viewModel.chartHabitID,
                        scrollStart: viewModel.chartScrollStart,
                        palette: palette
                    )
                    
                    MonthCalendarCard(
                        months: viewModel.calendarPages,
                        weekdayLabels: viewModel.weekdayLabels,
                        habits: viewModel.habits,
                        habitFilter: $viewModel.calendarHabitID,
                        visibleMonth: $viewModel.visibleMonth,
                        onSelectDay: {
                            viewModel.selectedDay = $0
                        },
                        palette: palette
                    )
                    
                    SelectedDayCard(
                        title: viewModel.selectedDayTitle,
                        fraction: viewModel.selectedDayFraction,
                        rows: viewModel.selectedDayRows,
                        palette: palette
                    )
                    streaks
                }
                .padding(.horizontal)
            }
            .background { DawnBackground() }
            .navigationTitle("Insights")
        }
    }

    /// The Streaks card, left out when there are no habits.
    @ViewBuilder
    private var streaks: some View {
        let rows = viewModel.streakRows
        if !rows.isEmpty {
            StreaksCard(rows: rows)
        }
    }

    /// The Best tile, with the Needs-work tile beside it when there is one.
    @ViewBuilder
    private var highlights: some View {
        if let best = viewModel.bestHabit {
            HStack(spacing: 14) {
                HabitHighlightTile(title: "BEST HABIT", titleSymbol: "star.fill", tint: palette.best, highlight: best)
                if let needsWork = viewModel.needsWorkHabit {
                    HabitHighlightTile(
                        title: "NEEDS WORK", titleSymbol: "exclamationmark.triangle.fill",
                        tint: palette.needsWork, highlight: needsWork
                    )
                }
            }
        }
    }
}

#Preview("Insights") {
    InsightsScreen(store: SampleHabits.makeStore())
}

#Preview("No habits") {
    InsightsScreen(store: HabitStore())
}
