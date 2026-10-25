import SwiftUI

/// The Settings screen, pushed from the Habits tab. For now it only holds the theme choice.
struct SettingsScreen: View {
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                RadioGroup(
                    title: "Appearance",
                    options: AppAppearance.allCases,
                    selection: $appearance,
                    optionTitle: \.title,
                    optionDescription: { $0.summary }
                )
                Text("Widgets always follow your device's setting.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
            .padding(20)
        }
        .background { DawnBackground() }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsScreen() }
}
