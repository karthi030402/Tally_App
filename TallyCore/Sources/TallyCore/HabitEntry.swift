import Foundation

/// One logged amount for a habit, such as a single tap of +250 ml, or one check-off.
public struct HabitEntry: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let habitID: UUID
    /// When it was logged. The day it counts for comes from this, using the user's calendar.
    public var date: Date
    public var amount: Double

    public init(id: UUID = UUID(), habitID: UUID, date: Date, amount: Double) {
        self.id = id
        self.habitID = habitID
        self.date = date
        self.amount = amount
    }
}
