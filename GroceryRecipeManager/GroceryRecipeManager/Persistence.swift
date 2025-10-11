import CoreData

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

// MARK: - IngredientTemplate Migration Support (STEP 4 - ADDED)
extension IngredientTemplate {
    
    // Add these inside your existing IngredientTemplate extension:

    /// Safely toggles staple status with error handling
    func toggleStapleStatus() -> Bool {
        guard let context = managedObjectContext else {
            print("❌ Cannot toggle staple status - no managed object context")
            return false
        }
        
        isStaple.toggle()
        
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Staple status updated for: \(name ?? "Unknown")")
                return true
            }
            return true // No changes needed
        } catch {
            print("❌ Failed to save staple status change: \(error)")
            isStaple.toggle() // Revert the change
            return false
        }
    }

    /// Updates category assignment with validation
    func assignCategory(_ newCategory: String?) -> Bool {
        guard let context = managedObjectContext else {
            print("❌ Cannot assign category - no managed object context")
            return false
        }
        
        let oldCategory = category
        category = newCategory
        
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Category updated for \(name ?? "Unknown"): \(oldCategory ?? "None") → \(newCategory ?? "None")")
                return true
            }
            return true // No changes needed
        } catch {
            print("❌ Failed to save category assignment: \(error)")
            category = oldCategory // Revert the change
            return false
        }
    }

    // MARK: - Migration Support
    
    /// Migrates existing staples from GroceryItem.isStaple to IngredientTemplate.isStaple
    /// This is a one-time migration that preserves all existing staple data
    static func migrateStaplesFromGroceryItems(in context: NSManagedObjectContext) {
        print("🔄 Starting staples migration from GroceryItem to IngredientTemplate...")
        
        // Fetch all staples from GroceryItem
        let stapleRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        stapleRequest.predicate = NSPredicate(format: "isStaple == YES")
        
        do {
            let existingStaples = try context.fetch(stapleRequest)
            print("📦 Found \(existingStaples.count) existing staples to migrate")
            
            var migratedCount = 0
            let skippedCount = 0
            
            for staple in existingStaples {
                let stapleName = staple.name ?? "Unknown"
                
                // Check if IngredientTemplate already exists for this name
                let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                templateRequest.predicate = NSPredicate(format: "name ==[c] %@", stapleName)
                templateRequest.fetchLimit = 1
                
                if let existingTemplate = try context.fetch(templateRequest).first {
                    // Template exists, just mark as staple
                    existingTemplate.isStaple = true
                    
                    // Preserve category if staple has one and template doesn't
                    if existingTemplate.category?.isEmpty != false,
                       let stapleCategory = staple.category,
                       !stapleCategory.isEmpty {
                        existingTemplate.category = stapleCategory
                    }
                    
                    print("✅ Updated existing template '\(stapleName)' as staple")
                    migratedCount += 1
                } else {
                    // Create new IngredientTemplate from staple
                    let newTemplate = IngredientTemplate(context: context)
                    newTemplate.id = UUID()
                    newTemplate.name = stapleName
                    newTemplate.isStaple = true
                    newTemplate.usageCount = 1 // Start with usage count
                    
                    // Preserve category assignment
                    if let stapleCategory = staple.category, !stapleCategory.isEmpty {
                        newTemplate.category = stapleCategory
                    } else {
                        newTemplate.category = "Uncategorized"
                    }
                    
                    print("🆕 Created new template '\(stapleName)' as staple in '\(newTemplate.category ?? "Uncategorized")'")
                    migratedCount += 1
                }
            }
            
            // Save the migration
            if context.hasChanges {
                try context.save()
                print("✅ Migration completed: \(migratedCount) migrated, \(skippedCount) skipped")
                
                // Mark migration as complete
                UserDefaults.standard.set(true, forKey: "StaplesMigrationCompleted")
                UserDefaults.standard.set(Date(), forKey: "StaplesMigrationDate")
            } else {
                print("ℹ️ No changes needed during migration")
            }
            
        } catch {
            print("❌ Migration error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Migration Status
    
    /// Check if staples migration has been completed
    static var isMigrationCompleted: Bool {
        return UserDefaults.standard.bool(forKey: "StaplesMigrationCompleted")
    }
    
    /// Get migration completion date
    static var migrationDate: Date? {
        return UserDefaults.standard.object(forKey: "StaplesMigrationDate") as? Date
    }
    
    // MARK: - Validation
    
    /// Validate migration success
    static func validateMigration(in context: NSManagedObjectContext) -> (success: Bool, report: String) {
        var report = "📊 STAPLES MIGRATION VALIDATION\n\n"
        
        do {
            // Count original staples
            let stapleRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
            stapleRequest.predicate = NSPredicate(format: "isStaple == YES")
            let originalStaplesCount = try context.count(for: stapleRequest)
            
            // Count migrated templates
            let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            templateRequest.predicate = NSPredicate(format: "isStaple == YES")
            let migratedTemplatesCount = try context.count(for: templateRequest)
            
            report += "✅ Original staples: \(originalStaplesCount)\n"
            report += "✅ Migrated templates: \(migratedTemplatesCount)\n\n"
            
            if let migrationDate = migrationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                report += "📅 Migration completed: \(formatter.string(from: migrationDate))\n"
            }
            
            let success = migratedTemplatesCount > 0 || originalStaplesCount == 0
            report += success ? "\n🎯 Migration validation: PASSED" : "\n❌ Migration validation: FAILED"
            
            return (success, report)
            
        } catch {
            report += "❌ Validation error: \(error.localizedDescription)"
            return (false, report)
        }
    }
}

// MARK: - Category Extensions for Uncategorized Management
extension Category {
    
    /// Ensures Uncategorized category always appears last in sort order
    static func updateSortOrderForUncategorized(in context: NSManagedObjectContext) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)]
        
        do {
            let categories = try context.fetch(request)
            var sortOrder: Int16 = 0
            
            // Assign sort orders, skipping Uncategorized
            for category in categories {
                if category.displayName.lowercased() != "uncategorized" {
                    category.sortOrder = sortOrder
                    sortOrder += 1
                }
            }
            
            // Always put Uncategorized last
            if let uncategorized = categories.first(where: { $0.displayName.lowercased() == "uncategorized" }) {
                uncategorized.sortOrder = sortOrder
                print("✅ Uncategorized category moved to position \(sortOrder)")
            }
            
        } catch {
            print("❌ Error updating sort order for Uncategorized: \(error)")
        }
    }
    
    /// Migrates all nil ingredient template assignments to Uncategorized category
    static func migrateNilAssignmentsToUncategorized(in context: NSManagedObjectContext) {
        // First, ensure Uncategorized category exists
        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "name ==[c] %@", "Uncategorized")
        
        do {
            let existingUncategorized = try context.fetch(categoryRequest)
            let uncategorizedCategory: Category
            
            if let existing = existingUncategorized.first {
                uncategorizedCategory = existing
                print("ℹ️ Found existing Uncategorized category")
            } else {
                // Create Uncategorized category if it doesn't exist
                uncategorizedCategory = Category(context: context)
                uncategorizedCategory.id = UUID()
                uncategorizedCategory.name = "Uncategorized"
                uncategorizedCategory.color = "#9E9E9E" // Gray color
                uncategorizedCategory.isDefault = false // Custom category, not a default
                uncategorizedCategory.dateCreated = Date()
                uncategorizedCategory.sortOrder = Int16.max // Will be corrected by updateSortOrderForUncategorized
                print("✅ Created Uncategorized category")
            }
            
            // Now migrate all nil assignments
            let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            templateRequest.predicate = NSPredicate(format: "category == nil OR category == ''")
            
            let templatesWithNilCategory = try context.fetch(templateRequest)
            
            if !templatesWithNilCategory.isEmpty {
                for template in templatesWithNilCategory {
                    template.category = uncategorizedCategory.displayName
                }
                print("✅ Migrated \(templatesWithNilCategory.count) ingredient templates to Uncategorized")
            } else {
                print("ℹ️ No ingredient templates needed migration to Uncategorized")
            }
            
            // Update sort orders to ensure Uncategorized is last
            updateSortOrderForUncategorized(in: context)
            
        } catch {
            print("❌ Error during migration to Uncategorized: \(error)")
        }
    }
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
            listItem.displayText = quantity
            listItem.numericValue = 0.0
            listItem.isParseable = false
            listItem.parseConfidence = 0.0
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
    
    // MARK: - One-Time Setup (ENHANCED with Step 4 Migration - UPDATED)
    /// Performs all setup operations in the correct order to prevent duplicates
    private func performOneTimeSetup() {
        // Use a single background context for all setup operations
        container.performBackgroundTask { backgroundContext in
            // Step 1: Ensure categories exist first (only once)
            self.ensureCategoriesExist(in: backgroundContext)
            
            // Step 2: Migrate existing data to use category relationships
            self.migrateExistingData(in: backgroundContext)
            
            // Step 3: Migrate nil assignments to Uncategorized
            self.migrateToUncategorizedCategory(in: backgroundContext)
            
            // Step 4: NEW - Execute Step 4 staples migration
            self.executeStaplesMigrationIfNeeded(in: backgroundContext)
            
            // Step 5: Add sample data only if database is empty
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
    
    /// Migrates nil ingredient template assignments to Uncategorized category
    private func migrateToUncategorizedCategory(in context: NSManagedObjectContext) {
        print("🔄 Starting migration to Uncategorized category...")
        Category.migrateNilAssignmentsToUncategorized(in: context)
    }
    
    /// NEW - Execute Step 4 staples migration if needed (ADDED)
    private func executeStaplesMigrationIfNeeded(in context: NSManagedObjectContext) {
        // Check if migration has already been completed
        guard !IngredientTemplate.isMigrationCompleted else {
            print("ℹ️ Step 4 staples migration already completed, skipping...")
            return
        }
        
        print("🚀 Executing Step 4 staples migration...")
        IngredientTemplate.migrateStaplesFromGroceryItems(in: context)
        
        // Validate migration
        let validation = IngredientTemplate.validateMigration(in: context)
        print(validation.report)
        
        if !validation.success {
            print("⚠️ Step 4 migration validation failed - manual review recommended")
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

// MARK: - Step 4 Migration Support Extension (ADDED)
extension PersistenceController {
    
    // MARK: - Step 4 Migration Support
    
    /// Execute one-time staples migration during app startup
    func executeMigrationIfNeeded() {
        // Check if migration has already been completed
        guard !IngredientTemplate.isMigrationCompleted else {
            print("ℹ️ Staples migration already completed, skipping...")
            return
        }
        
        print("🚀 Executing staples migration on app startup...")
        
        // Perform migration in background context
        container.performBackgroundTask { context in
            IngredientTemplate.migrateStaplesFromGroceryItems(in: context)
            
            // Validate migration
            let validation = IngredientTemplate.validateMigration(in: context)
            print(validation.report)
            
            if !validation.success {
                print("⚠️ Migration validation failed - manual review recommended")
            }
        }
    }
    
    // MARK: - Migration Testing (Development Only)
    
    #if DEBUG
    /// Reset migration status for testing purposes (DEBUG builds only)
    func resetMigrationForTesting() {
        UserDefaults.standard.removeObject(forKey: "StaplesMigrationCompleted")
        UserDefaults.standard.removeObject(forKey: "StaplesMigrationDate")
        print("🔄 Migration status reset for testing")
    }
    
    /// Get migration status report for debugging
    func getMigrationStatusReport() -> String {
        var report = "🔍 MIGRATION STATUS REPORT\n\n"
        
        if IngredientTemplate.isMigrationCompleted {
            report += "✅ Migration Status: COMPLETED\n"
            if let date = IngredientTemplate.migrationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                report += "📅 Completion Date: \(formatter.string(from: date))\n"
            }
        } else {
            report += "⏳ Migration Status: PENDING\n"
        }
        
        // Get current data counts
        let context = container.viewContext
        
        do {
            let stapleRequest: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
            stapleRequest.predicate = NSPredicate(format: "isStaple == YES")
            let staplesCount = try context.count(for: stapleRequest)
            
            let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            templateRequest.predicate = NSPredicate(format: "isStaple == YES")
            let templatesCount = try context.count(for: templateRequest)
            
            report += "\n📊 Current Data:\n"
            report += "   GroceryItem staples: \(staplesCount)\n"
            report += "   IngredientTemplate staples: \(templatesCount)\n"
            
        } catch {
            report += "\n❌ Error fetching counts: \(error.localizedDescription)"
        }
        
        return report
    }
    #endif
}
