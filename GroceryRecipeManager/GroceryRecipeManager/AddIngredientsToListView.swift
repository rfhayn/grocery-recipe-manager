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
    
    // FIXED: Use direct Core Data operations instead of PersistenceController.performWrite
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
            guard let name = ingredient.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { continue }
            
            // Find or create template
            let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[cd] %@", name)
            
            do {
                let template: IngredientTemplate
                if let existing = try viewContext.fetch(request).first {
                    template = existing
                } else {
                    template = IngredientTemplate(context: viewContext)
                    template.id = UUID()
                    template.name = name
                    template.usageCount = 0
                    template.dateCreated = Date()
                    // FIXED: New templates start as "Uncategorized" instead of nil
                    template.category = "Uncategorized"
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
    
    // FIXED: Check for "Uncategorized" templates that need assignment
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
        
        // FIXED: Find templates that need category assignment (nil, empty, or "Uncategorized")
        var uncategorized: [IngredientTemplate] = []
        
        for ingredient in selectedIngredientsList {
            if let template = ingredient.ingredientTemplate {
                // Check if category is nil, empty, or "Uncategorized"
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
            let cleanName: String
            let completeQuantity: String
            
            if let ingredientTemplate = ingredient.ingredientTemplate {
                cleanName = ingredientTemplate.name ?? "Unknown"
            } else {
                cleanName = extractCleanIngredientName(from: ingredient.name ?? "Unknown")
            }
            completeQuantity = buildCompleteQuantity(from: ingredient)
            
            if let existingItem = findExistingItem(named: cleanName, in: existingItems) {
                let mergedQuantity = mergeQuantities(
                    existing: existingItem.quantity ?? "",
                    new: completeQuantity
                )
                existingItem.quantity = mergedQuantity
                mergeCount += 1
                print("Merged quantities for '\(cleanName)': \(mergedQuantity)")
            } else {
                let listItem = GroceryListItem(context: viewContext)
                listItem.id = UUID()
                listItem.name = cleanName
                listItem.quantity = completeQuantity
                listItem.isCompleted = false
                listItem.source = "Recipe: \(recipe.title ?? "Unknown Recipe")"
                
                // FIXED: Use proper category assignment logic
                if let template = ingredient.ingredientTemplate,
                   let categoryString = template.category,
                   !categoryString.isEmpty,
                   categoryString.lowercased() != "uncategorized" {
                    listItem.categoryName = categoryString
                    print("Assigned category '\(categoryString)' to '\(cleanName)'")
                } else {
                    listItem.categoryName = "UNCATEGORIZED"
                    print("Assigned UNCATEGORIZED to '\(cleanName)'")
                }
                
                weeklyList.addToItems(listItem)
                print("Created new item: \(cleanName) (\(completeQuantity))")
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
            return itemName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ==
                   targetName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private func extractCleanIngredientName(from fullText: String) -> String {
        let cleaned = fullText
            .replacingOccurrences(of: #"\d+(\.\d+)?\s*(cup|cups|tablespoon|tablespoons|teaspoon|teaspoons|pound|pounds|ounce|ounces|gram|grams|kilogram|kilograms|liter|liters|milliliter|milliliters|tsp|tbsp|lb|oz|g|kg|l|ml)\s*"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned.isEmpty ? fullText : cleaned
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
    
    private func mergeQuantities(existing: String, new: String) -> String {
        if existing.isEmpty {
            return new
        } else if new.isEmpty {
            return existing
        } else {
            return "\(existing), \(new)"
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
                    
                    // FIXED: Show proper categorization status
                    if let template = ingredient.ingredientTemplate {
                        HStack(spacing: 4) {
                            if let category = template.category,
                               !category.isEmpty,
                               category.lowercased() != "uncategorized" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                Text("Categorized")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                Text("Needs Category")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    } else {
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
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleIngredientSelection(ingredient)
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
