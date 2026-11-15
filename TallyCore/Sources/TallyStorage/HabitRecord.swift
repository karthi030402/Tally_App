import Foundation
import SwiftData
import TallyCore

/// A habit as saved in the database. The app never sees this class. It works with `HabitModel`.
@Model
final class HabitRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var symbol: String?
    var colorName: String
    var kindRaw: String
    /// Position in the list, so habits come back in the order they were added.
    var sortIndex: Int
    var initialRule: RuleSnapshot
    /// The dated changes, oldest first.
    var changes: [RevisionSnapshot]

    init(habit: HabitModel, sortIndex: Int) {
        self.id = habit.id
        self.name = habit.name
        self.symbol = habit.symbol
        self.colorName = habit.colorName
        self.kindRaw = habit.kind.rawValue
        self.sortIndex = sortIndex
        self.initialRule = RuleSnapshot(habit.initialRule)
        self.changes = habit.changes.map(RevisionSnapshot.init)
    }

    /// Copies an edited habit's values onto this record. The type and position stay as they were.
    func apply(_ habit: HabitModel) {
        name = habit.name
        symbol = habit.symbol
        colorName = habit.colorName
        initialRule = RuleSnapshot(habit.initialRule)
        changes = habit.changes.map(RevisionSnapshot.init)
    }

    /// The habit again, or nil if the stored type isn't one this version knows.
    func habit() -> HabitModel? {
        guard let kind = HabitKind(rawValue: kindRaw) else { return nil }
        return HabitModel(
            id: id, name: name, symbol: symbol, colorName: colorName, kind: kind,
            initialRule: initialRule.rule(kind: kind),
            changes: changes.map { $0.revision(kind: kind) }
        )
    }
}
