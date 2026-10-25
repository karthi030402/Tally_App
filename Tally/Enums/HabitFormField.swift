/// The fields on the Add Habit form. Used to move focus and to scroll to a field with an error.
enum HabitFormField: Hashable {
    case name, goal, step, unit
    case schedule, color, icon
}
