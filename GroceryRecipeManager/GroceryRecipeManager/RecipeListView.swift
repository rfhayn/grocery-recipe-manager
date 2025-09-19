import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recipeService = OptimizedRecipeDataService(context: PersistenceController.shared.container.viewContext)
    
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recipe.lastUsed, ascending: false),
            NSSortDescriptor(keyPath: \Recipe.title, ascending: true)
        ],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                recipe.title?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if filteredRecipes.isEmpty {
                    emptyStateView
                } else {
                    recipeListContent
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddRecipe) {
            // Add recipe functionality (placeholder for Story 2.2)
            Text("Add Recipe functionality coming in Story 2.2")
                .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Recipes Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start building your recipe collection")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                createSampleRecipe()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Sample Recipe")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var recipeListContent: some View {
        List {
            ForEach(filteredRecipes, id: \.objectID) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe, searchText: searchText)
                }
            }
            .onDelete(perform: deleteRecipes)
        }
        .listStyle(PlainListStyle())
    }
    
    private func createSampleRecipe() {
        withAnimation {
            let newRecipe = Recipe(context: viewContext)
            newRecipe.id = UUID()
            newRecipe.title = "Sample Chocolate Chip Cookies"
            newRecipe.instructions = "1. Preheat oven to 375°F\n2. Mix dry ingredients\n3. Combine wet ingredients\n4. Mix everything together\n5. Drop spoonfuls on baking sheet\n6. Bake for 9-11 minutes"
            newRecipe.servings = 24
            newRecipe.prepTime = 15
            newRecipe.cookTime = 10
            newRecipe.usageCount = 0
            newRecipe.dateCreated = Date()
            newRecipe.isFavorite = false
            
            do {
                try viewContext.save()
                addSampleIngredientsWithTemplates(to: newRecipe, in: viewContext)
                try viewContext.save()
                print("Sample recipe '\(newRecipe.title ?? "Unknown")' created successfully with template integration")
            } catch {
                print("Error creating sample recipe: \(error)")
            }
        }
    }
    
    private func addSampleIngredientsWithTemplates(to recipe: Recipe, in context: NSManagedObjectContext) {
        // Sample ingredients with realistic variety for template testing
        let ingredientTexts = [
            "2 cups all-purpose flour",
            "1 cup granulated sugar",
            "2 large eggs",
            "1 tsp vanilla extract",
            "1/2 cup butter, melted",
            "1 tsp baking powder",
            "1/2 tsp salt",
            "1/4 cup milk"
        ]
        
        // Create simple ingredients without complex parsing service integration
        for (index, text) in ingredientTexts.enumerated() {
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = text  // Store full text as name for now
            ingredient.sortOrder = Int16(index)
            ingredient.recipe = recipe
        }
        
        print("Created \(ingredientTexts.count) sample ingredients")
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { recipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                print("Recipe(s) deleted successfully")
            } catch {
                print("Error deleting recipes: \(error)")
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
            
            // Usage tracking
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

// MARK: - Recipe Detail View (Simplified - removing complex template service integration for now)

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    
    // UI state for Add to List functionality
    @State private var showingAddToListSheet = false
    @State private var showingMarkUsedConfirmation = false
    
    private var hasIngredients: Bool {
        guard let ingredients = recipe.ingredients else { return false }
        return !ingredients.allObjects.isEmpty  // Convert to Array first, then check isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recipe Header Section
                recipeHeaderSection
                
                // Timing Information Section
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    timingSection
                }
                
                // Usage Analytics Section
                usageAnalyticsSection
                
                // Ingredients Section
                if hasIngredients {
                    ingredientsSection
                }
                
                // Instructions Section
                if let instructions = recipe.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                toolbarActions
            }
        }
        .sheet(isPresented: $showingAddToListSheet) {
            AddIngredientsToListView(recipe: recipe)  // FIXED: Only recipe parameter
                .environment(\.managedObjectContext, viewContext)
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
    
    // MARK: - View Components
    
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.title ?? "Untitled Recipe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
                
                // Favorite indicator
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
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
    
    private var timingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Timing")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                if recipe.prepTime > 0 {
                    VStack {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Prep")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.prepTime)m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                if recipe.cookTime > 0 {
                    VStack {
                        Image(systemName: "flame")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Cook")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.cookTime)m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                if recipe.prepTime > 0 && recipe.cookTime > 0 {
                    VStack {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.prepTime + recipe.cookTime)m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var usageAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
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
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
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
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingredients")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Add to List button
                Button(action: {
                    showingAddToListSheet = true
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
                .disabled(!hasIngredients)
            }
            
            if let ingredientsSet = recipe.ingredients {
                let ingredientsList = Array(ingredientsSet) as! [Ingredient]
                ForEach(ingredientsList, id: \.objectID) { ingredient in
                    HStack {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(ingredient.name ?? "Unknown ingredient")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func instructionsSection(_ instructions: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(instructions)
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    private var toolbarActions: some View {
        HStack {
            Button(action: {
                showingMarkUsedConfirmation = true
            }) {
                Image(systemName: "checkmark.circle")
            }
            
            Button(action: {
                // Edit functionality (placeholder for Story 2.2)
            }) {
                Image(systemName: "pencil")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var formattedLastUsed: String {
        guard let lastUsed = recipe.lastUsed else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUsed, relativeTo: Date())
    }
    
    private func markRecipeAsUsed() {
        recipe.usageCount += 1
        recipe.lastUsed = Date()
        
        do {
            try viewContext.save()
            print("Recipe marked as used successfully")
        } catch {
            print("Error marking recipe as used: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        RecipeListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
