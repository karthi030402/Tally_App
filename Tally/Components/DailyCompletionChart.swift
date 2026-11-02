import SwiftUI
import Charts
import TallyCore

/// The "Daily completion" card: one bar per day, colored by how much of the day was done.
/// It shows the last seven days and scrolls back through earlier weeks.
struct DailyCompletionChart: View {
    let completions: [DayCompletion]
    let habits: [HabitModel]
    @Binding var habitFilter: UUID?
    /// The first day shown when the chart opens.
    let scrollStart: Date
    var palette: CompletionPalette = .daybreak

    private static let visibleDays = 7

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Daily completion").font(.headline)
                    Spacer()
                    HabitFilterMenu(habits: habits, selection: $habitFilter)
                }

                chart

                Label("Swipe to see earlier weeks", systemImage: "arrow.left")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                CompletionLegend(palette: palette)
            }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(completions, id: \.date) { completion in
                if let fraction = completion.fraction {
                    BarMark(
                        x: .value("Day", completion.date, unit: .day),
                        y: .value("Completion", fraction * 100)
                    )
                    .foregroundStyle(palette.color(fraction))
                    .cornerRadius(5)
                }
            }
            RuleMark(y: .value("Target", 100))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(palette.target.opacity(0.7))
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: Double(Self.visibleDays) * 24 * 3600)
        .chartScrollPosition(initialX: scrollStart)
        .chartYScale(domain: 0...110)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 50, 100]) { value in
                AxisGridLine()
                AxisValueLabel("\(value.as(Int.self) ?? 0)%")
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(centered: true) {
                    if let date = value.as(Date.self) {
                        VStack(spacing: 2) {
                            Text(date, format: .dateTime.weekday(.narrow))
                            Text(date, format: .dateTime.day())
                                .fontWeight(.semibold)
                        }
                        .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 190)
    }
}

#Preview {
    DailyCompletionChartPreview()
}

/// Wires the chart to sample data so the preview can show real bars and the filter.
private struct DailyCompletionChartPreview: View {
    @State private var viewModel = InsightsViewModel(store: SampleHabits.makeStore())

    var body: some View {
        ScrollView {
            DailyCompletionChart(
                completions: viewModel.chartCompletions,
                habits: viewModel.habits,
                habitFilter: $viewModel.chartHabitID,
                scrollStart: viewModel.chartScrollStart
            )
            .padding()
        }
        .background { DawnBackground() }
    }
}
