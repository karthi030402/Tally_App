import Testing
import Foundation
@testable import Tally

struct MonthCalendarBuilderTests {
    /// A Monday-first calendar in UTC, like the one the app's calendar tests assume.
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12)) ?? .distantPast
    }

    private func builder(first: Date? = nil, selected: Date? = nil) -> MonthCalendarBuilder {
        MonthCalendarBuilder(
            calendar: calendar, today: date(3, 9),
            firstDay: first ?? date(1, 20), selectedDay: selected ?? date(3, 9)
        )
    }

    private func allDays(_ pages: [CalendarMonth]) -> [CalendarDay] {
        pages.flatMap(\.weeks).flatMap { $0 }.compactMap { $0 }
    }

    @Test func monthsRunFromTheFirstDaysMonthThroughThisMonth() {
        let months = builder().months.map { calendar.component(.month, from: $0) }
        #expect(months == [1, 2, 3])
    }

    @Test func weekdayLabelsStartWithTheCalendarsFirstWeekday() {
        #expect(builder().weekdayLabels == ["M", "T", "W", "T", "F", "S", "S"])
    }

    @Test func everyMonthIsSixRowsOfSevenWithTheFirstOnTheRightWeekday() throws {
        let march = try #require(builder().months.last)
        let weeks = builder().weeks(in: march)
        #expect(weeks.count == 6)
        #expect(weeks.allSatisfy { $0.count == 7 })
        // 1 March 2026 is a Sunday, the last day of a Monday-first week.
        #expect(weeks[0][5] == nil)
        #expect(weeks[0][6] != nil)
        #expect(weeks.flatMap { $0 }.compactMap { $0 }.count == 31)
    }

    @Test func daysOutsideTheDataHaveNoRing() throws {
        let pages = builder(first: date(3, 3)).pages { _ in 0.5 }
        let days = allDays(pages)
        func day(_ number: Int, month: Int = 3) throws -> CalendarDay {
            try #require(days.first { calendar.isDate($0.date, inSameDayAs: date(month, number)) })
        }
        #expect(try day(2).fraction == nil)      // before the first day
        #expect(try day(3).fraction == 0.5)
        #expect(try day(9).fraction == 0.5)
        #expect(try day(10).fraction == nil)     // after today
        #expect(try day(10).isFuture)
        #expect(try !day(9).isFuture)
    }

    @Test func onlyTheSelectedDayIsMarked() {
        let pages = builder(selected: date(3, 5)).pages { _ in 1 }
        let selected = allDays(pages).filter(\.isSelected)
        #expect(selected.count == 1)
        #expect(selected.first.map { calendar.isDate($0.date, inSameDayAs: date(3, 5)) } == true)
    }
}
