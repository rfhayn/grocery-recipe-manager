//
//  MealPlanDetailView.swift
//  GroceryRecipeManager
//
//  Enhanced for M4.2.1-3 Enhancement: Inline Autocomplete Meal Planning
//  Each day has its own search field for quick recipe assignment
//  Type-to-filter workflow similar to ingredient autocomplete
//

import SwiftUI
import CoreData

// M4.2.1-3 Enhancement: Meal plan detail view with inline autocomplete per day
// Clean list format where each day has its own search field
// Type to filter recipes, tap to assign - no modals needed
struct MealPlanDetailView: View {
    
    // MARK: - Properties
    
    // M4.2.4: The meal plan to display
    @ObservedObject var mealPlan: MealPlan
    
    // M4.2.4: Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    
    // M4.2.4: Fetch planned meals for this meal plan
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    // M4.2.1-3 Enhancement: All recipes loaded for autocomplete
    @State private var allRecipes: [Recipe] = []
    
    // MARK: - Initialization
    
    init(mealPlan: MealPlan) {
        self.mealPlan = mealPlan
        
        // Configure FetchRequest for this specific meal plan
        let planID = mealPlan.id ?? UUID()
        _plannedMeals = FetchRequest<PlannedMeal>(
            sortDescriptors: [NSSortDescriptor(keyPath: \PlannedMeal.date, ascending: true)],
            predicate: NSPredicate(format: "mealPlan.id == %@", planID as CVarArg)
        )
    }
    
    // MARK: - Computed Properties
    
