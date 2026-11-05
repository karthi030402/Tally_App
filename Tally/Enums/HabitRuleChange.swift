/// What an edit changed about a habit's goal and schedule.
enum HabitRuleChange {
    case goal
    case schedule
    case goalAndSchedule

    /// How the change is named in the "from today" message.
    var name: String {
        switch self {
        case .goal: "goal"
        case .schedule: "schedule"
        case .goalAndSchedule: "goal and schedule"
        }
    }

    /// "applies" after one thing, "apply" after two.
    var verb: String {
        self == .goalAndSchedule ? "apply" : "applies"
    }
}
