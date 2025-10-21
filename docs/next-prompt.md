# Next Prompt: M3.5 Phase 1 - Data Model Validation

**Copy-paste this prompt to begin M3.5 Phase 1 implementation.**

---

# START M3.5 PHASE 1: DATA MODEL VALIDATION

## Context
We're implementing M3.5 Foundation Hardening to validate our data model before M4 meal planning complexity. This phase adds Core Data validation rules to all entities to prevent bad data from ever being saved.

**Current State:**
- M3 Complete ✅ - All structured quantity features operational
- No known data quality issues
- All existing data should pass validation (need to verify)
- Pre-production app - can make breaking changes if needed

**Goal:** Add comprehensive validation to Recipe, Ingredient, IngredientTemplate, and GroceryListItem entities.

---

## Phase 1 Implementation Plan (3-4 hours)

### Task 1: Recipe Entity Validation (60 minutes)

**Step 1: Review Current Recipe Entity (10 min)**
Search project knowledge for:
- Current Recipe+CoreDataProperties.swift
- All Recipe attributes and their types
- Current validation (if any exists)

**Step 2: Implement Recipe Validation (35 min)**

Create validation extension in `Recipe+CoreDataClass.swift`:
```swift
extension Recipe {
    // MARK: - Validation
    
    override public func validateForInsert() throws {
        try super.validateForInsert()
        try validateRecipeData()
    }
    
    override public func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateRecipeData()
    }
    
    private func validateRecipeData() throws {
        try validateTitle()
        try validateServings()
        try validateTimes()
        try validateInstructions()
    }
    
    private func validateTitle() throws {
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            throw ValidationError.emptyTitle
        }
        
        guard title.count >= 3 else {
            throw ValidationError.titleTooShort
        }
        
        guard title.count <= 100 else {
            throw ValidationError.titleTooLong
        }
    }
    
    private func validateServings() throws {
        guard servings >= 1 else {
            throw ValidationError.invalidServings
        }
        
        guard servings <= 99 else {
            throw ValidationError.servingsTooLarge
        }
    }
    
    private func validateTimes() throws {
        guard prepTime >= 0 && cookTime >= 0 else {
            throw ValidationError.negativeTimes
        }
        
        guard prepTime <= 1440 && cookTime <= 1440 else {
            throw ValidationError.timesTooLarge
        }
    }
    
    private func validateInstructions() throws {
        guard let instructions = instructions?.trimmingCharacters(in: .whitespacesAndNewlines),
              !instructions.isEmpty else {
            throw ValidationError.emptyInstructions
        }
        
        guard instructions.count <= 5000 else {
            throw ValidationError.instructionsTooLong
        }
    }
}
```

**Step 3: Create ValidationError Enum (10 min)**

Create new file `GroceryRecipeManager/ValidationError.swift`:
```swift
import Foundation

enum ValidationError: LocalizedError {
    // Recipe errors
    case emptyTitle
    case titleTooShort
    case titleTooLong
    case invalidServings
    case servingsTooLarge
    case negativeTimes
    case timesTooLarge
    case emptyInstructions
    case instructionsTooLong
    
    // Ingredient errors
    case emptyIngredientName
    case emptyDisplayText
    case invalidNumericValue
    case invalidConfidence
    case missingTemplate
    
    // Template errors
    case emptyTemplateName
    case duplicateTemplateName
    case emptyCategory
    case invalidUsageCount
    
    // Grocery list item errors
    case emptyItemName
    case emptyItemDisplayText
    case invalidItemQuantity
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Recipe title cannot be empty"
        case .titleTooShort:
            return "Recipe title must be at least 3 characters"
        case .titleTooLong:
            return "Recipe title cannot exceed 100 characters"
        case .invalidServings:
            return "Servings must be at least 1"
        case .servingsTooLarge:
            return "Servings cannot exceed 99"
        case .negativeTimes:
            return "Prep and cook times cannot be negative"
        case .timesTooLarge:
            return "Times cannot exceed 24 hours (1440 minutes)"
        case .emptyInstructions:
            return "Recipe instructions cannot be empty"
        case .instructionsTooLong:
            return "Instructions cannot exceed 5000 characters"
        case .emptyIngredientName:
            return "Ingredient name cannot be empty"
        case .emptyDisplayText:
            return "Ingredient display text cannot be empty"
        case .invalidNumericValue:
            return "Parseable ingredients must have positive numeric value"
        case .invalidConfidence:
            return "Parse confidence must be between 0.0 and 1.0"
        case .missingTemplate:
            return "Ingredient must be linked to a template"
        case .emptyTemplateName:
            return "Template name cannot be empty"
        case .emptyCategory:
            return "Template must have a category assigned"
        case .invalidUsageCount:
            return "Usage count cannot be negative"
        case .emptyItemName:
            return "Grocery item name cannot be empty"
        case .emptyItemDisplayText:
            return "Grocery item display text cannot be empty"
        case .invalidItemQuantity:
            return "Grocery item quantity is invalid"
        default:
            return "Validation error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyTitle:
            return "Please enter a title for your recipe"
        case .titleTooShort:
            return "Please enter a longer title (at least 3 characters)"
        case .titleTooLong:
            return "Please shorten your title to 100 characters or less"
        case .invalidServings:
            return "Please enter a number of servings (1-99)"
        case .servingsTooLarge:
            return "Please enter a smaller number of servings (1-99)"
        case .negativeTimes:
            return "Please enter positive time values"
        case .timesTooLarge:
            return "Please enter times less than 24 hours"
        case .emptyInstructions:
            return "Please add instructions for your recipe"
        case .instructionsTooLong:
            return "Please shorten your instructions to 5000 characters or less"
        case .emptyIngredientName:
            return "Please provide an ingredient name"
        case .emptyDisplayText:
            return "Ingredient must have display text"
        case .invalidNumericValue:
            return "Please ensure parseable ingredients have valid quantities"
        case .invalidConfidence:
            return "System error: Invalid confidence score"
        case .missingTemplate:
            return "System error: Ingredient must be linked to template"
        case .emptyTemplateName:
            return "Template must have a name"
        case .emptyCategory:
            return "Please assign a category to this ingredient"
        case .invalidUsageCount:
            return "System error: Invalid usage count"
        case .emptyItemName:
            return "Please provide a name for this grocery item"
        case .emptyItemDisplayText:
            return "Grocery item must have display text"
        case .invalidItemQuantity:
            return "Please check the quantity value"
        default:
            return "Please check your input and try again"
        }
    }
}
```

