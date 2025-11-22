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
            // M3: Use displayText from ingredient (already populated by parsing service)
            let fullIngredientText = ingredient.displayText ?? ingredient.name ?? "Unknown ingredient"
            
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
                // M3: Simple quantity merging using displayText for now
                // Phase 5 will enhance this with numeric operations
                let existingDisplayText = existingItem.displayText ?? ""
                let newDisplayText = fullIngredientText
                
                // M4.3.1: Only merge non-empty displayText to avoid empty strings
                if !newDisplayText.isEmpty && newDisplayText != "1" && !existingDisplayText.isEmpty {
                    existingItem.displayText = "\(existingDisplayText) + \(newDisplayText)"
                } else if !newDisplayText.isEmpty && newDisplayText != "1" {
                    existingItem.displayText = newDisplayText
                }
                
                // M4.3.1: Add recipe to sourceRecipes relationship
                existingItem.addToSourceRecipes(recipe)
                
                // TEMPORARY DEBUG
                print("🔍 DEBUG: Added recipe '\(recipe.title ?? "nil")' to item '\(cleanName)'")
                if let recipes = existingItem.sourceRecipes as? Set<Recipe> {
                    print("🔍 DEBUG: Item now has \(recipes.count) source recipes:")
                    for r in recipes {
                        print("   - \(r.title ?? "nil")")
                    }
                } else {
                    print("🔍 DEBUG: sourceRecipes is nil or not a Set!")
                }
                
                mergeCount += 1
                print("Merged quantities for '\(cleanName)' and added recipe source")
            } else {
                // Create new item
                let listItem = GroceryListItem(context: viewContext)
                listItem.id = UUID()
                listItem.name = cleanName
                
                // M3: Copy structured quantity fields from ingredient
                listItem.displayText = fullIngredientText
                listItem.numericValue = ingredient.numericValue
                listItem.standardUnit = ingredient.standardUnit
                listItem.isParseable = ingredient.isParseable
                listItem.parseConfidence = ingredient.parseConfidence
                
                listItem.isCompleted = false
                listItem.source = "Recipe: \(recipe.title ?? "Unknown Recipe")"
                
                // M4.3.1: Add recipe to sourceRecipes relationship
                listItem.addToSourceRecipes(recipe)
                
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
        
        return cleaned.isEmpty ? text : cleaned
    }
    
    // DEBUGGING: Helper function to find existing template with debugging
    private func findExistingTemplate(cleanName: String) -> IngredientTemplate? {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", cleanName)
        request.fetchLimit = 1
        
        do {
            let templates = try viewContext.fetch(request)
            return templates.first
        } catch {
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
                    // M3: Show displayText instead of quantity/unit
                    if let displayText = ingredient.displayText, !displayText.isEmpty {
                        Text(displayText)
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
