//
//  GroceryListItem+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//
//

import Foundation
import CoreData


extension GroceryListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryListItem> {
        return NSFetchRequest<GroceryListItem>(entityName: "GroceryListItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var quantity: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var dateCompleted: Date?
    @NSManaged public var source: String?
    @NSManaged public var sortOrder: Int16

}

extension GroceryListItem : Identifiable {

}
