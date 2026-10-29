import SwiftUI
import TallyCore

/// The Today tab: today's progress, then the habits due, then the ones not scheduled.
struct TodayScreen: View {
    @State private var viewModel: TodayViewModel
    @State private var customAmountHabit: HabitModel?
    @State private var customAmountText = ""
    @State private var showsNotScheduled = false

    init(store: HabitStore) {
        self.init(viewModel: TodayViewModel(store: store))
    }

    init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(viewModel.dateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    summaryCard
                    dueSection
                    notScheduledSection
                }
                .padding(.horizontal)
            }
            .background { DawnBackground() }
            .navigationTitle("Today")
            .alert("Log amount", isPresented: customAmountIsPresented, presenting: customAmountHabit) { habit in
                TextField("Amount", text: $customAmountText)
                    .keyboardType(.decimalPad)
                Button("Add") {
                    viewModel.logCustom(habit, text: customAmountText)
                }
                Button("Cancel", role: .cancel) {}
            } message: { habit in
                Text("How much \(habit.name) to add?")
            }
        }
    }

    // MARK: Sections
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(viewModel.summaryTitle)
                    .font(.headline)
                
                Spacer()
                
                Text(viewModel.summaryPercentText)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
            }
            
            ProgressView(value: viewModel.summaryFraction)
                .tint(AppTheme.accent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var dueSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(TodaySection.due.title(count: viewModel.dueHabits.count))
            if viewModel.dueHabits.isEmpty {
                EmptySectionCard(message: TodaySection.due.emptyMessage)
            } else {
                ForEach(viewModel.dueHabits) { habit in
                    card(for: habit)
                }
            }
        }
    }

    @ViewBuilder
    private var notScheduledSection: some View {
        if !viewModel.notScheduledHabits.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Button {
                    withAnimation { showsNotScheduled.toggle() }
                } label: {
                    HStack {
                        sectionTitle(TodaySection.notScheduled.title(count: viewModel.notScheduledHabits.count))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(showsNotScheduled ? 90 : 0))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                if showsNotScheduled {
                    ForEach(viewModel.notScheduledHabits) { habit in
                        card(for: habit).opacity(0.7)
                    }
                }
            }
        }
    }

    // MARK: Pieces
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }

    private func card(for habit: HabitModel) -> some View {
        TodayHabitCard(
            habit: habit,
            progress: viewModel.progress(for: habit),
            subtitle: viewModel.subtitle(for: habit),
            buttonTitle: viewModel.buttonTitle(for: habit),
            canUndo: viewModel.canUndo(habit),
            onTap: { viewModel.tap(habit) },
            onCustomAmount: {
                customAmountText = ""
                customAmountHabit = habit
            },
            onUndoLast: { viewModel.undoLast(habit) }
        )
    }

    private var customAmountIsPresented: Binding<Bool> {
        Binding(
            get: { customAmountHabit != nil },
            set: {
                if !$0 { customAmountHabit = nil }
            }
        )
    }
}

#Preview("Today") {
    TodayScreen(store: SampleHabits.makeStore())
}

#Preview("Nothing yet") {
    TodayScreen(store: HabitStore())
}
