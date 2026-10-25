/// The pickers the Add Habit screen can open as a sheet.
enum AddHabitSheet: Identifiable {
    case schedule
    case color
    case icon

    var id: Self { self }
}
