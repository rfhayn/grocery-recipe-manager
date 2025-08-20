//
//  CategoryMigrationHelper.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/20/25.
//
//

import Foundation
import CoreData

struct CategoryMigrationHelper {
    
    static func performMigration(in context: NSManagedObjectContext) {
        #if DEBUG
        print("🔄 Starting category migration...")
        #endif
        
        // Step 1: Clean up any duplicates first
        cleanupDuplicateCategories(in: context)
        
        // Step 2: Ensure default categories exist
        Category.ensureDefaultCategories(in: context)
        
        // Step 3: Migrate existing GroceryItems from string categories to relationships
        migrateGroceryItemCategories(in: context)
        
        // Step 4: Save changes
        do {
            if context.hasChanges {
                try context.save()
                #if DEBUG
                print("✅ Category migration completed successfully")
                #endif
            }
        } catch {
            #if DEBUG
            print("❌ Category migration failed: \(error)")
            #endif
        }
    }
    
    private static func cleanupDuplicateCategories(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let allCategories = try context.fetch(request)
            let groupedCategories = Dictionary(grouping: allCategories) { $0.displayName }
            
            for (categoryName, categories) in groupedCategories {
                if categories.count > 1 {
                    #if DEBUG
                    print("🧹 Found \(categories.count) duplicate categories named '\(categoryName)'")
                    #endif
                    
                    // Keep the first one (with lowest sortOrder)
                    let sortedCategories = categories.sorted { $0.sortOrder < $1.sortOrder }
                    let categoryToKeep = sortedCategories.first!
                    
                    // Delete the rest
                    for category in sortedCategories.dropFirst() {
                        #if DEBUG
                        print("🗑️ Deleting duplicate category: \(category.displayName)")
                        #endif
                        context.delete(category)
                    }
                }
            }
        } catch {
            print("❌ Error cleaning up duplicate categories: \(error)")
        }
    }
    
    private static func migrateGroceryItemCategories(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        request.predicate = NSPredicate(format: "categoryEntity == nil AND category != nil")
        
        do {
            let itemsToMigrate = try context.fetch(request)
            #if DEBUG
            print("🔄 Migrating \(itemsToMigrate.count) grocery items to category relationships")
            #endif
            
            for item in itemsToMigrate {
                item.migrateToCategory(in: context)
            }
            
        } catch {
            print("Error fetching items for migration: \(error)")
        }
    }
    
    // MARK: - Legacy Category Mapping
    /// Maps old hardcoded category strings to default categories
    static func mapLegacyCategory(_ categoryString: String) -> String {
        let mapping: [String: String] = [
            "Produce": "Produce",
            "Deli & Meat": "Deli & Meat",
            "Dairy & Fridge": "Dairy & Fridge",
            "Bread & Frozen": "Bread & Frozen",
            "Boxed & Canned": "Boxed & Canned",
            "Snacks, Drinks, & Other": "Snacks, Drinks, & Other",
            // Legacy mappings for any old category names
            "Grocery": "Boxed & Canned",
            "Meat": "Deli & Meat",
            "Dairy": "Dairy & Fridge",
            "Pantry": "Boxed & Canned"
        ]
        
        return mapping[categoryString] ?? "Snacks, Drinks, & Other"
    }
}
