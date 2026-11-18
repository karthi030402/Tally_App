import SwiftUI
import TallyCore

/// The app's three tabs.
struct MainTabView: View {
    /// The one store shared by every tab.
    let store: HabitStore
    @State private var selection: AppTab = .today
    /// A habit a link asked to open. The Habits tab takes it and clears it.
    @State private var requestedHabitID: UUID?

    var body: some View {
        TabView(selection: $selection) {
            TodayScreen(store: store)
            .tabItem {
                Label("Today", systemImage: "checkmark.circle")
            }
            .tag(AppTab.today)
            InsightsScreen(store: store)
            .tabItem {
                Label("Insights", systemImage: "chart.bar.xaxis")
            }
            .tag(AppTab.insights)
            HabitsScreen(store: store, requestedHabitID: $requestedHabitID)
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }
            .tag(AppTab.habits)
        }
        .tint(AppTheme.accent)
        .onOpenURL { url in
            switch DeepLink(url: url) {
            case .today:
                selection = .today
            case .habit(let id):
                requestedHabitID = id
                selection = .habits
            case nil:
                break
            }
        }
    }
}

#Preview {
    MainTabView(store: SampleHabits.makeStore())
}
