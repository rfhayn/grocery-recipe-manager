//
//  GroceryItem+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//
//

import Foundation
import CoreData

extension GroceryItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryItem> {
        return NSFetchRequest<GroceryItem>(entityName: "GroceryItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var isStaple: Bool
    @NSManaged public var dateCreated: Date?
    @NSManaged public var lastPurchased: Date?
    @NSManaged public var categoryEntity: Category?

}

extension GroceryItem : Identifiable {

}

// MARK: - Category Management Convenience
extension GroceryItem {
    
    /// Returns the category name, preferring the relationship over the legacy string field
    var effectiveCategory: String {
        if let categoryEntity = categoryEntity {
            return categoryEntity.displayName
        }
        return category ?? "Uncategorized"
    }
    
    /// Returns the category color for UI display
    var categoryColor: String {
        return categoryEntity?.displayColor ?? "#757575"
    }
    
    /// Migrates from string category to Category entity relationship
    func migrateToCategory(in context: NSManagedObjectContext) {
        guard categoryEntity == nil, let categoryString = category else { return }
        
        // Find matching Category entity
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", categoryString)
        
        do {
            let categories = try context.fetch(request)
            if let matchingCategory = categories.first {
                self.categoryEntity = matchingCategory
            }
        } catch {
            print("Error migrating category for item \\(name ?? 'unknown'): \\(error)")
        }
    }
}
