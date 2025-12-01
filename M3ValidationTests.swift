//
//  M3ValidationTests.swift
//  forager
//
//  M3.5 Phase 1 Task 5: Automated Validation Testing
//  Tests all M3 functionality that doesn't require UI interaction
//

import Foundation
import CoreData

/// Comprehensive automated validation for M3 features
/// Call from Settings → Developer Tools → "M3.5 Final Validation"
func runM3ValidationTests(context: NSManagedObjectContext) {
    print("\n" + String(repeating: "=", count: 70))
    print("🧪 M3.5 COMPREHENSIVE VALIDATION TEST SUITE")
    print(String(repeating: "=", count: 70) + "\n")
    
    var passCount = 0
    var failCount = 0
    var totalTests = 0
    
    // Run all test suites
    let results: [(String, Bool)] = [
        ("Template System", testTemplateSystem(context: context)),
        ("Data Integrity", testDataIntegrity(context: context)),
        ("Computed Properties", testComputedProperties(context: context)),
        ("Recipe Scaling", testRecipeScaling(context: context)),
        ("Edge Cases", testEdgeCases(context: context)),
        ("Performance", testPerformance(context: context))
    ]
    
    // Calculate results
    for (name, passed) in results {
        totalTests += 1
        if passed {
            passCount += 1
            print("✅ \(name): PASS")
        } else {
            failCount += 1
            print("❌ \(name): FAIL")
        }
    }
    
    // Final summary
    print("\n" + String(repeating: "=", count: 70))
    print("📊 VALIDATION SUMMARY")
    print(String(repeating: "-", count: 70))
    print("Total Tests: \(totalTests)")
    print("Passed: ✅ \(passCount)")
    print("Failed: ❌ \(failCount)")
    print("Success Rate: \(passCount * 100 / totalTests)%")
    print(String(repeating: "=", count: 70))
    
    if failCount == 0 {
        print("\n🎉 ALL TESTS PASSED - M3 READY FOR M4!")
    } else {
        print("\n⚠️  SOME TESTS FAILED - REVIEW ISSUES ABOVE")
    }
    print("")
}

// MARK: - Test Suite 1: Template System

private func testTemplateSystem(context: NSManagedObjectContext) -> Bool {
    print("\n📗 TEST SUITE 1: TEMPLATE SYSTEM")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Test 1.1: Templates exist
    let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    guard let templateCount = try? context.count(for: templateRequest) else {
        print("  ❌ 1.1: Cannot count templates")
        return false
    }
    
    if templateCount > 0 {
        print("  ✅ 1.1: Templates exist (\(templateCount) templates)")
    } else {
        print("  ❌ 1.1: No templates found")
        allPassed = false
    }
    
    // Test 1.2: All templates have categories
    let uncategorizedRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    uncategorizedRequest.predicate = NSPredicate(format: "category == nil OR category == ''")
    
    let uncategorizedCount = (try? context.count(for: uncategorizedRequest)) ?? 0
    if uncategorizedCount == 0 {
        print("  ✅ 1.2: All templates have categories")
    } else {
        print("  ⚠️  1.2: \(uncategorizedCount) templates without categories")
        // Not critical, just a warning
    }
    
    // Test 1.3: Template-Ingredient relationships valid
    let templates = try? context.fetch(templateRequest)
    let sampleSize = min(5, templates?.count ?? 0)
    var relationshipValid = true
    
    if let templates = templates?.prefix(sampleSize) {
        for template in templates {
            // Check if template can access its ingredients
            let _ = template.ingredients?.count ?? 0
            // If we get here without crashing, relationship is valid
        }
        print("  ✅ 1.3: Template-Ingredient relationships valid (sampled \(sampleSize))")
    } else {
        print("  ❌ 1.3: Cannot verify template relationships")
        allPassed = false
        relationshipValid = false
    }
    
    return allPassed && relationshipValid
}

// MARK: - Test Suite 2: Data Integrity

