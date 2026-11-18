import SwiftUI
import TallyCore

/// The small widget: one ring for how much of today is done.
struct SmallTodayView: View {
    let summary: TodaySummary

    var body: some View {
        VStack(spacing: 8) {
			ZStack {
				Circle().stroke(TallyColors.accent.opacity(0.2), lineWidth: 10)
				Circle()
					.trim(from: 0, to: summary.fraction)
					.stroke(TallyColors.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
					.rotationEffect(.degrees(-90))

				GeometryReader { proxy in
					let diameter = min(proxy.size.width, proxy.size.height)
					let inner = diameter - 2 * 10 - 8          // minus stroke on both sides, minus a little padding
					VStack(spacing: 0) {
						Text("\(summary.doneCount)/\(summary.dueCount)")
							.font(.title2.bold())
							.minimumScaleFactor(0.5)
							.lineLimit(1)
						Text("done").font(.caption2).foregroundStyle(.secondary)
					}
					.frame(width: inner)                         // text can't be wider than the ring's inside
					.position(x: proxy.size.width / 2, y: proxy.size.height / 2)
				}
			}
			.aspectRatio(1, contentMode: .fit)
			
            Text(caption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var caption: String {
        if summary.rows.isEmpty { return "Nothing due today" }
        return summary.doneCount == summary.dueCount ? "All done" : "Today"
    }
}
