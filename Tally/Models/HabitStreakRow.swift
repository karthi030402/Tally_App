import Foundation
import TallyCore

/// One habit's row in the Streaks card, with its text already worked out.
struct HabitStreakRow: Identifiable {
    let habit: HabitModel
    /// The streak right now, for example "12 days".
    let currentText: String
    /// The longest streak so far, for example "20 days".
    let bestText: String

    var id: UUID { habit.id }
}
