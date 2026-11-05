import Foundation

/// The screens that can be pushed onto the Habits stack.
enum HabitsRoute: Hashable {
    case addHabit
    /// The edit form for the habit with this id.
    case editHabit(UUID)
    case settings
}
