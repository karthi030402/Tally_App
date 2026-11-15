import Foundation
import TallyCore

/// One habit's row in the selected-day card.
struct HabitDayDetail: Identifiable {
    let habit: HabitModel
    /// 0 to 1, or nil when the habit wasn't scheduled that day.
    let fraction: Double?
    /// "Done", "1500 / 2500 ml", or "Not scheduled".
    let text: String

    var id: UUID { habit.id }
}

extension HabitDayDetail {
    /// How `habit` did on `day`: "Not scheduled", or its progress with a line such as "Done" or
    /// "1500 / 2500 ml". The unit and goal are the ones that applied that day.
    init(habit: HabitModel, entries: [HabitEntry], day: Date, calendar: Calendar) {
        guard habit.isDue(on: day, calendar: calendar) else {
            self.init(habit: habit, fraction: nil, text: "Not scheduled")
            return
        }
        let progress = habit.progress(from: entries, on: day, calendar: calendar)
        let text: String
        switch habit.kind {
        case .checkOff:
            text = progress.isMet ? "Done" : "Not done"
        case .counter:
            let unit = habit.rule(on: day, calendar: calendar).unit.map { " \($0)" } ?? ""
            text = "\(progress.total.habitAmountText) / \(progress.goal.habitAmountText)\(unit)"
        }
        self.init(habit: habit, fraction: progress.fraction, text: text)
    }
}
