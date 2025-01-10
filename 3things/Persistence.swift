//
//  Persistence.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import CoreData

struct PersistenceController {
    // Shared singleton instance that will be used across the app
    static let shared = PersistenceController()
    
    // The NSPersistentContainer manages the Core Data stack
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create the container with your data model name
        container = NSPersistentContainer(name: "_things")
        
        // Configure persistent store for testing if needed
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Set up store description options before loading stores
        // This enables cloud sync capabilities and history tracking
        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.setOption(true as NSNumber,
                                     forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            storeDescription.setOption(true as NSNumber,
                                     forKey: NSPersistentHistoryTrackingKey)
        }
        
        // Load the persistent stores
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In a production app, you should handle this error appropriately
                // rather than crashing with fatalError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Configure view context to better handle concurrent changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
