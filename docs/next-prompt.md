# M3: Structured Quantity Management Development Prompt

**Copy and paste this prompt when ready to continue M3 implementation:**

---

I'm ready to continue **M3: Structured Quantity Management** for my Grocery & Recipe Manager iOS app.

## Current Status - M2 COMPLETE:
- **M1**: Professional Grocery Management successfully implemented (32 hours, Aug 2025)
- **M2.1**: Recipe Architecture Services successfully implemented (1 hour, Sep 7, 2025)
- **M2.2**: Recipe Catalog with 7 tasks successfully completed (10.5 hours, Sep 7-28, 2025)
- **M2.3**: Recipe Creation & Editing successfully completed (5 hours, Oct 4, 2025)

### **M2.3 Achievement Summary - COMPLETE:**

**Recipe Creation & Editing Success:**
- **Parse-Then-Autocomplete**: Intelligent ingredient matching with fuzzy search operational
- **Template Alignment**: 100% ingredient-to-template linking with READ-ONLY pattern enforced
- **Category Assignment**: Batch category assignment modal integration working
- **Core Data Transactions**: Proper save order (Templates → Ingredients → Recipe) validated
- **Unsaved Changes Protection**: Comprehensive discard confirmation implemented
- **Create and Edit Workflows**: Full recipe lifecycle management operational
- **Form Validation**: Complete validation preventing data integrity issues
- **Professional UI**: Time pickers, autocomplete dropdowns, native iOS patterns

**Technical Achievements:**
- **IngredientAutocompleteService**: Multi-pass search with fuzzy matching < 0.1s
- **RecipeFormData**: Comprehensive form state management with validation
- **CreateRecipeView**: Full-featured recipe creation with all requirements
- **EditRecipeView**: Recipe editing preserving data integrity
- **Transaction Management**: Single-save pattern with rollback on error

**Performance**: All operations maintaining sub-0.5s response times with proper Core Data management
**Recipe Management Complete**: Full create/read/update/delete lifecycle operational
**User Experience**: Professional forms with native iOS patterns and accessibility

## M3: STRUCTURED QUANTITY MANAGEMENT (8-12 hours)

### **Goal:**
Replace string-based quantity storage with structured numeric + unit fields, enabling recipe scaling, intelligent shopping consolidation, and analytics foundation with clean architecture.

### **Problem Statement:**
**Current State**: All quantities stored as separate string fields
- `Ingredient.quantity: String?` // "2", "1 1/2"
- `Ingredient.unit: String?` // "cups", "lbs"
- `GroceryListItem.quantity: String?` // "3", "a pinch"

**Limitations**:
- No mathematical operations: Cannot scale recipes or combine quantities
- No unit conversions or standardization
- Nutritional tracking and spending analysis impossible with string data
- No quantity-based intelligence features

**User Value Gap**: Users cannot scale recipes for different servings, shopping lists don't combine duplicate ingredients intelligently, and no foundation exists for nutrition or budget tracking

### **Solution Overview:**
Direct replacement of string quantity fields with structured data model, enabling mathematical operations while supporting both precise measurements ("2 cups") and imprecise descriptions ("a pinch").

### **Implementation Plan (8-12 hours total):**

#### **Phase 1: Core Data Model Updates (60-90 minutes)**

**Update Ingredient Entity:**
```swift
// REMOVE these fields:
quantity: String?    // "2", "1 1/2" 
unit: String?        // "cups", "lbs"

// ADD these fields:
numericValue: Double?     // 2.0, 1.5, nil for "a pinch"
standardUnit: String?     // "cup", "lb", "tsp" (standardized)
displayText: String       // "2 cups", "a pinch" (user-facing display)
isParseable: Bool         // true = can scale/merge, false = text only
parseConfidence: Float    // 0.0-1.0 (for future ML improvements)
```

**Update GroceryListItem Entity:**
```swift
// REMOVE:
quantity: String?

// ADD: Same structured fields as Ingredient
numericValue: Double?
standardUnit: String?
displayText: String
isParseable: Bool
parseConfidence: Float
```

**Core Data Tasks:**
- Open GroceryRecipeManager.xcdatamodeld in Xcode
- Update Ingredient entity: remove quantity/unit, add new fields
- Update GroceryListItem entity: remove quantity, add new fields
- Add fetch indexes for numericValue and standardUnit for performance
- Generate new NSManagedObject subclasses
- Verify build succeeds with new schema

#### **Phase 2: Enhanced Parsing Service (90-120 minutes)**

**Extend Existing IngredientParsingService:**

Current service already parses text into components. Enhance it to return structured data:

```swift
struct StructuredQuantity {
    let numericValue: Double?      // 2.0, 1.5, nil
    let standardUnit: String?      // "cup", "lb", nil
    let displayText: String        // "2 cups", "a pinch"
    let isParseable: Bool          // can this be used in math?
    let parseConfidence: Float     // 0.0-1.0
}

// NEW methods to add:
func convertToNumeric(_ quantity: String) -> Double? {
    // "2" → 2.0
    // "1 1/2" → 1.5  
    // "3/4" → 0.75
    // "a pinch" → nil
}

func standardizeUnit(_ unit: String?) -> String? {
    // "cups" → "cup"
    // "tablespoons"/"tbsp"/"T" → "tbsp"
    // "pounds"/"lbs" → "lb"
}

func parseToStructured(text: String) -> StructuredQuantity {
    // Use existing regex patterns
    // Convert quantity string to numeric
    // Standardize unit
    // Determine if parseable
    // Return structured result
}
```

