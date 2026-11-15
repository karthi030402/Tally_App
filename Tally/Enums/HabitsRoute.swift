import Foundation

/// The screens that can be pushed onto the Habits stack.
enum HabitsRoute: Hashable {
    case addHabit
    /// One habit's page, for an active or an archived habit.
    case habitDetail(UUID)
    /// The edit form for the habit with this id.
    case editHabit(UUID)
    case settings
}