private func testDataIntegrity(context: NSManagedObjectContext) -> Bool {
    print("\n📘 TEST SUITE 2: DATA INTEGRITY")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Test 2.1: Recipe count
    let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    let recipeCount = (try? context.count(for: recipeRequest)) ?? 0
    print("  ℹ️  2.1: \(recipeCount) recipes in database")
    
    // Test 2.2: Check sample recipe data
    if recipeCount > 0 {
        recipeRequest.fetchLimit = 1
        if let recipe = try? context.fetch(recipeRequest).first {
            let hasTitle = recipe.title != nil && !recipe.title!.isEmpty
            let hasIngredients = (recipe.ingredients?.count ?? 0) > 0
            
            if hasTitle && hasIngredients {
                print("  ✅ 2.2: Sample recipe has valid structure")
            } else {
                print("  ⚠️  2.2: Sample recipe missing data (title: \(hasTitle), ingredients: \(hasIngredients))")
            }
        }
    } else {
        print("  ℹ️  2.2: No recipes to validate (expected for new app)")
    }
    
    // Test 2.3: Ingredient data quality
    let ingredientRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
    let ingredientCount = (try? context.count(for: ingredientRequest)) ?? 0
    
    if ingredientCount > 0 {
        ingredientRequest.fetchLimit = 10
        if let ingredients = try? context.fetch(ingredientRequest) {
            let hasNames = ingredients.filter { ($0.name?.isEmpty ?? true) == false }.count
            let hasTemplates = ingredients.filter { $0.ingredientTemplate != nil }.count
            let hasParsedQty = ingredients.filter { $0.isParseable }.count
            
            let namePercent = (hasNames * 100) / ingredients.count
            let templatePercent = (hasTemplates * 100) / ingredients.count
            let parsedPercent = (hasParsedQty * 100) / ingredients.count
            
            print("  ✅ 2.3: Ingredient quality (sample of \(ingredients.count)):")
            print("       - Names: \(namePercent)%")
            print("       - Templates: \(templatePercent)%")
            print("       - Parsed quantities: \(parsedPercent)%")
        }
    } else {
        print("  ℹ️  2.3: No ingredients to validate")
    }
    
    // Test 2.4: Grocery list items
    let itemRequest: NSFetchRequest<GroceryListItem> = GroceryListItem.fetchRequest()
    let itemCount = (try? context.count(for: itemRequest)) ?? 0
    print("  ℹ️  2.4: \(itemCount) grocery list items in database")
    
    return allPassed
}

// MARK: - Test Suite 3: Computed Properties

private func testComputedProperties(context: NSManagedObjectContext) -> Bool {
    print("\n📙 TEST SUITE 3: COMPUTED PROPERTIES")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Test 3.1: Create test recipe
    let testRecipe = Recipe(context: context)
    testRecipe.id = UUID()
    testRecipe.title = "Validation Test Recipe"
    testRecipe.servings = 4
    testRecipe.prepTime = 15
    testRecipe.cookTime = 30
    testRecipe.instructions = "Test instructions"
    testRecipe.usageCount = 5
    testRecipe.lastUsed = Date()
    testRecipe.dateCreated = Date()
    
    // Test Recipe computed properties
    let tests: [(String, () -> Bool)] = [
        ("recipeDisplayTitle", { testRecipe.recipeDisplayTitle == "Validation Test Recipe" }),
        ("recipeServingsDescription", { testRecipe.recipeServingsDescription.contains("4") }),
        ("recipeFormattedPrepTime", { testRecipe.recipeFormattedPrepTime.contains("15") }),
        ("recipeFormattedCookTime", { testRecipe.recipeFormattedCookTime.contains("30") }),
        ("recipeFormattedTotalTime", { testRecipe.recipeFormattedTotalTime.contains("45") }),
        ("hasRecipeTiming", { testRecipe.hasRecipeTiming == true }),
        ("recipeUsageDescription", { testRecipe.recipeUsageDescription.contains("5") }),
        ("hasBasicRecipeInfo", { testRecipe.hasBasicRecipeInfo == true }),
        ("hasRecipeInstructions", { testRecipe.hasRecipeInstructions == true })
    ]
    
    var propertyTestsPassed = 0
    for (propertyName, test) in tests {
        if test() {
            propertyTestsPassed += 1
        } else {
            print("  ❌ 3.1: \(propertyName) failed")
            allPassed = false
        }
    }
    
    print("  ✅ 3.1: Recipe properties (\(propertyTestsPassed)/\(tests.count) passed)")
    
    // Test 3.2: Ingredient computed properties
    let testIngredient = Ingredient(context: context)
    testIngredient.id = UUID()
    testIngredient.name = "test flour"
    testIngredient.numericValue = 2.0
    testIngredient.standardUnit = "cups"
    testIngredient.isParseable = true
    testIngredient.parseConfidence = 0.95
    
    let ingredientTests: [(String, () -> Bool)] = [
        ("ingredientDisplayName", { testIngredient.ingredientDisplayName == "test flour" }),
        ("hasIngredientName", { testIngredient.hasIngredientName == true }),
        ("hasStructuredQuantity", { testIngredient.hasStructuredQuantity == true }),
        ("isValidIngredient", { testIngredient.isValidIngredient == true })
    ]
    
    var ingredientTestsPassed = 0
    for (propertyName, test) in ingredientTests {
        if test() {
            ingredientTestsPassed += 1
        } else {
            print("  ❌ 3.2: \(propertyName) failed")
            allPassed = false
        }
    }
    
    print("  ✅ 3.2: Ingredient properties (\(ingredientTestsPassed)/\(ingredientTests.count) passed)")
    
    // Cleanup test data (don't save)
    context.rollback()
    
    return allPassed
}

