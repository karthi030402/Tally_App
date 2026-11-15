import Foundation
import Observation
import TallyCore

/// Drives one habit's page: its streaks, completion rates, total logged, and its own calendar.
@MainActor
@Observable
final class HabitDetailViewModel {
    private let store: HabitStore
    private let habitID: UUID
    private let calendar: Calendar
    private let now: () -> Date

    var selectedDay: Date
    /// First day of the month the calendar shows. Optional because a paging scroll view needs that.
    var visibleMonth: Date?

    /// `now` can be replaced so tests and previews use a fixed date.
    init(store: HabitStore, habitID: UUID, calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.store = store
        self.habitID = habitID
        self.calendar = calendar
        self.now = now
        let today = calendar.startOfDay(for: now())
        selectedDay = today
        visibleMonth = calendar.dateInterval(of: .month, for: today)?.start
    }

    private var today: Date { calendar.startOfDay(for: now()) }

    // MARK: The habit

    /// The habit, active or archived. Nil once it has been deleted, so the page can close itself.
    var habit: HabitModel? { store.allHabits.first { $0.id == habitID } }
    var isMissing: Bool { habit == nil }
    var isArchived: Bool { habit?.isArchived ?? false }
    /// Only active habits can be edited.
    var canEdit: Bool { habit != nil && !isArchived }
    var detailText: String { habit?.detailText ?? "" }

    private var habitEntries: [HabitEntry] { store.entries.filter { $0.habitID == habitID } }

    /// The first day this habit was logged, or nil if it never was.
    private var firstLogDay: Date? {
        habitEntries.map(\.date).min().map { calendar.startOfDay(for: $0) }
    }

    // MARK: Streaks

    private var streak: HabitStreak? {
        habit.map { store.streak(for: $0, now: now(), calendar: calendar) }
    }

    var currentStreakText: String { (streak?.current ?? 0).dayCountText }
    var bestStreakText: String { (streak?.best ?? 0).dayCountText }

    // MARK: Rates and total

    /// Completion for the last 7 days, the last 30 days, and since the first log.
    /// Each period starts no earlier than the first log, so a new habit isn't marked down
    /// for days before it existed.
    var rateSummaries: [HabitRateSummary] {
        [summary("Last 7 days", daysBack: 6), summary("Last 30 days", daysBack: 29), summary("All time", daysBack: nil)]
    }

    private func summary(_ title: String, daysBack: Int?) -> HabitRateSummary {
        guard let habit, let first = firstLogDay else {
            return HabitRateSummary(title: title, percentText: "–", detail: "No logs yet")
        }
        let periodStart = daysBack.flatMap { calendar.date(byAdding: .day, value: -$0, to: today) } ?? first
        let start = max(periodStart, first)
        guard let rate = HabitInsights.rate(
            of: habit, entries: store.entries, from: start, through: today, calendar: calendar
        ) else {
            return HabitRateSummary(title: title, percentText: "–", detail: "No due days")
        }
        let percent = Int((rate.rate * 100).rounded())
        return HabitRateSummary(
            title: title,
            percentText: "\(percent)%",
            detail: "\(rate.met) of \(rate.due) due \(rate.due == 1 ? "day" : "days")"
        )
    }

    /// A check-off counts its check-ins. A goal adds up everything logged, in its unit.
    var totalLoggedText: String {
        let entries = habitEntries
        guard let habit, !entries.isEmpty else { return "Nothing logged yet" }
        switch habit.kind {
        case .checkOff:
            return "\(entries.count) \(entries.count == 1 ? "check-in" : "check-ins")"
        case .counter:
            let total = entries.reduce(0) { $0 + $1.amount }
            return "\(total.habitAmountText)\(habit.unit.map { " \($0)" } ?? "")"
        }
    }

    // MARK: Calendar

    private var calendarBuilder: MonthCalendarBuilder {
        MonthCalendarBuilder(calendar: calendar, today: today, firstDay: firstLogDay ?? today, selectedDay: selectedDay)
    }

    var weekdayLabels: [String] { calendarBuilder.weekdayLabels }

    /// This habit's month pages. Days it wasn't due, including any after it was archived, get no ring.
    var calendarPages: [CalendarMonth] {
        guard let habit else { return [] }
        let entries = habitEntries
        return calendarBuilder.pages { day in
            habit.isDue(on: day, calendar: calendar)
                ? habit.progress(from: entries, on: day, calendar: calendar).fraction
                : nil
        }
    }

    // MARK: Selected day

    var selectedDayTitle: String {
        selectedDay.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private var selectedDayDetail: HabitDayDetail? {
        habit.map { HabitDayDetail(habit: $0, entries: habitEntries, day: selectedDay, calendar: calendar) }
    }

    var selectedDayFraction: Double? { selectedDayDetail?.fraction }
    var selectedDayRows: [HabitDayDetail] { selectedDayDetail.map { [$0] } ?? [] }

    // MARK: Actions

    /// Archives an active habit from today, or brings an archived one back from today.
    func toggleArchive() {
        guard let habit else { return }
        if habit.isArchived {
            store.unarchive(habit, from: now(), calendar: calendar)
        } else {
            store.archive(habit, from: now(), calendar: calendar)
        }
    }

    /// Permanently removes the habit and its logs. The page then reports the habit missing.
    func delete() {
        guard let habit else { return }
        store.delete(habit)
    }

    /// The delete confirmation text, saying how many logs will go.
    var deleteMessage: String {
        guard let habit else { return "" }
        return HabitDeleteMessage.text(logCount: store.logCount(for: habit))
    }
}
