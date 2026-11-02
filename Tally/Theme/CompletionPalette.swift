import SwiftUI
import TallyCore

/// One color per completion band, so the bars and the calendar read the same way.
/// In both light and dark mode, a deeper or brighter step always means more completion.
struct CompletionPalette {
    struct Band {
        let label: String
        let color: Color
    }

    /// Six steps: 0% (neutral gray), then 1–24%, 25–49%, 50–74%, 75–99%, and 100%.
    let bands: [Band]
    /// The faint unfilled part of a ring.
    let trackColor: Color

    func color(_ value: Double) -> Color {
        switch value {
        case ..<0.001: bands[0].color
        case ..<0.25: bands[1].color
        case ..<0.5: bands[2].color
        case ..<0.75: bands[3].color
        case ..<1: bands[4].color
        default: bands[5].color
        }
    }

    func track(_ value: Double) -> Color {
        value < 0.001 ? bands[0].color.opacity(0.5) : trackColor
    }

    /// Tint of the Best tile, and the strongest emphasis color.
    var best: Color { bands[5].color }
    /// Tint of the Needs-work tile.
    var needsWork: Color { bands[3].color }
    /// The dashed 100% line on the bar chart.
    var target: Color { bands[4].color }

    /// "Colorful daybreak": night indigo through violet and pink to coral and sunrise gold.
    static let daybreak = CompletionPalette(
        bands: [
            Band(label: "0%", color: Color(lightHex: 0xD6D2DC, darkHex: 0x48444F)),
            Band(label: "1–24%", color: Color(lightHex: 0xB8C4F6, darkHex: 0x2F3C7E)),
            Band(label: "25–49%", color: Color(lightHex: 0x9B84EC, darkHex: 0x6A52C9)),
            Band(label: "50–74%", color: Color(lightHex: 0xDB5FB0, darkHex: 0xC466B3)),
            Band(label: "75–99%", color: Color(lightHex: 0xF47B4E, darkHex: 0xF08A5D)),
            Band(label: "100%", color: Color(lightHex: 0xE8A000, darkHex: 0xFFD166))
        ],
        trackColor: Color(lightHex: 0xF1ECF7, darkHex: 0x2B2536)
    )
}
