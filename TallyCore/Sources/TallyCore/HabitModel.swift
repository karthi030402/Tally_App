import Foundation

/// A habit the user tracks. Pure data with no UI types, so the app, widget and intents can share it.
public struct HabitModel: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    /// SF Symbol name. `nil` means none was chosen, and the app shows a fallback icon.
    public var symbol: String?
    /// Key into the app's color palette, so this package needs no SwiftUI.
    public var colorName: String
    public var kind: HabitKind
    /// The goal and schedule the habit started with.
    private let initialRule: HabitRule
    /// Later changes to the goal or schedule, oldest first. Each applies from its own day onwards.
    public private(set) var changes: [HabitRevision]

    public init(
        id: UUID = UUID(),
        name: String,
        symbol: String? = nil,
        colorName: String,
        kind: HabitKind,
        target: Double? = nil,
        step: Double? = nil,
        unit: String? = nil,
        weekdays: Set<HabitWeekday> = HabitWeekday.everyDay
    ) {
        self.id = id
        self.name = name
        self.colorName = colorName
        self.kind = kind
        self.initialRule = HabitRule(kind: kind, target: target, step: step, unit: unit, weekdays: weekdays)
        self.changes = []

        // A blank symbol name counts as "not chosen".
        let trimmedSymbol = symbol?.trimmingCharacters(in: .whitespaces) ?? ""
        self.symbol = trimmedSymbol.isEmpty ? nil : trimmedSymbol
    }

    /// The goal and schedule in force right now.
    public var currentRule: HabitRule { changes.last?.rule ?? initialRule }

    /// Daily goal. Only for counter habits; `nil` for check-off.
    public var target: Double? { currentRule.target }
    /// Amount added per tap. Only for counter habits; `nil` for check-off.
    public var step: Double? { currentRule.step }
    /// Unit label such as "ml". `nil` for check-off, or for a counter with no unit.
    public var unit: String? { currentRule.unit }
    /// The days the habit is due. Never empty; every day is all seven.
    public var weekdays: Set<HabitWeekday> { currentRule.weekdays }

    /// The goal and schedule that applied on `date`. Days before any change use the starting rule.
    public func rule(on date: Date, calendar: Calendar = .current) -> HabitRule {
        let day = calendar.startOfDay(for: date)
        return changes.last { $0.effectiveFrom <= day }?.rule ?? initialRule
    }

    /// A copy with `rule` in force from the start of `date` onwards. Earlier days keep their rule.
    /// A second change on the same day replaces the first, and a change that matches the rule
    /// already in force is not recorded.
    public func changing(to rule: HabitRule, from date: Date, calendar: Calendar = .current) -> HabitModel {
        var copy = self
        let start = calendar.startOfDay(for: date)
        copy.changes.removeAll { $0.effectiveFrom >= start }
        guard rule != copy.currentRule else { return copy }
        copy.changes.append(HabitRevision(effectiveFrom: start, rule: rule))
        return copy
    }

    public var isEveryDay: Bool {
        weekdays.count == HabitWeekday.allCases.count
    }

    public func isScheduled(on weekday: HabitWeekday) -> Bool {
        weekdays.contains(weekday)
    }

    /// SF Symbol shown when a habit has no icon.
    public static let fallbackSymbol = "target"

    /// The symbol to show: the chosen one, or the fallback when none was chosen.
    public var displaySymbol: String {
        symbol ?? Self.fallbackSymbol
    }
}
