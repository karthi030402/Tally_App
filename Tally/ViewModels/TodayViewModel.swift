import Foundation
import Observation
import TallyCore

/// Drives the Today tab: which habits are due, how far each got, and the text the cards show.
@MainActor
@Observable
final class TodayViewModel {
    private let store: HabitStore
    private let calendar: Calendar
    private let now: () -> Date

    /// `now` can be replaced so tests and previews use a fixed date.
    init(store: HabitStore, calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.store = store
        self.calendar = calendar
        self.now = now
    }

    private var today: Date { now() }

    // MARK: Lists
    var dueHabits: [HabitModel] { store.habits.filter { $0.isDue(on: today, calendar: calendar) } }
    var notScheduledHabits: [HabitModel] { store.habits.filter { !$0.isDue(on: today, calendar: calendar) } }

    // MARK: Summary
    private var doneCount: Int { dueHabits.filter { progress(for: $0).isMet }.count }
    var summaryTitle: String { "\(doneCount) of \(dueHabits.count) done" }
    var summaryFraction: Double { dueHabits.isEmpty ? 0 : Double(doneCount) / Double(dueHabits.count) }
    var summaryPercentText: String { "\(Int((summaryFraction * 100).rounded()))%" }
    var dateText: String { today.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()) }

    // MARK: Card text
    func progress(for habit: HabitModel) -> HabitProgress {
        habit.progress(from: store.entries, on: today, calendar: calendar)
    }

    /// "Done" / "Not done", or "1500 / 2500 ml".
    func subtitle(for habit: HabitModel) -> String {
        let progress = progress(for: habit)
        switch habit.kind {
        case .checkOff:
            return progress.isMet ? "Done" : "Not done"
        case .counter:
            return "\(progress.total.habitAmountText) / \(progress.goal.habitAmountText)\(unitSuffix(for: habit))"
        }
    }

    /// "+250 ml", or "+5" when the habit has no unit.
    func buttonTitle(for habit: HabitModel) -> String {
        "+\(habit.tapAmount.habitAmountText)\(unitSuffix(for: habit))"
    }

    func canUndo(_ habit: HabitModel) -> Bool {
        progress(for: habit).total > 0
    }

    private func unitSuffix(for habit: HabitModel) -> String {
        habit.unit.map { " \($0)" } ?? ""
    }

    // MARK: Logging
    /// A goal habit adds one step. A check-off habit toggles between done and not done.
    func tap(_ habit: HabitModel) {
        if habit.kind == .checkOff, progress(for: habit).isMet {
            store.clear(habit, on: today, calendar: calendar)
        } else {
            store.log(habit, at: today)
        }
    }

    func undoLast(_ habit: HabitModel) {
        store.undoLast(for: habit, on: today, calendar: calendar)
    }

    /// Logs a typed amount. Anything that isn't a number above zero is ignored.
    func logCustom(_ habit: HabitModel, text: String) {
        guard let amount = Double(text.trimmingCharacters(in: .whitespaces)), amount > 0 else { return }
        store.log(habit, amount: amount, at: today)
    }
}
