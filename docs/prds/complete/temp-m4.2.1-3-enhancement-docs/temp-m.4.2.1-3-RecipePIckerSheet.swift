//
//  RecipePickerSheet.swift
//  forager
//
//  Created for M4.2.1-3: Calendar Recipe Assignment Enhancement
//  Modal sheet for selecting a recipe to add to a specific date in meal plan
//  Used when user taps on an empty day in the calendar
//

import SwiftUI
import CoreData

// M4.2.1-3: Payload for data-driven sheet presentation
// Prevents blank sheet bug by using .sheet(item:) instead of .sheet(isPresented:)
struct RecipePickerPayload: Identifiable {
    let id = UUID()
    let date: Date
    let mealPlan: MealPlan
}

// M4.2.1-3 ENHANCEMENT: Recipe picker for calendar tap-to-add
// Shows list of all recipes with search, allows selection to assign to date
struct RecipePickerSheet: View {
    
    // MARK: - Properties
    
    // M4.2.1-3: Date to assign recipe to
    var date: Date
    
    // M4.2.1-3: Meal plan to add recipe to
    var mealPlan: MealPlan
    
    // M4.2.1-3: Closure called when recipe is selected
    var onRecipeSelected: (Recipe) -> Void
    
    // M4.2.1-3: Controls sheet dismissal
    @Environment(\.dismiss) private var dismiss
    
    // M4.2.1-3: Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    
    // M4.2.1-3: All recipes - loaded manually
    @State private var recipes: [Recipe] = []
    
    // M4.2.1-3: Search text for filtering recipes
    @State private var searchText = ""
    
    // M4.2.1-3: Selected servings (defaults to recipe servings)
    @State private var selectedServings: [UUID: Int] = [:]
    
    // MARK: - Computed Properties
    
    // M4.2.1-3: Filter recipes based on search text
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                guard let title = recipe.title else { return false }
                return title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // M4.2.1-3: Date formatter for display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredRecipes.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        dateContextBanner
                        recipeList
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes")
        }
        .onAppear {
            loadRecipes()
        }
    }
    
    // MARK: - Date Context Banner
    
    // M4.2.1-3: Shows which date the recipe will be assigned to
    private var dateContextBanner: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.blue)
            
            Text("Adding to \(dateFormatter.string(from: date))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
    }
    
    // MARK: - Recipe List
    
    // M4.2.1-3: Scrollable list of all recipes
    private var recipeList: some View {
        List {
            ForEach(filteredRecipes, id: \.id) { recipe in
                RecipeRowButton(
                    recipe: recipe,
                    servings: getServings(for: recipe),
                    onServingsChange: { newServings in
                        setServings(newServings, for: recipe)
                    },
                    onSelect: {
                        handleRecipeSelection(recipe)
                    }
                )
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    // M4.2.1-3: Shown when no recipes exist or search returns no results
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "fork.knife.circle" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "No Recipes" : "No Results")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ?
                 "Create recipes in the Recipes tab to add them to your meal plan" :
                 "No recipes match '\(searchText)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Helper Functions
    
    // M4.2.1-3: Load recipes from Core Data manually
    // Avoids @FetchRequest context issues in sheets
    private func loadRecipes() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)]
        
        do {
            recipes = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching recipes: \(error)")
            recipes = []
        }
    }
    
    // M4.2.1-3: Get servings for recipe (defaults to recipe servings)
    private func getServings(for recipe: Recipe) -> Int {
        guard let recipeID = recipe.id else { return Int(recipe.servings) }
        return selectedServings[recipeID] ?? Int(recipe.servings)
    }
    
    // M4.2.1-3: Set servings for recipe
    private func setServings(_ servings: Int, for recipe: Recipe) {
        guard let recipeID = recipe.id else { return }
        selectedServings[recipeID] = servings
    }
    
    // M4.2.1-3: Handle recipe selection
    // Adds recipe to meal plan and dismisses sheet
    private func handleRecipeSelection(_ recipe: Recipe) {
        let servings = getServings(for: recipe)
        
        // Add recipe to meal plan via service
        if let _ = MealPlanService.shared.addRecipeToMealPlan(
            recipe: recipe,
            date: date,
            mealPlan: mealPlan,
            servings: Int16(servings)
        ) {
            // Success - notify parent and dismiss
            onRecipeSelected(recipe)
            dismiss()
        } else {
            // Error adding recipe
            print("Error adding recipe to meal plan")
        }
    }
}

// MARK: - Recipe Row Button

// M4.2.1-3: Individual recipe row with servings adjuster and tap-to-select
struct RecipeRowButton: View {
    let recipe: Recipe
    let servings: Int
    let onServingsChange: (Int) -> Void
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Recipe title
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text(recipe.title ?? "Untitled Recipe")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recipe details
                HStack(spacing: 12) {
                    Label("\(recipe.ingredients?.count ?? 0) ingredients",
                          systemImage: "list.bullet")
                    
                    if recipe.servings > 0 {
                        Label("Serves \(Int(recipe.servings))",
                              systemImage: "person.2")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Servings adjuster
                HStack {
                    Text("Servings:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Decrement button
                    Button {
                        if servings > 1 {
                            onServingsChange(servings - 1)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(servings > 1 ? .blue : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(servings <= 1)
                    
                    // Current servings
                    Text("\(servings)")
                        .font(.headline)
                        .frame(minWidth: 30)
                    
                    // Increment button
                    Button {
                        if servings < 99 {
                            onServingsChange(servings + 1)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(servings < 99 ? .blue : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(servings >= 99)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("With Recipes") {
    let context = PersistenceController.preview.container.viewContext
    
    // Create sample meal plan
    let plan = MealPlan(context: context)
    plan.id = UUID()
    plan.name = "This Week"
    plan.startDate = Date()
    plan.duration = 7
    
    // Create sample recipes
    let recipe1 = Recipe(context: context)
    recipe1.id = UUID()
    recipe1.title = "Spaghetti Carbonara"
    recipe1.servings = 4
    
    let recipe2 = Recipe(context: context)
    recipe2.id = UUID()
    recipe2.title = "Chicken Stir Fry"
    recipe2.servings = 2
    
    let recipe3 = Recipe(context: context)
    recipe3.id = UUID()
    recipe3.title = "Vegetable Soup"
    recipe3.servings = 6
    
    try? context.save()
    
    return RecipePickerSheet(
        date: Date(),
        mealPlan: plan,
        onRecipeSelected: { _ in }
    )
    .environment(\.managedObjectContext, context)
}

#Preview("Empty State") {
    let context = PersistenceController.preview.container.viewContext
    
    let plan = MealPlan(context: context)
    plan.id = UUID()
    plan.name = "Empty Week"
    plan.startDate = Date()
    plan.duration = 7
    
    return RecipePickerSheet(
        date: Date(),
        mealPlan: plan,
        onRecipeSelected: { _ in }
    )
    .environment(\.managedObjectContext, context)
}