**Step 4: Test Recipe Validation (5 min)**
1. Build project - ensure no errors
2. Test creating invalid recipe in simulator
3. Verify error messages appear correctly
4. Test valid recipe still saves

---

### Task 2: Ingredient Entity Validation (45 minutes)

**Step 1: Review Current Ingredient Entity (5 min)**
Search for Ingredient+CoreDataProperties.swift and review fields

**Step 2: Implement Ingredient Validation (30 min)**

Add to `Ingredient+CoreDataClass.swift`:
```swift
extension Ingredient {
    // MARK: - Validation
    
    override public func validateForInsert() throws {
        try super.validateForInsert()
        try validateIngredientData()
    }
    
    override public func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateIngredientData()
    }
    
    private func validateIngredientData() throws {
        try validateName()
        try validateDisplayText()
        try validateQuantityData()
        try validateTemplate()
    }
    
    private func validateName() throws {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            throw ValidationError.emptyIngredientName
        }
    }
    
    private func validateDisplayText() throws {
        guard let displayText = displayText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !displayText.isEmpty else {
            throw ValidationError.emptyDisplayText
        }
    }
    
    private func validateQuantityData() throws {
        // If parseable, must have valid numeric value
        if isParseable {
            guard numericValue > 0 else {
                throw ValidationError.invalidNumericValue
            }
        }
        
        // Confidence must be in valid range
        guard parseConfidence >= 0.0 && parseConfidence <= 1.0 else {
            throw ValidationError.invalidConfidence
        }
    }
    
    private func validateTemplate() throws {
        guard ingredientTemplate != nil else {
            throw ValidationError.missingTemplate
        }
    }
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        do {
            try validateIngredientData()
            return true
        } catch {
            return false
        }
    }
}
```

**Step 3: Test Ingredient Validation (10 min)**
1. Build project
2. Create ingredient through recipe creation
3. Verify validation works
4. Test edge cases (empty name, no template, etc.)

---

### Task 3: IngredientTemplate Entity Validation (30 minutes)

**Step 1: Review Current Template Entity (5 min)**

**Step 2: Implement Template Validation (20 min)**

