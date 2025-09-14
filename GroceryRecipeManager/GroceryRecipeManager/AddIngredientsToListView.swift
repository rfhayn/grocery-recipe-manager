//
//  AddIngredientsToListView.swift
//  GroceryRecipeManager
//
//  Enhanced with Smart List Selection Logic
//  Step 3a Implementation - September 14, 2025
//

import SwiftUI
import CoreData

struct AddIngredientsToListView: View {
    let recipe: Recipe
    @Binding var selectedIngredients: Set<UUID>
    let templateService: IngredientTemplateService
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isProcessing = false
    @State private var processingMessage = "Adding to grocery list..."
    @State private var showingListSelectionAlert = false
    @State private var targetWeeklyList: WeeklyList?
    
    var body: some View {
        NavigationView {
            VStack {
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
                        initiateAddToList()
                    }
                    .disabled(selectedIngredients.isEmpty || isProcessing)
                }
            }
        }
        .alert("Create New Grocery List", isPresented: $showingListSelectionAlert) {
            Button("Create New List") {
                createNewListAndAddIngredients()
            }
            Button("Cancel", role: .cancel) {
                // User cancelled, reset processing state
                isProcessing = false
            }
        } message: {
            Text("No incomplete grocery lists found. Create a new list for Week of \(formattedCurrentDate)?")
        }
        .onAppear {
            // Pre-select all ingredients by default
            preselectAllIngredients()
        }
    }
    
    // MARK: - Smart List Selection Logic
    
    private func initiateAddToList() {
        isProcessing = true
        processingMessage = "Finding grocery list..."
        
        // Step 1: Try to find an existing uncompleted list
        if let existingList = findNewestUncompletedList() {
            targetWeeklyList = existingList
            addSelectedToGroceryList()
        } else {
            // Step 2: No uncompleted lists found, prompt user for new list creation
            showingListSelectionAlert = true
        }
    }
    
    private func findNewestUncompletedList() -> WeeklyList? {
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
            print("❌ Error fetching uncompleted lists: \(error)")
            return nil
        }
    }
    
    private func createNewListAndAddIngredients() {
        // Create new list and save it immediately
        let newList = createNewWeeklyList()
        
        // Save the new list first to ensure it exists in the database
        do {
            try viewContext.save()
            targetWeeklyList = newList
            print("✅ Successfully created new list: \(newList.name ?? "Unnamed")")
            addSelectedToGroceryList()
        } catch {
            print("❌ Error saving new weekly list: \(error)")
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
        
        print("✅ Created new weekly list: \(newList.name ?? "Unnamed")")
        return newList
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    // MARK: - UI Components (Existing)
    
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
            // Header with recipe info
            headerSection
            
            // Ingredients list
            List {
                if let ingredientsSet = recipe.ingredients, ingredientsSet.count > 0 {
                    let ingredientsList = Array(ingredientsSet) as! [Ingredient]
                    ForEach(ingredientsList, id: \.id) { ingredient in
                        ingredientRowView(ingredient)
                    }
                } else {
                    Text("No ingredients found")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.title ?? "Unknown Recipe")
                .font(.headline)
                .lineLimit(2)
            
            Text("Select ingredients to add to your grocery list")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if selectedIngredients.count > 0 {
                Text("\(selectedIngredients.count) ingredient\(selectedIngredients.count == 1 ? "" : "s") selected")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
    }
    
    private func ingredientRowView(_ ingredient: Ingredient) -> some View {
        HStack(spacing: 12) {
            // Selection indicator
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
                    // Quantity info
                    if let quantity = ingredient.quantity, !quantity.isEmpty {
                        Text("Qty: \(quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Unit info
                    if let unit = ingredient.unit, !unit.isEmpty {
                        Text("Unit: \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Template status
                    if ingredient.ingredientTemplate != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("Templated")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("New")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleIngredientSelection(ingredient)
        }
    }
    
    // MARK: - Helper Methods (Existing)
    
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
    
    // MARK: - Enhanced Grocery List Creation
    
    private func addSelectedToGroceryList() {
        guard let targetList = targetWeeklyList else {
            isProcessing = false
            return
        }
        
        processingMessage = "Creating grocery list items..."
        
        // Simulate processing delay for user feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            createGroceryListItems(in: targetList)
        }
    }
    
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
        
        // Fetch existing items in the target list for quantity merging
        let existingItems = fetchExistingItems(in: weeklyList)
        var mergeCount = 0
        
        // Create grocery list items from selected ingredients with quantity merging
        for ingredient in selectedIngredientsToAdd {
            let cleanName: String
            let completeQuantity: String
            
            // Extract clean ingredient name and combine quantity + unit
            if let ingredientTemplate = ingredient.ingredientTemplate {
                cleanName = ingredientTemplate.name ?? "Unknown"
            } else {
                cleanName = extractCleanIngredientName(from: ingredient.name ?? "Unknown")
            }
            completeQuantity = buildCompleteQuantity(from: ingredient)
            
            // Check for existing item with same name (case-insensitive)
            if let existingItem = findExistingItem(named: cleanName, in: existingItems) {
                // Merge quantities
                let mergedQuantity = mergeQuantities(
                    existing: existingItem.quantity ?? "",
                    new: completeQuantity
                )
                existingItem.quantity = mergedQuantity
                mergeCount += 1
                print("🔄 Merged quantities for '\(cleanName)': \(mergedQuantity)")
            } else {
                // Create new item
                let listItem = GroceryListItem(context: viewContext)
                listItem.id = UUID()
                listItem.name = cleanName
                listItem.quantity = completeQuantity
                listItem.isCompleted = false
                listItem.source = "Recipe: \(recipe.title ?? "Unknown")"
                listItem.sourceType = "recipe"
                listItem.sourceRecipeID = recipe.id
                listItem.weeklyList = weeklyList
                print("➕ Added new item '\(cleanName)': \(completeQuantity)")
            }
            
            // Increment template usage if connected
            if let template = ingredient.ingredientTemplate {
                templateService.incrementUsage(template: template)
            }
        }
        
        // Save changes
        do {
            try viewContext.save()
            
            let newItemsCount = selectedIngredientsToAdd.count - mergeCount
            var message = "Successfully processed \(selectedIngredientsToAdd.count) items!"
            if mergeCount > 0 {
                message += "\n\(mergeCount) quantities merged, \(newItemsCount) new items added."
            }
            processingMessage = message
            
            // Brief success message before dismissing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("❌ Error saving grocery list items: \(error)")
            processingMessage = "Error adding items to list"
            isProcessing = false
        }
    }
    
    // MARK: - Quantity Merging Logic
    
    private func fetchExistingItems(in weeklyList: WeeklyList) -> [GroceryListItem] {
        guard let items = weeklyList.items as? Set<GroceryListItem> else { return [] }
        return Array(items)
    }
    
    private func findExistingItem(named itemName: String, in items: [GroceryListItem]) -> GroceryListItem? {
        return items.first { existingItem in
            guard let existingName = existingItem.name else { return false }
            return existingName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                   itemName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func mergeQuantities(existing: String, new: String) -> String {
        // Clean input strings
        let existingClean = existing.trimmingCharacters(in: .whitespacesAndNewlines)
        let newClean = new.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If either is empty, return the non-empty one
        if existingClean.isEmpty { return newClean }
        if newClean.isEmpty { return existingClean }
        
        // Parse quantities and units
        let existingParsed = parseQuantityAndUnit(existingClean)
        let newParsed = parseQuantityAndUnit(newClean)
        
        // Try to merge if units are compatible
        if let mergedQuantity = attemptQuantityMerge(existingParsed, newParsed) {
            return mergedQuantity
        }
        
        // If units are incompatible, combine both quantities
        return "\(existingClean) + \(newClean)"
    }
    
    private func parseQuantityAndUnit(_ quantityString: String) -> (number: Double?, unit: String) {
        // Remove parentheses if present
        let cleaned = quantityString.replacingOccurrences(of: "[()]", with: "", options: .regularExpression)
        
        // Pattern to match number (including fractions) and unit
        let pattern = #"^(\d+(?:[./]\d+)?)\s*(.*)$"#
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)) {
            
            let numberRange = Range(match.range(at: 1), in: cleaned)!
            let unitRange = Range(match.range(at: 2), in: cleaned)!
            
            let numberString = String(cleaned[numberRange])
            let unit = String(cleaned[unitRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Convert fractions to decimals
            let number = convertToDecimal(numberString)
            
            return (number: number, unit: unit)
        }
        
        return (number: nil, unit: quantityString)
    }
    
    private func convertToDecimal(_ numberString: String) -> Double? {
        // Handle fractions like "1/2", "3/4"
        if numberString.contains("/") {
            let parts = numberString.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]),
               denominator != 0 {
                return numerator / denominator
            }
        }
        
        // Handle regular decimals
        return Double(numberString)
    }
    
    private func attemptQuantityMerge(_ existing: (number: Double?, unit: String), _ new: (number: Double?, unit: String)) -> String? {
        // Both must have numbers to merge
        guard let existingNum = existing.number, let newNum = new.number else { return nil }
        
        // Units must be the same (case-insensitive) or compatible
        let existingUnit = existing.unit.lowercased()
        let newUnit = new.unit.lowercased()
        
        if existingUnit == newUnit || areUnitsCompatible(existingUnit, newUnit) {
            let sum = existingNum + newNum
            let unit = existing.unit.isEmpty ? new.unit : existing.unit
            
            // Format the result nicely
            if sum == floor(sum) {
                return "\(Int(sum)) \(unit)"
            } else {
                return String(format: "%.1f \(unit)", sum)
            }
        }
        
        return nil // Units incompatible
    }
    
    private func areUnitsCompatible(_ unit1: String, _ unit2: String) -> Bool {
        let compatibleUnits: [[String]] = [
            ["cup", "cups"],
            ["tsp", "teaspoon", "teaspoons"],
            ["tbsp", "tablespoon", "tablespoons"],
            ["oz", "ounce", "ounces"],
            ["lb", "pound", "pounds"],
            ["large", "medium", "small"] // For eggs, etc.
        ]
        
        for group in compatibleUnits {
            if group.contains(unit1) && group.contains(unit2) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Helper Methods for Name/Quantity Processing
    
    private func buildCompleteQuantity(from ingredient: Ingredient) -> String {
        // First, try to build from separate quantity and unit fields
        let quantity = ingredient.quantity?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let unit = ingredient.unit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !quantity.isEmpty && !unit.isEmpty {
            return "\(quantity) \(unit)"
        } else if !quantity.isEmpty {
            return quantity
        } else if !unit.isEmpty {
            return unit
        }
        
        // Fallback: try to extract from the original ingredient name
        if let originalName = ingredient.name {
            let extractedQuantity = extractQuantityFromName(originalName)
            if !extractedQuantity.isEmpty {
                return extractedQuantity
            }
        }
        
        return ""
    }
    
    // MARK: - Helper Methods for Name/Quantity Separation
    
    private func extractCleanIngredientName(from fullName: String) -> String {
        // Remove common quantity patterns from ingredient names
        let quantityPatterns = [
            #"\d+\s*(cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|oz|ounce|ounces|lb|pound|pounds|large|medium|small|bunch|bunches|clove|cloves)s?\b"#,
            #"\d+/\d+\s*(cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|oz|ounce|ounces|lb|pound|pounds)s?\b"#,
            #"^\d+\s+"#, // Remove leading numbers
            #"^\d+/\d+\s+"#, // Remove leading fractions
        ]
        
        var cleanName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for pattern in quantityPatterns {
            cleanName = cleanName.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            ).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Remove leading/trailing commas and extra whitespace
        cleanName = cleanName.replacingOccurrences(of: "^[,\\s]+|[,\\s]+$", with: "", options: .regularExpression)
        
        return cleanName.isEmpty ? fullName : cleanName
    }
    
    private func extractQuantityFromName(_ fullName: String) -> String {
        // Extract complete quantity portion (number + unit) from ingredient names
        let quantityPatterns = [
            // Match full quantity with units: "1/2 cup", "2 tbsp", "1 tsp", "2 large", etc.
            #"^\d+(?:/\d+)?\s*(?:cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|oz|ounce|ounces|lb|pound|pounds|large|medium|small|bunch|bunches|clove|cloves)s?\b"#,
            // Match fractions with units: "1/4 cup", "3/4 tsp"
            #"^\d+/\d+\s*(?:cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|oz|ounce|ounces|lb|pound|pounds)s?\b"#,
            // Match numbers with common descriptors: "2 large", "1 medium", "3 small"
            #"^\d+\s*(?:large|medium|small|extra\s*large|x-large)\b"#,
            // Match standalone numbers at beginning (fallback)
            #"^\d+(?:/\d+)?\s*"#
        ]
        
        for pattern in quantityPatterns {
            if let range = fullName.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let quantity = String(fullName[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                // Don't return empty or just whitespace
                if !quantity.isEmpty && quantity != fullName {
                    return quantity
                }
            }
        }
        
        return ""
    }
}
