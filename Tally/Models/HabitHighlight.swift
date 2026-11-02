import TallyCore

/// A habit picked for a Best or Needs-work tile, with the line shown under its name.
struct HabitHighlight {
    let habit: HabitModel
    /// For example "7 of 7 days met".
    let detail: String
}
