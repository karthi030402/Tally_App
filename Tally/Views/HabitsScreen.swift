import SwiftUI
import TallyCore

/// The Habits tab: active habits, then archived habits. An empty section shows a placeholder.
struct HabitsScreen: View {
    @State private var viewModel: HabitsViewModel
    @State private var path: [HabitsRoute] = []

    /// The screen owns its view model, which reads from the store shared by every tab.
    init(store: HabitStore) {
        self.init(viewModel: HabitsViewModel(store: store))
    }

    /// Previews and tests can pass their own view model.
    init(viewModel: HabitsViewModel) {
        _viewModel = State(initialValue: viewModel)
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
            hasActiveStreak: viewModel.streak(for: habit) > 0
        )
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
                case .settings:
                    SettingsScreen()
                }
            }
        }
    }
}

#Preview("Habits") {
    HabitsScreen(store: SampleHabits.makeStore())
}

#Preview("Empty") {
    HabitsScreen(store: HabitStore())
}

#Preview("No archived") {
    HabitsScreen(store: HabitStore(habits: SampleHabits.active, streaks: SampleHabits.streaks))
}
