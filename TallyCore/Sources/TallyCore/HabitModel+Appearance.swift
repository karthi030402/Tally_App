import SwiftUI
import UIKit

public extension HabitModel {
    /// The palette color for `colorName`. An unknown name falls back to the accent color, so a
    /// habit saved with a color that no longer exists still shows up.
    var color: Color {
        HabitAppearance.color(forKey: colorName)
    }

    /// The icon to draw. Falls back when none was chosen or the saved name isn't a real SF Symbol,
    /// because `Image(systemName:)` draws nothing at all for a name that doesn't exist.
    var iconName: String {
        UIImage(systemName: displaySymbol) != nil ? displaySymbol : Self.fallbackSymbol
    }
}
