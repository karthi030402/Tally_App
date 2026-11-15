import Testing
import Foundation
import TallyCore
@testable import Tally

@MainActor
struct HabitDetailViewModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    /// March 2026 at noon UTC. 9 March 2026 is a Monday. "Now" is Thursday the 12th.
    private func march(_ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)) ?? .distantPast
    }

    private let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
    private let water = HabitModel(name: "Water", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")

    private func done(_ habit: HabitModel, _ days: Int...) -> [HabitEntry] {
        days.map { HabitEntry(habitID: habit.id, date: march($0), amount: habit.goalAmount) }
    }

    private func viewModel(for habit: HabitModel, entries: [HabitEntry] = []) -> HabitDetailViewModel {
        HabitDetailViewModel(
            store: HabitStore(habits: [habit], entries: entries),
            habitID: habit.id, calendar: calendar, now: { march(12) }
        )
    }

    @Test func aHabitThatIsGoneIsReportedMissing() {
        let viewModel = HabitDetailViewModel(store: HabitStore(), habitID: UUID(), calendar: calendar, now: { march(12) })
        #expect(viewModel.isMissing)
        #expect(!viewModel.canEdit)
        #expect(viewModel.calendarPages.isEmpty)
    }

    @Test func anArchivedHabitCannotBeEdited() {
        let store = HabitStore(archivedHabits: [vitamins])
        let viewModel = HabitDetailViewModel(store: store, habitID: vitamins.id, calendar: calendar, now: { march(12) })
        #expect(viewModel.isArchived)
        #expect(!viewModel.canEdit)
        #expect(!viewModel.isMissing)
    }

    @Test func streaksAreWorkedOutAndPhrased() {
        // Done 9 and 10, missed 11, done 12 (today): current 1, best 2.
        let viewModel = viewModel(for: vitamins, entries: done(vitamins, 9, 10, 12))
        #expect(viewModel.currentStreakText == "1 day")
        #expect(viewModel.bestStreakText == "2 days")
    }

    @Test func ratesStartFromTheFirstLog() {
        // Logging starts on the 9th, so the 7-day period covers 9 to 12: 3 met of 4 due.
        let summaries = viewModel(for: vitamins, entries: done(vitamins, 9, 10, 12)).rateSummaries
        #expect(summaries.map(\.title) == ["Last 7 days", "Last 30 days", "All time"])
        #expect(summaries.map(\.percentText) == ["75%", "75%", "75%"])
        #expect(summaries.first?.detail == "3 of 4 due days")
    }

    @Test func aHabitWithNoLogsHasNothingToMeasure() {
        let viewModel = viewModel(for: vitamins)
        #expect(viewModel.rateSummaries.allSatisfy { $0.percentText == "–" && $0.detail == "No logs yet" })
        #expect(viewModel.totalLoggedText == "Nothing logged yet")
    }

    @Test func theTotalCountsCheckInsOrAddsUpAGoal() {
        #expect(viewModel(for: vitamins, entries: done(vitamins, 9, 10, 12)).totalLoggedText == "3 check-ins")
        #expect(viewModel(for: vitamins, entries: done(vitamins, 9)).totalLoggedText == "1 check-in")
        let entries = [
            HabitEntry(habitID: water.id, date: march(9), amount: 1500),
            HabitEntry(habitID: water.id, date: march(10), amount: 1000)
        ]
        #expect(viewModel(for: water, entries: entries).totalLoggedText == "2500 ml")
    }

    @Test func theCalendarHasRingsOnlyFromTheFirstLogToToday() throws {
        let pages = viewModel(for: vitamins, entries: done(vitamins, 9, 10, 11, 12)).calendarPages
        let days = pages.flatMap(\.weeks).flatMap { $0 }.compactMap { $0 }
        func day(_ number: Int) throws -> CalendarDay {
            try #require(days.first { calendar.isDate($0.date, inSameDayAs: march(number)) })
        }
        #expect(try day(8).fraction == nil)    // before the first log
        #expect(try day(12).fraction == 1)
        #expect(try day(13).fraction == nil)   // after today
        #expect(try day(13).isFuture)
    }

    @Test func theSelectedDayCardFollowsTheSelection() {
        let viewModel = viewModel(for: vitamins, entries: done(vitamins, 9, 10, 12))
        #expect(viewModel.selectedDayRows.first?.text == "Done")        // today, the 12th
        viewModel.selectedDay = march(11)
        #expect(viewModel.selectedDayRows.first?.text == "Not done")
        #expect(viewModel.selectedDayFraction == 0)
    }

    @Test func archivingAndUnarchivingFromThePage() {
        let viewModel = viewModel(for: vitamins, entries: done(vitamins, 9))
        #expect(viewModel.canEdit)
        viewModel.toggleArchive()
        #expect(viewModel.isArchived)
        #expect(!viewModel.canEdit)
        viewModel.toggleArchive()
        #expect(!viewModel.isArchived)
        #expect(viewModel.canEdit)
    }

    @Test func deletingMakesThePageMissing() {
        let viewModel = viewModel(for: vitamins, entries: done(vitamins, 9))
        viewModel.delete()
        #expect(viewModel.isMissing)
    }

    @Test func theDeleteMessageCountsTheLogs() {
        let viewModel = viewModel(for: vitamins, entries: done(vitamins, 9, 10, 12))
        #expect(viewModel.deleteMessage.contains("its 3 logs,"))
    }
}
