import SwiftUI
import CoreData

struct AddIngredientsToListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let recipe: Recipe
    
    @State private var selectedIngredients: Set<UUID> = []
    @State private var isProcessing = false
    @State private var processingMessage = "Processing..."
    @State private var targetWeeklyList: WeeklyList?
    
    // MARK: - Category Assignment Modal States
    @State private var showingCategoryAssignment = false
    @State private var uncategorizedTemplates: [IngredientTemplate] = []
    @State private var pendingAddOperation: (() -> Void)?
    
    // M2.2.6 - STEP 1: Add Category FetchRequest (add this after your existing @State properties)
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    // M2.2.6 - ADDED: Computed properties for custom category grouping
    private var groupedIngredients: [String: [Ingredient]] {
        guard let ingredientsSet = recipe.ingredients else { return [:] }
        let ingredientsList = Array(ingredientsSet) as! [Ingredient]
        
        return Dictionary(grouping: ingredientsList) { ingredient in
            ingredient.ingredientTemplate?.category ?? "Uncategorized"
        }
    }

    private var sortedCategoryNames: [String] {
        let grouped = groupedIngredients
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.displayName, $0.sortOrder) })
        
        return grouped.keys.sorted { category1, category2 in
            // Handle "Uncategorized" - put it at the end
            if category1 == "Uncategorized" && category2 != "Uncategorized" { return false }
            if category2 == "Uncategorized" && category1 != "Uncategorized" { return true }
            if category1 == "Uncategorized" && category2 == "Uncategorized" { return false }
            
            // Use custom sort order for real categories
            let order1 = categoryMap[category1] ?? Int16.max
            let order2 = categoryMap[category2] ?? Int16.max
            
            if order1 == order2 {
                return category1 < category2 // Fallback to alphabetical
            }
            return order1 < order2
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isProcessing {
                    processingView
                } else {
                    ingredientSelectionView
                }
            }
            .navigationTitle("Add to Grocery List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Selected") {
                        addSelectedToGroceryListWithCategoryCheck()
                    }
                    .disabled(selectedIngredients.isEmpty)
                }
            }
        }
        .onAppear {
            preselectAllIngredients()
        }
        .sheet(isPresented: $showingCategoryAssignment) {
            CategoryAssignmentModal(
                uncategorizedTemplates: uncategorizedTemplates,
                onAssignmentsComplete: {
                    if let operation = pendingAddOperation {
                        operation()
                        pendingAddOperation = nil
                    }
                }
            )
            .environment(\.managedObjectContext, viewContext)
        }
    }
    
    // MARK: - Enhanced Add to List Process with Category Assignment
    
    private func addSelectedToGroceryListWithCategoryCheck() {
        isProcessing = true
        processingMessage = "Preparing ingredients..."
        
        // Step 1: Prepare ingredients and create/update templates
        prepareIngredientsAndTemplates { success in
            if success {
                // Step 2: Check for uncategorized templates
                checkForUncategorizedTemplates { uncategorized in
                    if !uncategorized.isEmpty {
                        // Step 3: Show category assignment modal
                        DispatchQueue.main.async {
                            self.isProcessing = false
                            self.uncategorizedTemplates = uncategorized
                            self.pendingAddOperation = {
                                self.proceedWithExistingAddFlow()
                            }
                            self.showingCategoryAssignment = true
                        }
                    } else {
                        // Step 4: Proceed with existing flow
                        self.proceedWithExistingAddFlow()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.processingMessage = "Failed to prepare ingredients"
                    self.isProcessing = false
                }
            }
        }
    }
    
    // IMPROVED: Updated ingredient parsing with clean names for templates
    private func prepareIngredientsAndTemplates(completion: @escaping (Bool) -> Void) {
        guard let ingredientsSet = recipe.ingredients else {
            completion(false)
            return
        }
        
        let ingredients = Array(ingredientsSet) as! [Ingredient]
        let selectedIngredientsList = ingredients.filter { ingredient in
            guard let id = ingredient.id else { return false }
            return selectedIngredients.contains(id)
        }
        
        // Use viewContext directly
        for ingredient in selectedIngredientsList {
            guard let fullName = ingredient.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !fullName.isEmpty else { continue }
            
            // IMPROVED: Extract clean ingredient name for template matching
            let cleanName = extractCleanIngredientName(from: fullName)
            print("Looking for ingredient: '\(fullName)' -> clean: '\(cleanName)'")
            
            // Find or create template using the CLEAN name
            let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[cd] %@", cleanName)
            
            do {
                let template: IngredientTemplate
                if let existing = try viewContext.fetch(request).first {
                    template = existing
                    print("Found existing template: '\(existing.name ?? "nil")'")
                } else {
                    template = IngredientTemplate(context: viewContext)
                    template.id = UUID()
                    template.name = cleanName  // Store CLEAN name
                    template.usageCount = 0
                    template.dateCreated = Date()
                    template.category = nil  // Will be handled by category assignment flow
                    template.isStaple = false // Default value
                    print("Created new template: '\(cleanName)'")
                }
                
                // Update usage count and ESTABLISH RELATIONSHIP
                template.usageCount += 1
                ingredient.ingredientTemplate = template
                
            } catch {
                print("Error creating template: \(error)")
            }
        }
        
        // Save context
        do {
            try viewContext.save()
            print("Templates prepared successfully")
            completion(true)
        } catch {
            print("Error saving templates: \(error)")
            completion(false)
        }
    }
    
    // FIXED: Check for templates that need category assignment
    private func checkForUncategorizedTemplates(completion: @escaping ([IngredientTemplate]) -> Void) {
        guard let ingredientsSet = recipe.ingredients else {
            completion([])
            return
        }
        
        let ingredients = Array(ingredientsSet) as! [Ingredient]
        let selectedIngredientsList = ingredients.filter { ingredient in
            guard let id = ingredient.id else { return false }
            return selectedIngredients.contains(id)
        }
        
        // DEBUG: Add debugging to see what's actually in the templates
        for ingredient in selectedIngredientsList {
            if let template = ingredient.ingredientTemplate {
                print("Template '\(template.name ?? "nil")' has category: '\(template.category ?? "nil")'")
            }
        }
        
        // Find templates that need category assignment (nil, empty, or "Uncategorized")
        var uncategorized: [IngredientTemplate] = []
        
        for ingredient in selectedIngredientsList {
            if let template = ingredient.ingredientTemplate {
                // FIXED: Check if category is nil, empty, or "Uncategorized"
                if template.category == nil ||
                   template.category?.isEmpty == true ||
                   template.category?.lowercased() == "uncategorized" {
                    uncategorized.append(template)
                }
            }
        }
        
        // Remove duplicates based on template ID
        let uniqueUncategorized = Array(Set(uncategorized.map { $0.objectID }))
            .compactMap { objectID in
                uncategorized.first { $0.objectID == objectID }
            }
        
        print("Found \(uniqueUncategorized.count) ingredients needing category assignment")
        completion(uniqueUncategorized)
    }
    
    private func proceedWithExistingAddFlow() {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.processingMessage = "Finding grocery list..."
            
            // Use existing logic
            if let existingList = self.findMostRecentUncompletedList() {
                self.targetWeeklyList = existingList
                self.processingMessage = "Adding to \(existingList.name ?? "grocery list")..."
                self.addSelectedToGroceryList()
            } else {
                self.processingMessage = "Creating new grocery list..."
                self.createNewListAndAddIngredients()
            }
        }
    }
    
    // MARK: - Existing Logic (PRESERVED)
    
    private func findMostRecentUncompletedList() -> WeeklyList? {
        let request: NSFetchRequest<WeeklyList> = WeeklyList.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \WeeklyList.dateCreated, ascending: false)
        ]
        request.fetchLimit = 1
        
        do {
            let uncompletedLists = try viewContext.fetch(request)
            return uncompletedLists.first
        } catch {
            print("Error fetching uncompleted lists: \(error)")
            return nil
        }
    }
    
    private func createNewListAndAddIngredients() {
        let newList = createNewWeeklyList()
        
        do {
            try viewContext.save()
            targetWeeklyList = newList
            print("Successfully created new list: \(newList.name ?? "Unnamed")")
            addSelectedToGroceryList()
        } catch {
            print("Error saving new weekly list: \(error)")
            processingMessage = "Error creating new list"
            isProcessing = false
        }
    }
    
    private func createNewWeeklyList() -> WeeklyList {
        let newList = WeeklyList(context: viewContext)
        newList.id = UUID()
        newList.name = "Week of \(formattedCurrentDate)"
        newList.dateCreated = Date()
        newList.isCompleted = false
        newList.notes = "Created from recipe: \(recipe.title ?? "Unknown Recipe")"
        
        print("Created new weekly list: \(newList.name ?? "Unnamed")")
        return newList
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    private func addSelectedToGroceryList() {
        guard let targetList = targetWeeklyList else {
            isProcessing = false
            return
        }
        
        processingMessage = "Creating grocery list items..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            createGroceryListItems(in: targetList)
        }
    }
    
    // FIXED: Modified to preserve quantities in grocery list items
    private func createGroceryListItems(in weeklyList: WeeklyList) {
        guard let ingredientsSet = recipe.ingredients else {
            isProcessing = false
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        let ingredients = Array(ingredientsSet) as! [Ingredient]
        let selectedIngredientsToAdd = ingredients.filter { ingredient in
            guard let id = ingredient.id else { return false }
            return selectedIngredients.contains(id)
        }
        
        guard !selectedIngredientsToAdd.isEmpty else {
            isProcessing = false
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        let existingItems = fetchExistingItems(in: weeklyList)
        var mergeCount = 0
        
        for ingredient in selectedIngredientsToAdd {
            // FIXED: Use full ingredient text WITH quantities for grocery list
            let fullIngredientText = ingredient.name ?? "Unknown ingredient"
            
            // But use clean name for template operations and duplicate detection
            let cleanName: String
            if let ingredientTemplate = ingredient.ingredientTemplate {
                cleanName = ingredientTemplate.name ?? extractCleanIngredientName(from: fullIngredientText)
            } else {
                cleanName = extractCleanIngredientName(from: fullIngredientText)
            }
            
            print("DEBUG: Processing ingredient '\(fullIngredientText)' -> clean: '\(cleanName)'")
            
            // Check for existing items by clean name
            if let existingItem = findExistingItem(named: cleanName, in: existingItems) {
                // FIXED: Merge quantities if both have quantities
                let existingName = existingItem.name ?? ""
                let newQuantityInfo = extractQuantityInfo(from: fullIngredientText)
                let existingQuantityInfo = extractQuantityInfo(from: existingName)
                
                print("DEBUG: Merging - existing: '\(existingName)', new: '\(fullIngredientText)'")
                print("DEBUG: Extracted quantities - existing: '\(existingQuantityInfo)', new: '\(newQuantityInfo)'")
                
                if !newQuantityInfo.isEmpty && !existingQuantityInfo.isEmpty {
                    // Try to merge quantities
                    let mergedQuantity = mergeQuantities(existing: existingQuantityInfo, new: newQuantityInfo)
                    existingItem.name = "\(mergedQuantity) \(cleanName)"
                    print("DEBUG: Final merged result: '\(existingItem.name ?? "nil")'")
                } else if !newQuantityInfo.isEmpty && existingQuantityInfo.isEmpty {
                    // Add quantity to existing item
                    existingItem.name = fullIngredientText
                    print("DEBUG: Added quantity to existing: '\(existingItem.name ?? "nil")'")
                }
                // If new item has no quantity, keep existing as-is
                
                mergeCount += 1
                print("Merged quantities for '\(cleanName)'")
            } else {
                // Create new item with full name including quantities
                let listItem = GroceryListItem(context: viewContext)
                listItem.id = UUID()
                listItem.name = fullIngredientText  // CHANGED: Keep full name with quantities
                listItem.isCompleted = false
                listItem.source = "Recipe: \(recipe.title ?? "Unknown Recipe")"
                
                // Use proper category assignment logic
                if let template = ingredient.ingredientTemplate,
                   let categoryString = template.category,
                   !categoryString.isEmpty {
                    listItem.categoryName = categoryString
                    print("Assigned category '\(categoryString)' to '\(cleanName)'")
                } else {
                    listItem.categoryName = "UNCATEGORIZED"
                    print("Assigned UNCATEGORIZED to '\(cleanName)'")
                }
                
                weeklyList.addToItems(listItem)
                print("Created new item: \(fullIngredientText)")
            }
        }
        
        do {
            try viewContext.save()
            print("Successfully added \(selectedIngredientsToAdd.count) ingredients")
            if mergeCount > 0 {
                print("Merged quantities for \(mergeCount) existing items")
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Error saving grocery list items: \(error)")
            DispatchQueue.main.async {
                self.processingMessage = "Error saving items"
                self.isProcessing = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchExistingItems(in weeklyList: WeeklyList) -> [GroceryListItem] {
        guard let itemsSet = weeklyList.items else { return [] }
        return Array(itemsSet) as! [GroceryListItem]
    }
    
    private func findExistingItem(named targetName: String, in items: [GroceryListItem]) -> GroceryListItem? {
        return items.first { item in
            guard let itemName = item.name else { return false }
            let cleanItemName = extractCleanIngredientName(from: itemName)
            return cleanItemName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                   targetName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func extractCleanIngredientName(from fullText: String) -> String {
        let text = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("Extracting clean name from: '\(text)'")
        
        var cleaned = text
        
        // Remove measurements with units (comprehensive pattern)
        let measurementPattern = #"^[\d/.\s-]*(cups?|tbsp?|tsp?|tablespoons?|teaspoons?|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|liters?|l|milliliters?|ml|eggs?)\s+"#
        cleaned = cleaned.replacingOccurrences(of: measurementPattern, with: "", options: [.regularExpression, .caseInsensitive])
        
        // Remove any remaining numbers and fractions at the start
        let numberPattern = #"^[\d/.\s-]+"#
        cleaned = cleaned.replacingOccurrences(of: numberPattern, with: "", options: [.regularExpression])
        
        // Remove size descriptors at the start
        let sizePattern = #"^(large|small|medium|whole)\s+"#
        cleaned = cleaned.replacingOccurrences(of: sizePattern, with: "", options: [.regularExpression, .caseInsensitive])
        
        // Remove articles at the start
        let articlePattern = #"^(a|an|the)\s+"#
        cleaned = cleaned.replacingOccurrences(of: articlePattern, with: "", options: [.regularExpression, .caseInsensitive])
        
        // Clean up the end - remove descriptors after comma
        let descriptorPattern = #",.*$"#
        cleaned = cleaned.replacingOccurrences(of: descriptorPattern, with: "", options: [.regularExpression])
        
        // Remove parenthetical info
        let parenthesesPattern = #"\s*\([^)]*\).*$"#
        cleaned = cleaned.replacingOccurrences(of: parenthesesPattern, with: "", options: [.regularExpression])
        
        // Final cleanup
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let result = cleaned.isEmpty ? text : cleaned
        print("Final clean name: '\(result)'")
        return result
    }
    
    // DEBUGGING: Helper function to find existing template with debugging
    private func findExistingTemplate(cleanName: String) -> IngredientTemplate? {
        print("Looking for template with clean name: '\(cleanName)'")
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", cleanName)
        request.fetchLimit = 1
        
        do {
            let templates = try viewContext.fetch(request)
            if let found = templates.first {
                print("Found template: '\(found.name ?? "nil")' with category: '\(found.category ?? "nil")'")
                return found
            } else {
                print("No template found for: '\(cleanName)'")
                
                // DEBUG: Let's see what templates actually exist
                let allTemplatesRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                let allTemplates = try viewContext.fetch(allTemplatesRequest)
                print("Existing templates in database:")
                for template in allTemplates.prefix(10) { // Show first 10
                    print("   - '\(template.name ?? "nil")' -> '\(template.category ?? "nil")'")
                }
                
                return nil
            }
        } catch {
            print("Error finding existing template: \(error)")
            return nil
        }
    }
    
    // IMPROVED: Helper function to get category color
    private func categoryColor(for categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "produce": return .green
        case "deli & meat": return .red
        case "dairy & fridge": return .blue
        case "bread & frozen": return .orange
        case "boxed & canned": return .brown
        case "snacks, drinks, & other": return .purple
        default: return .gray
        }
    }
    
    // MARK: - FIXED Quantity Processing Methods
    
    // IMPROVED: Better quantity extraction that handles size descriptors like "large eggs"
    private func extractQuantityInfo(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Enhanced patterns to handle fractions, decimals, and ranges INCLUDING EGGS with size descriptors
        let quantityPatterns = [
            // Numbers with optional size descriptors + units: "2 large eggs", "4 eggs", "1/2 cup"
            #"^(\d+(?:/\d+)?(?:\.\d+)?\s+(?:large\s+|medium\s+|small\s+)?(?:cups?|tbsp?|tsp?|tablespoons?|teaspoons?|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|liters?|liter|milliliters?|ml|eggs?))"#,
            // Just fractions: "1/2", "3/4"
            #"^(\d+/\d+)"#,
            // Just numbers: "2", "1.5", "4"
            #"^(\d+(?:\.\d+)?)"#,
            // Ranges: "2-3", "1-2"
            #"^(\d+\s*-\s*\d+)"#
        ]
        
        for pattern in quantityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                var result = String(trimmed[Range(match.range, in: trimmed)!])
                
                // Remove size descriptors from the result for cleaner merging
                result = result.replacingOccurrences(of: #"\b(large|medium|small)\s+"#, with: "", options: [.regularExpression, .caseInsensitive])
                
                print("DEBUG extractQuantityInfo: Extracted '\(result)' from '\(text)'")
                return result
            }
        }
        
        print("DEBUG extractQuantityInfo: No quantity found in '\(text)'")
        return ""
    }
    
    // FIXED: Improved quantity merging with better debugging and egg support
    private func mergeQuantities(existing: String, new: String) -> String {
        print("DEBUG mergeQuantities: Starting merge - existing: '\(existing)', new: '\(new)'")
        
        if existing.isEmpty {
            print("DEBUG mergeQuantities: Existing empty, returning new: '\(new)'")
            return new
        } else if new.isEmpty {
            print("DEBUG mergeQuantities: New empty, returning existing: '\(existing)'")
            return existing
        }
        
        // Extract numeric and unit parts
        let existingParts = parseQuantityParts(from: existing)
        let newParts = parseQuantityParts(from: new)
        
        print("DEBUG mergeQuantities: Existing parts - number: '\(existingParts.number)', unit: '\(existingParts.unit ?? "nil")'")
        print("DEBUG mergeQuantities: New parts - number: '\(newParts.number)', unit: '\(newParts.unit ?? "nil")'")
        
        // Check if units are compatible (or both nil)
        let unitsCompatible: Bool
        if let existingUnit = existingParts.unit, let newUnit = newParts.unit {
            unitsCompatible = areUnitsCompatible(existingUnit, newUnit)
            print("DEBUG mergeQuantities: Units compatible check: '\(existingUnit)' vs '\(newUnit)' = \(unitsCompatible)")
        } else if existingParts.unit == nil && newParts.unit == nil {
            unitsCompatible = true
            print("DEBUG mergeQuantities: Both units nil, treating as compatible")
        } else {
            unitsCompatible = false
            print("DEBUG mergeQuantities: One unit nil, one not - incompatible")
        }
        
        if unitsCompatible {
            // Convert both to decimals and add
            let existingDecimal = convertToDecimal(existingParts.number)
            let newDecimal = convertToDecimal(newParts.number)
            
            print("DEBUG mergeQuantities: Converted to decimals - existing: \(existingDecimal?.description ?? "nil"), new: \(newDecimal?.description ?? "nil")")
            
            if let existingVal = existingDecimal, let newVal = newDecimal {
                let sum = existingVal + newVal
                let displayNumber = formatNumber(sum)
                
                // Determine the unit to use
                let finalUnit: String?
                if let existingUnit = existingParts.unit {
                    finalUnit = pluralizeUnit(normalizeUnit(existingUnit), quantity: sum)
                } else if let newUnit = newParts.unit {
                    finalUnit = pluralizeUnit(normalizeUnit(newUnit), quantity: sum)
                } else {
                    finalUnit = nil
                }
                
                let mergedResult: String
                if let unit = finalUnit {
                    mergedResult = "\(displayNumber) \(unit)"
                } else {
                    mergedResult = displayNumber
                }
                
                print("DEBUG mergeQuantities: Successfully merged to: '\(mergedResult)'")
                return mergedResult
            }
        }
        
        // If units aren't compatible or can't parse, combine them
        let fallbackResult = "\(existing) + \(new)"
        print("DEBUG mergeQuantities: Using fallback merge: '\(fallbackResult)'")
        return fallbackResult
    }
    
    // FIXED: Better parsing for simple quantities like "4 eggs"
    private func parseQuantityParts(from text: String) -> (number: String, unit: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("DEBUG parseQuantityParts: Parsing '\(trimmed)'")
        
        // Try multiple patterns in order of complexity
        
        // Pattern 1: Number + unit (e.g., "4 eggs", "2 cups", "1.5 tsp")
        let numberUnitPattern = #"^(\d+(?:/\d+)?(?:\.\d+)?)\s+(.+)$"#
        if let regex = try? NSRegularExpression(pattern: numberUnitPattern),
           let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
           match.numberOfRanges >= 3 {
            
            let numberRange = match.range(at: 1)
            let number = String(trimmed[Range(numberRange, in: trimmed)!])
            
            let unitRange = match.range(at: 2)
            let unitString = String(trimmed[Range(unitRange, in: trimmed)!]).trimmingCharacters(in: .whitespacesAndNewlines)
            let unit = unitString.isEmpty ? nil : unitString
            
            print("DEBUG parseQuantityParts: Parsed '\(trimmed)' -> number: '\(number)', unit: '\(unit ?? "nil")'")
            return (number: number, unit: unit)
        }
        
        // Pattern 2: Just a number (e.g., "4", "2", "1.5")
        let numberOnlyPattern = #"^(\d+(?:/\d+)?(?:\.\d+)?)$"#
        if let regex = try? NSRegularExpression(pattern: numberOnlyPattern),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            print("DEBUG parseQuantityParts: Parsed as number only: '\(trimmed)'")
            return (number: trimmed, unit: nil)
        }
        
        // Pattern 3: Fallback - treat whole thing as unparseable
        print("DEBUG parseQuantityParts: Failed to parse quantity: '\(trimmed)'")
        return (number: trimmed, unit: nil)
    }
    
    // ENHANCED: Better number conversion with debugging
    private func convertToDecimal(_ numberString: String) -> Double? {
        let trimmed = numberString.trimmingCharacters(in: .whitespacesAndNewlines)
        print("DEBUG convertToDecimal: Converting '\(trimmed)' to decimal")
        
        // Handle fractions
        if trimmed.contains("/") {
            let parts = trimmed.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]),
               denominator != 0 {
                let result = numerator / denominator
                print("DEBUG convertToDecimal: Fraction '\(trimmed)' converted to \(result)")
                return result
            }
        }
        
        // Handle regular decimals
        if let result = Double(trimmed) {
            print("DEBUG convertToDecimal: Number '\(trimmed)' converted to \(result)")
            return result
        }
        
        print("DEBUG convertToDecimal: Failed to convert '\(trimmed)' to decimal")
        return nil
    }
    
    // ENHANCED: Better number formatting
    private func formatNumber(_ value: Double) -> String {
        print("DEBUG formatNumber: Formatting number \(value)")
        
        // If it's a whole number, display as integer
        if value == floor(value) {
            let result = String(Int(value))
            print("DEBUG formatNumber: Formatted as integer: '\(result)'")
            return result
        }
        
        // Check if it's a common fraction
        let commonFractions: [(Double, String)] = [
            (0.25, "1/4"),
            (0.33, "1/3"),
            (0.5, "1/2"),
            (0.67, "2/3"),
            (0.75, "3/4")
        ]
        
        for (decimal, fraction) in commonFractions {
            if abs(value - decimal) < 0.01 {
                print("DEBUG formatNumber: Formatted as fraction: '\(fraction)'")
                return fraction
            }
        }
        
        // For mixed numbers (like 1.5), check if the decimal part is a common fraction
        let wholeNumber = floor(value)
        let decimalPart = value - wholeNumber
        
        if wholeNumber > 0 {
            for (decimal, fraction) in commonFractions {
                if abs(decimalPart - decimal) < 0.01 {
                    let result = "\(Int(wholeNumber)) \(fraction)"
                    print("DEBUG formatNumber: Formatted as mixed number: '\(result)'")
                    return result
                }
            }
        }
        
        // Default to one decimal place, removing trailing zeros
        let formatted = String(format: "%.1f", value)
        let result = formatted.hasSuffix(".0") ? String(Int(value)) : formatted
        print("DEBUG formatNumber: Formatted as decimal: '\(result)'")
        return result
    }
    
    // FIXED: Improved unit compatibility checking with debugging
    private func areUnitsCompatible(_ unit1: String, _ unit2: String) -> Bool {
        let normalized1 = normalizeUnit(unit1)
        let normalized2 = normalizeUnit(unit2)
        let compatible = normalized1 == normalized2
        print("DEBUG areUnitsCompatible: '\(unit1)' -> '\(normalized1)', '\(unit2)' -> '\(normalized2)', compatible: \(compatible)")
        return compatible
    }
    
    // FIXED: Better unit normalization including eggs and large eggs
    private func normalizeUnit(_ unit: String) -> String {
        let lowercased = unit.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Normalize plural forms to singular for comparison
        switch lowercased {
        case "cup", "cups": return "cup"
        case "tsp", "teaspoon", "teaspoons": return "tsp"
        case "tbsp", "tablespoon", "tablespoons": return "tbsp"
        case "pound", "pounds", "lb", "lbs": return "lb"
        case "ounce", "ounces", "oz": return "oz"
        case "gram", "grams", "g": return "g"
        case "kilogram", "kilograms", "kg": return "kg"
        case "liter", "liters", "l": return "l"
        case "milliliter", "milliliters", "ml": return "ml"
        case "egg", "eggs": return "egg"
        case "large egg", "large eggs": return "egg"
        case "medium egg", "medium eggs": return "egg"
        case "small egg", "small eggs": return "egg"
        default: return lowercased
        }
    }
    
    // FIXED: Better pluralization including eggs
    private func pluralizeUnit(_ normalizedUnit: String, quantity: Double) -> String {
        if quantity == 1.0 {
            return normalizedUnit
        }
        
        // Pluralize for quantities > 1
        switch normalizedUnit {
        case "cup": return "cups"
        case "tsp": return "tsp" // Already abbreviated
        case "tbsp": return "tbsp" // Already abbreviated
        case "lb": return "lbs"
        case "oz": return "oz" // Already abbreviated
        case "g": return "g" // Already abbreviated
        case "kg": return "kg" // Already abbreviated
        case "l": return "l" // Already abbreviated
        case "ml": return "ml" // Already abbreviated
        case "egg": return "eggs"
        default: return normalizedUnit // For unknown units, don't change
        }
    }
    
    private func buildCompleteQuantity(from ingredient: Ingredient) -> String {
        var parts: [String] = []
        
        if let quantity = ingredient.quantity?.trimmingCharacters(in: .whitespacesAndNewlines), !quantity.isEmpty {
            parts.append(quantity)
        }
        
        if let unit = ingredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines), !unit.isEmpty {
            parts.append(unit)
        }
        
        return parts.joined(separator: " ")
    }
    
    // MARK: - Category Helper
    private func categoryHeaderSimple(categoryName: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(categoryColor(for: categoryName))
                .frame(width: 12, height: 12)
                .overlay(
                    Text(categoryEmoji(for: categoryName))
                        .font(.system(size: 8))
                )
            
            Text(categoryName.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }

    private func categoryEmoji(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "produce": return "🥬"
        case "deli & meat": return "🥩"
        case "dairy & fridge": return "🥛"
        case "bread & frozen": return "🍞"
        case "boxed & canned": return "📦"
        case "snacks, drinks, & other": return "🥤"
        default: return "📦"
        }
    }
    
    // MARK: - UI Components
    private var processingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(processingMessage)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var ingredientSelectionView: some View {
        VStack {
            headerSection
            
            List {
                if groupedIngredients.isEmpty {
                    Text("No ingredients found in this recipe")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(sortedCategoryNames, id: \.self) { categoryName in
                        let categoryIngredients = groupedIngredients[categoryName] ?? []
                        
                        if !categoryIngredients.isEmpty {
                            Section(header: categoryHeaderSimple(categoryName: categoryName, count: categoryIngredients.count)) {
                                ForEach(categoryIngredients, id: \.objectID) { ingredient in
                                    ingredientRow(ingredient)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            selectionSummary
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recipe: \(recipe.title ?? "Unknown Recipe")")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let ingredientsSet = recipe.ingredients {
                Text("\(ingredientsSet.count) ingredients available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    // IMPROVED: Better ingredient status display in AddIngredientsToListView
    private func ingredientRow(_ ingredient: Ingredient) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                toggleIngredientSelection(ingredient)
            }) {
                Image(systemName: isSelected(ingredient) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected(ingredient) ? .green : .gray)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name ?? "Unknown ingredient")
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack {
                    if let quantity = ingredient.quantity, !quantity.isEmpty {
                        Text("Qty: \(quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let unit = ingredient.unit, !unit.isEmpty {
                        Text("Unit: \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // IMPROVED: Show actual category status
                    ingredientStatusView(for: ingredient)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleIngredientSelection(ingredient)
        }
    }
    
    // FIXED: Status view logic - show category if exists, "Needs Category" if template exists but no category
    @ViewBuilder
    private func ingredientStatusView(for ingredient: Ingredient) -> some View {
        // Check if ingredient already has a linked template
        if let existingTemplate = ingredient.ingredientTemplate {
            // Template exists - check if it has a category
            if let category = existingTemplate.category,
               !category.isEmpty,
               category.lowercased() != "uncategorized" {
                // Has category - show it with color dot
                HStack(spacing: 4) {
                    Circle()
                        .fill(categoryColor(for: category))
                        .frame(width: 8, height: 8)
                    Text(category)
                        .font(.caption2)
                        .foregroundColor(categoryColor(for: category))
                }
            } else {
                // Template exists but needs category - orange warning
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("Needs Category")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        } else {
            // No template exists yet - check if one exists in database
            let cleanName = extractCleanIngredientName(from: ingredient.name ?? "")
            let existingTemplate = findExistingTemplate(cleanName: cleanName)
            
            if let template = existingTemplate {
                // Template exists in database but not linked - check category
                if let category = template.category,
                   !category.isEmpty,
                   category.lowercased() != "uncategorized" {
                    // Has category
                    HStack(spacing: 4) {
                        Circle()
                            .fill(categoryColor(for: category))
                            .frame(width: 8, height: 8)
                        Text(category)
                            .font(.caption2)
                            .foregroundColor(categoryColor(for: category))
                    }
                } else {
                    // Template exists but needs category
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("Needs Category")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            } else {
                // No template exists - will create new
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("New Template")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var selectionSummary: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(selectedIngredients.count) ingredients selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if selectedIngredients.count > 0 {
                    Button("Select All") {
                        preselectAllIngredients()
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private func isSelected(_ ingredient: Ingredient) -> Bool {
        guard let id = ingredient.id else { return false }
        return selectedIngredients.contains(id)
    }
    
    private func toggleIngredientSelection(_ ingredient: Ingredient) {
        guard let id = ingredient.id else { return }
        
        if selectedIngredients.contains(id) {
            selectedIngredients.remove(id)
        } else {
            selectedIngredients.insert(id)
        }
    }
    
    private func preselectAllIngredients() {
        guard let ingredientsSet = recipe.ingredients else { return }
        
        let ingredients = Array(ingredientsSet) as! [Ingredient]
        selectedIngredients = Set(ingredients.compactMap { $0.id })
    }
}
