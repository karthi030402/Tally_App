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