Add to `IngredientTemplate+CoreDataClass.swift` (or create if doesn't exist):
```swift
extension IngredientTemplate {
    // MARK: - Validation
    
    override public func validateForInsert() throws {
        try super.validateForInsert()
        try validateTemplateData()
    }
    
    override public func validateForUpdate() throws {
        try super.validateForUpdate()
        try validateTemplateData()
    }
    
    private func validateTemplateData() throws {
        try validateName()
        try validateCategory()
        try validateUsageCount()
    }
    
    private func validateName() throws {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            throw ValidationError.emptyTemplateName
        }
    }
    
    private func validateCategory() throws {
        guard let category = category?.trimmingCharacters(in: .whitespacesAndNewlines),
              !category.isEmpty else {
            throw ValidationError.emptyCategory
        }
    }
    
    private func validateUsageCount() throws {
        guard usageCount >= 0 else {
            throw ValidationError.invalidUsageCount
        }
    }
    
    // MARK: - Computed Properties
    
    var hasValidCategory: Bool {
        guard let category = category else { return false }
        return !category.isEmpty
    }
    
    var isUncategorized: Bool {
        return category?.lowercased() == "uncategorized"
    }
}
```

**Step 3: Test Template Validation (5 min)**

---

### Task 4: Add Computed Properties (45 minutes)

**Recipe Computed Properties:**

Add to `Recipe+CoreDataClass.swift`:
```swift
extension Recipe {
    // MARK: - Computed Properties
    
    var hasValidIngredients: Bool {
        guard let ingredients = ingredients as? Set<Ingredient> else { return false }
        return !ingredients.isEmpty && ingredients.allSatisfy { $0.isValid }
    }
    
    var totalTime: Int32 {
        return prepTime + cookTime
    }
    
    var ingredientCount: Int {
        return (ingredients as? Set<Ingredient>)?.count ?? 0
    }
    
    var formattedTotalTime: String {
        let hours = totalTime / 60
        let minutes = totalTime % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}
```

**Update UI to use computed properties where beneficial** (optional, can be done later)

---

### Task 5: Validation Testing (30 minutes)

**Step 1: Create Test Scenarios (10 min)**
Document test cases:
- Valid recipe with all fields
- Invalid recipes (empty title, bad servings, etc.)
- Valid/invalid ingredients
- Valid/invalid templates

**Step 2: Manual Testing (15 min)**
1. Test recipe creation with validation
2. Test editing existing recipes
3. Test ingredient parsing and validation
4. Test template validation
5. Verify error messages are clear

**Step 3: Run Against Existing Data (5 min)**

Create a simple test in your app or run in debug console:
```swift
// Test helper to validate all existing data
func validateAllExistingData() {
    let context = PersistenceController.shared.container.viewContext
    
    // Test all recipes
    let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    do {
        let recipes = try context.fetch(recipeRequest)
        print("📊 Testing \(recipes.count) recipes...")
        
        for recipe in recipes {
            do {
                try recipe.validateForUpdate()
                print("✅ Recipe '\(recipe.title ?? "Unknown")' is valid")
            } catch {
                print("❌ Recipe '\(recipe.title ?? "Unknown")' validation failed: \(error.localizedDescription)")
            }
        }
    } catch {
        print("❌ Error fetching recipes: \(error)")
    }
    
    // Test all templates
    let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    do {
        let templates = try context.fetch(templateRequest)
        print("📊 Testing \(templates.count) templates...")
        
        for template in templates {
            do {
                try template.validateForUpdate()
                print("✅ Template '\(template.name ?? "Unknown")' is valid")
            } catch {
                print("❌ Template '\(template.name ?? "Unknown")' validation failed: \(error.localizedDescription)")
            }
        }
    } catch {
        print("❌ Error fetching templates: \(error)")
    }
    
    // Test all ingredients
    let ingredientRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
    do {
        let ingredients = try context.fetch(ingredientRequest)
        print("📊 Testing \(ingredients.count) ingredients...")
        
        var validCount = 0
        var invalidCount = 0
        
        for ingredient in ingredients {
            do {
                try ingredient.validateForUpdate()
                validCount += 1
            } catch {
                invalidCount += 1
                print("❌ Ingredient '\(ingredient.name ?? "Unknown")' validation failed: \(error.localizedDescription)")
            }
        }
        
        print("📊 Ingredients: \(validCount) valid, \(invalidCount) invalid")
    } catch {
        print("❌ Error fetching ingredients: \(error)")
    }
}
```

---

## Acceptance Criteria Checklist

- [ ] Recipe entity has complete validation
- [ ] Ingredient entity has complete validation
- [ ] IngredientTemplate entity has complete validation
- [ ] GroceryListItem entity has complete validation (optional for Phase 1)
- [ ] ValidationError enum with clear messages
- [ ] Computed properties added to entities
- [ ] All validation tests passing
- [ ] Zero validation errors on existing data
- [ ] Error messages are clear and helpful
- [ ] Performance not degraded (< 0.1s validation)
- [ ] Build successful with zero errors
- [ ] Documentation updated

---

## Expected Challenges & Solutions

### Challenge 1: Existing Data Violations
**If found**: Document violations, create migration script
**Solution**: Add to validation exceptions temporarily, fix in migration

### Challenge 2: Performance Impact
**If validation slows saves**: Optimize validation checks
**Solution**: Cache expensive checks, use lazy evaluation

### Challenge 3: Unclear Error Messages
**If users confused**: Improve errorDescription and recoverySuggestion
**Solution**: Test with actual error scenarios, refine messages

---

## Next Steps After Phase 1

Once Phase 1 is complete:
1. Update `docs/current-story.md` with Phase 1 completion
2. Document any findings in learning notes
3. Begin Phase 2: Parsing Enhancement & Testing
4. Update `docs/next-prompt.md` for Phase 2

---

## Questions to Answer During Implementation

1. Do any existing recipes/ingredients/templates violate new rules?
2. Are validation error messages clear enough?
3. Does validation impact save performance?
4. Should validation be stricter or more lenient?
5. Are computed properties used correctly in UI?

---

**Ready to Start**: Begin with Task 1, Step 1 - Review Recipe Entity

**Estimated Session Time**: 3-4 hours for complete Phase 1