**Unit Standardization Map:**
- Volume: cup/cups → "cup", tablespoon/tbsp/T → "tbsp", teaspoon/tsp/t → "tsp"
- Weight: pound/pounds/lb/lbs → "lb", ounce/ounces/oz → "oz"
- Metric: milliliter/ml → "ml", liter/l → "l", gram/g → "g", kilogram/kg → "kg"

#### **Phase 3: Data Migration Service (60 minutes)**

**One-Time Migration of Existing Data:**

```swift
class QuantityMigrationService {
    private let context: NSManagedObjectContext
    private let parsingService: IngredientParsingService
    
    func migrateAllQuantities() {
        // 1. Fetch all Ingredients
        let ingredients = fetchAllIngredients()
        
        for ingredient in ingredients {
            // 2. Parse old quantity + unit strings
            let oldText = "\(ingredient.quantity ?? "") \(ingredient.unit ?? "")"
            let structured = parsingService.parseToStructured(text: oldText)
            
            // 3. Write new structured fields
            ingredient.numericValue = structured.numericValue
            ingredient.standardUnit = structured.standardUnit
            ingredient.displayText = structured.displayText
            ingredient.isParseable = structured.isParseable
            ingredient.parseConfidence = structured.parseConfidence
        }
        
        // 4. Repeat for GroceryListItems
        // 5. Save context
        try? context.save()
    }
    
    func getMigrationPreview() -> MigrationSummary {
        // Show: X parseable, Y unparseable
        // User can review before committing
    }
}
```

**Migration UI:**
- Show preview: "85% quantities parsed successfully"
- List unparseable quantities for user review
- Allow manual corrections if needed
- One-time operation on first launch after update

#### **Phase 4: Recipe Scaling Service (90-120 minutes)**

**New Service for Mathematical Scaling:**

```swift
class RecipeScalingService {
    func scale(recipe: Recipe, factor: Double) -> ScaledRecipe {
        var scaledIngredients: [ScaledIngredient] = []
        
        for ingredient in recipe.ingredientsArray {
            if ingredient.isParseable, let value = ingredient.numericValue {
                // Scale parseable quantities
                let scaled = value * factor
                let newDisplay = formatScaled(scaled, unit: ingredient.standardUnit)
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient.name,
                    displayText: newDisplay,
                    wasScaled: true
                ))
            } else {
                // Keep unparseable with note
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient.name,
                    displayText: "\(ingredient.displayText) (adjust to taste for \(Int(factor))x servings)",
                    wasScaled: false
                ))
            }
        }
        
        return ScaledRecipe(
            title: recipe.title,
            servings: Int(Double(recipe.servings) * factor),
            ingredients: scaledIngredients
        )
    }
    
    func formatScaled(_ value: Double, unit: String?) -> String {
        // 1.33 cups → "1 1/3 cups"
        // 2.5 lbs → "2 1/2 lbs"
        // Smart fractional display
    }
}
```

**Scaling UI:**
- Recipe detail view: "Scale Recipe" button
- Slider or stepper for serving size adjustment
- Preview scaled quantities before applying
- Summary: "12 ingredients auto-scaled, 3 require manual adjustment"

#### **Phase 5: Quantity Merge Service (90-120 minutes)**

**Shopping List Consolidation:**

```swift
class QuantityMergeService {
    func merge(items: [GroceryListItem]) -> [MergedItem] {
        // 1. Group by ingredient name (using IngredientTemplate if available)
        let grouped = Dictionary(grouping: items) { $0.ingredientTemplate?.name ?? $0.name }
        
        var merged: [MergedItem] = []
        
        for (ingredientName, itemGroup) in grouped {
            // 2. Separate parseable from unparseable
            let parseable = itemGroup.filter { $0.isParseable }
            let unparseable = itemGroup.filter { !$0.isParseable }
            
            // 3. Group parseable by unit
            let byUnit = Dictionary(grouping: parseable) { $0.standardUnit }
            
            for (unit, sameUnitItems) in byUnit {
                // 4. Sum numeric values
                let total = sameUnitItems.reduce(0.0) { sum, item in
                    sum + (item.numericValue ?? 0.0)
                }
                
                merged.append(MergedItem(
                    name: ingredientName,
                    displayText: formatQuantity(total, unit: unit),
                    sources: sameUnitItems.map { $0.source }
                ))
            }
            
            // 5. List unparseable separately
            if !unparseable.isEmpty {
                merged.append(MergedItem(
                    name: ingredientName,
                    displayText: "Plus: \(unparseable.map { $0.displayText }.joined(separator: ", "))",
                    sources: unparseable.map { $0.source }
                ))
            }
        }
        
        return merged
    }
}
```

