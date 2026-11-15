import Foundation
import SwiftData
import TallyCore

/// One log as saved in the database. It points at its habit by id.
@Model
final class EntryRecord {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var date: Date
    var amount: Double

    init(_ entry: HabitEntry) {
        id = entry.id
        habitID = entry.habitID
        date = entry.date
        amount = entry.amount
    }

    var entry: HabitEntry {
        HabitEntry(id: id, habitID: habitID, date: date, amount: amount)
    }
}