    // M4.2.1-3 Enhancement: Generate array of dates for the meal plan
    private var daysInPlan: [Date] {
        guard let startDate = mealPlan.startDate else { return [] }
        let duration = Int(mealPlan.duration)
        
        return (0..<duration).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: startDate)
        }
    }
    
    // M4.2.1-3 Enhancement: Get planned meal for a specific date
    private func plannedMeal(for date: Date) -> PlannedMeal? {
        plannedMeals.first { meal in
            guard let mealDate = meal.date else { return false }
            return Calendar.current.isDate(mealDate, inSameDayAs: date)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Plan header
                planHeaderView
                    .padding(.bottom, 16)
                
                // Days list with inline autocomplete
                VStack(spacing: 12) {
                    ForEach(daysInPlan, id: \.self) { date in
                        DayRowView(
                            date: date,
                            plannedMeal: plannedMeal(for: date),
                            allRecipes: allRecipes,
                            mealPlan: mealPlan,
                            onRecipeAdded: { recipe, servings in
                                addRecipeToDay(recipe: recipe, date: date, servings: servings)
                            },
                            onRecipeRemoved: { meal in
                                removePlannedMeal(meal)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(mealPlan.name ?? "Meal Plan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAllRecipes()
        }
    }
    
    // MARK: - Plan Header
    
    private var planHeaderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date range
            if let startDate = mealPlan.startDate {
                Text(formatDateRange(startDate: startDate, duration: Int(mealPlan.duration)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            HStack(spacing: 16) {
                Label("\(plannedMeals.count) meals", systemImage: "fork.knife")
                Label("\(Int(mealPlan.duration)) days", systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
    
    // M4.2.1-3 Enhancement: Load all recipes for autocomplete
    private func loadAllRecipes() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)]
        
        do {
            allRecipes = try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching recipes: \(error)")
            allRecipes = []
        }
    }
    
    // M4.2.1-3 Enhancement: Add recipe to specific day
    private func addRecipeToDay(recipe: Recipe, date: Date, servings: Int) {
        // Check if there's already a meal on this day
        if let existingMeal = plannedMeal(for: date) {
            // Remove existing meal first
            removePlannedMeal(existingMeal)
        }
        
        // Add new recipe
        if let _ = MealPlanService.shared.addRecipeToMealPlan(
            recipe: recipe,
            date: date,
            mealPlan: mealPlan,
            servings: Int16(servings)
        ) {
            // Success - meal added
        } else {
            print("Error adding recipe to meal plan")
        }
    }
    
    // M4.2.1-3: Remove planned meal
    private func removePlannedMeal(_ meal: PlannedMeal) {
        viewContext.delete(meal)
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing planned meal: \(error)")
        }
    }
    
    // M4.2.1-3: Format date range for display
    private func formatDateRange(startDate: Date, duration: Int) -> String {
        let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = yearFormatter.string(from: startDate)
        
        return "\(startString) - \(endString), \(year)"
    }
}

// MARK: - Day Row View

// M4.2.1-3 Enhancement: Individual day row with inline autocomplete
// Each day has its own search field for quick recipe assignment
struct DayRowView: View {
    let date: Date
    let plannedMeal: PlannedMeal?
    let allRecipes: [Recipe]
    let mealPlan: MealPlan
    let onRecipeAdded: (Recipe, Int) -> Void
    let onRecipeRemoved: (PlannedMeal) -> Void
    
    // M4.2.1-3 Enhancement: Search text for this day's autocomplete
    @State private var searchText = ""
    
    // M4.2.1-3 Enhancement: Focus state for search field
    @FocusState private var isSearchFocused: Bool
    
    // M4.2.1-3 Enhancement: Servings for selected recipe
    @State private var selectedServings: Int = 4
    
    // M4.2.1-3 Enhancement: Show servings adjuster
    @State private var showServingsAdjuster = false
    @State private var pendingRecipe: Recipe?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Day header
            dayHeader
            
            // Assigned recipe (if exists)
            if let meal = plannedMeal {
                assignedRecipeView(meal: meal)
            } else {
                // Autocomplete search field
                autocompleteSearchField
                
                // Filtered recipe results (when typing)
                if !searchText.isEmpty && !filteredRecipes.isEmpty {
                    recipeResultsList
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - View Components
    
    // M4.2.1-3 Enhancement: Day header with formatted date
    private var dayHeader: some View {
        Text(formattedDate)
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    // M4.2.1-3 Enhancement: Autocomplete search field (like ingredient input)
    private var autocompleteSearchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            TextField("Add recipe...", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
    
    // M4.2.1-3 Enhancement: Filtered recipe results list
    private var recipeResultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(filteredRecipes.prefix(5), id: \.id) { recipe in
                Button {
                    handleRecipeSelection(recipe)
                } label: {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.title ?? "Untitled")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Text("\(recipe.ingredients?.count ?? 0) ingredients • Serves \(Int(recipe.servings))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            
            if filteredRecipes.count > 5 {
                Text("+ \(filteredRecipes.count - 5) more...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
            }
        }
    }
    
    // M4.2.1-3 Enhancement: Assigned recipe display
    private func assignedRecipeView(meal: PlannedMeal) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.recipe?.title ?? "Untitled Recipe")
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("\(Int(meal.servings)) servings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Remove button
            Button {
                onRecipeRemoved(meal)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
    
    // MARK: - Helper Functions
    
    // M4.2.1-3 Enhancement: Filter recipes based on search text
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return []
        }
        
        return allRecipes.filter { recipe in
            guard let title = recipe.title else { return false }
            return title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // M4.2.1-3 Enhancement: Handle recipe selection
    private func handleRecipeSelection(_ recipe: Recipe) {
        // Add with default servings
        let servings = Int(recipe.servings)
        onRecipeAdded(recipe, servings)
        
        // Clear search
        searchText = ""
        isSearchFocused = false
    }
    
    // M4.2.1-3 Enhancement: Format date for display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"  // "Friday, Nov 7"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

struct MealPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
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
        recipe1.title = "Hot Dog and Tortellini"
        recipe1.servings = 4
        
        let recipe2 = Recipe(context: context)
        recipe2.id = UUID()
        recipe2.title = "Chocolate Chip Cookies"
        recipe2.servings = 24
        
        try? context.save()
        
        return NavigationStack {
            MealPlanDetailView(mealPlan: plan)
                .environment(\.managedObjectContext, context)
        }
    }
}
