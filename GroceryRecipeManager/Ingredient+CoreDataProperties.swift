//
//  Ingredient+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//
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

}

extension Ingredient : Identifiable {

}
