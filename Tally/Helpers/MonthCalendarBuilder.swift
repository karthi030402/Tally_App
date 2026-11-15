import Foundation

/// Works out the pages of a calendar of rings: which months to show, the weeks in each, and the
/// state of every day. The Insights tab and a habit's own page both build their calendars with it.
struct MonthCalendarBuilder {
    let calendar: Calendar
    /// The last day that has happened. Later days have no ring.
    let today: Date
    /// The first day with data. Earlier days have no ring, and the first page is this day's month.
    let firstDay: Date
    /// The day drawn as selected.
    let selectedDay: Date

    /// The first day of every month from `firstDay`'s month through today's month, oldest first.
    var months: [Date] {
        guard let first = calendar.dateInterval(of: .month, for: firstDay)?.start,
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
    func weeks(in month: Date) -> [[Date?]] {
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
        let offset = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        days += (0..<count).map { calendar.date(byAdding: .day, value: $0, to: month) }
        while days.count < 42 { days.append(nil) }
        return stride(from: 0, to: 42, by: 7).map { Array(days[$0..<$0 + 7]) }
    }

    /// Every month page. `fraction` gives a day's ring value from 0 to 1. It is only asked about
    /// days that have data, so days outside that range get no ring.
    func pages(fraction: (Date) -> Double?) -> [CalendarMonth] {
        months.map { month in
            CalendarMonth(start: month, weeks: weeks(in: month).map { week in week.map { $0.map { day($0, fraction: fraction) } } })
        }
    }

    private func day(_ date: Date, fraction: (Date) -> Double?) -> CalendarDay {
        let hasData = date <= today && date >= calendar.startOfDay(for: firstDay)
        return CalendarDay(
            date: date,
            number: calendar.component(.day, from: date),
            fraction: hasData ? fraction(date) : nil,
            isSelected: calendar.isDate(date, inSameDayAs: selectedDay),
            isFuture: date > today
        )
    }
}
