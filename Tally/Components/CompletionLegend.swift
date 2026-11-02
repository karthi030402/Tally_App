import SwiftUI

/// The six completion bands with their colors, shared by the bar chart and the calendar.
struct CompletionLegend: View {
    var palette: CompletionPalette = .daybreak

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 3), spacing: 6) {
            ForEach(palette.bands, id: \.label) { band in
                HStack(spacing: 6) {
                    Circle()
                        .fill(band.color)
                        .frame(width: 10, height: 10)
                    
                    Text(band.label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        // The colors only repeat what the percentages already say, so VoiceOver skips the key.
        .accessibilityHidden(true)
    }
}

#Preview {
    CompletionLegend()
        .padding()
}
