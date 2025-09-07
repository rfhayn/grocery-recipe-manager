//
//  Recipe+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Richard Hayn on 9/7/25.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var cookTime: Int16
    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var instructions: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastUsed: Date?
    @NSManaged public var prepTime: Int16
    @NSManaged public var servings: Int16
    @NSManaged public var sourceURL: String?
    @NSManaged public var title: String?
    @NSManaged public var usageCount: Int32
    @NSManaged public var ingredients: NSSet?

}

// MARK: Generated accessors for ingredients
extension Recipe {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Recipe : Identifiable {

}
