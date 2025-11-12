import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var popToRoot: Bool
    
    @StateObject private var recipeService = OptimizedRecipeDataService(context: PersistenceController.shared.container.viewContext)
    
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var searchHistory: [String] = []
    
    // M4.2.4 PHASE 7: Updated to use SelectMealPlanSheet for multi-plan support
    @State private var showingMealPlanSheet = false
    @State private var selectedRecipeForMealPlan: Recipe?
    
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recipe.lastUsed, ascending: false),
            NSSortDescriptor(keyPath: \Recipe.title, ascending: true)
        ],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    // M3.5: Simplified search using computed property
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        }
        
        // M3.5: Use computed property for search
        return Array(recipes).filter { recipe in
            recipe.matchesRecipeSearchQuery(searchText)
        }.sorted { first, second in
            // Sort by usage count (higher first)
            if first.usageCount != second.usageCount {
                return first.usageCount > second.usageCount
            }
            // Then alphabetical by title
            return first.recipeDisplayTitle < second.recipeDisplayTitle
        }
    }
    
    // ENHANCED: Search result analysis for UI indicators
    private func getMatchIndicators(for recipe: Recipe) -> [SearchMatchType] {
        guard !searchText.isEmpty else { return [] }
        
        let searchTerms = searchText.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        var indicators: [SearchMatchType] = []
        let title = recipe.title?.lowercased() ?? ""
        let instructions = recipe.instructions?.lowercased() ?? ""
        
        let ingredientNames = (recipe.ingredients?.allObjects as? [Ingredient])?
            .compactMap { $0.name?.lowercased() } ?? []
        
        for term in searchTerms {
            if title.contains(term) {
                indicators.append(.title)
            }
            if ingredientNames.contains(where: { $0.contains(term) }) {
                indicators.append(.ingredient)
            }
            if instructions.contains(term) {
                indicators.append(.instructions)
            }
        }
        
        return Array(Set(indicators)) // Remove duplicates
    }
    
    // ENHANCED: Search history management
    private func addToSearchHistory(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !searchHistory.contains(trimmed) else { return }
        
        searchHistory.insert(trimmed, at: 0)
        if searchHistory.count > 8 {
            searchHistory = Array(searchHistory.prefix(8))
        }
        
        // Persist search history
        UserDefaults.standard.set(searchHistory, forKey: "RecipeSearchHistory")
    }
    
    // ENHANCED: Load search history
    private func loadSearchHistory() {
        searchHistory = UserDefaults.standard.stringArray(forKey: "RecipeSearchHistory") ?? []
    }

    var body: some View {
            Group {
                if filteredRecipes.isEmpty {
                    enhancedEmptyStateView
                } else {
                    recipeListContent
                }
            }
            .navigationTitle("Recipes")
            .searchable(
                text: $searchText,
                prompt: "Search recipes, ingredients, instructions..."
            )
            .searchSuggestions {
                if !searchText.isEmpty && !searchHistory.isEmpty {
                    searchSuggestionsView
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        .sheet(isPresented: $showingAddRecipe) {
            CreateRecipeView(context: viewContext)
        }
        // M4.2.4 PHASE 7: Updated to use SelectMealPlanSheet for multi-plan support
        .sheet(isPresented: $showingMealPlanSheet) {
            if let recipe = selectedRecipeForMealPlan {
                SelectMealPlanSheet(recipe: recipe) { plan, date in
                    // M4.2.4: Add recipe to selected plan and date
                    // Recipe tracking now happens in MealPlanService.addRecipeToMealPlan
                    if let _ = MealPlanService.shared.addRecipeToMealPlan(
                        recipe: recipe,
                        date: date,
                        mealPlan: plan
                    ) {
                        print("✅ M4.2.4: Added \(recipe.title ?? "recipe") to \(plan.name ?? "plan") on \(date)")
                    } else {
                        print("❌ M4.2.4: Failed to add recipe (date may already be occupied)")
                    }
                }
            }
        }
        .onAppear {
            loadSearchHistory()
        }
        .onSubmit(of: .search) {
            if !searchText.isEmpty {
                addToSearchHistory(searchText)
            }
        }
        .onChange(of: popToRoot) { _, _ in
            if showingAddRecipe { showingAddRecipe = false }
            if showingMealPlanSheet { showingMealPlanSheet = false }
            if selectedRecipeForMealPlan != nil { selectedRecipeForMealPlan = nil }
        }
    }
    
    // ENHANCED: Improved empty state with search awareness
    private var enhancedEmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "book.closed" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "No Recipes Yet" : "No Matches Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if searchText.isEmpty {
                    Text("Start building your recipe collection")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    VStack(spacing: 4) {
                        Text("No recipes found for \"\(searchText)\"")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Try searching for recipe names, ingredients, or cooking methods")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            if searchText.isEmpty {
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
            } else {
                Button("Clear Search") {
                    searchText = ""
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private var recipeListContent: some View {
        VStack(spacing: 0) {
            if !searchText.isEmpty {
                searchResultHeader
            }
            
            List {
                ForEach(filteredRecipes, id: \.objectID) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        EnhancedRecipeRowView(
                            recipe: recipe,
                            searchText: searchText,
                            matchIndicators: getMatchIndicators(for: recipe)
                        )
                    }
                    // M4.2: Swipe action to add recipe to meal plan
                    .swipeActions(edge: .leading) {
                        Button {
                            selectedRecipeForMealPlan = recipe
                            showingMealPlanSheet = true
                        } label: {
                            Label("Add to Meal Plan", systemImage: "calendar.badge.plus")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    // ENHANCED: Search result header with count
    private var searchResultHeader: some View {
        HStack {
            Text("\(filteredRecipes.count) recipe\(filteredRecipes.count == 1 ? "" : "s") found")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if !filteredRecipes.isEmpty {
                Text("Sorted by relevance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // ENHANCED: Search suggestions
    private var searchSuggestionsView: some View {
        ForEach(searchHistory.prefix(5), id: \.self) { historyItem in
            Button(action: {
                searchText = historyItem
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(historyItem)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
        }
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
                print("Sample recipe '\(newRecipe.title ?? "Unknown")' created successfully")
            } catch {
                print("Error creating sample recipe: \(error)")
            }
        }
    }
    
    private func addSampleIngredientsWithTemplates(to recipe: Recipe, in context: NSManagedObjectContext) {
        let ingredientTexts = [
            "2 cups all-purpose flour",
            "1 cup chocolate chips",
            "1/2 cup butter",
            "3/4 cup sugar",
            "2 eggs",
            "1 tsp vanilla extract"
        ]
        
        let templateService = IngredientTemplateService(context: context)
        let parsingService = IngredientParsingService(context: context, templateService: templateService)
        
        for (index, text) in ingredientTexts.enumerated() {
            let parsed = parsingService.parseIngredient(text: text)
            let structured = parsingService.parseToStructured(text: text)
            
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = parsed.originalText
            ingredient.sortOrder = Int16(index)
            ingredient.recipe = recipe
            
            ingredient.numericValue = structured.numericValue ?? 0.0
            ingredient.standardUnit = structured.standardUnit
            ingredient.isParseable = structured.isParseable
            ingredient.parseConfidence = structured.parseConfidence
        }
        
        print("✅ Created \(ingredientTexts.count) sample ingredients with structured quantities")
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
                print("Recipe(s) deleted successfully")
            } catch {
                print("Error deleting recipes: \(error)")
            }
        }
    }
}

// ENHANCED: Recipe Row with search indicators - M3.5: USES COMPUTED PROPERTIES
struct EnhancedRecipeRowView: View {
    let recipe: Recipe
    var searchText: String = ""
    let matchIndicators: [SearchMatchType]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // M3.5: Use recipeDisplayTitle (handles nil)
                    Text(recipe.recipeDisplayTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // M3.5: Use recipeServingsDescription (always shows, handles 0)
                    Text(recipe.recipeServingsDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            HStack {
                // M3.5: Use recipeUsageDescription (replaces custom logic)
                Text(recipe.recipeUsageDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if recipe.usageCount > 0 {
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // M3.5: Use recipeLastUsedDescription (replaces formatted date logic)
                    Text(recipe.recipeLastUsedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // M3.5: Use hasRecipeTiming check
                if recipe.hasRecipeTiming {
                    // M3.5: Use recipeFormattedPrepTime
                    Label(recipe.recipeFormattedPrepTime, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !matchIndicators.isEmpty && !searchText.isEmpty {
                searchMatchIndicators
            }
        }
        .padding(.vertical, 4)
    }
    
    private var searchMatchIndicators: some View {
        HStack(spacing: 8) {
            Text("Matches:")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            ForEach(matchIndicators, id: \.self) { indicator in
                HStack(spacing: 4) {
                    Image(systemName: indicator.iconName)
                        .font(.caption2)
                    Text(indicator.displayName)
                        .font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(indicator.color.opacity(0.15))
                .foregroundColor(indicator.color)
                .cornerRadius(4)
            }
            
            Spacer()
        }
    }
}

// MARK: - M3 PHASE 4: RecipeDetailView with Scaling Integration - M3.5: USES COMPUTED PROPERTIES

struct RecipeDetailView: View {
    @ObservedObject var recipe: Recipe
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    @State private var showingAddToListSheet = false
    @State private var showingMarkUsedConfirmation = false
    @State private var showingEditSheet = false
    
    // M4.2.4 PHASE 7: Updated to use SelectMealPlanSheet for multi-plan support
    @State private var showingMealPlanSheet = false
    
    // M3 PHASE 4: Recipe Scaling State
    @State private var showingScalingSheet = false
    private let scalingService: RecipeScalingService
    
    // M3 PHASE 4: Initialize scaling service
    init(recipe: Recipe) {
        self.recipe = recipe
        self.scalingService = RecipeScalingService(
            context: PersistenceController.shared.container.viewContext
        )
    }
    
    private var groupedIngredients: [String: [Ingredient]] {
        guard let ingredientsSet = recipe.ingredients else { return [:] }
        let ingredientsList = Array(ingredientsSet) as! [Ingredient]
        
        return Dictionary(grouping: ingredientsList) { ingredient in
            ingredient.ingredientTemplate?.category ?? "Uncategorized"
        }
    }
    
    private var sortedCategoryNames: [String] {
        let categoryOrder = categories.compactMap { $0.name }
        var sortedNames = groupedIngredients.keys.sorted()
        
        sortedNames.sort { first, second in
            let firstIndex = categoryOrder.firstIndex(of: first) ?? Int.max
            let secondIndex = categoryOrder.firstIndex(of: second) ?? Int.max
            return firstIndex < secondIndex
        }
        
        return sortedNames
    }
    
    private var hasIngredients: Bool {
        return !(groupedIngredients.isEmpty)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                recipeHeaderSection
                
                if recipe.hasRecipeTiming {
                    timingSection
                }
                
                usageAnalyticsSection
                
                ingredientsSection
                
                if let instructions = recipe.instructions, !instructions.isEmpty {
                    instructionsSection(instructions)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // M3 PHASE 4: Scaling button
                Button(action: {
                    showingScalingSheet = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                }
                
                Button(action: {
                    showingMarkUsedConfirmation = true
                }) {
                    Image(systemName: "checkmark.circle")
                }
                
                // M4.2: Add to Meal Plan menu
                Menu {
                    Button {
                        showingMealPlanSheet = true
                    } label: {
                        Label("Add to Meal Plan", systemImage: "calendar.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .confirmationDialog("Mark Recipe as Used?", isPresented: $showingMarkUsedConfirmation) {
            Button("Yes, Mark as Used") {
                // M3.5: Use recordRecipeUsage() convenience method
                recipe.recordRecipeUsage()
                do {
                    try viewContext.save()
                    print("Recipe marked as used successfully")
                } catch {
                    print("Error marking recipe as used: \(error)")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will increment the usage count and update the last used date.")
        }
        .sheet(isPresented: $showingAddToListSheet) {
            if hasIngredients {
                AddIngredientsToListView(recipe: recipe)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: recipe, context: viewContext)
        }
        .sheet(isPresented: $showingScalingSheet) {
            RecipeScalingView(recipe: recipe, scalingService: scalingService)
        }
        // M4.2.4 PHASE 7: Updated to use SelectMealPlanSheet for multi-plan support
        .sheet(isPresented: $showingMealPlanSheet) {
            SelectMealPlanSheet(recipe: recipe) { plan, date in
                // M4.2.4: Add recipe to selected plan and date
                // Recipe tracking now happens in MealPlanService.addRecipeToMealPlan
                if let _ = MealPlanService.shared.addRecipeToMealPlan(
                    recipe: recipe,
                    date: date,
                    mealPlan: plan
                ) {
                    print("✅ M4.2.4: Added \(recipe.title ?? "recipe") to \(plan.name ?? "plan") on \(date)")
                } else {
                    print("❌ M4.2.4: Failed to add recipe (date may already be occupied)")
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // M3.5: Use recipeDisplayTitle
                Text(recipe.recipeDisplayTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
                
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            
            // M3.5: Use recipeServingsDescription (no need for conditional)
            HStack {
                Image(systemName: "person.2")
                    .foregroundColor(.secondary)
                Text(recipe.recipeServingsDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                        // M3.5: Use recipeFormattedPrepTime
                        Text(recipe.recipeFormattedPrepTime)
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
                        // M3.5: Use recipeFormattedCookTime
                        Text(recipe.recipeFormattedCookTime)
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
                        // M3.5: Use recipeFormattedTotalTime
                        Text(recipe.recipeFormattedTotalTime)
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
                        Text("Last Used")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // M3.5: Use recipeLastUsedDescription
                    Text(recipe.recipeLastUsedDescription)
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
            
            if groupedIngredients.isEmpty {
                Text("No ingredients found")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(sortedCategoryNames, id: \.self) { categoryName in
                    let categoryIngredients = groupedIngredients[categoryName] ?? []
                    
                    if !categoryIngredients.isEmpty {
                        categoryHeaderView(categoryName: categoryName, count: categoryIngredients.count)
                        
                        ForEach(categoryIngredients, id: \.objectID) { ingredient in
                            ingredientRowView(ingredient: ingredient)
                        }
                    }
                }
            }
        }
    }
    
    private func categoryHeaderView(categoryName: String, count: Int) -> some View {
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
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(6)
    }
    
    // M3: Updated to use displayText - M3.5: USES COMPUTED PROPERTIES
    private func ingredientRowView(ingredient: Ingredient) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.secondary.opacity(0.6))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                // M3.5: Use ingredientDisplayName (handles nil)
                Text(ingredient.ingredientDisplayName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                // M3: Use displayText instead of quantity
                // M3.5: Use bestIngredientDisplayText (better fallback handling)
                if ingredient.hasStructuredQuantity || ingredient.displayText != nil {
                    Text(ingredient.bestIngredientDisplayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                
                if let notes = ingredient.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.leading, 8)
    }
    
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
}

// MARK: - Search Match Types

enum SearchMatchType: CaseIterable, Hashable {
    case title
    case ingredient
    case instructions
    
    var displayName: String {
        switch self {
        case .title: return "Name"
        case .ingredient: return "Ingredient"
        case .instructions: return "Instructions"
        }
    }
    
    var iconName: String {
        switch self {
        case .title: return "textformat"
        case .ingredient: return "leaf"
        case .instructions: return "list.bullet"
        }
    }
    
    var color: Color {
        switch self {
        case .title: return .blue
        case .ingredient: return .green
        case .instructions: return .orange
        }
    }
}

#Preview {
    NavigationView {
        RecipeListView(popToRoot: .constant(false))
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
