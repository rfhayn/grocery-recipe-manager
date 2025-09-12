//
//  Ingredient+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Updated September 12, 2025 - Step 3: IngredientTemplate Integration
//

import Foundation
import CoreData

extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var unit: String?
    @NSManaged public var notes: String?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var recipe: Recipe?                    // ← MISSING - ADDED
    @NSManaged public var ingredientTemplate: IngredientTemplate?  // ← MISSING - ADDED
}

extension Ingredient : Identifiable {

}
