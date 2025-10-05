# Product Requirements Document: M3 - Structured Quantity Management

**Document Version**: 2.0  
**Created**: September 8, 2025  
**Updated**: October 5, 2025  
**Priority**: HIGH - Foundational enhancement for recipe intelligence  
**Estimated Effort**: 8-12 hours  
**Approach**: Clean replacement of string fields with structured data

---

## Executive Summary

Replace string-based ingredient and grocery list quantity storage with structured numeric + unit fields, enabling advanced mathematical operations, recipe scaling, nutrition analysis, and intelligent shopping features through clean architectural replacement.

---

## Problem Statement

### Current Limitations
- **No Mathematical Operations**: Cannot scale recipes, combine quantities, or perform calculations
- **Limited Intelligence**: No unit conversions, price-per-unit analysis, or quantity-based sorting
- **Data Analysis Barriers**: Nutritional tracking and spending analysis impossible with string data
- **User Experience Gaps**: No recipe scaling, smart list consolidation, or quantity validation

### Business Impact
- Reduced user engagement due to lack of advanced recipe features
- Missed opportunities for intelligent shopping assistance
- Limited data insights for user behavior analysis
- Competitive disadvantage against apps with recipe scaling capabilities

---

## Solution Overview

### Core Architecture Change
```swift
// Current Model (String-based)
Ingredient.quantity: String?  // "2", "1 1/2"
Ingredient.unit: String?      // "cups", "lbs"

// New Model (Structured)
Ingredient.numericValue: Double?    // 2.0, 1.5, nil for "a pinch"
Ingredient.standardUnit: String?    // "cup", "lb" (standardized)
Ingredient.displayText: String      // "2 cups", "a pinch" (user-facing)
Ingredient.isParseable: Bool        // true = can scale/merge
Ingredient.parseConfidence: Float   // 0.0-1.0
```

### Clean Replacement Benefits
- **Structured Data**: Enable mathematical operations on all parseable quantities
- **No Technical Debt**: Single source of truth, no dual-storage complexity
- **One-Time Migration**: Parse existing data once during upgrade
- **Flexible Support**: Both precise measurements and imprecise descriptions
- **Analytics Ready**: Foundation for nutrition and budget intelligence

---

## Detailed Requirements

### Functional Requirements

#### FR-1: Structured Quantity Data Model
**Description**: Replace string quantity fields with structured numeric + unit fields
**Acceptance Criteria**:
- Remove `quantity: String?` and `unit: String?` from Ingredient entity
- Add `numericValue: Double?`, `standardUnit: String?`, `displayText: String`, `isParseable: Bool`
- Apply same changes to GroceryListItem entity
- Add Core Data indexes for numericValue and standardUnit
- Generate new NSManagedObject subclasses

#### FR-2: Enhanced Parsing Service
**Description**: Extend existing IngredientParsingService to return structured data
**Acceptance Criteria**:
- Parse standard measurements: "2 cups", "1.5 lbs", "3/4 teaspoon"
- Handle fractional inputs: "1 1/2" → 1.5, "2/3" → 0.667, "3/4" → 0.75
- Recognize common units: volume (cups, tbsp, ml), weight (lbs, oz, kg), count (pieces, cloves)
- Standardize unit aliases: "cups"/"cup" → "cup", "tablespoons"/"tbsp" → "tbsp"
- Flag unparseable quantities: "a pinch", "to taste" (numericValue = nil, isParseable = false)
- Preserve original text in displayText field
- Performance: < 0.1s per quantity parse

**Unit Standardization Map**:
- Volume: cup/cups → "cup", tablespoon/tbsp/T → "tbsp", teaspoon/tsp/t → "tsp"
- Weight: pound/pounds/lb/lbs → "lb", ounce/ounces/oz → "oz"
- Metric: milliliter/ml → "ml", liter/l → "l", gram/g → "g", kilogram/kg → "kg"

#### FR-3: One-Time Data Migration
**Description**: Convert existing string quantities to structured format
**Acceptance Criteria**:
- Batch parsing of all existing Ingredient and GroceryListItem quantities
- Migration preview: "X quantities parsed successfully, Y remain as text-only"
- User review interface showing parse results
- Manual correction capability for incorrect parses
- Progress tracking during migration
- Rollback mechanism if errors detected
- Zero data loss: all original text preserved in displayText

#### FR-4: Recipe Scaling Engine
**Description**: Mathematical recipe scaling for parseable quantities
**Acceptance Criteria**:
- Scale all parseable quantities proportionally: 2 cups × 1.5 = 3 cups
- Handle fractional scaling factors: 1.5x, 0.75x, 2x
- Smart formatting: 1.33 cups suggests "1 1/3 cups", 2.5 lbs displays "2 1/2 lbs"
- Unparseable quantity handling: display with note "a pinch (adjust to taste for X servings)"
- Scaling summary: "12 ingredients auto-scaled, 3 require manual adjustment"
- Performance: < 0.5s for 20+ ingredient recipes

