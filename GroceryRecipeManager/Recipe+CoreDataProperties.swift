//
//  Recipe+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var instructions: String?
    @NSManaged public var servings: Int16
    @NSManaged public var prepTime: Int16
    @NSManaged public var cookTime: Int16
    @NSManaged public var usageCount: Int32
    @NSManaged public var lastUsed: Date?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var sourceURL: String?

}

extension Recipe : Identifiable {

}
