//
//  TextEditorCommands.swift
//  3things
//
//  Created by Matthieu Draveny on 01/01/2025.
//

import SwiftUI

final class DocumentManager: ObservableObject {
    static let shared = DocumentManager()
    
    private init() {}
    
    func createNewEntry() {
        let viewContext = PersistenceController.shared.container.viewContext
        
        // Create a Calendar instance for date calculations
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Set up a fetch request to check for existing entries
        let fetchRequest = Journal.fetchRequest()
        
        // Create a predicate that checks for entries created today
        // This ensures we don't create multiple entries for the same day
        fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@",
                                           today as NSDate,
                                           calendar.date(byAdding: .day, value: 1, to: today)! as NSDate
        )
        
        do {
            // Check for existing entries
            let existingEntries = try viewContext.fetch(fetchRequest)
            if !existingEntries.isEmpty {
                // If an entry already exists for today, don't create a new one
                return
            }
            
            // Create a new entry with a guaranteed UUID
            let newEntry = Journal(context: viewContext)
            let newId = UUID()  // Create UUID first to ensure consistency
            
            // Initialize all required properties
            newEntry.id = newId  // Using the id property directly now
            newEntry.title = ""
            newEntry.contentUp = ""    // Left editor content
            newEntry.contentDown = ""   // Right editor content
            newEntry.createdAt = Date()
            newEntry.updatedAt = Date()
            newEntry.memory1 = ""
            newEntry.memory2 = ""
            newEntry.memory3 = ""
            newEntry.memory1Checked = false
            newEntry.memory2Checked = false
            newEntry.memory3Checked = false
            
            // Save the context to persist the new entry
            try viewContext.save()
            
            // Post a notification about the new document
            // Using the id property directly instead of wrappedId
            NotificationCenter.default.post(
                name: .documentCreated,
                object: nil,
                userInfo: ["documentId": newId]  // Using newId directly
            )
        } catch {
            print("Error handling document creation: \(error)")
        }
    }
}

struct TextEditorCommands: Commands {
    var body: some Commands {
        // Replace the default New Item menu commands
        CommandGroup(after: .help) {
                   Button("Privacy Policy") {
                       if let window = NSApp.keyWindow {
                           let privacyView = NSHostingController(rootView: PrivacyView())
                           let privacyWindow = NSWindow(
                               contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                               styleMask: [.titled, .closable, .miniaturizable, .resizable],
                               backing: .buffered,
                               defer: false
                           )
                           privacyWindow.contentViewController = privacyView
                           privacyWindow.title = "Privacy Policy"
                           privacyWindow.center()
                           window.addChildWindow(privacyWindow, ordered: .above)
                       }
                   }
               }
           }
       }