#### FR-5: Shopping List Consolidation
**Description**: Intelligent combination of like ingredients across lists
**Acceptance Criteria**:
- Combine same ingredients with same units: "1 cup flour" + "2 cups flour" = "3 cups flour"
- Group by ingredient name (using IngredientTemplate for normalization)
- Separate parseable from unparseable quantities
- Sum numeric values for same ingredient + same unit
- Display unparseable separately: "Salt: 3 tsp, plus: a pinch (Recipe A), to taste (Recipe B)"
- Source tracking: show which recipes contributed quantities
- Consolidation preview with user approval before applying
- Performance: < 2s for complex shopping lists

### Non-Functional Requirements

#### NFR-1: Performance
- Quantity parsing: < 0.1s per ingredient
- Recipe scaling: < 0.5s for recipes with 20+ ingredients
- Database migration: < 30s for 1000+ existing records
- Shopping list consolidation: < 2s

#### NFR-2: Data Integrity
- Zero data loss during migration
- All original text preserved in displayText field
- Rollback capability for migration errors
- Transaction safety for all Core Data operations

#### NFR-3: User Experience
- Parsing happens transparently during input
- Clear visual indicators for parseable vs unparseable quantities
- Simple override mechanism for incorrect parsing
- Migration UI with clear progress and results
- Non-intrusive user education about calculation limitations

---

## User Stories

### Epic 1: Smart Recipe Scaling

**US-3.1**: As a home cook, I want to scale recipes up or down so that I can cook for different numbers of people
**Acceptance Criteria**:
- Select target serving size and see all quantities automatically adjusted
- View original and scaled quantities side-by-side
- Get practical measurement conversions: "1.33 cups" displays as "1 1/3 cups"
- See clear indication of which ingredients were auto-scaled vs require manual adjustment
- Unparseable quantities display with helpful note: "adjust to taste for X servings"

**US-3.2**: As a meal planner, I want to scale multiple recipes at once so that I can batch cook efficiently
**Acceptance Criteria**:
- Select multiple recipes and apply consistent scaling factor
- Generate consolidated shopping list with scaled quantities
- Handle ingredient overlaps across scaled recipes
- Export scaled recipes for cooking reference

### Epic 2: Intelligent Shopping Lists

**US-3.3**: As a grocery shopper, I want my shopping lists to automatically combine duplicate ingredients so that I don't buy redundant items
**Acceptance Criteria**:
- Automatically detect and combine same ingredients from different sources
- Present consolidation preview before finalizing list
- Show source breakdown: "Flour: 3 cups (Recipe A: 1 cup, Recipe B: 2 cups)"
- Handle mixed quantity types gracefully with clear separation
- Option to manually resolve unparseable quantities during consolidation

**US-3.4**: As a budget-conscious shopper, I want quantity data structured for future price tracking
**Acceptance Criteria**:
- Structured quantities ready for price-per-unit calculations (M9 future)
- Data model supports cost analysis features
- Clear indication when quantities are text-only and excluded from calculations

### Epic 3: Data Migration

**US-3.5**: As an existing user, I want my current recipes preserved during the quantity system upgrade
**Acceptance Criteria**:
- All existing recipes and ingredients preserved with zero data loss
- Migration preview shows parse success rate before committing
- Manual review capability for unparseable quantities
- Clear communication about what changed and why
- Rollback option if migration results are unsatisfactory

---

## User Experience Flow

### Scenario 1: Initial Migration
1. User launches app after M3 update
2. System detects quantity field schema change
3. Migration preview displays: "85 of 100 quantities parsed successfully"
4. User reviews list of unparseable quantities
5. User can manually correct or proceed
6. Migration completes with success summary
7. All recipes display with new structured quantities

### Scenario 2: Recipe Scaling
1. User opens recipe detail view
2. Taps "Scale Recipe" button
3. Adjusts serving size slider: 4 servings → 6 servings (1.5x)
4. Preview shows:
   - "2 cups flour" → "3 cups flour" ✓
   - "1.5 lbs chicken" → "2 1/4 lbs chicken" ✓
   - "Salt to taste" → "Salt to taste (adjust for 6 servings)" ⓘ
5. Summary: "8 ingredients auto-scaled, 2 require manual adjustment"
6. User confirms and recipe updates

