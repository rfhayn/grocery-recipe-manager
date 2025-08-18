//
//  WeeklyList+CoreDataProperties.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//
//

import Foundation
import CoreData


extension WeeklyList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeeklyList> {
        return NSFetchRequest<WeeklyList>(entityName: "WeeklyList")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var notes: String?

}

extension WeeklyList : Identifiable {

}
