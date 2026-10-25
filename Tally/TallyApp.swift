//
//  TallyApp.swift
//  Tally
//
//  Created by SATHAPPAN on 18/10/26.
//

import SwiftUI
import SwiftData

@main
struct TallyApp: App {
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(appearance.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
