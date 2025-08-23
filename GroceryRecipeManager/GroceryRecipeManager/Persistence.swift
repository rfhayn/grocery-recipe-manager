import CoreData

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create comprehensive sample data with categories
        addSampleData(to: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // Enhanced sample data method with category relationships
    private static func addSampleData(to context: NSManagedObjectContext) {
        #if DEBUG
        // ONLY ensure categories exist in sample data - don't call migration here
        Category.ensureDefaultCategories(in: context)
        
        // Fetch categories for relationship assignment
        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = (try? context.fetch(categoryRequest)) ?? []
        let categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.displayName, $0) })
        
        // Sample Grocery Items (Staples) with category relationships
        let groceryItems = [
            ("Bananas", "Produce", true),
            ("Apples", "Produce", true),
            ("Strawberries", "Produce", true),
            ("Grapes", "Produce", true),
            ("Cucumbers", "Produce", true),
            ("Peppers", "Produce", true),
            ("Ham", "Deli & Meat", true),
            ("Bologna", "Deli & Meat", true),
            ("Bread", "Bread & Frozen", true),
            ("Kids Yogurt", "Dairy & Fridge", true),
            ("Milk 2%", "Dairy & Fridge", true),
            ("Milk 1%", "Dairy & Fridge", true)
        ]
        
        var groceryItemsDict: [String: GroceryItem] = [:]
        
        for (name, categoryName, isStaple) in groceryItems {
            let item = GroceryItem(context: context)
            item.id = UUID()
            item.name = name
            item.category = categoryName // Keep for legacy compatibility
            item.categoryEntity = categoryDict[categoryName] // Set relationship
            item.isStaple = isStaple
            item.dateCreated = Date().addingTimeInterval(-Double.random(in: 0...30) * 24 * 60 * 60)
            if isStaple {
                item.lastPurchased = Date().addingTimeInterval(-Double.random(in: 1...14) * 24 * 60 * 60)
            }
            groceryItemsDict[name] = item
        }
        
        // Sample Tags
        let tagData = [
            ("Quick & Easy", "#FF6B6B"),
            ("Healthy", "#4ECDC4"),
            ("Comfort Food", "#45B7D1"),
            ("Vegetarian", "#96CEB4"),
            ("30 Minutes", "#FECA57"),
            ("Leftovers", "#FF9FF3")
        ]
        
        var tagsDict: [String: Tag] = [:]
        
        for (name, color) in tagData {
            let tag = Tag(context: context)
            tag.id = UUID()
            tag.name = name
            tag.color = color
            tag.dateCreated = Date()
            tagsDict[name] = tag
        }
        
        // Sample Recipes with realistic data
        let recipeData = [
            ("Chicken Stir Fry", "Heat oil in wok. Add chicken and cook until done. Add vegetables and stir fry for 5 minutes. Season with soy sauce.", 4, 15, 10, 5),
            ("Spaghetti Carbonara", "Cook pasta. In pan, cook eggs and cheese mixture. Combine with hot pasta. Add pepper and serve.", 2, 10, 20, 8),
            ("Banana Bread", "Preheat oven to 350°F. Mix dry ingredients. In separate bowl, mash bananas and mix with wet ingredients. Combine and bake for 1 hour.", 8, 20, 60, 2),
            ("Fried Rice", "Cook rice day before. Heat oil, scramble eggs, add rice and vegetables. Season with soy sauce.", 4, 10, 15, 12)
        ]
        
        for (title, instructions, servings, prepTime, cookTime, usageCount) in recipeData {
            let recipe = Recipe(context: context)
            recipe.id = UUID()
            recipe.title = title
            recipe.instructions = instructions
            recipe.servings = Int16(servings)
            recipe.prepTime = Int16(prepTime)
            recipe.cookTime = Int16(cookTime)
            recipe.usageCount = Int32(usageCount)
            recipe.dateCreated = Date().addingTimeInterval(-Double.random(in: 0...60) * 24 * 60 * 60)
            recipe.lastUsed = Date().addingTimeInterval(-Double.random(in: 0...30) * 24 * 60 * 60)
            recipe.isFavorite = usageCount > 5
            recipe.sourceURL = "https://example.com/recipe/\(title.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
        
        // Sample Weekly List
        let weeklyList = WeeklyList(context: context)
        weeklyList.id = UUID()
        weeklyList.name = "Weekly Shopping - \(DateFormatter.shortDate.string(from: Date()))"
        weeklyList.dateCreated = Date()
        weeklyList.isCompleted = false
        weeklyList.notes = "Don't forget to check for coupons!"
        
        // Sample Grocery List Items
        let listItems = [
            ("Bananas", "2 bunches", false, "staples"),
            ("Milk", "1 gallon", false, "staples"),
            ("Tomatoes", "1 lb", true, "recipe"),
            ("Special Ice Cream", "1 pint", false, "manual")
        ]
        
        for (name, quantity, isCompleted, source) in listItems {
            let listItem = GroceryListItem(context: context)
            listItem.id = UUID()
            listItem.name = name
            listItem.quantity = quantity
            listItem.isCompleted = isCompleted
            listItem.source = source
            listItem.sortOrder = Int16(listItems.firstIndex(where: { $0.0 == name }) ?? 0)
            if isCompleted {
                listItem.dateCompleted = Date().addingTimeInterval(-Double.random(in: 0...7) * 24 * 60 * 60)
            }
        }
        #else
        // Production builds: no sample data created
        print("Production build: Sample data creation skipped")
        #endif
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GroceryRecipeManager")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // FIXED: Only perform setup once, in the right order
        if !inMemory {
            performOneTimeSetup()
        }
    }
    
    // MARK: - One-Time Setup (FIXED)
    /// Performs all setup operations in the correct order to prevent duplicates
    private func performOneTimeSetup() {
        // Use a single background context for all setup operations
        container.performBackgroundTask { backgroundContext in
            // Step 1: Ensure categories exist first (only once)
            self.ensureCategoriesExist(in: backgroundContext)
            
            // Step 2: Migrate existing data to use category relationships
            self.migrateExistingData(in: backgroundContext)
            
            // Step 3: Add sample data only if database is empty
            self.addSampleDataIfNeeded(in: backgroundContext)
            
            // Save all changes at once
            do {
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                    print("✅ One-time setup completed successfully")
                }
            } catch {
                print("❌ Setup failed: \(error)")
            }
        }
    }
    
    /// Ensures categories exist (called only once)
    private func ensureCategoriesExist(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let existingCategories = try context.fetch(request)
            if existingCategories.isEmpty {
                Category.createDefaultCategories(in: context)
                print("✅ Created default categories")
            } else {
                print("ℹ️ Categories already exist (\(existingCategories.count) found)")
            }
        } catch {
            print("❌ Error checking categories: \(error)")
            Category.createDefaultCategories(in: context)
        }
    }
    
    /// Migrates existing grocery items to use category relationships
    private func migrateExistingData(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        request.predicate = NSPredicate(format: "categoryEntity == nil AND category != nil")
        
        do {
            let itemsToMigrate = try context.fetch(request)
            if !itemsToMigrate.isEmpty {
                print("🔄 Migrating \(itemsToMigrate.count) items to category relationships")
                for item in itemsToMigrate {
                    item.migrateToCategory(in: context)
                }
            }
        } catch {
            print("❌ Migration failed: \(error)")
        }
    }
    
    /// Add sample data only if database is completely empty
    private func addSampleDataIfNeeded(in context: NSManagedObjectContext) {
        #if DEBUG
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                // DON'T call ensureDefaultCategories here - categories already exist
                print("📦 Adding sample data to empty database")
                PersistenceController.addSampleDataWithoutCategories(to: context)
            } else {
                print("ℹ️ Database has data (\(count) items), skipping sample data")
            }
        } catch {
            print("❌ Error checking for existing data: \(error)")
        }
        #endif
    }
    
    /// Sample data creation that doesn't create categories (they already exist)
    private static func addSampleDataWithoutCategories(to context: NSManagedObjectContext) {
        // Fetch existing categories
        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = (try? context.fetch(categoryRequest)) ?? []
        let categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.displayName, $0) })
        
        // Only create grocery items and other data - categories already exist
        let groceryItems = [
            ("Bananas", "Produce", true),
            ("Apples", "Produce", true),
            ("Strawberries", "Produce", true),
            ("Ham", "Deli & Meat", true),
            ("Bologna", "Deli & Meat", true),
            ("Milk 2%", "Dairy & Fridge", true),
            ("Kids Yogurt", "Dairy & Fridge", true),
            ("Bread", "Bread & Frozen", true)
        ]
        
        for (name, categoryName, isStaple) in groceryItems {
            let item = GroceryItem(context: context)
            item.id = UUID()
            item.name = name
            item.category = categoryName
            item.categoryEntity = categoryDict[categoryName]
            item.isStaple = isStaple
            item.dateCreated = Date().addingTimeInterval(-Double.random(in: 0...30) * 24 * 60 * 60)
            if isStaple {
                item.lastPurchased = Date().addingTimeInterval(-Double.random(in: 1...14) * 24 * 60 * 60)
            }
        }
        
        print("✅ Sample data added with existing categories")
    }
    
    // MARK: - Background Operations
    /// Performs Core Data write operations on a background context to prevent UI blocking.
    func performWrite(_ block: @escaping (NSManagedObjectContext) -> Void, onError: ((Error) -> Void)? = nil) {
        container.performBackgroundTask { ctx in
            ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(ctx)
            if ctx.hasChanges {
                do {
                    try ctx.save()
                } catch {
                    print("❌ Background save failed: \(error)")
                    DispatchQueue.main.async {
                        onError?(error)
                    }
                }
            }
        }
    }
}
