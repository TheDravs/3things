//
//  TextDocument+CoreDataProperties.swift
//  3things
//
//  Created by Matthieu Draveny on 01/01/2025.
//

import Foundation
import CoreData

extension Journal {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Journal> {
        return NSFetchRequest<Journal>(entityName: "Journal")
    }

    // MARK: - Core Data Properties
    // Change _id to id to match the Core Data model
    @NSManaged public var id: UUID?  // Now directly using 'id' instead of '_id'
    @NSManaged public var title: String?
    @NSManaged public var contentUp: String?
    @NSManaged public var contentDown: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    @NSManaged public var memory1: String?
    @NSManaged public var memory2: String?
    @NSManaged public var memory3: String?
    @NSManaged public var memory1Checked: Bool
    @NSManaged public var memory2Checked: Bool
    @NSManaged public var memory3Checked: Bool
    @NSManaged public var contentUpData: Data?
    
    // MARK: - Public Interface
    
    // We can now simplify the id property since we're using it directly
    // No need for the getter/setter wrapper anymore
    public var wrappedId: UUID {
        id ?? UUID()
    }
    
    // Rest of your wrapper properties remain the same
    public var wrappedTitle: String {
        title ?? ""
    }
    
    public var wrappedContentUp: String {
        contentUp ?? ""
    }
    
    public var wrappedContentDown: String {
        contentDown ?? ""
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    public var wrappedUpdatedAt: Date {
        updatedAt ?? Date()
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: wrappedCreatedAt)
    }
    
    public var wrappedMemory1: String {
        memory1 ?? ""
    }
    public var wrappedMemory2: String {
        memory2 ?? ""
    }
    public var wrappedMemory3: String {
        memory3 ?? ""
    }

}