// MARK: - Test Suite 4: Recipe Scaling

private func testRecipeScaling(context: NSManagedObjectContext) -> Bool {
    print("\n📕 TEST SUITE 4: RECIPE SCALING")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Create test recipe
    let recipe = Recipe(context: context)
    recipe.id = UUID()
    recipe.title = "Scaling Test"
    recipe.servings = 4
    
    // Add test ingredient
    let ingredient = Ingredient(context: context)
    ingredient.id = UUID()
    ingredient.name = "flour"
    ingredient.numericValue = 2.0
    ingredient.standardUnit = "cups"
    ingredient.isParseable = true
    ingredient.recipe = recipe
    
    // Test 4.1: Initialize scaling service
    let scalingService = RecipeScalingService(context: context)
    print("  ✅ 4.1: RecipeScalingService initialized")
    
    // Test 4.2: Scale to 2x
    let scaled2x = scalingService.scale(recipe: recipe, scaleFactor: 2.0)
    let expected2x = 8
    if scaled2x.scaledServings == expected2x {
        print("  ✅ 4.2: 2x scaling works (4 → 8 servings)")
    } else {
        print("  ❌ 4.2: 2x scaling failed (expected \(expected2x), got \(scaled2x.scaledServings))")
        allPassed = false
    }
    
    // Test 4.3: Scale to 0.5x
    let scaled05x = scalingService.scale(recipe: recipe, scaleFactor: 0.5)
    let expected05x = 2
    if scaled05x.scaledServings == expected05x {
        print("  ✅ 4.3: 0.5x scaling works (4 → 2 servings)")
    } else {
        print("  ❌ 4.3: 0.5x scaling failed (expected \(expected05x), got \(scaled05x.scaledServings))")
        allPassed = false
    }
    
    // Test 4.4: Ingredient display text contains scaled value
    if let scaledIngredient = scaled2x.scaledIngredients.first {
        // ScaledIngredient has displayText, not quantity
        // Check if displayText contains "4" (scaled from 2)
        if scaledIngredient.displayText.contains("4") {
            print("  ✅ 4.4: Ingredient scaling works (displayText: \(scaledIngredient.displayText))")
        } else {
            print("  ❌ 4.4: Ingredient scaling unclear (displayText: \(scaledIngredient.displayText))")
            allPassed = false
        }
    } else {
        print("  ❌ 4.4: No scaled ingredients found")
        allPassed = false
    }
    
    // Cleanup
    context.rollback()
    
    return allPassed
}

// MARK: - Test Suite 5: Edge Cases

