//
//  GroceryListItem+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Updated September 12, 2025 - Step 3: IngredientTemplate Integration
//

import Foundation
import CoreData

extension GroceryListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryListItem> {
        return NSFetchRequest<GroceryListItem>(entityName: "GroceryListItem")
    }

    @NSManaged public var dateCompleted: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var source: String?
    @NSManaged public var sourceType: String?        // ← MISSING - ADDED
    @NSManaged public var sourceRecipeID: UUID?      // ← MISSING - ADDED
    @NSManaged public var categoryName: String?
    @NSManaged public var isFromRecipe: Bool          // ← MISSING - ADDED
    @NSManaged public var weeklyList: WeeklyList?
}

extension GroceryListItem : Identifiable {

}
