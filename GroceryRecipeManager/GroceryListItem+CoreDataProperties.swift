//
//  GroceryListItem+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 10/10/25.
//
//

public import Foundation
public import CoreData


public typealias GroceryListItemCoreDataPropertiesSet = NSSet

extension GroceryListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryListItem> {
        return NSFetchRequest<GroceryListItem>(entityName: "GroceryListItem")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var dateCompleted: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isFromRecipe: Bool
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int16
    @NSManaged public var source: String?
    @NSManaged public var sourceRecipeID: UUID?
    @NSManaged public var sourceType: String?
    @NSManaged public var numericValue: Double
    @NSManaged public var standardUnit: String?
    @NSManaged public var displayText: String?
    @NSManaged public var isParseable: Bool
    @NSManaged public var parseConfidence: Float
    @NSManaged public var weeklyList: WeeklyList?

}

extension GroceryListItem : Identifiable {

}
