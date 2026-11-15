import Foundation
import TallyCore

extension HabitModel {
    /// "Check-off · Daily" or "Goal 2500 ml · Mon Wed Fri".
    var detailText: String {
        let kindText: String
        switch kind {
        case .checkOff:
            kindText = "Check-off"
        case .counter:
            // "Goal 2500 ml", "Goal 20 pages". Missing parts are simply left out.
            let amount = target?.habitAmountText
            kindText = ["Goal", amount, unit].compactMap { $0 }.joined(separator: " ")
        }
        return "\(kindText) · \(scheduleText)"
    }

    /// "Daily", or the due weekdays in Monday-first order, such as "Mon Wed Fri".
    var scheduleText: String {
        guard !isEveryDay else { return "Daily" }
        let symbols = Calendar.current.shortWeekdaySymbols // index 0 is Sunday
        // allCases is declared Monday-first, which is the display order.
        return HabitWeekday.allCases
            .filter { weekdays.contains($0) }
            .map { symbols[$0.rawValue - 1] }
            .joined(separator: " ")
    }
}
