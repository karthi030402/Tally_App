import SwiftUI

/// The app's light/dark choice. `system` follows the device.
/// Saved by raw value, so the case names must not be renamed once released.
enum AppAppearance: String, CaseIterable {
    case system
    case light
    case dark

    /// The UserDefaults key the choice is saved under.
    static let storageKey = "appearance"

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var summary: String {
        switch self {
        case .system: "Follows your device's light or dark setting."
        case .light: "Always use the light look."
        case .dark: "Always use the dark look."
        }
    }

    /// `nil` tells SwiftUI to follow the system.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
