//
//  ComputedPropertiesTests.swift
//  GroceryRecipeManager
//
//  Created for M3.5 Phase 1 Task 4: Computed Properties Testing
//  Date: October 22, 2025
//
//  Purpose: Test function for computed properties - call from Settings
//

import Foundation
import CoreData

/// Run comprehensive tests of Recipe and Ingredient computed properties
/// Call this from Settings → Developer Tools → "M3.5 Computed Properties"
func runComputedPropertiesTests(context: NSManagedObjectContext) {
    print("\n" + String(repeating: "=", count: 60))
    print("🧪 M3.5 COMPUTED PROPERTIES TEST")
    print(String(repeating: "=", count: 60) + "\n")
    
    // Test Recipe Properties
    testRecipeComputedProperties(context: context)
    
    // Test Ingredient Properties
    testIngredientComputedProperties(context: context)
    
    print("\n" + String(repeating: "=", count: 60))
    print("✅ COMPUTED PROPERTIES TEST COMPLETE")
    print(String(repeating: "=", count: 60) + "\n")
}

// MARK: - Recipe Computed Properties Tests

private func testRecipeComputedProperties(context: NSManagedObjectContext) {
    print("📗 RECIPE COMPUTED PROPERTIES")
    print(String(repeating: "-", count: 60))
    
    let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    fetchRequest.fetchLimit = 3
    
    do {
        let recipes = try context.fetch(fetchRequest)
        
        if recipes.isEmpty {
            print("⚠️  No recipes found - creating test recipe...")
            let testRecipe = createTestRecipe(context: context)
            try context.save()
            testRecipeProperties(testRecipe)
        } else {
            print("✅ Found \(recipes.count) recipe(s) to test\n")
            for (index, recipe) in recipes.enumerated() {
                print("Recipe \(index + 1):")
                testRecipeProperties(recipe)
                print("")
            }
        }
    } catch {
        print("❌ Error fetching recipes: \(error)")
    }
}

private func testRecipeProperties(_ recipe: Recipe) {
    // Display Properties
    print("  recipeDisplayTitle: '\(recipe.recipeDisplayTitle)'")
    print("  recipeListDisplayTitle: '\(recipe.recipeListDisplayTitle)'")
    print("  recipeServingsDescription: '\(recipe.recipeServingsDescription)'")
    
    // Timing Properties
    if recipe.hasRecipeTiming {
        print("  recipeFormattedPrepTime: '\(recipe.recipeFormattedPrepTime)'")
        print("  recipeFormattedCookTime: '\(recipe.recipeFormattedCookTime)'")
        print("  recipeFormattedTotalTime: '\(recipe.recipeFormattedTotalTime)'")
        print("  recipeTotalTime: \(recipe.recipeTotalTime) minutes")
    } else {
        print("  (No timing information)")
    }
    
    // Usage Properties
    print("  recipeUsageDescription: '\(recipe.recipeUsageDescription)'")
    print("  recipeLastUsedDescription: '\(recipe.recipeLastUsedDescription)'")
    print("  isFrequentlyUsedRecipe: \(recipe.isFrequentlyUsedRecipe)")
    print("  wasRecipeUsedRecently: \(recipe.wasRecipeUsedRecently)")
    print("  isNewRecipe: \(recipe.isNewRecipe)")
    
    // Ingredient Properties
    print("  recipeIngredientCount: \(recipe.recipeIngredientCount)")
    print("  recipeIngredientCountDescription: '\(recipe.recipeIngredientCountDescription)'")
    print("  recipeAllIngredientsHaveTemplates: \(recipe.recipeAllIngredientsHaveTemplates)")
    
    // Validation Properties
    print("  hasBasicRecipeInfo: \(recipe.hasBasicRecipeInfo)")
    print("  hasValidRecipeIngredients: \(recipe.hasValidRecipeIngredients)")
    print("  hasRecipeInstructions: \(recipe.hasRecipeInstructions)")
    print("  isCompleteRecipe: \(recipe.isCompleteRecipe)")
    
    // Tags Properties
    if recipe.hasRecipeTags {
        print("  recipeTags: \(recipe.recipeTags)")
        print("  recipeTagsDescription: '\(recipe.recipeTagsDescription)'")
    }
    
    // Search
    let searchable = recipe.recipeSearchableText
    let preview = searchable.count > 50 ? String(searchable.prefix(50)) + "..." : searchable
    print("  recipeSearchableText: '\(preview)'")
}

