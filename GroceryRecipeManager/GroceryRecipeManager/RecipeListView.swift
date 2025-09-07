//
//  RecipeListView.swift
//  GroceryRecipeManager
//
//  Created on September 7, 2025
//  MILESTONE 2 - Phase 2: Recipe Core Development
//  Story 2.1: Recipe Catalog Foundation - Step 1: Basic RecipeListView
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
        print("📝 Add Recipe tapped - Creating sample recipe for Step 1 testing")
        
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

// MARK: - Simple Recipe Detail View (for Step 1)

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(recipe.title ?? "Untitled Recipe")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if recipe.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                    
                    if let dateCreated = recipe.dateCreated {
                        Text("Added \(dateCreated, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Recipe timing (non-optional Int16 values)
                HStack(spacing: 20) {
                    if recipe.servings > 0 {
                        Label("\(recipe.servings) servings", systemImage: "person.2")
                    }
                    
                    if recipe.prepTime > 0 {
                        Label("\(recipe.prepTime) min prep", systemImage: "clock")
                    }
                    
                    Spacer()
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Instructions
                if let instructions = recipe.instructions, !instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text(instructions)
                            .font(.body)
                    }
                }
                
                // Usage analytics (Step 6 foundation)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Usage Statistics")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Times Used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(recipe.usageCount)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        if let lastUsed = recipe.lastUsed {
                            VStack(alignment: .trailing) {
                                Text("Last Used")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(lastUsed, style: .date)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    print("📝 Edit Recipe tapped - Recipe editing coming in Story 2.2")
                }
            }
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
