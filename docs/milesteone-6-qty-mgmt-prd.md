# Product Requirements Document: Milestone 6 - Structured Quantity Management

**Document Version**: 1.1  
**Created**: September 8, 2025  
**Updated**: September 8, 2025  
**Priority**: Future Enhancement (Post-Milestone 5)  
**Estimated Effort**: 8-12 hours  

---

## Executive Summary

Transform ingredient and grocery list quantity management from string-based to structured numeric + unit fields, enabling advanced mathematical operations, recipe scaling, nutrition analysis, and intelligent shopping features while maintaining backward compatibility and user input flexibility.

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
// Current Model
quantity: String  // "2 cups", "1 1/2 lbs", "a pinch"

// Proposed Model
numericValue: Double?     // 2.0, 1.5, nil
unit: String?            // "cups", "lbs", nil
originalText: String     // "2 cups", "a pinch of salt" 
isParseable: Bool        // true/false
displayText: String      // Auto-generated or user override
userNotified: Bool       // User acknowledged calculation exclusion
```

### Hybrid Approach Benefits
- **Structured Data**: Enable mathematical operations where possible
- **Flexibility Preservation**: Maintain support for imprecise measurements
- **Backward Compatibility**: Existing data preserved in originalText field
- **User Choice**: Allow manual override of auto-parsing
- **Transparent Limitations**: Clear communication about calculation exclusions

---

## Detailed Requirements

### Functional Requirements

#### FR-1: Quantity Parsing Engine with User Awareness
**Description**: Automatic parsing of quantity strings into structured components with user notification for unparseable quantities
**Acceptance Criteria**:
- Parse standard measurements: "2 cups", "1.5 lbs", "3/4 teaspoon"
- Handle fractional inputs: "1 1/2", "2/3", "3 3/4"
- Recognize common units: volume (cups, tbsp, ml), weight (lbs, oz, kg), count (pieces, cloves)
- **UPDATED**: When user enters unparseable quantities ("a pinch", "to taste", "handful"):
  - Allow the entry without restriction
  - Show user-friendly notification explaining calculation limitations
  - Notification options:
    - **In-line badge**: Small "Not included in calculations" badge next to quantity
    - **One-time tooltip**: "Quantities like 'a pinch' won't be included in recipe scaling or calculations"
    - **Info icon**: Tappable (i) icon showing explanation when needed
  - Track notification acknowledgment to avoid repetitive warnings
  - Store `userNotified: Bool` flag to remember user has been informed
- Maintain original text for all entries
- Provide clear visual distinction between parsed and unparsed quantities

**UI/UX Specifications**:
- **Badge Approach**: Subtle gray badge with "Manual only" text
- **Tooltip Timing**: Show on first unparseable entry, then only on user request
- **Visual Distinction**: Parsed quantities have calculator icon, unparsed have text icon
- **Batch Notification**: When importing recipes with multiple unparseable quantities, show single summary notification

#### FR-2: Unit Management System
**Description**: Comprehensive unit handling with standardization
**Acceptance Criteria**:
- Predefined unit categories: Volume, Weight, Count, Temperature
- Unit aliases support: "cup"/"cups", "tablespoon"/"tbsp"/"T"
- Custom unit creation for specialized ingredients
- Unit validation preventing invalid combinations
- Export unit database for backup/sync

#### FR-3: Recipe Scaling with Smart Handling
**Description**: Mathematical recipe scaling with graceful handling of unparseable quantities
**Acceptance Criteria**:
- Scale all parseable quantities proportionally
- **UPDATED**: For unparseable quantities during scaling:
  - Display original text with scaling note: "a pinch (adjust to taste for X servings)"
  - Show scaling guidance: "Consider adjusting seasoning quantities for larger/smaller batches"
  - Provide scaling hints based on common knowledge: "For 2x recipe, start with 1.5x seasoning"
  - Option to manually override with scaled quantity if user chooses
- Handle fractional scaling factors: 1.5x, 0.75x
- Round results to practical measurements
- Display scaling history for user reference
- Show scaling summary indicating how many ingredients were auto-scaled vs. manually adjusted

#### FR-4: Quantity Consolidation with Mixed Types
**Description**: Intelligent combination of like ingredients across lists with mixed parseable/unparseable handling
**Acceptance Criteria**:
- Combine same ingredients with same units automatically
- Suggest unit conversions for different units of same ingredient
- **UPDATED**: For mixed parseable/unparseable consolidation:
  - Group parseable quantities mathematically
  - List unparseable quantities separately with note: "Plus: a pinch, to taste"
  - Allow user to manually convert unparseable to parseable if desired
  - Show consolidation preview before applying changes
- Present consolidation options to user for approval
- Maintain source tracking for consolidated items

#### FR-5: Data Migration with User Validation
**Description**: Convert existing string quantities to structured format with user review
**Acceptance Criteria**:
- Batch parsing of existing quantity strings
- **UPDATED**: Migration process for unparseable quantities:
  - Show parsing results with clear parsed/unparsed breakdown
  - Allow users to manually convert unparsed quantities if they choose
  - Provide migration summary: "X quantities parsed successfully, Y remain as text-only"
  - Option to proceed with mixed results or review unparsed quantities individually
- User review interface for parsing validation
- Manual correction capability for failed parses
- Rollback mechanism for migration errors
- Progress tracking and error reporting

### Non-Functional Requirements

#### NFR-1: Performance
- Quantity parsing: < 0.1s per ingredient
- Recipe scaling: < 0.5s for recipes with 20+ ingredients
- Database migration: < 30s for 1000+ existing records
- Notification rendering: < 0.05s for UI responsiveness

#### NFR-2: Data Integrity
- Zero data loss during migration
- Reversible parsing operations
- Audit trail for all quantity modifications
- Backup creation before major operations

#### NFR-3: User Experience
- Parsing happens transparently during input
- Clear visual indicators for parsed vs unparsed quantities
- Simple override mechanism for incorrect parsing
- Consistent behavior across recipe and grocery contexts
- **NEW**: Non-intrusive notification system that doesn't interrupt workflow

---

## User Stories

### Epic 1: Smart Recipe Scaling

**US-6.1**: As a home cook, I want to scale recipes up or down so that I can cook for different numbers of people
**Acceptance Criteria**:
- Select target serving size and see all quantities automatically adjusted
- View original and scaled quantities side-by-side
- Get practical measurement conversions (e.g., "1.33 cups" suggests "1 1/3 cups")
- **UPDATED**: See helpful scaling notes for unparseable ingredients with cooking guidance
- Understand which ingredients were auto-scaled vs. require manual adjustment

**US-6.2**: As a meal planner, I want to scale multiple recipes at once so that I can batch cook efficiently
**Acceptance Criteria**:
- Select multiple recipes and apply consistent scaling factor
- Generate consolidated shopping list with scaled quantities
- Handle ingredient overlaps across scaled recipes
- **UPDATED**: Get comprehensive scaling summary showing mix of auto-scaled and manual ingredients
- Export scaled recipes for cooking reference

### Epic 2: Intelligent Shopping Lists

**US-6.3**: As a grocery shopper, I want my shopping lists to automatically combine duplicate ingredients so that I don't buy redundant items
**Acceptance Criteria**:
- Automatically detect and combine same ingredients from different sources
- Present consolidation suggestions before finalizing list
- Show source breakdown for combined quantities (Recipe A: 2 cups, Recipe B: 1 cup)
- **UPDATED**: Handle mixed quantity types gracefully with clear breakdown of calculable vs. text quantities
- Option to manually resolve text quantities during consolidation

**US-6.4**: As a budget-conscious shopper, I want to see price-per-unit calculations so that I can make cost-effective purchasing decisions
**Acceptance Criteria**:
- Calculate and display price per ounce, pound, count as appropriate
- Compare unit prices across different package sizes
- Track historical price-per-unit data for spending insights
- Alert when current prices exceed historical averages
- **UPDATED**: Clearly indicate when price calculations exclude unparseable quantities

### Epic 3: Nutrition and Analytics

**US-6.5**: As a health-conscious cook, I want to track nutritional information for my recipes so that I can make informed dietary choices
**Acceptance Criteria**:
- Calculate nutritional totals based on structured ingredient quantities
- Scale nutritional information with recipe scaling
- Display per-serving nutritional breakdowns
- **UPDATED**: Show nutrition calculation coverage percentage (e.g., "85% of ingredients included")
- Option to manually estimate nutrition for unparseable quantities
- Integration preparation for future nutrition database connections

**US-6.6**: As a data-driven user, I want to see spending and usage analytics so that I can optimize my grocery habits
**Acceptance Criteria**:
- Track spending by ingredient type and quantity over time
- Identify most/least used ingredients in recipe collection
- Calculate average cost per meal based on ingredient quantities
- **UPDATED**: Analytics dashboards show data coverage and calculation confidence levels
- Generate insights about shopping patterns and preferences

### Epic 4: Advanced Input and Validation

**US-6.7**: As a recipe creator, I want smart quantity input assistance so that I can enter measurements quickly and accurately
**Acceptance Criteria**:
- Auto-complete common quantity + unit combinations
- Validate measurements and suggest corrections for typos
- Support natural language input ("one and a half cups")
- **UPDATED**: Provide gentle guidance about calculation limitations without restricting input
- Show parsing results in real-time with clear visual feedback
- Provide quantity conversion suggestions during input

**US-6.8**: As a recipe importer, I want automatic quantity parsing when importing recipes so that I can quickly add external recipes to my collection
**Acceptance Criteria**:
- Parse quantities from imported recipe text automatically
- Present parsing results for user validation before saving
- Handle various recipe format styles and measurement systems
- **UPDATED**: Show import parsing summary with success rates and unparseable quantity handling
- Maintain original text for reference and troubleshooting

---

## User Experience Flow for Unparseable Quantities

### Scenario 1: Manual Recipe Entry
1. User types "a pinch of salt"
2. System recognizes as unparseable
3. Shows subtle inline indicator (badge or icon)
4. On first occurrence: Brief, dismissible tooltip explains calculation limitations
5. Quantity saves successfully with all metadata

### Scenario 2: Recipe Scaling
1. User selects 2x scaling for recipe
2. System scales all parseable quantities automatically
3. For "a pinch of salt": Shows "a pinch (adjust to taste for 8 servings)"
4. Scaling summary: "12 ingredients auto-scaled, 3 require manual adjustment"

### Scenario 3: Shopping List Consolidation
1. Multiple recipes added to shopping list
2. System combines "2 cups flour" + "1 cup flour" = "3 cups flour"
3. For unparseable: Shows "Salt needed for: Recipe A (a pinch), Recipe B (to taste)"
4. User can manually resolve or proceed with text list

### Scenario 4: Migration Process
1. Existing recipes contain mix of "2 cups" and "a pinch" quantities
2. Migration shows preview: "85% quantities parsed successfully"
3. User reviews unparseable quantities with option to manually convert
4. User approves migration with understanding of mixed quantity types

---

## Technical Considerations

### Data Model Changes
```swift
// Enhanced Core Data Entities