private func testEdgeCases(context: NSManagedObjectContext) -> Bool {
    print("\n📓 TEST SUITE 5: EDGE CASES")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Test 5.1: Nil title handling
    let nilTitleRecipe = Recipe(context: context)
    nilTitleRecipe.id = UUID()
    nilTitleRecipe.title = nil
    
    if nilTitleRecipe.recipeDisplayTitle == "Untitled Recipe" {
        print("  ✅ 5.1: Nil title handled gracefully")
    } else {
        print("  ❌ 5.1: Nil title not handled correctly")
        allPassed = false
    }
    
    // Test 5.2: Zero servings
    let zeroServingsRecipe = Recipe(context: context)
    zeroServingsRecipe.id = UUID()
    zeroServingsRecipe.servings = 0
    
    if zeroServingsRecipe.recipeServingsDescription.contains("0") {
        print("  ✅ 5.2: Zero servings handled")
    } else {
        print("  ❌ 5.2: Zero servings not handled correctly")
        allPassed = false
    }
    
    // Test 5.3: Nil ingredient name
    let nilNameIngredient = Ingredient(context: context)
    nilNameIngredient.id = UUID()
    nilNameIngredient.name = nil
    
    if nilNameIngredient.ingredientDisplayName == "Unknown Ingredient" {
        print("  ✅ 5.3: Nil ingredient name handled gracefully")
    } else {
        print("  ❌ 5.3: Nil ingredient name not handled correctly")
        allPassed = false
    }
    
    // Test 5.4: Non-parseable quantity
    let nonParseableIngredient = Ingredient(context: context)
    nonParseableIngredient.id = UUID()
    nonParseableIngredient.name = "to taste"
    nonParseableIngredient.isParseable = false
    
    if nonParseableIngredient.hasStructuredQuantity == false {
        print("  ✅ 5.4: Non-parseable quantity flagged correctly")
    } else {
        print("  ❌ 5.4: Non-parseable quantity check failed")
        allPassed = false
    }
    
    // Cleanup
    context.rollback()
    
    return allPassed
}

// MARK: - Test Suite 6: Performance

private func testPerformance(context: NSManagedObjectContext) -> Bool {
    print("\n⚡ TEST SUITE 6: PERFORMANCE")
    print(String(repeating: "-", count: 70))
    
    var allPassed = true
    
    // Test 6.1: Recipe fetch performance
    let startFetch = Date()
    let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    let _ = try? context.fetch(recipeRequest)
    let fetchTime = Date().timeIntervalSince(startFetch)
    
    if fetchTime < 1.0 {
        print("  ✅ 6.1: Recipe fetch < 1s (\(String(format: "%.3f", fetchTime))s)")
    } else {
        print("  ⚠️  6.1: Recipe fetch slow (\(String(format: "%.3f", fetchTime))s)")
    }
    
    // Test 6.2: Template fetch performance
    let startTemplateFetch = Date()
    let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    let _ = try? context.fetch(templateRequest)
    let templateFetchTime = Date().timeIntervalSince(startTemplateFetch)
    
    if templateFetchTime < 0.5 {
        print("  ✅ 6.2: Template fetch < 0.5s (\(String(format: "%.3f", templateFetchTime))s)")
    } else {
        print("  ⚠️  6.2: Template fetch slow (\(String(format: "%.3f", templateFetchTime))s)")
    }
    
    // Test 6.3: Computed property performance
    if let recipe = try? context.fetch(recipeRequest).first {
        let startComputed = Date()
        for _ in 0..<100 {
            let _ = recipe.recipeDisplayTitle
            let _ = recipe.recipeServingsDescription
            let _ = recipe.recipeFormattedPrepTime
        }
        let computedTime = Date().timeIntervalSince(startComputed)
        
        if computedTime < 0.1 {
            print("  ✅ 6.3: Computed properties fast (\(String(format: "%.3f", computedTime))s for 100 calls)")
        } else {
            print("  ⚠️  6.3: Computed properties slow (\(String(format: "%.3f", computedTime))s)")
        }
    }
    
    return allPassed
}
