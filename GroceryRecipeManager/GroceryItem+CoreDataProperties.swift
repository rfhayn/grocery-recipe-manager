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

}

extension GroceryItem : Identifiable {

}
