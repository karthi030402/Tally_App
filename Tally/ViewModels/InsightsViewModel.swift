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

    /// The habits the filter menus offer.
    var habits: [HabitModel] { store.habits }

    private func filteredHabits(_ id: UUID?) -> [HabitModel] {
        guard let id else { return store.habits }
        return store.habits.filter { $0.id == id }
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
            from: weekStart, through: lastCountedDay, habits: store.habits,
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
            of: store.habits, entries: store.entries, from: weekStart,
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
        guard let rate, let habit = store.habits.first(where: { $0.id == rate.habitID }) else { return nil }
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

    /// The first day of every month from the first log through this month, oldest first.
    private var calendarMonths: [Date] {
        guard let first = calendar.dateInterval(of: .month, for: earliestDay)?.start,
              let last = calendar.dateInterval(of: .month, for: today)?.start else { return [] }
        var months: [Date] = []
        var month = first
        while month <= last {
            months.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return months
    }

    /// Single-letter day names, starting from the calendar's first weekday.
    var weekdayLabels: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }

    /// The month split into weeks, padded with nil to exactly six rows of seven
    /// so every page has the same height.
    private func weeks(in month: Date) -> [[Date?]] {
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let offset = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        days += (0..<count).map { calendar.date(byAdding: .day, value: $0, to: month) }
        while days.count < 42 { days.append(nil) }
        return stride(from: 0, to: 42, by: 7).map { Array(days[$0..<$0 + 7]) }
    }

    /// Every month the calendar can show, with each day's ring value and state already worked out.
    var calendarPages: [CalendarMonth] {
        calendarMonths.map { month in
            CalendarMonth(start: month, weeks: weeks(in: month).map { week in week.map { $0.map(calendarDay) } })
        }
    }

    private func calendarDay(_ date: Date) -> CalendarDay {
        // Days that haven't happened, or came before the first log, have no value, so no ring.
        let hasData = date <= today && date >= earliestDay
        return CalendarDay(
            date: date,
            number: calendar.component(.day, from: date),
            fraction: hasData ? completion(on: date).fraction : nil,
            isSelected: calendar.isDate(date, inSameDayAs: selectedDay),
            isFuture: date > today
        )
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
        guard habit.isDue(on: day, calendar: calendar) else {
            return HabitDayDetail(habit: habit, fraction: nil, text: "Not scheduled")
        }
        let progress = habit.progress(from: store.entries, on: day, calendar: calendar)
        let text: String
        switch habit.kind {
        case .checkOff:
            text = progress.isMet ? "Done" : "Not done"
        case .counter:
            let unit = habit.unit.map { " \($0)" } ?? ""
            text = "\(progress.total.habitAmountText) / \(progress.goal.habitAmountText)\(unit)"
        }
        return HabitDayDetail(habit: habit, fraction: progress.fraction, text: text)
    }
}
