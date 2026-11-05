import Foundation

/// The parts of a habit that can change over time: its goal and its schedule.
public struct HabitRule: Hashable, Sendable {
    /// Daily goal. Only for counter habits; `nil` for check-off.
    public let target: Double?
    /// Amount added per tap. Only for counter habits; `nil` for check-off.
    public let step: Double?
    /// Unit label such as "ml". `nil` for check-off, or for a counter with no unit.
    public let unit: String?
    /// The days the habit is due. Never empty; every day is all seven.
    public let weekdays: Set<HabitWeekday>

    /// Cleans the values the way a new habit always has: a check-off has no goal fields,
    /// a goal must be above zero, a step can't exceed the goal, and no days means every day.
    public init(
        kind: HabitKind,
        target: Double? = nil,
        step: Double? = nil,
        unit: String? = nil,
        weekdays: Set<HabitWeekday> = HabitWeekday.everyDay
    ) {
        self.weekdays = weekdays.isEmpty ? HabitWeekday.everyDay : weekdays
        switch kind {
        case .checkOff:
            self.target = nil
            self.step = nil
            self.unit = nil
        case .counter:
            // Fractions are allowed, so the only rule is "greater than zero".
            let cleanTarget: Double
            if let target, target > 0 { cleanTarget = target } else { cleanTarget = 1 }
            // A step must be above zero and can't exceed the target. A missing step means one tap
            // adds the whole goal.
            let cleanStep: Double
            if let step, step > 0 { cleanStep = min(step, cleanTarget) } else { cleanStep = cleanTarget }
            self.target = cleanTarget
            self.step = cleanStep
            let trimmedUnit = unit?.trimmingCharacters(in: .whitespaces) ?? ""
            self.unit = trimmedUnit.isEmpty ? nil : trimmedUnit
        }
    }
}

/// A change of rule, in force from the start of `effectiveFrom` onwards.
public struct HabitRevision: Hashable, Sendable {
    public let effectiveFrom: Date
    public let rule: HabitRule

    public init(effectiveFrom: Date, rule: HabitRule) {
        self.effectiveFrom = effectiveFrom
        self.rule = rule
    }
}
