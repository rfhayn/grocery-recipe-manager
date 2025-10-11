import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var recipeService = OptimizedRecipeDataService(context: PersistenceController.shared.container.viewContext)
    
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var searchHistory: [String] = []
    
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recipe.lastUsed, ascending: false),
            NSSortDescriptor(keyPath: \Recipe.title, ascending: true)
        ],
        animation: .default
    ) private var recipes: FetchedResults<Recipe>
    
    // ENHANCED: Multi-field search with intelligent ranking
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return Array(recipes)
        }
        
        let searchTerms = searchText.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        if searchTerms.isEmpty {
            return Array(recipes)
        }
        
        // Apply multi-field search with relevance scoring
        return Array(recipes)
            .compactMap { recipe in
                let relevanceScore = calculateRelevanceScore(for: recipe, searchTerms: searchTerms)
                return relevanceScore > 0 ? (recipe, relevanceScore) : nil
            }
            .sorted { first, second in
                // Primary sort: Relevance score (higher first)
                if first.1 != second.1 {
                    return first.1 > second.1
                }
                // Secondary sort: Usage count (higher first)
                if first.0.usageCount != second.0.usageCount {
                    return first.0.usageCount > second.0.usageCount
                }
                // Tertiary sort: Alphabetical
                return (first.0.title ?? "") < (second.0.title ?? "")
            }
            .map { $0.0 }
    }
    
    // ENHANCED: Search relevance scoring algorithm
    private func calculateRelevanceScore(for recipe: Recipe, searchTerms: [String]) -> Int {
        var score = 0
        let title = recipe.title?.lowercased() ?? ""
        let instructions = recipe.instructions?.lowercased() ?? ""
        
        // Get ingredient names (handling Core Data relationship safely)
        let ingredientNames = (recipe.ingredients?.allObjects as? [Ingredient])?
            .compactMap { $0.name?.lowercased() } ?? []
        
        for term in searchTerms {
            // Exact title match (highest priority): +100 points
            if title == term {
                score += 100
                continue
            }
            
            // Title contains term: +50 points
            if title.contains(term) {
                score += 50
                continue
            }
            
            // Ingredient name exact match: +30 points
            if ingredientNames.contains(term) {
                score += 30
                continue
            }
            
            // Ingredient name contains term: +20 points
            if ingredientNames.contains(where: { $0.contains(term) }) {
                score += 20
                continue
            }
            
            // Instructions contain term: +10 points
            if instructions.contains(term) {
                score += 10
                continue
            }
            
            // If no match found for this term, recipe doesn't match
            return 0
        }
        
        // Bonus points for highly used recipes
        if recipe.usageCount > 5 {
            score += 5
        } else if recipe.usageCount > 2 {
            score += 2
        }
        
        return score
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
        NavigationView {
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
        }
        .sheet(isPresented: $showingAddRecipe) {
            CreateRecipeView(context: viewContext)
        }
        .onAppear {
            loadSearchHistory()
        }
        .onSubmit(of: .search) {
            if !searchText.isEmpty {
                addToSearchHistory(searchText)
            }
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
                print("Sample recipe '\(newRecipe.title ?? "Unknown")' created successfully with template integration")
            } catch {
                print("Error creating sample recipe: \(error)")
            }
        }
    }
    
    // M3 FIX: Updated to populate all structured quantity fields
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
        
        // Initialize parsing service for structured quantities
        let templateService = IngredientTemplateService(context: context)
        let parsingService = IngredientParsingService(context: context, templateService: templateService)
        
        // Create ingredients with proper structured quantities
        for (index, text) in ingredientTexts.enumerated() {
            // Parse the text to get structured data
            let structured = parsingService.parseToStructured(text: text)
            
            // Create ingredient with ALL required M3 fields
            let ingredient = Ingredient(context: context)
            ingredient.id = UUID()
            ingredient.name = text  // Store full text as name
            ingredient.sortOrder = Int16(index)
            ingredient.recipe = recipe
            
            // M3: Set structured quantity fields
            ingredient.displayText = structured.displayText
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

// ENHANCED: Recipe Row with search indicators
struct EnhancedRecipeRowView: View {
    let recipe: Recipe
    var searchText: String = ""
    let matchIndicators: [SearchMatchType]
    
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
                
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
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
                
                if recipe.prepTime > 0 {
                    Label("\(recipe.prepTime)m", systemImage: "clock")
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

// MARK: - M3 PHASE 4: RecipeDetailView with Scaling Integration

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
        let grouped = groupedIngredients
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.displayName, $0.sortOrder) })
        
        return grouped.keys.sorted { category1, category2 in
            if category1 == "Uncategorized" && category2 != "Uncategorized" { return false }
            if category2 == "Uncategorized" && category1 != "Uncategorized" { return true }
            if category1 == "Uncategorized" && category2 == "Uncategorized" { return false }
            
            let order1 = categoryMap[category1] ?? Int16.max
            let order2 = categoryMap[category2] ?? Int16.max
            
            if order1 == order2 {
                return category1 < category2
            }
            return order1 < order2
        }
    }
    
    private var hasIngredients: Bool {
        guard let ingredients = recipe.ingredients else { return false }
        return !ingredients.allObjects.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                recipeHeaderSection
                
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    timingSection
                }
                
                usageAnalyticsSection
                
                if hasIngredients {
                    ingredientsSection
                }
                
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
            ToolbarItem(placement: .navigationBarTrailing) {
                // M3 PHASE 4: Enhanced toolbar with Menu
                Menu {
                    Button {
                        showingMarkUsedConfirmation = true
                    } label: {
                        Label("Mark as Used", systemImage: "checkmark.circle")
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Recipe", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    // M3 PHASE 4: Scale Recipe Button
                    Button {
                        showingScalingSheet = true
                    } label: {
                        Label("Scale Recipe", systemImage: "slider.horizontal.3")
                    }
                    .disabled(!hasIngredients)
                    
                    Divider()
                    
                    Button {
                        showingAddToListSheet = true
                    } label: {
                        Label("Add to Shopping List", systemImage: "cart.badge.plus")
                    }
                    .disabled(!hasIngredients)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddToListSheet) {
            AddIngredientsToListView(recipe: recipe)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: recipe, context: viewContext)
        }
        // M3 PHASE 4: Recipe Scaling Sheet
        .sheet(isPresented: $showingScalingSheet) {
            NavigationStack {
                RecipeScalingView(
                    recipe: recipe,
                    scalingService: scalingService
                )
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
    
    // MARK: - View Components
    
    private var recipeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recipe.title ?? "Untitled Recipe")
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
    
    // M3: Updated to use displayText instead of quantity
    private func ingredientRowView(ingredient: Ingredient) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.secondary.opacity(0.6))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name ?? "Unknown Ingredient")
                    .font(.body)
                    .foregroundColor(.primary)
                
                // M3: Use displayText instead of quantity
                if let displayText = ingredient.displayText?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !displayText.isEmpty {
                    Text(displayText)
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
        RecipeListView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
