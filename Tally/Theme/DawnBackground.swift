import SwiftUI
import TallyCore

/// A soft night-to-sunrise wash: indigo at the top, through pink, to peach at the bottom.
struct DawnBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(lightHex: 0xE6E8FF, darkHex: 0x111330),
                Color(lightHex: 0xF8E6F6, darkHex: 0x25173A),
                Color(lightHex: 0xFFEBDD, darkHex: 0x33202A)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