// QuantityComponent (new entity)
@NSManaged public var numericValue: Double
@NSManaged public var unit: String?
@NSManaged public var originalText: String
@NSManaged public var isParseable: Bool
@NSManaged public var isUserValidated: Bool
@NSManaged public var parseConfidence: Float
@NSManaged public var userNotified: Bool        // NEW: Track notification status
@NSManaged public var calculationExcluded: Bool // NEW: Explicit exclusion flag

// Updated Entities
// Ingredient.quantity -> Ingredient.quantityComponent (relationship)
// GroceryListItem.quantity -> GroceryListItem.quantityComponent (relationship)
```

### Service Architecture
```swift
// Enhanced Services
QuantityParsingService: String parsing and validation with user notification
UnitConversionService: Unit standardization and conversion
RecipeScalingService: Mathematical operations with mixed quantity handling
QuantityMergeService: Shopping list consolidation with text quantity support
NotificationService: User awareness and education system  // NEW
MigrationService: Data conversion and validation
```

### Notification System Design
```swift
// UserQuantityNotificationService
func shouldShowParsingNotification(for quantity: String) -> Bool
func markUserNotified(for quantityType: String)
func generateScalingGuidance(for unparseableQuantities: [String], scaleFactor: Double) -> [String]
func createConsolidationSummary(parseableTotal: Double, unparseableItems: [String]) -> String
```

### Migration Strategy
1. **Phase 1**: Add new structured fields alongside existing string fields
2. **Phase 2**: Implement parsing service and batch convert existing data with user notification system
3. **Phase 3**: Update UI to use structured data with string fallback and user awareness features
4. **Phase 4**: Deprecate old string-only fields after validation period

---

## Success Metrics

### User Engagement
- Recipe scaling feature adoption rate > 40%
- Shopping list consolidation acceptance rate > 60%
- User retention improvement of 15% post-implementation
- **NEW**: User notification dismissal rate < 20% (indicating good UX design)

### Data Quality
- Successful parsing rate > 80% for existing quantity strings
- User validation rate < 10% for auto-parsed quantities
- Zero data loss during migration process
- **NEW**: User satisfaction score > 4.0/5.0 for mixed quantity handling

### Performance
- Recipe scaling response time < 0.5s for complex recipes
- Shopping list generation time < 2s with consolidation
- Migration completion rate > 95% in single session
- **NEW**: Notification rendering time < 0.05s

### User Understanding
- **NEW**: Post-feature survey showing > 85% users understand calculation limitations
- **NEW**: Support tickets related to quantity confusion < 5% of user base
- **NEW**: Feature abandonment rate < 10% after notification education

---

## Risks and Mitigation

### Technical Risks
**Risk**: Complex migration might cause data corruption
**Mitigation**: Comprehensive backup strategy, rollback mechanisms, staged migration

**Risk**: Parsing accuracy lower than expected
**Mitigation**: Extensive test dataset, machine learning approach consideration, user validation workflow

**Risk**: Performance degradation with structured data
**Mitigation**: Database indexing strategy, caching layer, background processing

### User Experience Risks
**Risk**: Users might reject automatic parsing
**Mitigation**: Clear opt-out mechanisms, manual override capabilities, gradual feature rollout

**Risk**: Notification fatigue from unparseable quantity warnings
**Mitigation**: **NEW**: Smart notification frequency, one-time education approach, subtle visual indicators

**Risk**: Increased complexity might confuse users
**Mitigation**: Progressive disclosure, contextual help, optional advanced features, **NEW**: comprehensive user education system

### Business Risks
**Risk**: Feature complexity might delay other development priorities
**Mitigation**: Phased implementation approach, minimum viable product definition, clear success criteria

---

## Dependencies

### Technical Dependencies
- Completion of Milestones 2-5 providing stable recipe and grocery foundation
- Enhanced Core Data model with relationship optimization
- Comprehensive unit testing framework for mathematical operations
- **NEW**: User interface framework for notification and education system

### Business Dependencies
- User research validation of recipe scaling demand
- Competitive analysis of quantity management approaches
- Performance baseline establishment from current string-based system
- **NEW**: User testing of notification system and mixed quantity workflows

---

## Future Enhancements

### Post-Milestone 6 Opportunities
- **Nutrition Database Integration**: Connect structured quantities to nutritional APIs
- **Voice Input Processing**: "Add two cups of flour" voice-to-structured conversion with parsing
- **International Unit Support**: Metric/Imperial conversion and localization
- **Machine Learning Enhancement**: Improve parsing accuracy through usage patterns and user feedback
- **Inventory Tracking**: Use structured quantities for pantry management features
- **Smart Quantity Suggestions**: Learn from user patterns to suggest better quantity formats
- **Community Quantity Database**: Crowdsourced quantity standardization for better parsing

---

**Milestone 6 represents a foundational enhancement that unlocks advanced recipe intelligence while maintaining the simplicity and flexibility that users expect from quantity input. The updated approach ensures users remain in control while being appropriately informed about system limitations.**