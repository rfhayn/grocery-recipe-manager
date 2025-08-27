//
//  GroceryListItem+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Richard Hayn on 8/27/25.
//
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
    @NSManaged public var categoryName: String?
    @NSManaged public var weeklyList: WeeklyList?

}

extension GroceryListItem : Identifiable {

}
