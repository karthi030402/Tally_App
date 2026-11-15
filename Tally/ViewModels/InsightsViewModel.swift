import Foundation
import Observation
import TallyCore

/// Drives the Insights tab: the weekly report, best and worst habits, the daily chart,
/// the month calendar and the selected-day card.
@MainActor
@Observable
final class InsightsViewModel {
    private let store: HabitStore
    private let calendar: Calendar
    private let now: () -> Date

    /// Which habit the bar chart and the calendar show. Nil means all habits.
    var chartHabitID: UUID?
    var calendarHabitID: UUID?
    var selectedDay: Date
    /// First day of the month the calendar shows. Optional because a paging scroll view needs that.
    var visibleMonth: Date?

    /// `now` can be replaced so tests and previews use a fixed date.
    init(store: HabitStore, calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.store = store
        self.calendar = calendar
        self.now = now
        let today = calendar.startOfDay(for: now())
        selectedDay = today
        visibleMonth = calendar.dateInterval(of: .month, for: today)?.start
    }

    private var today: Date { calendar.startOfDay(for: now()) }

    /// The habits the filter menus offer. Archived habits are included, so their past can be looked at.
    var habits: [HabitModel] { store.allHabits }

    private func filteredHabits(_ id: UUID?) -> [HabitModel] {
        guard let id else { return store.allHabits }
        return store.allHabits.filter { $0.id == id }
    }

    /// The first day anything was logged, so the chart and calendar start where the data starts.
    private var earliestDay: Date {
        store.entries.map(\.date).min().map { calendar.startOfDay(for: $0) } ?? today
    }

    // MARK: Weekly report

    private var weekStart: Date { calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today }
    private var weekEnd: Date { calendar.date(byAdding: .day, value: 6, to: weekStart) ?? today }
    /// Days after today haven't happened, so they are left out of the numbers.
    private var lastCountedDay: Date { min(today, weekEnd) }

    var weekRangeText: String {
        let style = Date.FormatStyle().month(.abbreviated).day()
        return "\(weekStart.formatted(style)) – \(weekEnd.formatted(style))"
    }

    private var weekTotals: (met: Int, due: Int) {
        let days = HabitInsights.completions(
            from: weekStart, through: lastCountedDay, habits: store.allHabits,
            entries: store.entries, calendar: calendar
        )
        return (days.reduce(0) { $0 + $1.met }, days.reduce(0) { $0 + $1.due })
    }

    var weekPercentText: String {
        let totals = weekTotals
        guard totals.due > 0 else { return "–" }
        return "\(Int((Double(totals.met) / Double(totals.due) * 100).rounded()))%"
    }

    var weekCaption: String {
        let totals = weekTotals
        guard totals.due > 0 else { return "Nothing scheduled yet this week" }
        return "\(totals.met) of \(totals.due) scheduled days met"
    }

    // MARK: Best and needs work

    private var weekRates: [HabitRate] {
        HabitInsights.rates(
            of: store.allHabits, entries: store.entries, from: weekStart,
            through: lastCountedDay, calendar: calendar
        )
    }

    var bestHabit: HabitHighlight? {
        highlight(HabitInsights.best(in: weekRates))
    }

    /// Nil when there is nothing to improve: one habit only, or everything was met.
    var needsWorkHabit: HabitHighlight? {
        let rates = weekRates
        // Reversed, so when rates tie the last habit is picked and it differs from the best one.
        guard let worst = HabitInsights.worst(in: rates.reversed()),
              worst.rate < 1, worst.habitID != HabitInsights.best(in: rates)?.habitID else { return nil }
        return highlight(worst)
    }

    private func highlight(_ rate: HabitRate?) -> HabitHighlight? {
        guard let rate, let habit = store.allHabits.first(where: { $0.id == rate.habitID }) else { return nil }
        let unit = rate.due == 1 ? "day" : "days"
        return HabitHighlight(habit: habit, detail: "\(rate.met) of \(rate.due) \(unit) met")
    }

    // MARK: Daily completion chart

    /// The chart opens showing the last seven days, with earlier weeks off to the left.
    var chartScrollStart: Date { calendar.date(byAdding: .day, value: -6, to: today) ?? today }

    /// One value per day with something scheduled, from the first log through today.
    var chartCompletions: [DayCompletion] {
        HabitInsights.completions(
            from: earliestDay, through: today, habits: filteredHabits(chartHabitID),
            entries: store.entries, calendar: calendar
        )
        .filter { $0.fraction != nil }
    }

    // MARK: Month calendar

    private var calendarBuilder: MonthCalendarBuilder {
        MonthCalendarBuilder(calendar: calendar, today: today, firstDay: earliestDay, selectedDay: selectedDay)
    }

    /// Single-letter day names, starting from the calendar's first weekday.
    var weekdayLabels: [String] { calendarBuilder.weekdayLabels }

    /// Every month the calendar can show, with each day's ring value and state already worked out.
    var calendarPages: [CalendarMonth] {
        calendarBuilder.pages { completion(on: $0).fraction }
    }

    /// How `day` went across the habits the calendar filter allows.
    private func completion(on day: Date) -> DayCompletion {
        HabitInsights.completion(
            on: day, habits: filteredHabits(calendarHabitID), entries: store.entries, calendar: calendar
        )
    }

    // MARK: Selected day

    var selectedDayTitle: String {
        selectedDay.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    var selectedDayFraction: Double? { completion(on: selectedDay).fraction }

    var selectedDayRows: [HabitDayDetail] {
        filteredHabits(calendarHabitID).map { dayDetail(for: $0, on: selectedDay) }
    }

    private func dayDetail(for habit: HabitModel, on day: Date) -> HabitDayDetail {
        HabitDayDetail(habit: habit, entries: store.entries, day: day, calendar: calendar)
    }

    // MARK: Streaks

    /// One row per habit, in the order the habits are listed.
    var streakRows: [HabitStreakRow] {
        store.habits.map { habit in
            let streak = store.streak(for: habit)
            return HabitStreakRow(
                habit: habit,
                currentText: streak.current.dayCountText,
                bestText: streak.best.dayCountText
            )
        }
    }
}
