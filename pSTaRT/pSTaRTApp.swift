//
//  pSTaRTApp.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 11.09.22.
//  Copyright © 2022 Kurt Höblinger. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct pSTaRTApp: App {
    let persistenceController: PersistenceController
    let iapListener = NWIAPListener()
    init () {
        // initialize default values for several settings.
        // This does not override already modified settings.
        AppSettings.registerDefaults()
        persistenceController = PersistenceController.shared
    }
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                Overview()
            } detail: {
                NavigationStack {
                    PersonsList()
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
