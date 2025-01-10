//
//  _thingsApp.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import SwiftUI

@main
struct TextEditorApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            let _ = print("hasCompletedOnboarding: \(userSettings.hasCompletedOnboarding)")
            if !userSettings.hasCompletedOnboarding {
                OnboardingView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userSettings)
                    .frame(minWidth: 800, minHeight: 600) // Taille minimale de la fenêtre
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userSettings)
                    .frame(minWidth: 1000, minHeight: 800) // Taille minimale de la fenêtre principale
            }
        }
        .windowStyle(.automatic) // Style de fenêtre automatique
        .defaultSize(width: 1200, height: 800) // Taille par défaut de la fenêtre
        .commands {
            TextEditorCommands()
        }
        Settings {
                   SettingsView()
                       .environmentObject(userSettings)
               }
    }
}