### Scenario 3: Shopping List Consolidation
1. User adds Recipe A (needs 1 cup flour) to shopping list
2. User adds Recipe B (needs 2 cups flour) to shopping list
3. Taps "Consolidate" button
4. Preview shows: "Flour: 3 cups (Recipe A: 1 cup, Recipe B: 2 cups)"
5. User approves consolidation
6. Shopping list updates with merged quantities

---

## Technical Considerations

### Data Model Changes
```swift
// Ingredient Entity - UPDATED
@NSManaged public var id: UUID?
@NSManaged public var name: String?
@NSManaged public var notes: String?
@NSManaged public var sortOrder: Int16

// REMOVED:
// @NSManaged public var quantity: String?
// @NSManaged public var unit: String?

// ADDED:
@NSManaged public var numericValue: Double      // 0.0 for unparseable
@NSManaged public var standardUnit: String?     // nil for unparseable
@NSManaged public var displayText: String       // Always populated
@NSManaged public var isParseable: Bool         // true/false
@NSManaged public var parseConfidence: Float    // 0.0-1.0

// Relationships (unchanged)
@NSManaged public var recipe: Recipe?
@NSManaged public var ingredientTemplate: IngredientTemplate?

// GroceryListItem Entity - Same changes as Ingredient
```

### Service Architecture
```swift
// Enhanced existing service
IngredientParsingService {
    // NEW: Numeric conversion
    func convertToNumeric(_ quantity: String) -> Double?
    
    // NEW: Unit standardization  
    func standardizeUnit(_ unit: String?) -> String?
    
    // NEW: Structured output
    func parseToStructured(text: String) -> StructuredQuantity
}

// New services
QuantityMigrationService {
    func migrateAllQuantities(context: NSManagedObjectContext)
    func getMigrationPreview() -> MigrationSummary
    func rollback()
}

RecipeScalingService {
    func scale(recipe: Recipe, factor: Double) -> ScaledRecipe
    func formatScaled(_ value: Double, unit: String?) -> String
}

QuantityMergeService {
    func merge(items: [GroceryListItem]) -> [MergedItem]
    func getConsolidationPreview(items: [GroceryListItem]) -> MergePreview
}
```

### Migration Strategy
**Single-Phase Clean Replacement:**
1. Add new structured fields to Core Data model
2. Generate new property files, build succeeds
3. Implement enhanced parsing service with numeric conversion
4. Build migration service
5. On first launch with new version:
   - Run migration
   - Show preview and results
   - Save migrated data
6. Update all UI code to use new fields
7. Remove old string field references from codebase

---

## Success Metrics

### Data Quality
- Successful parsing rate > 80% for existing quantity strings
- User validation rate < 10% for auto-parsed quantities
- Zero data loss during migration process
- Migration completion rate > 95% in single session

### Feature Adoption
- Recipe scaling feature usage > 40% of users within first month
- Shopping list consolidation acceptance rate > 60%
- User satisfaction score > 4.0/5.0 for quantity management

### Performance
- Recipe scaling response time < 0.5s for complex recipes
- Shopping list consolidation < 2s
- Parsing operations < 0.1s per ingredient
- Migration completion < 30s for 1000+ records

---

## Risks and Mitigation

### Technical Risks
**Risk**: Migration complexity might cause data corruption
**Mitigation**: Comprehensive testing, rollback mechanism, staged deployment

**Risk**: Parsing accuracy lower than expected
**Mitigation**: Extensive test dataset, user validation workflow, manual correction UI

**Risk**: Performance degradation with structured data
**Mitigation**: Core Data indexing, performance profiling, optimization

### User Experience Risks
**Risk**: Users confused by quantity system change
**Mitigation**: Clear migration communication, preview interface, help documentation

**Risk**: Unparseable quantities frustrate users
**Mitigation**: Graceful handling, clear visual indicators, support for text-only quantities

---

## Dependencies

### Technical Dependencies
- Completion of M2 (Recipe Integration) providing stable ingredient foundation
- Existing IngredientParsingService with proven regex patterns
- Core Data migration capabilities
- UI components for scaling and consolidation features

### Business Dependencies
- User acceptance of one-time migration process
- Support resources for migration assistance
- Clear communication about feature benefits

---

## Future Enhancements

### Post-M3 Opportunities (M8-M9)
- **Nutrition Database Integration**: Connect structured quantities to nutritional APIs
- **Price Tracking**: Use numeric values for cost-per-unit analysis
- **Unit Conversion**: Advanced metric/imperial conversions
- **ML Enhancement**: Improve parsing accuracy through usage patterns
- **Inventory Tracking**: Use structured quantities for pantry management

---

**M3 represents a foundational architectural improvement that unlocks advanced recipe intelligence while maintaining support for both precise measurements and cooking intuition. The clean replacement approach eliminates technical debt and provides a robust foundation for future analytics features.**