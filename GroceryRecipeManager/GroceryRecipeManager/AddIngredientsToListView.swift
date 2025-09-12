//
//  AddIngredientsToListView.swift
//  GroceryRecipeManager
//
//  Created on September 12, 2025
//  MILESTONE 2 - Phase 2: Recipe Core Development
//  Step 3: Add to Grocery List Functionality
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
                        addSelectedToGroceryList()
                    }
                    .disabled(selectedIngredients.isEmpty || isProcessing)
                }
            }
        }
        .onAppear {
            // Pre-select all ingredients by default
            preselectAllIngredients()
        }
    }
    
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
                    let sortedIngredients = ingredientsList.sorted { $0.sortOrder < $1.sortOrder }
                    
                    ForEach(sortedIngredients, id: \.self) { ingredient in
                        ingredientSelectionRow(ingredient)
                    }
                } else {
                    Text("No ingredients to add")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("From: \(recipe.title ?? "Unknown Recipe")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if recipe.servings > 0 {
                    Text("\(recipe.servings) servings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
            
            Text("Select ingredients to add to your grocery list")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func ingredientSelectionRow(_ ingredient: Ingredient) -> some View {
        HStack {
            // Selection checkbox
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
    
    private func addSelectedToGroceryList() {
        isProcessing = true
        processingMessage = "Creating grocery list items..."
        
        // Simulate processing delay for user feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            createGroceryListItems()
        }
    }
    
    private func createGroceryListItems() {
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
        
        // Find or create current weekly list
        let weeklyList = findOrCreateCurrentWeeklyList()
        
        // Create grocery list items from selected ingredients
        for ingredient in selectedIngredientsToAdd {
            let listItem = GroceryListItem(context: viewContext)
            listItem.id = UUID()
            listItem.name = ingredient.name
            listItem.quantity = ingredient.quantity
            listItem.isCompleted = false
            listItem.source = "Recipe: \(recipe.title ?? "Unknown")"
            listItem.sourceType = "recipe"
            listItem.sourceRecipeID = recipe.id
            listItem.weeklyList = weeklyList
            
            // Increment template usage if connected
            if let template = ingredient.ingredientTemplate {
                templateService.incrementUsage(template: template)
            }
        }
        
        // Save changes
        do {
            try viewContext.save()
            processingMessage = "Successfully added \(selectedIngredientsToAdd.count) items!"
            
            // Show success message briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isProcessing = false
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            processingMessage = "Error adding items: \(error.localizedDescription)"
            print("❌ Error saving grocery list items: \(error)")
            
            // Show error message briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isProcessing = false
            }
        }
    }
    
    private func findOrCreateCurrentWeeklyList() -> WeeklyList {
        // Try to find current week's list
        let request: NSFetchRequest<WeeklyList> = WeeklyList.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeeklyList.dateCreated, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let existingLists = try viewContext.fetch(request)
            if let recentList = existingLists.first,
               let createdDate = recentList.dateCreated,
               Calendar.current.isDate(createdDate, equalTo: Date(), toGranularity: .weekOfYear) {
                return recentList
            }
        } catch {
            print("❌ Error fetching weekly lists: \(error)")
        }
        
        // Create new weekly list for current week
        let newList = WeeklyList(context: viewContext)
        newList.id = UUID()
        newList.name = "Week of \(DateFormatter.weekFormatter.string(from: Date()))"
        newList.dateCreated = Date()
        newList.isCompleted = false
        
        return newList
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}//
//  AddIngredientsToListView.swift
//  GroceryRecipeManager
//
//  Created by Richard Hayn on 9/12/25.
//

