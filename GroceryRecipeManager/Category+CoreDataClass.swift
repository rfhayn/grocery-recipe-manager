//
//  Category+CoreDataClass.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/20/25.
//
//

import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {
    
    // MARK: - Default Categories
    static let defaultCategories: [(name: String, color: String, sortOrder: Int16)] = [
        ("Produce", "#4CAF50", 0),              // Green - Store entrance
        ("Deli & Meat", "#F44336", 1),          // Red - Back perimeter
        ("Dairy & Fridge", "#2196F3", 2),       // Blue - Back wall
        ("Bread & Frozen", "#FF9800", 3),       // Orange - Side aisles
        ("Boxed & Canned", "#795548", 4),       // Brown - Center aisles
        ("Snacks, Drinks, & Other", "#9C27B0", 5) // Purple - Checkout area
    ]
    
    // MARK: - Category Management
    static func createDefaultCategories(in context: NSManagedObjectContext) {
        for (name, color, sortOrder) in defaultCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.color = color
            category.sortOrder = sortOrder
            category.isDefault = true
            category.dateCreated = Date()
        }
    }
    
    static func ensureDefaultCategories(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let existingCategories = try context.fetch(request)
            if existingCategories.isEmpty {
                createDefaultCategories(in: context)
            }
        } catch {
            print("Error checking for existing categories: \\(error)")
            createDefaultCategories(in: context)
        }
    }
    
    // MARK: - Sort Order Management
    static func updateSortOrder(categories: [Category], in context: NSManagedObjectContext) {
        for (index, category) in categories.enumerated() {
            category.sortOrder = Int16(index)
        }
    }
    
    static func resetToDefaultOrder(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "isDefault == YES")
        
        do {
            let defaultCategories = try context.fetch(request)
            for category in defaultCategories {
                if let defaultData = Self.defaultCategories.first(where: { $0.name == category.name }) {
                    category.sortOrder = defaultData.sortOrder
                }
            }
        } catch {
            print("Error resetting category order: \\(error)")
        }
    }
}
