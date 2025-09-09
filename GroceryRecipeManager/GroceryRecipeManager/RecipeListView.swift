//
//  RecipeListView.swift
//  GroceryRecipeManager
//
//  Created on September 7, 2025
//  MILESTONE 2 - Phase 2: Recipe Core Development
//  Story 2.1: Recipe Catalog Foundation - Step 1: Basic RecipeListView
//  Updated September 8, 2025 - Step 2: Enhanced RecipeDetailView with Working Favorite Toggle
//

import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Core Data fetch request for recipes
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recipe.lastUsed, ascending: false),
            NSSortDescriptor(keyPath: \Recipe.title, ascending: true)
        ],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    // Performance-optimized data service from Phase 1
    @StateObject private var recipeService = OptimizedRecipeDataService(context: PersistenceController.shared.container.viewContext)
    
    // State for search functionality (will enhance in Step 5)
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !searchText.isEmpty {
                    searchResultsSection
                } else {
                    recipeListSection
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addSampleRecipe) {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search recipes...")
        }
    }
    
    // MARK: - Recipe List Section
    
    private var recipeListSection: some View {
        Group {
            if recipes.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(recipes, id: \.self) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                    .onDelete(perform: deleteRecipes)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    // MARK: - Search Results Section (Step 5 preview)
    
    private var searchResultsSection: some View {
        List {
            ForEach(filteredRecipes, id: \.self) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe, searchText: searchText)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.pages")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Recipes Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first recipe to get started with meal planning and automated grocery lists.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: addSampleRecipe) {
                Label("Add Recipe", systemImage: "plus")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Computed Properties
    
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                recipe.title?.localizedCaseInsensitiveContains(searchText) == true ||
                recipe.instructions?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    // MARK: - Actions
    
    private func addSampleRecipe() {
        print("🍴 Add Recipe tapped - Creating sample recipe for Step 2 testing")
        
        withAnimation {
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = UUID()
            newRecipe.title = "Sample Recipe \(Int(Date().timeIntervalSince1970) % 1000)"
            newRecipe.instructions = "Sample instructions for this delicious recipe. This will be replaced with proper recipe creation in Story 2.2."
            newRecipe.dateCreated = Date()
            newRecipe.usageCount = Int32.random(in: 0...5) // Random usage for testing
            newRecipe.isFavorite = Bool.random() // Random favorite for testing
            newRecipe.servings = Int16.random(in: 2...6) // Random servings
            newRecipe.prepTime = Int16.random(in: 15...45) // Random prep time
            newRecipe.cookTime = Int16.random(in: 20...60) // Random cook time
            
            // Add sample ingredients using proper Core Data relationships
            addSampleIngredients(to: newRecipe)
            
            // Occasionally set lastUsed for testing
            if newRecipe.usageCount > 0 {
                newRecipe.lastUsed = Date().addingTimeInterval(-Double.random(in: 86400...604800)) // 1-7 days ago
            }
            
            do {
                try viewContext.save()
                print("✅ Sample recipe '\(newRecipe.title ?? "Unknown")' created successfully")
            } catch {
                print("❌ Error creating sample recipe: \(error)")
            }
        }
    }
    
    private func addSampleIngredients(to recipe: Recipe) {
        // Add sample ingredients for testing
        let sampleIngredients = [
            ("2 cups", "flour", ""),
            ("1 cup", "sugar", ""),
            ("2 large", "eggs", ""),
            ("1 tsp", "vanilla extract", ""),
            ("1/2 cup", "butter", "melted")
        ]
        
        for (index, ingredientData) in sampleIngredients.enumerated() {
            let ingredient = Ingredient(context: viewContext)
            ingredient.id = UUID()
            ingredient.quantity = ingredientData.0
            ingredient.name = ingredientData.1
            ingredient.notes = ingredientData.2
            ingredient.sortOrder = Int16(index)
            recipe.addToIngredients(ingredient)
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { recipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                print("✅ Recipe(s) deleted successfully")
            } catch {
                print("❌ Error deleting recipes: \(error)")
            }
        }
    }
}

// MARK: - Recipe Row View

struct RecipeRowView: View {
    let recipe: Recipe
    var searchText: String = ""
    
    private var formattedLastUsed: String {
        guard let lastUsed = recipe.lastUsed else {
            return "Never used"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Used \(formatter.localizedString(for: lastUsed, relativeTo: Date()))"
    }
    
    private var usageText: String {
        let count = recipe.usageCount
        if count == 0 {
            return "Never used"
        } else if count == 1 {
            return "Used 1 time"
        } else {
            return "Used \(count) times"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Recipe title
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title ?? "Untitled Recipe")
                        .font(.headline)
                        .lineLimit(1)
                    
                    if recipe.servings > 0 {
                        Text("\(recipe.servings) servings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Favorite indicator
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            // Usage tracking (Step 6 foundation)
            HStack {
                Text(usageText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if recipe.usageCount > 0 {
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formattedLastUsed)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Recipe indicators
                if recipe.prepTime > 0 {
                    Label("\(recipe.prepTime)m", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Enhanced Recipe Detail View (Step 2)

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recipeService = OptimizedRecipeDataService(context: PersistenceController.shared.container.viewContext)
    
    // State for enhanced functionality
    @State private var showingMarkUsedConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recipe Header Section
                recipeHeaderSection
                
                // Enhanced Timing Information Section
                enhancedTimingSection
                
                // Improved Usage Analytics Section
                enhancedUsageAnalyticsSection
                
                // Enhanced Ingredients Section
                enhancedIngredientsSection
                
                // Instructions Section
                if let instructions = recipe.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
                
                // Recipe Notes Section will be added in Story 2.2
                
                Spacer(minLength: 100) // Bottom padding for scroll
            }
            .padding(.horizontal)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                enhancedToolbarActions
            }
        }
        .confirmationDialog(
            "Mark Recipe as Used",
            isPresented: $showingMarkUsedConfirmation,
            titleVisibility: .visible
        ) {
            Button("Mark as Used Today") {
                markRecipeAsUsed()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will update the usage count and last used date for this recipe.")
        }
    }
    
    // MARK: - Recipe Header Section
    
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.title ?? "Untitled Recipe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
                
                // Favorite indicator with enhanced styling
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 32, height: 32)
                        )
                }
            }
            
            // Recipe metadata
            if recipe.servings > 0 {
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.secondary)
                    Text("\(recipe.servings) servings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Enhanced Timing Information Section
    
    private var enhancedTimingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timing")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // Prep Time
                if recipe.prepTime > 0 {
                    timingCard(
                        title: "Prep Time",
                        time: recipe.prepTime,
                        icon: "clock",
                        color: .blue
                    )
                }
                
                // Cook Time
                if recipe.cookTime > 0 {
                    timingCard(
                        title: "Cook Time",
                        time: recipe.cookTime,
                        icon: "flame",
                        color: .orange
                    )
                }
                
                // Total Time (if both prep and cook are available)
                if recipe.prepTime > 0 && recipe.cookTime > 0 {
                    timingCard(
                        title: "Total Time",
                        time: recipe.prepTime + recipe.cookTime,
                        icon: "timer",
                        color: .green
                    )
                } else if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    // Show total time even with just one timing
                    timingCard(
                        title: "Total Time",
                        time: max(recipe.prepTime, recipe.cookTime),
                        icon: "timer",
                        color: .green
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func timingCard(title: String, time: Int16, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(time)m")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Enhanced Usage Analytics Section
    
    private var enhancedUsageAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Usage Analytics")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingMarkUsedConfirmation = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                        Text("Mark Used")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
            
            HStack(spacing: 20) {
                // Usage Count
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.blue)
                        Text("Times Made")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(recipe.usageCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Last Used
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                        Text("Last Made")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(formattedLastUsed)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            // Usage frequency indicator
            if recipe.usageCount > 0 {
                HStack {
                    Image(systemName: usageFrequencyIcon)
                        .foregroundColor(usageFrequencyColor)
                    Text(usageFrequencyText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Enhanced Ingredients Section
    
    private var enhancedIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingredients")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Preparation for IngredientTemplate integration (Step 3)
                Button(action: {
                    // TODO: Implement in Step 3 - Add to Grocery List
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.badge.plus")
                        Text("Add to List")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(recipe.ingredients?.count == 0) // Enable when ingredients exist
            }
            
            // Enhanced ingredients display using Core Data relationship
            if let ingredientsSet = recipe.ingredients, ingredientsSet.count > 0 {
                let ingredientsList = Array(ingredientsSet) as! [Ingredient]
                let sortedIngredients = ingredientsList.sorted { ($0.sortOrder) < ($1.sortOrder) }
                
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(sortedIngredients.enumerated()), id: \.offset) { index, ingredient in
                        enhancedIngredientRow(ingredient: ingredient, index: index)
                    }
                }
            } else {
                // Empty state for ingredients
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No ingredients added")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Ingredients will be added when this recipe is edited")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func enhancedIngredientRow(ingredient: Ingredient, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Ingredient number
            Text("\(index + 1)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            
            // Ingredient text with enhanced formatting
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name ?? "Unknown ingredient")
                        .font(.body)
                        .lineLimit(nil)
                    
                    // Show unit and notes if available (on separate line for additional info)
                    if let unit = ingredient.unit, !unit.isEmpty {
                        Text("Unit: \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let notes = ingredient.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Quantity right-aligned on same line as ingredient name
                if let quantity = ingredient.quantity, !quantity.isEmpty {
                    Text(quantity)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // Preparation for template integration (Step 3)
            Image(systemName: "checkmark.circle")
                .font(.caption)
                .foregroundColor(.green)
                .opacity(0.3) // Will be functional in Step 3
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Instructions Section
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(instructions)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Enhanced Toolbar Actions with Working Favorite Toggle
    
    private var enhancedToolbarActions: some View {
        HStack(spacing: 16) {
            // Favorite toggle with @ObservedObject UI refresh
            Button(action: {
                print("❤️ Heart button tapped - Current favorite status: \(recipe.isFavorite)")
                toggleFavorite()
            }) {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(recipe.isFavorite ? .red : .primary)
                    .font(.body)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Share recipe (placeholder for future implementation)
            Button(action: {
                print("📤 Share button tapped")
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Edit recipe (Story 2.2 placeholder)
            Button(action: {
                print("✏️ Edit Recipe tapped - Recipe editing coming in Story 2.2")
            }) {
                Text("Edit")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Methods
    
    private var formattedLastUsed: String {
        guard let lastUsed = recipe.lastUsed else {
            return "Never"
        }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(lastUsed, inSameDayAs: Date()) {
            return "Today"
        } else if calendar.isDate(lastUsed, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            return "Yesterday"
        } else if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()),
                  weekInterval.contains(lastUsed) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: lastUsed)
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: lastUsed)
        }
    }
    
    private var usageFrequencyIcon: String {
        switch recipe.usageCount {
        case 0: return "circle"
        case 1...3: return "circle.dotted"
        case 4...10: return "circle.fill"
        default: return "star.circle.fill"
        }
    }
    
    private var usageFrequencyColor: Color {
        switch recipe.usageCount {
        case 0: return .gray
        case 1...3: return .orange
        case 4...10: return .green
        default: return .purple
        }
    }
    
    private var usageFrequencyText: String {
        switch recipe.usageCount {
        case 0: return "New recipe"
        case 1: return "Tried once"
        case 2...3: return "Tried a few times"
        case 4...10: return "Regular recipe"
        default: return "Favorite recipe"
        }
    }
    
    private func toggleFavorite() {
        print("🔧 toggleFavorite() called")
        print("🔧 Current recipe.isFavorite: \(recipe.isFavorite)")
        print("🔧 Recipe title: \(recipe.title ?? "nil")")
        
        withAnimation(.easeInOut(duration: 0.2)) {
            let oldValue = recipe.isFavorite
            recipe.isFavorite.toggle()
            
            print("🔧 After toggle - recipe.isFavorite: \(recipe.isFavorite)")
            print("🔧 Changed from \(oldValue) to \(recipe.isFavorite)")
            
            do {
                try viewContext.save()
                print("✅ Core Data save successful - Favorite status: \(recipe.isFavorite ? "Added" : "Removed")")
                print("🔄 UI should auto-refresh via @ObservedObject")
                
            } catch {
                print("❌ Core Data save failed: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                // Revert the change if save failed
                recipe.isFavorite = oldValue
                print("🔧 Reverted to original value: \(recipe.isFavorite)")
            }
        }
    }
    
    private func markRecipeAsUsed() {
        recipe.usageCount += 1
        recipe.lastUsed = Date()
        
        do {
            try viewContext.save()
        } catch {
            // Handle error appropriately
            print("Error marking recipe as used: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        RecipeListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