**Consolidation UI:**
- "Consolidate" button on shopping list
- Preview merged quantities
- Show source breakdown: "Flour: 3 cups (Recipe A: 1 cup, Recipe B: 2 cups)"
- User approval before applying changes

#### **Phase 6: UI Updates (45-60 minutes)**

**Update Recipe Forms:**
- CreateRecipeView: Use structured quantity input
- EditRecipeView: Display and edit structured quantities
- Visual indicators: ✓ for parseable, ⓘ for unparseable quantities

**Update Recipe Display:**
- RecipeDetailView: Show displayText for quantities
- Add "Scale Recipe" button and UI
- Show scaling preview

**Update Shopping Lists:**
- Display consolidated quantities
- Show source tracking
- "Consolidate" feature with preview

**Visual Design:**
- Parseable quantities: calculator icon
- Unparseable quantities: text icon with tooltip
- Inline help for calculation limitations

### **Technical Implementation Requirements:**

**Core Data Schema Changes:**
```swift
// Ingredient entity
@NSManaged public var numericValue: Double  // 0.0 for unparseable
@NSManaged public var standardUnit: String?
@NSManaged public var displayText: String
@NSManaged public var isParseable: Bool
@NSManaged public var parseConfidence: Float

// GroceryListItem entity (same structure)
```

**Service Architecture:**
```swift
// Enhanced existing service
IngredientParsingService: Add numeric conversion and unit standardization

// New services
QuantityMigrationService: One-time data migration
RecipeScalingService: Mathematical scaling operations
QuantityMergeService: Shopping list consolidation
```

**Migration Strategy:**
1. Add new fields to Core Data model
2. Generate new property files
3. Implement enhanced parsing service
4. Build migration service
5. Run one-time migration on app launch
6. Update all UI to use new fields

### **Success Criteria:**
- **Parsing Accuracy**: > 80% success rate for existing quantity strings
- **Recipe Scaling**: Functional scaling for all parseable ingredients
- **Shopping Consolidation**: Intelligent quantity merging operational
- **Performance**: Parsing < 0.1s per ingredient, scaling < 0.5s for 20+ ingredient recipes
- **Migration Success**: > 95% completion rate in single session
- **Zero Data Loss**: All original text preserved in displayText field

### **Validation Plan:**
- **Parsing Engine**: Test with 100+ real ingredient quantities
- **Numeric Conversion**: Verify "1 1/2" → 1.5, "3/4" → 0.75 accuracy
- **Unit Standardization**: Test all unit aliases
- **Scaling Accuracy**: Verify mathematical correctness across scale factors
- **Consolidation Logic**: Test merging scenarios including edge cases
- **Migration Safety**: Validate data preservation with rollback capability
- **Performance Testing**: Validate sub-0.1s parsing and sub-0.5s scaling targets

### **Structured Quantity Management Features:**

1. **Structured Data Model**: Numeric values + standardized units
2. **Intelligent Parsing**: Automatic quantity parsing with fraction support
3. **Recipe Scaling**: Mathematical scaling with practical display formatting
4. **Smart Consolidation**: Intelligent shopping list quantity merging
5. **Flexible Support**: Both precise ("2 cups") and imprecise ("a pinch") quantities
6. **Clean Architecture**: Single source of truth for quantity data
7. **Performance Optimized**: Fast parsing and scaling operations

### **Strategic Value Enhancement:**
1. **Recipe Intelligence**: Enable scaling and portion adjustment features
2. **Shopping Efficiency**: Smart quantity consolidation reduces duplicate purchases
3. **Analytics Foundation**: Structured data enables nutrition and cost analysis (M8-M9)
4. **Competitive Advantage**: Advanced features with clean architecture
5. **User Flexibility**: Support both precise measurements and cooking intuition

### **Post-Implementation:**
After M3 completion, structured quantity foundation enables:
- **M4**: Meal Planning with intelligent grocery list generation from meal plans
- **M5**: CloudKit Family Sharing with quantity data synchronization
- **M7**: Analytics Dashboard with quantity-based insights
- **M8**: Health Analytics with nutrition calculations (future)
- **M9**: Budget Intelligence with price-per-unit analysis (future)

**Technical Foundation Ready:**
- **Unified Ingredient System**: IngredientTemplate-based architecture operational ✅
- **Recipe Management**: Complete create/read/update/delete lifecycle ✅
- **Custom Category Integration**: Store-layout optimization throughout app ✅
- **Performance Architecture**: Sub-0.1s response times established ✅
- **Parsing Infrastructure**: Regex-based ingredient parsing proven and operational ✅

**Current Achievement**: M1 and M2 complete (48.5 hours total) with revolutionary grocery management, store-layout optimization, and complete recipe integration providing robust foundation. Ready for clean structured quantity replacement enabling recipe scaling, intelligent consolidation, and analytics foundation.

**Please help me implement M3: Structured Quantity Management with clean replacement architecture, transforming string-based quantities to structured numeric system enabling recipe scaling, intelligent shopping consolidation, and analytics foundation.**