import SwiftUI
import TallyCore

/// The Habits tab: active habits, then archived habits. An empty section shows a placeholder.
/// Tapping a habit opens its page, and the ⋯ button on a card opens its options.
struct HabitsScreen: View {
    @State private var viewModel: HabitsViewModel
    /// Handed on to the pages this stack opens, so each one builds its own view model.
    private let store: HabitStore
    @State private var path: [HabitsRoute] = []
    /// The habit whose options sheet is open.
    @State private var optionsHabit: HabitModel?
    /// A habit another part of the app (a widget link) asked to open. Taken and cleared once handled.
    @Binding private var requestedHabitID: UUID?

    /// The screen owns its view model, which reads from the store shared by every tab.
    init(store: HabitStore, requestedHabitID: Binding<UUID?> = .constant(nil)) {
        self.store = store
        _requestedHabitID = requestedHabitID
        _viewModel = State(initialValue: HabitsViewModel(store: store))
    }

    private var activeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(HabitListSection.active.title(count: viewModel.habits.count))

            if viewModel.habits.isEmpty {
                EmptySectionCard(message: HabitListSection.active.emptyMessage)
            } else {
                ForEach(viewModel.habits) { habit in
                    card(for: habit)
                }
            }
        }
    }

    private var archivedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(HabitListSection.archived.title(count: viewModel.archivedHabits.count))
                .padding(.top, 8)

            if viewModel.archivedHabits.isEmpty {
                EmptySectionCard(message: HabitListSection.archived.emptyMessage)
            } else {
                ForEach(viewModel.archivedHabits) { habit in
                    card(for: habit)
                        .opacity(0.7)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }

    private func card(for habit: HabitModel) -> some View {
        HabitListCard(
            habit: habit,
            detailText: viewModel.detailText(for: habit),
            streakText: viewModel.streakText(for: habit),
            hasActiveStreak: viewModel.streak(for: habit) > 0,
            tapHint: "Opens the habit's page",
            onTap: { path.append(.habitDetail(habit.id)) },
            onMore: { optionsHabit = habit }
        )
    }

    /// Opens the page a link asked for, replacing whatever was open. A habit that no longer exists is ignored.
    private func openRequestedHabit() {
        guard let id = requestedHabitID else { return }
        requestedHabitID = nil
        guard store.allHabits.contains(where: { $0.id == id }) else { return }
        path = [.habitDetail(id)]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    activeSection
                    archivedSection
                }
                .padding(.horizontal)
            }
            .background { DawnBackground() }
            .navigationTitle("Habits")
            .sheet(item: $optionsHabit) { habit in
                HabitActionsSheet(
                    habit: habit,
                    deleteMessage: viewModel.deleteMessage(for: habit),
                    onToggleArchive: {
                        if habit.isArchived { viewModel.unarchive(habit) } else { viewModel.archive(habit) }
                    },
                    onDelete: { viewModel.delete(habit) }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape") { path.append(.settings) }
                }
                
                // A fixed gap splits the buttons into two separate round glass backgrounds.
                if #available(iOS 26, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Habit", systemImage: "plus") {
                        path.append(.addHabit)
                    }
                }
            }
            .navigationDestination(for: HabitsRoute.self) { route in
                switch route {
                case .addHabit:
                    AddHabitScreen {
                        viewModel.add($0)
                    }
                case .habitDetail(let id):
                    HabitDetailScreen(store: store, habitID: id) {
                        path.append(.editHabit(id))
                    }
                    // A link can swap one habit's page for another's, and the page keeps its view model.
                    .id(id)
                case .editHabit(let id):
                    // Looked up when the screen is built, in case the habit is gone by then.
                    if let habit = viewModel.habit(id: id) {
                        AddHabitScreen(editing: habit) {
                            viewModel.update($0)
                        }
                    }
                case .settings:
                    SettingsScreen()
                }
            }
        }
        // On the stack itself, so it still fires while a page covers the list.
        .onAppear(perform: openRequestedHabit)
        .onChange(of: requestedHabitID) { openRequestedHabit() }
    }
}

#Preview("Habits") {
    HabitsScreen(store: SampleHabits.makeStore())
}

#Preview("Empty") {
    HabitsScreen(store: HabitStore())
}

#Preview("No archived") {
    HabitsScreen(store: HabitStore(habits: SampleHabits.active, entries: SampleHabits.historyEntries() + SampleHabits.todayEntries()))
}
