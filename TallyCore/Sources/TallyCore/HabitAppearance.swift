import SwiftUI

/// How a habit looks. Shared by the app and the widgets so both show the same colors.
public enum HabitAppearance {
    /// Every color a habit can use, in picker order (spectrum). The key is the string saved on
    /// the habit. The picker and `HabitModel.color` both read this one list, so they can't drift
    /// apart. Keys are never renamed once saved habits can use them.
    public static let colorOptions: [(key: String, color: Color)] = [
        ("red", Color(lightHex: 0xD93A3F, darkHex: 0xFF6B6E)),
        ("coral", Color(lightHex: 0xF0605D, darkHex: 0xFF8A80)),
        ("orange", Color(lightHex: 0xEE7B22, darkHex: 0xFFA252)),
        ("gold", Color(lightHex: 0xE8960C, darkHex: 0xFFC247)),
        ("lime", Color(lightHex: 0x6FA82A, darkHex: 0xA3DB5A)),
        ("green", Color(lightHex: 0x2FA650, darkHex: 0x5ED67E)),
        ("mint", Color(lightHex: 0x14AE8C, darkHex: 0x4EDDB9)),
        ("teal", Color(lightHex: 0x129FB0, darkHex: 0x4AD0E0)),
        ("sky", Color(lightHex: 0x2F98E5, darkHex: 0x6CBBFF)),
        ("blue", Color(lightHex: 0x2D6AE8, darkHex: 0x6B99FF)),
        ("indigo", Color(lightHex: 0x4C63E0, darkHex: 0x8396FF)),
        ("violet", Color(lightHex: 0x7B55E5, darkHex: 0xAB92FF)),
        ("orchid", Color(lightHex: 0xB249D0, darkHex: 0xD77EF0)),
        ("pink", Color(lightHex: 0xE34A98, darkHex: 0xFF80BE)),
        ("brown", Color(lightHex: 0x9B6A4A, darkHex: 0xCC9878)),
        ("slate", Color(lightHex: 0x5D6B7E, darkHex: 0x9AA8BB))
    ]

    /// The palette color for a saved key. An unknown key falls back to the accent color.
    public static func color(forKey key: String) -> Color {
        colorOptions.first { $0.key == key }?.color ?? TallyColors.accent
    }

    /// A readable name for an SF Symbol: "figure.walk" -> "Figure Walk", "dumbbell.fill" -> "Dumbbell".
    public static func displayName(forSymbol symbol: String) -> String {
        symbol.split(separator: ".")
            .filter { $0 != "fill" }
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    /// The icons the picker offers, grouped by theme. Every name was checked to exist as an
    /// SF Symbol, and names newer than iOS 17 were avoided.
    public static let iconGroups: [HabitIconGroup] = [
        HabitIconGroup(title: "Health", symbols: [
            "drop.fill", "pills.fill", "heart.fill", "cross.case.fill", "bed.double.fill",
            "lungs.fill", "fork.knife", "cup.and.saucer.fill", "leaf.fill"
        ]),
        HabitIconGroup(title: "Fitness", symbols: [
            "figure.walk", "figure.run", "dumbbell.fill", "bicycle", "figure.pool.swim",
            "figure.hiking", "figure.yoga", "sportscourt.fill", "stopwatch.fill"
        ]),
        HabitIconGroup(title: "Learning", symbols: [
            "book.fill", "books.vertical.fill", "pencil", "graduationcap.fill",
            "lightbulb.fill", "brain", "laptopcomputer", "globe"
        ]),
        HabitIconGroup(title: "Mindfulness", symbols: [
            "figure.mind.and.body", "brain.head.profile", "sun.max.fill", "moon.stars.fill",
            "sparkles", "flame.fill", "heart.text.square.fill", "bell.fill"
        ]),
        HabitIconGroup(title: "Home & life", symbols: [
            "house.fill", "cart.fill", "creditcard.fill", "banknote.fill", "music.note",
            "paintbrush.fill", "camera.fill", "gamecontroller.fill", "pawprint.fill",
            "tree.fill", "star.fill", "phone.fill"
        ])
    ]
}