private func createTestRecipe(context: NSManagedObjectContext) -> Recipe {
    let recipe = Recipe(context: context)
    recipe.id = UUID()
    recipe.title = "Test Chocolate Chip Cookies"
    recipe.servings = 24
    recipe.prepTime = 15
    recipe.cookTime = 10
    recipe.instructions = "1. Preheat oven\n2. Mix ingredients\n3. Bake"
    recipe.usageCount = 3
    recipe.lastUsed = Calendar.current.date(byAdding: .day, value: -5, to: Date())
    recipe.dateCreated = Date()
    recipe.isFavorite = false
    
    // Add test ingredient
    let ingredient = Ingredient(context: context)
    ingredient.id = UUID()
    ingredient.name = "all-purpose flour"
    ingredient.displayText = "2 cups"
    ingredient.sortOrder = 0
    ingredient.recipe = recipe
    ingredient.numericValue = 2.0
    ingredient.standardUnit = "cups"
    ingredient.isParseable = true
    ingredient.parseConfidence = 0.95
    
    return recipe
}

// MARK: - Ingredient Computed Properties Tests

private func testIngredientComputedProperties(context: NSManagedObjectContext) {
    print("\n📘 INGREDIENT COMPUTED PROPERTIES")
    print(String(repeating: "-", count: 60))
    
    let fetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
    fetchRequest.fetchLimit = 5
    
    do {
        let ingredients = try context.fetch(fetchRequest)
        
        if ingredients.isEmpty {
            print("⚠️  No ingredients found")
        } else {
            print("✅ Found \(ingredients.count) ingredient(s) to test\n")
            for (index, ingredient) in ingredients.enumerated() {
                print("Ingredient \(index + 1):")
                testIngredientProperties(ingredient)
                print("")
            }
        }
    } catch {
        print("❌ Error fetching ingredients: \(error)")
    }
}

private func testIngredientProperties(_ ingredient: Ingredient) {
    // Display Properties
    print("  ingredientDisplayName: '\(ingredient.ingredientDisplayName)'")
    print("  bestIngredientDisplayText: '\(ingredient.bestIngredientDisplayText)'")
    print("  ingredientDisplayCategoryName: '\(ingredient.ingredientDisplayCategoryName)'")
    print("  ingredientDisplayTemplateName: '\(ingredient.ingredientDisplayTemplateName)'")
    
    // Quantity Properties
    if ingredient.isParseable {
        print("  ingredientFormattedQuantity: '\(ingredient.ingredientFormattedQuantity)'")
        print("  ingredientQuantityDescription: '\(ingredient.ingredientQuantityDescription)'")
        print("  ingredientConfidenceDescription: '\(ingredient.ingredientConfidenceDescription)'")
        print("  ingredientQuantityStatusEmoji: '\(ingredient.ingredientQuantityStatusEmoji)'")
    } else {
        print("  (Not parsed)")
    }
    
    // Validation Properties
    print("  hasIngredientName: \(ingredient.hasIngredientName)")
    print("  hasIngredientTemplate: \(ingredient.hasIngredientTemplate)")
    print("  hasIngredientCategory: \(ingredient.hasIngredientCategory)")
    print("  hasStructuredQuantity: \(ingredient.hasStructuredQuantity)")
    print("  isValidIngredient: \(ingredient.isValidIngredient)")
    
    // Recipe Relationship
    if ingredient.ingredientRecipeTitle != nil {
        print("  ingredientDisplayRecipeTitle: '\(ingredient.ingredientDisplayRecipeTitle)'")
    }
    
    // Sorting
    print("  ingredientCategorySortKey: '\(ingredient.ingredientCategorySortKey)'")
    print("  ingredientRecipeSortKey: '\(ingredient.ingredientRecipeSortKey)'")
    
    // Search
    let searchable = ingredient.ingredientSearchableText
    let preview = searchable.count > 50 ? String(searchable.prefix(50)) + "..." : searchable
    print("  ingredientSearchableText: '\(preview)'")
}
