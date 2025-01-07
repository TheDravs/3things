//
//  _thingsApp.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import SwiftUI

@main
struct _thingsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
