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
    
    // FIXED: Updated ingredient parsing with clean names for templates
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
        
        // Use viewContext directly instead of PersistenceController.performWrite
        for ingredient in selectedIngredientsList {
            guard let fullName = ingredient.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !fullName.isEmpty else { continue }
            
            // FIXED: Extract clean ingredient name without measurements for template matching
            let cleanName = extractCleanIngredientName(from: fullName)
            
            // Find or create template using the CLEAN name
            let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[cd] %@", cleanName)
            
            do {
                let template: IngredientTemplate
                if let existing = try viewContext.fetch(request).first {
                    template = existing
                } else {
                    template = IngredientTemplate(context: viewContext)
                    template.id = UUID()
                    template.name = cleanName  // Store CLEAN name, not full recipe text
                    template.usageCount = 0
                    template.dateCreated = Date()
                    template.category = nil  // Will be handled by category assignment flow
                }
                
                // Update usage count and link to ingredient
                template.usageCount += 1
                ingredient.ingredientTemplate = template
                
            } catch {
                print("Error creating template: \(error)")
            }
        }
        
        // Save context
        do {
            try viewContext.save()
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
                print("🔍 Template '\(template.name ?? "nil")' has category: '\(template.category ?? "nil")'")
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
            
            // Check for existing items by clean name
            if let existingItem = findExistingItem(named: cleanName, in: existingItems) {
                // FIXED: Merge quantities if both have quantities
                let existingName = existingItem.name ?? ""
                let newQuantityInfo = extractQuantityInfo(from: fullIngredientText)
                let existingQuantityInfo = extractQuantityInfo(from: existingName)
                
                if !newQuantityInfo.isEmpty && !existingQuantityInfo.isEmpty {
                    // Try to merge quantities
                    let mergedQuantity = mergeQuantities(existing: existingQuantityInfo, new: newQuantityInfo)
                    existingItem.name = "\(mergedQuantity) \(cleanName)"
                } else if !newQuantityInfo.isEmpty && existingQuantityInfo.isEmpty {
                    // Add quantity to existing item
                    existingItem.name = fullIngredientText
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
    
    // DEBUGGING: Enhanced ingredient name extraction with debugging
    private func extractCleanIngredientName(from fullText: String) -> String {
        let text = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🧹 Extracting clean name from: '\(text)'") // Debug
        
        // Remove common quantity patterns at the beginning
        let patterns = [
            #"^\d+(\.\d+)?\s*(cups?|tbsp?|tsp?|tablespoons?|teaspoons?|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|liters?|l|milliliters?|ml)\s+"#,
            #"^\d+(\.\d+)?\s*"#,  // Remove bare numbers
            #"^(a|an|the)\s+"#,    // Remove articles
            #"^\d+(/\d+)?\s+"#,    // Remove fractions like "1/2"
            #"^\d+\s*-\s*\d+\s+"# // Remove ranges like "2-3"
        ]
        
        var cleaned = text
        for pattern in patterns {
            let before = cleaned
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            if before != cleaned {
                print("   Applied pattern, result: '\(cleaned)'") // Debug
            }
        }
        
        // Remove common descriptors from the end
        let endPatterns = [
            #",\s*(chopped|diced|sliced|minced|grated|melted|softened|at room temperature|optional).*$"#,
            #",\s*.*$"#  // Remove everything after first comma
        ]
        
        for pattern in endPatterns {
            let before = cleaned
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            if before != cleaned {
                print("   Applied end pattern, result: '\(cleaned)'") // Debug
            }
        }
        
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If cleaning resulted in empty string, return original
        let result = cleaned.isEmpty ? text : cleaned
        print("🎯 Final clean name: '\(result)'") // Debug
        return result
    }
    
    // DEBUGGING: Helper function to find existing template with debugging
    private func findExistingTemplate(cleanName: String) -> IngredientTemplate? {
        print("🔍 Looking for template with clean name: '\(cleanName)'") // Debug
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", cleanName)
        request.fetchLimit = 1
        
        do {
            let templates = try viewContext.fetch(request)
            if let found = templates.first {
                print("✅ Found template: '\(found.name ?? "nil")' with category: '\(found.category ?? "nil")'") // Debug
                return found
            } else {
                print("❌ No template found for: '\(cleanName)'") // Debug
                
                // DEBUG: Let's see what templates actually exist
                let allTemplatesRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                let allTemplates = try viewContext.fetch(allTemplatesRequest)
                print("📋 Existing templates in database:")
                for template in allTemplates.prefix(10) { // Show first 10
                    print("   - '\(template.name ?? "nil")' -> '\(template.category ?? "nil")'")
                }
                
                return nil
            }
        } catch {
            print("❌ Error finding existing template: \(error)")
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
    
    // FIXED: New helper method to extract quantity info
    private func extractQuantityInfo(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract quantity patterns at the beginning
        let quantityPatterns = [
            #"^(\d+(\.\d+)?\s*(cups?|tbsp?|tsp?|tablespoons?|teaspoons?|pounds?|lbs?|ounces?|oz|grams?|g|kilograms?|kg|liters?|l|milliliters?|ml))"#,
            #"^(\d+(\.\d+)?)"#,  // Bare numbers
            #"^(\d+/\d+)"#,      // Fractions like "1/2"
            #"^(\d+\s*-\s*\d+)"# // Ranges like "2-3"
        ]
        
        for pattern in quantityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) {
                return String(trimmed[Range(match.range, in: trimmed)!])
            }
        }
        
        return ""
    }
    
    // FIXED: Enhanced quantity merging logic
    private func mergeQuantities(existing: String, new: String) -> String {
        if existing.isEmpty {
            return new
        } else if new.isEmpty {
            return existing
        }
        
        // Simple unit compatibility check
        let existingLower = existing.lowercased()
        let newLower = new.lowercased()
        
        // Check for compatible units (cups with cups, tsp with tsp, etc.)
        let cupUnits = ["cup", "cups"]
        let tspUnits = ["tsp", "teaspoon", "teaspoons"]
        let tbspUnits = ["tbsp", "tablespoon", "tablespoons"]
        
        let existingHasCups = cupUnits.contains { existingLower.contains($0) }
        let newHasCups = cupUnits.contains { newLower.contains($0) }
        
        let existingHasTsp = tspUnits.contains { existingLower.contains($0) }
        let newHasTsp = tspUnits.contains { newLower.contains($0) }
        
        let existingHasTbsp = tbspUnits.contains { existingLower.contains($0) }
        let newHasTbsp = tbspUnits.contains { newLower.contains($0) }
        
        // If units are compatible, try simple addition
        if (existingHasCups && newHasCups) || (existingHasTsp && newHasTsp) || (existingHasTbsp && newHasTbsp) {
            // Extract numeric values and add them
            let existingNum = extractNumericValue(from: existing)
            let newNum = extractNumericValue(from: new)
            
            if let existingVal = existingNum, let newVal = newNum {
                let sum = existingVal + newVal
                let unit = extractUnit(from: existing) ?? extractUnit(from: new) ?? ""
                return "\(sum) \(unit)"
            }
        }
        
        // If not compatible or can't parse, combine them
        return "\(existing), \(new)"
    }
    
    // FIXED: Helper methods for numeric extraction
    private func extractNumericValue(from text: String) -> Double? {
        let pattern = #"^(\d+(?:\.\d+)?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        
        let numString = String(text[Range(match.range, in: text)!])
        return Double(numString)
    }
    
    private func extractUnit(from text: String) -> String? {
        let pattern = #"^\d+(?:\.\d+)?\s*(.+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              match.numberOfRanges > 1 else {
            return nil
        }
        
        let unitRange = match.range(at: 1)
        return String(text[Range(unitRange, in: text)!]).trimmingCharacters(in: .whitespacesAndNewlines)
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
                if let ingredientsSet = recipe.ingredients, ingredientsSet.count > 0 {
                    let ingredientsList = Array(ingredientsSet) as! [Ingredient]
                    
                    ForEach(ingredientsList, id: \.objectID) { ingredient in
                        ingredientRow(ingredient)
                    }
                } else {
                    Text("No ingredients found in this recipe")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            
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
    
    // UPDATED: Status view logic - show category if exists, "Needs Category" if template exists but no category
    @ViewBuilder
    private func ingredientStatusView(for ingredient: Ingredient) -> some View {
        // Check if template already exists
        let cleanName = extractCleanIngredientName(from: ingredient.name ?? "")
        let existingTemplate = findExistingTemplate(cleanName: cleanName)
        
        if let template = existingTemplate {
            // Template exists - check if it has a category
            if let category = template.category, !category.isEmpty {
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
            // No template exists - will create new (this should be rare if salt exists)
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
