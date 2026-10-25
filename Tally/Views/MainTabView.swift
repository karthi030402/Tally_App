import SwiftUI

/// The app's three tabs. Insights is a placeholder until that screen is built.
struct MainTabView: View {
    /// The one store shared by every tab.
    @State private var store = SampleHabits.makeStore()

    var body: some View {
        TabView {
            TodayScreen(store: store)
            .tabItem {
                Label("Today", systemImage: "checkmark.circle")
            }
            PlaceholderScreen(
                title: "Insights",
                systemImage: "chart.bar.xaxis"
            )
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

private struct PlaceholderScreen: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text("Coming soon.")
            )
            .background { DawnBackground() }
            .navigationTitle(title)
        }
    }
}

#Preview {
    MainTabView()
}
