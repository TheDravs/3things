//
//  DataManager.swift
//  3things
//
//  Created by Matthieu Draveny on 07/01/2025.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    private let persistenceController = PersistenceController.shared
    
    // Export all journal entries as JSON
    enum ExportError: Error {
            case noEntriesFound
            case serializationFailed
            case fetchFailed(Error)
        }
        
        func exportData() -> Result<Data, ExportError> {
            let context = persistenceController.container.viewContext
            let fetchRequest: NSFetchRequest<Journal> = Journal.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Journal.createdAt, ascending: false)]
            
            do {
                let entries = try context.fetch(fetchRequest)
                
                // Check if we have any entries
                guard !entries.isEmpty else {
                    return .failure(.noEntriesFound)
                }
                
                let exportData = entries.map { entry -> [String: Any] in
                    return [
                        "date": entry.formattedDate,
                        "title": entry.wrappedTitle,
                        "journal": entry.wrappedContentUp,
                        "memories": [
                            entry.wrappedMemory1,
                            entry.wrappedMemory2,
                            entry.wrappedMemory3
                        ],
                        "created_at": entry.wrappedCreatedAt.timeIntervalSince1970,
                        "updated_at": entry.wrappedUpdatedAt.timeIntervalSince1970
                    ]
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys])
                    return .success(jsonData)
                } catch {
                    print("JSON serialization failed: \(error)")
                    return .failure(.serializationFailed)
                }
            } catch {
                print("Fetch failed: \(error)")
                return .failure(.fetchFailed(error))
            }
    }
    
    // Delete all user data
    func deleteAllData() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Journal.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistenceController.container.persistentStoreCoordinator.execute(deleteRequest, with: context)
            try context.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
}
