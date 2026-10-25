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
    /// Daily goal. Only for counter habits; `nil` for check-off.
    public var target: Double?
    /// Amount added per tap. Only for counter habits; `nil` for check-off.
    public var step: Double?
    /// Unit label such as "ml". `nil` for check-off, or for a counter with no unit.
    public var unit: String?
    /// The days the habit is due. Never empty; every day is all seven.
    public var weekdays: Set<HabitWeekday>

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
        self.weekdays = weekdays.isEmpty ? HabitWeekday.everyDay : weekdays

        // A blank symbol name counts as "not chosen".
        let trimmedSymbol = symbol?.trimmingCharacters(in: .whitespaces) ?? ""
        self.symbol = trimmedSymbol.isEmpty ? nil : trimmedSymbol

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

