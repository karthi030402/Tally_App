import SwiftUI
import TallyCore
import TallyStorage

/// One habit's page: its header, streaks, completion rates, and its own month calendar with a
/// card for the tapped day. It closes itself if the habit is deleted while it is open.
struct HabitDetailScreen: View {
    @State private var viewModel: HabitDetailViewModel
    /// Opens the edit form. The Habits tab supplies it, since that is where the stack lives.
    private let onEdit: () -> Void
    @State private var showsOptions = false
    @Environment(\.dismiss) private var dismiss

    init(store: HabitStore, habitID: UUID, onEdit: @escaping () -> Void) {
        self.init(viewModel: HabitDetailViewModel(store: store, habitID: habitID), onEdit: onEdit)
    }

    /// Previews and tests can pass their own view model.
    init(viewModel: HabitDetailViewModel, onEdit: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onEdit = onEdit
    }

    var body: some View {
        ScrollView {
            if let habit = viewModel.habit {
                VStack(spacing: 14) {
                    HabitDetailHeaderCard(habit: habit, detailText: viewModel.detailText, isArchived: viewModel.isArchived)
                    HabitStreakStatsCard(currentText: viewModel.currentStreakText, bestText: viewModel.bestStreakText)
                    HabitRatesCard(summaries: viewModel.rateSummaries, totalText: viewModel.totalLoggedText)
                    MonthCalendarCard(
                        months: viewModel.calendarPages,
                        weekdayLabels: viewModel.weekdayLabels,
                        visibleMonth: $viewModel.visibleMonth,
                        onSelectDay: { viewModel.selectedDay = $0 }
                    )
                    SelectedDayCard(
                        title: viewModel.selectedDayTitle,
                        fraction: viewModel.selectedDayFraction,
                        rows: viewModel.selectedDayRows
                    )
                }
                .padding(.horizontal)
            }
        }
        .background { DawnBackground() }
        .navigationTitle(viewModel.habit?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.canEdit {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "pencil", action: onEdit)
                }
                // A fixed gap splits the buttons into two separate round glass backgrounds.
                if #available(iOS 26, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("More options", systemImage: "ellipsis") { showsOptions = true }
            }
        }
        .sheet(isPresented: $showsOptions) {
            if let habit = viewModel.habit {
                HabitActionsSheet(
                    habit: habit,
                    deleteMessage: viewModel.deleteMessage,
                    onToggleArchive: { viewModel.toggleArchive() },
                    onDelete: { viewModel.delete() }
                )
            }
        }
        .onChange(of: viewModel.isMissing) { _, isMissing in
            if isMissing { dismiss() }
        }
    }
}

/// Stores for the previews, built here so the `#Preview` bodies stay a single expression.
private extension HabitStore {
    /// The sample store, where Water has a few months of history.
    static func previewActive() -> HabitStore { SampleHabits.makeStore() }

    /// Reading, archived yesterday, so its past still has rings and its future has none.
    static func previewArchived() -> HabitStore {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
        let reading = SampleHabits.reading.archiving(from: yesterday)
        let entries = SampleHabits.historyEntries() + SampleHabits.todayEntries()
        return HabitStore(repository: InMemoryHabitRepository(habits: [reading], entries: entries))
    }

    /// A habit that was just created, with nothing logged.
    static func previewNoLogs() -> HabitStore { HabitStore(habits: [SampleHabits.vitamins]) }
}

#Preview("Active") {
    NavigationStack { HabitDetailScreen(store: .previewActive(), habitID: SampleHabits.water.id, onEdit: {}) }
}

#Preview("Archived") {
    NavigationStack { HabitDetailScreen(store: .previewArchived(), habitID: SampleHabits.reading.id, onEdit: {}) }
}

#Preview("No logs") {
    NavigationStack { HabitDetailScreen(store: .previewNoLogs(), habitID: SampleHabits.vitamins.id, onEdit: {}) }
}
