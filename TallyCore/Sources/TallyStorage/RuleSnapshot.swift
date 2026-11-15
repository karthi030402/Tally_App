import Foundation
import TallyCore

/// A goal and schedule written as plain values, so SwiftData can store them.
struct RuleSnapshot: Codable, Hashable {
    var target: Double?
    var step: Double?
    var unit: String?
    /// Calendar weekday numbers in a fixed order, so the stored value is stable.
    var weekdays: [Int]
    var isActive: Bool

    init(_ rule: HabitRule) {
        target = rule.target
        step = rule.step
        unit = rule.unit
        weekdays = rule.weekdays.map(\.rawValue).sorted()
        isActive = rule.isActive
    }

    /// The rule again. `kind` decides whether goal fields apply.
    func rule(kind: HabitKind) -> HabitRule {
        HabitRule(
            kind: kind, target: target, step: step, unit: unit,
            weekdays: Set(weekdays.compactMap(HabitWeekday.init(rawValue:))),
            isActive: isActive
        )
    }
}

/// A dated change of rule, written as plain values.
struct RevisionSnapshot: Codable, Hashable {
    var effectiveFrom: Date
    var rule: RuleSnapshot

    init(_ revision: HabitRevision) {
        effectiveFrom = revision.effectiveFrom
        rule = RuleSnapshot(revision.rule)
    }

    func revision(kind: HabitKind) -> HabitRevision {
        HabitRevision(effectiveFrom: effectiveFrom, rule: rule.rule(kind: kind))
    }
}
