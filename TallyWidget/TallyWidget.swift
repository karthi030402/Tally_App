//
//  TallyWidget.swift
//  TallyWidget
//
//  Created by SATHAPPAN on 16/11/26.
//

import WidgetKit
import SwiftUI
import TallyCore

struct TallyWidget: Widget {
    static let kind = "TallyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: TodayTimelineProvider()) { entry in
            TallyWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(lightHex: 0xFFF1E6, darkHex: 0x2A2148), Color(lightHex: 0xFFE0EC, darkHex: 0x1D1B2A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Today")
        .description("See how today's habits are going.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private extension TodayEntry {
    static var preview: TodayEntry {
        let water = HabitModel(name: "Water", symbol: "drop.fill", colorName: "indigo", kind: .counter, target: 2500, step: 250, unit: "ml")
        let vitamins = HabitModel(name: "Vitamins", colorName: "gold", kind: .checkOff)
        let reading = HabitModel(name: "Reading", colorName: "orchid", kind: .counter, target: 20, step: 5, unit: "pages")
        let entries = [
            HabitEntry(habitID: water.id, date: .now, amount: 1500),
            HabitEntry(habitID: vitamins.id, date: .now, amount: 1)
        ]
        return TodayEntry(date: .now, summary: TodaySummary(habits: [water, vitamins, reading], entries: entries, on: .now))
    }
}

#Preview("Small", as: .systemSmall) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}

#Preview("Medium", as: .systemMedium) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}

#Preview("Large", as: .systemLarge) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}

#Preview("Lock Circular", as: .accessoryCircular) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}

#Preview("Lock Rectangular", as: .accessoryRectangular) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}

#Preview("Lock Inline", as: .accessoryInline) {
    TallyWidget()
} timeline: {
    TodayEntry.preview
}
