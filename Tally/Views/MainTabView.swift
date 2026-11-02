import SwiftUI

/// The app's three tabs.
struct MainTabView: View {
    /// The one store shared by every tab.
    @State private var store = SampleHabits.makeStore()

    var body: some View {
        TabView {
            TodayScreen(store: store)
            .tabItem {
                Label("Today", systemImage: "checkmark.circle")
            }
            InsightsScreen(store: store)
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }
            HabitsScreen(store: store)
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    MainTabView()
}
