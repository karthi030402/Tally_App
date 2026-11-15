import Foundation

enum HabitDeleteMessage {
    /// The delete confirmation, saying how many logs will go with the habit.
    static func text(logCount: Int) -> String {
        guard logCount > 0 else { return "This permanently removes the habit. This can't be undone." }
        let logs = logCount == 1 ? "1 log" : "\(logCount) logs"
        return "This permanently removes the habit and its \(logs), including its past in Insights. This can't be undone."
    }
}
