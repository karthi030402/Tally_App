//
//  TallyApp.swift
//  Tally
//
//  Created by SATHAPPAN on 18/10/26.
//

import SwiftUI

@main
struct TallyApp: App {
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system
    /// The one store shared by every tab, backed by the on-disk database.
    @State private var store = StoreSetup.makeStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainTabView(store: store)
                .preferredColorScheme(appearance.colorScheme)
                .onChange(of: scenePhase) { _, phase in
                    // The widgets write to the shared database, so pick up their changes.
                    if phase == .active { store.reload() }
                }
        }
    }
}
