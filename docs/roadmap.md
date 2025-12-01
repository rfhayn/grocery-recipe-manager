# forager - Development Roadmap

**Last Updated**: November 26, 2025  
**Current Phase**: M4 COMPLETE ✅  
**Status**: All M1-M4 milestones complete, ready for M5 or TestFlight

---

## 🎯 **PROJECT OVERVIEW**

**Vision**: Revolutionary iOS grocery and recipe management app with intelligent automation, family collaboration, and lifestyle optimization.

**Core Value Proposition**:
- Store-layout optimized grocery shopping
- Integrated recipe catalog with smart ingredient management
- Structured quantity system enabling scaling and consolidation
- Recipe ingredient autocomplete for efficient data entry
- Calendar-based meal planning
- CloudKit family collaboration
- Analytics-driven insights

---

## 📊 **CURRENT STATE - November 2025**

### **Completed Milestones** ✅

**M1: Professional Grocery Management (32 hours) - August 2025** ✅
- Store-layout optimized grocery lists with custom categories
- Drag-and-drop category management
- Staple item system with auto-population
- Professional iOS UI with SwiftUI
- Core Data architecture with performance optimization

**M2: Recipe Integration (16.5 hours) - September-October 2025** ✅
- Complete recipe catalog with CRUD operations
- Unified IngredientTemplate system for normalization
- Recipe-to-grocery list integration with category preservation
- Enhanced search across name, ingredients, tags, instructions
- Usage analytics and favorite tracking
- Recipe ingredient autocomplete with parse-then-search ✅
- Fuzzy matching and intelligent template alignment
- Performance: < 0.1s queries, < 0.5s complex operations

**M3: Structured Quantity Management (10.5 hours) - October 2025** ✅
- **Phase 1-2** (3 hours): Core data model & enhanced parsing ✅
- **Phase 3** (1.5 hours): Data migration with 100% success ✅
- **Phase 4** (2.5 hours): Recipe scaling service with fractions ✅
- **Phase 5** (2.5 hours): Quantity consolidation with unit conversion ✅
- **Phase 6** (1 hour): UI polish & comprehensive documentation ✅

**M3 Completion**: All 33 requirements complete, production-ready quality achieved

**M3.5: Foundation Validation & Testing (8.5 hours) - October 2025** ✅
- **Phase 1** (8.5 hours): Comprehensive validation and test infrastructure ✅
  - Template system validation (16 templates verified)
  - Core Data audit and documentation
  - Edge case analysis and handling
  - 75+ computed properties added across Recipe/Ingredient entities
  - **Automated validation test suite built** (6 test suites, 100% pass rate)
  - Performance validation (all operations < 0.5s)

**M3.5 Completion**: Test automation pattern established, 100% validation success, production-ready

**M4.1: Settings Infrastructure Foundation (1.5 hours) - October 2025** ✅
- UserPreferences Core Data entity (single-record pattern)
- UserPreferencesService with singleton pattern and auto-save
- Meal Planning preferences UI in SettingsView
- Real-time validation and persistence
- Duration (3-14 days) and start day (Sun-Sat) configuration

**M4.1 Completion**: Settings infrastructure complete, M4.2 ready to use preferences

**M4.2: Calendar-Based Meal Planning Core (~4 hours) - November 2025** ✅
- MealPlan and PlannedMeal Core Data entities with relationships
- MealPlanService with singleton pattern
- Calendar grid view with tap-to-add recipe functionality (M4.2.1-3)
- RecipePickerSheet with search, servings adjustment, manual fetching
- Date range picker enhancement (replaced duration stepper)
- Recipe usage tracking (usageCount, lastUsed)
- Sheet pattern discovery and fix (`.sheet(item:)` vs `.sheet(isPresented:)`)

**M4.2 Completion**: Functional meal planning operational, M4.3 ready for grocery integration

**M4: Meal Planning & Enhanced Grocery Integration (19.25 hours) - November 2025** ✅
- **M4.1**: Settings Infrastructure Foundation (1.5h) ✅
- **M4.2**: Calendar-Based Meal Planning Core (~4h) ✅
- **M4.3.1**: Recipe Source Tracking Foundation (3.5h) ✅
- **M4.3.2**: Scaled Recipe to List Integration (1.25h) ✅
- **M4.3.3**: Bulk Add from Meal Plan (2.5h) ✅
- **M4.3.4**: Meal Completion Tracking (1.0h) ✅
- **M4.3.5**: Ingredient Normalization - All 4 Phases (5.5h) ✅
  - Phase 1: Case normalization (Butter → butter)
  - Phase 2: Singular/plural with 13-item preserve-plural list
  - Phase 3: Abbreviation expansion (tbsp → tablespoon)
  - Phase 4: Variation handling (diced tomato → tomato)
- Complete grocery-recipe workflow operational
- 30% reduction in ingredient template fragmentation
- Intelligent plural preservation ("peas", "chocolate chips")
- Revolutionary meal planning to grocery automation

**M4 Completion**: Core workflow complete (planning accuracy: 90%), ready for CloudKit or TestFlight

---

## 🚀 **IMMEDIATE NEXT STEPS**

### **M4 COMPLETE - Next Priority Decision** ✅

With M4 completion, you have two strategic paths:

**Option A: M5 - Production Infrastructure & CloudKit Sync**
- CloudKit family sharing for meal plans
- Production-ready data sync
- Conflict resolution
- Offline support
- Estimated: 20-25 hours

**Option B: TestFlight Beta Deployment**
- Apple Developer Account enrollment
- Real device testing
- User feedback gathering
- Bug fixes and polish
- Estimated: 8-12 hours

**Recommendation**: TestFlight first for real-world validation before CloudKit investment

### **M4 Component Summary:**

**✅ M4.1: Settings Infrastructure Foundation - COMPLETE**
- Completed: October 2025
- Actual Time: 1.5 hours
- UserPreferences entity and service
- Meal planning settings UI

**✅ M4.2: Calendar-Based Meal Planning Core - COMPLETE**
- Completed: November 2025
- Actual Time: ~4 hours
- Calendar grid with recipe assignment
- RecipePickerSheet with search
- Date range picker

**✅ M4.3.1: Recipe Source Tracking Foundation - COMPLETE**
- Completed: November 22, 2025
- Actual Time: 3.5 hours (est: 2-2.5h, +40%)
- Many-to-many GroceryListItem ↔ Recipe relationships
- Display Options in Settings with toggle
- Recipe source badges with navigation
- 11/11 tests passing, production-ready

**✅ M4.3.2: Scaled Recipe to List Integration - COMPLETE**
- Completed: November 22, 2025
- Actual Time: 1.25 hours (est: 1.5-2h, -17%)
- Servings adjustment UI with scale warnings
- Real-time quantity scaling with fractions
- RecipeScalingService integration
- All tests passing, professional UI

**✅ M4.3.3: Bulk Add from Meal Plan - COMPLETE**
- Completed: November 24, 2025
- Actual Time: 2.5 hours (est: 2h, +25%)
- Bulk add button with progress overlay
- Servings adjustment UI enhancement (collapsible recipes)
- Scale indicators (e.g., "↕ 2.0x scale")
- Perfect integration: M4.3.1 badges, M4.3.2 scaling, M3 consolidation
- 5 core tests passing (85% coverage)
- Mathematical accuracy: 100%
- Production-ready

**✅ M4.3.4: Meal Completion Tracking - COMPLETE**
- Completed: November 24, 2025
- Actual Time: 1.0 hour (est: 45 min, +33%)
- Checkbox toggle for meal completion
- Visual feedback: green checkmark, strikethrough, opacity
- Core Data persistence with isCompleted and completedDate
- SwiftUI reactivity fix with refreshID
- Production-ready

**✅ M4.3.5: Ingredient Normalization - COMPLETE**
- Completed: November 26, 2025
- Actual Time: 5.5 hours (est: 4-5h, +10%)
- Complete 4-phase normalization pipeline:
  - Phase 1: Case normalization (2.5h)
  - Phase 2: Singular/plural with preserve-plural list (1.5h)
  - Phase 3: Abbreviation expansion (0.5h)
  - Phase 4: Variation handling with compound word fix (1h)
- 30% reduction in template fragmentation (50+ → 35 templates)
- 13-item preserve-plural list (peas, beans, chocolate chips, etc.)
- Handles "frozen peas" → "peas" (qualifier stripping)
- Handles "largeegg" compound words → "egg"
- StandardEmptyStateView component created
- Production-ready

### **Strategic Integration Points:**
- **M3 Phase 4 → M4.3**: Recipe scaling service enables scaled-to-list feature ✅
- **M3 Phase 5 → M4.3**: Quantity consolidation enhances grocery automation ✅
- **M4.1 → M4.3.1**: Settings infrastructure ready for Display Options ✅
- **M4.2 → M4.3**: Meal planning data ready for bulk grocery list generation ✅
- **M4.3.1 → M4.3.2+**: Core Data relationships enable recipe source display ✅
- **M4 → M5**: Meal planning data architecture ready for family collaboration
- **M3 + M4 → M7**: Rich analytics data from structured quantities and meal patterns
- **M3 + M4 → M8-M11**: Advanced intelligence platform built on structured data foundation

### **Timeline Summary:**
- **Core Platform (M1-M7)**: ~103-136 hours total
- **M1 Complete**: 32 hours ✅
- **M2 Complete**: 16.5 hours ✅
- **M3 Complete**: 10.5 hours ✅
- **M3.5 Complete**: 8.5 hours ✅
- **M4.1 Complete**: 1.5 hours ✅
- **M4.2 Complete**: ~4 hours ✅
- **M4.3.1 Complete**: 3.5 hours ✅
- **M4.3.2 Complete**: 1.25 hours ✅
- **M4.3.3 Complete**: 2.5 hours ✅
- **M4.3.4 Complete**: 1.0 hour ✅
- **M4.3.5 Remaining**: 4 hours (ready to begin)
- **M4 Total Progress**: ~14.25h complete, ~4h remaining
- **M4.2.1-3 Enhancement**: 1 hour (optional)
- **Future (M5-M7)**: ~32-47 hours

---

## 📝 **CURRENT DEVELOPMENT STATE**

### **Technical Foundation Complete:**
- **Structured Quantity Model**: numericValue, standardUnit, displayText, isParseable, parseConfidence ✅
- **Enhanced Parsing**: Numeric conversion, unit standardization, fraction handling ✅
- **Data Migration**: Complete one-time migration with 100% success ✅
- **Recipe Scaling**: Mathematical scaling with kitchen-friendly fractions ✅
- **Quantity Consolidation**: Intelligent merging with unit conversion ✅
- **Recipe Ingredient Autocomplete**: Parse-then-search with fuzzy matching ✅
- **Settings Infrastructure**: Professional settings tab operational ✅
- **Meal Planning**: Calendar-based planning with recipe assignment ✅
- **Help Documentation**: Comprehensive in-app user guide (HelpView.swift) ✅
- **Performance Architecture**: All targets met or exceeded ✅
- **Automated Testing**: Comprehensive validation test suite for future milestones ✅

### **Recipe Features Complete:**
- **Complete Recipe Catalog**: Professional list view with Core Data integration ✅
- **Enhanced Recipe Details**: Comprehensive timing, analytics, and ingredient display ✅
- **Recipe Management**: Full CRUD operations (create/read/update/delete) ✅
- **Recipe Scaling**: Professional scaling UI with live preview and fraction conversion ✅
- **Recipe Ingredient Autocomplete**: Smart ingredient entry with template linking ✅
- **Search and Navigation**: Multi-field filtering with intelligent ranking ✅
- **Favorite Toggle**: @ObservedObject UI refresh with Core Data persistence ✅
- **Usage Analytics**: Functional mark-as-used with usage count and date tracking ✅
- **Template System**: Ingredient parsing, template creation, grocery integration ✅
- **Meal Planning Integration**: Recipe assignment to meal plans with servings ✅

### **UI Enhancements Complete:**
- **Visual Indicators**: Color coding for parseable vs unparseable quantities ✅
- **Consolidation Badge**: Shows merge opportunities in grocery list toolbar ✅
- **Help System**: Comprehensive in-app documentation accessible from settings ✅
- **Calendar View**: Professional date-range meal planning interface ✅
- **Recipe Picker**: Search-enabled recipe selection with servings adjustment ✅

### **Ready for M4.3.1:**
- ✅ Core Data schema ready for relationship changes
- ✅ Settings infrastructure exists for Display Options
- ✅ GroceryListItem entity ready for many-to-many recipe relationships
- ✅ Recipe entity ready for contributedToItems relationship
- ✅ Meal planning data ready for bulk grocery generation
- ✅ All M4.2 foundations production-ready

---

## 📋 **MILESTONE DETAILS**

### **✅ M3: Structured Quantity Management - COMPLETE**

**Status**: ✅ Complete  
**Total Time**: 10.5 hours (target: 8-12 hours) ✅  
**Completion Date**: October 20, 2025

#### **Phase Summary:**

**✅ Phase 1-2: Core Data Model & Enhanced Parsing (3 hours)**
- Replaced string quantities with structured data (numericValue, standardUnit, displayText, isParseable, parseConfidence)
- Enhanced IngredientParsingService with numeric conversion and unit standardization
- Updated 10 files across codebase with zero build errors
- Performance: Sub-0.1s response times

**✅ Phase 3: Data Migration (1.5 hours)**
- QuantityMigrationService with batch processing and async/await
- Professional UI: Preview → Migration → Results workflow
- Settings infrastructure created
- 100% success: 24 parsed (75%), 8 text-only (25%)

**✅ Phase 4: Recipe Scaling Service (2.5 hours)**
- RecipeScalingService with mathematical quantity scaling
- Kitchen-friendly fraction conversion (1.5 → "1 1/2")
- Professional scaling UI with slider and quick buttons (0.25x-4x)
- Graceful degradation for unparseable ingredients
- Performance: < 0.5s for 20+ ingredient recipes

**✅ Phase 5: Quantity Merge Service (2.5 hours)**
- QuantityMergeService with intelligent consolidation logic
- UnitConversionService for volume/weight conversions (cups ↔ tbsp ↔ tsp, lb ↔ oz)
- ConsolidationPreviewView with professional preview UI
- Source tracking for recipe provenance
- Performance: < 0.3s analysis for 50+ items, < 0.8s merge execution
- User value: Reduces list redundancy by 30-50%

**✅ Phase 6: UI Polish & Documentation (1 hour)**
- Recipe ingredient autocomplete validated with M3 features
- Consolidation button with opportunity badge
- Visual indicators for quantity types (green dot, yellow dot, no dot)
- Comprehensive in-app help documentation (HelpView.swift)
- Learning notes and documentation finalized

**Key Achievements:**
- 95%+ parsing accuracy for common quantity formats
- Zero data loss during migration
- All performance targets exceeded
- Professional UI with visual feedback
- Comprehensive user documentation
- Foundation for M4 scaled recipe features

---

### **✅ M3.5: Foundation Validation & Testing - COMPLETE**

**Status**: ✅ Complete  
**Total Time**: 8.5 hours (target: 7 hours)  
**Completion Date**: October 25, 2025

#### **Phase Summary:**

**✅ Phase 1: Comprehensive Validation (8.5 hours)**
- Template system validation (16 templates verified)
- Core Data audit and documentation
- Edge case analysis and handling
- 75+ computed properties added across Recipe/Ingredient entities
- Automated validation test suite built (6 test suites)
- Performance validation (all operations < 0.5s)
- 100% test pass rate

**Key Achievements:**
- Test automation pattern established
- Production-ready validation confirmed
- Zero technical debt
- Foundation for efficient future development

---

### **✅ M4.1: Settings Infrastructure Foundation - COMPLETE**

**Status**: ✅ Complete  
**Total Time**: 1.5 hours (target: 1.5 hours) ✅  
**Completion Date**: October 28, 2025

#### **Implementation Summary:**

**Core Data Entity:**
- UserPreferences entity with single-record pattern
- Properties: mealPlanDuration (3-14 days), mealPlanStartDay (0-6)
- Codegen: Class Definition for automatic code generation

**Service Layer:**
- UserPreferencesService singleton pattern
- Automatic record creation on first access
- Auto-save with 0.3s debouncing
- Thread-safe Core Data operations

**UI Implementation:**
- Settings tab with Meal Planning section
- Duration stepper (3-14 days) with validation
- Start day picker (Sunday-Saturday)
- Real-time updates with proper data binding

**Key Achievements:**
- Professional settings infrastructure operational
- Zero build errors
- Clean service architecture
- Ready for M4.2 calendar integration

---

### **✅ M4.2: Calendar-Based Meal Planning Core - COMPLETE**

**Status**: ✅ Complete  
**Total Time**: ~4 hours (target: 2.5-3 hours, extended for UX improvements)  
**Completion Date**: November 3, 2025

#### **Implementation Summary:**

**Core Data Entities:**
- MealPlan entity (id, name, startDate, duration, dates)
- PlannedMeal entity (id, date, servings)
- Relationships: MealPlan ↔ PlannedMeal ↔ Recipe
- Proper cascade rules and data integrity

**Service Layer:**
- MealPlanService singleton pattern
- addRecipeToMealPlan() with date, plan, servings
- Date validation and availability checking
- Active meal plan management
- Recipe usage tracking (usageCount, lastUsed)

**UI Implementation:**
- MealPlanDetailView with calendar grid
- **M4.2.1-3**: Tap-to-add functionality
  - Tap empty day → RecipePickerSheet opens
  - Tap occupied day → Replace confirmation
  - Remove recipe with confirmation
- RecipePickerSheet with recipe list
  - Manual recipe fetching (avoids @FetchRequest sheet issues)
  - Search functionality
  - Servings adjustment
  - Add to plan functionality
- CreateMealPlanSheet with date range picker
  - Start and end date pickers (replaced duration stepper)
  - Day-of-week display for clarity
  - Auto-generated names
  - Date validation

**Key Technical Achievements:**

1. **Blank Sheet Bug Fix** (Critical Discovery):
   - Problem: `.sheet(isPresented:)` caused blank sheets with Core Data
   - Solution: Used `.sheet(item:)` pattern with `RecipePickerPayload`
   - Pattern discovered in own learning notes (M1 StaplesView pattern)
   - Created data payload with `Identifiable` protocol
   - Prevents timing issues between selection and presentation

2. **Date Range Picker Enhancement**:
   - Replaced duration stepper with end date picker
   - Shows "Mon" for start, "Sun" for end (day-of-week only)
   - Auto-calculates duration from date range
   - Better UX: users think in dates, not duration

3. **Manual Core Data Fetching**:
   - Replaced `@FetchRequest` with manual `fetch()` in sheets
   - Avoids context issues in modal presentations
   - Pattern: Load on `.onAppear` into `@State` array
   - More reliable for complex sheet hierarchies

**Key Achievements:**
- Functional meal planning operational
- Professional calendar interface
- Recipe assignment with servings tracking
- Recipe usage analytics working
- Sheet pattern best practices established
- Zero data integrity issues
- Ready for M4.3 grocery integration

---

### **🚀 M4.3: Enhanced Grocery Integration - IN PROGRESS**

**Status**: 🔄 Active (M4.3.1-3 complete, M4.3.4 next)  
**Estimated Time**: 11.75 hours total (7.25h complete, 4.75h remaining)  
**Target Completion**: November-December 2025

#### **Component Breakdown:**

**🚀 M4.3.1: Recipe Source Tracking Foundation (2-2.5 hours) - READY**

**Phase 1: Core Data Schema Changes** (45-60 min)
- Remove `sourceRecipeId` UUID property from GroceryListItem
- Add many-to-many relationship: `contributingRecipes` (GroceryListItem → Recipe)
- Add inverse relationship: `contributedToItems` (Recipe → GroceryListItem)
- Set delete rule: Nullify (independent lifecycle)
- Add fetch indexes for query optimization
- Lightweight Core Data migration (automatic)

**Phase 2: Settings UI Enhancement** (30-45 min)
- Create "Display Options" section in SettingsView
- Add `showRecipeSourcesOnGroceryItems` toggle preference
- Update UserPreferences entity with new boolean property
- Add display preference to UserPreferencesService
- Test settings persistence and real-time updates

**Phase 3: Foundation Integration** (45-60 min)
- Update addToShoppingList() to establish relationships
- Update IngredientTemplateService for relationship preservation
- Add computed property: groceryListItemRecipeNames
- Test relationship creation with single recipe
- Verify database integrity and cascade behavior
- Update unit tests for relationship logic

**Acceptance Criteria:**
- ✅ Many-to-many relationship operational between GroceryListItem and Recipe
- ✅ Legacy sourceRecipeId removed from codebase
- ✅ Display Options section in Settings with toggle
- ✅ Settings preference persists correctly
- ✅ Single recipe-to-list still works correctly
- ✅ Database migration successful with no data loss
- ✅ Zero build errors or warnings
- ✅ Foundation ready for M4.3.2+ features

---

#### **✅ M4.3.1: Recipe Source Tracking Foundation - COMPLETE**

**Completed**: November 22, 2025  
**Actual Time**: 3.5 hours  
**Status**: Production-ready, all acceptance criteria met

**What Was Built:**
- Many-to-many relationships (GroceryListItem ↔ Recipe)
- Display Options section in Settings
- Recipe source badges with horizontal scrolling
- Tappable navigation to recipe details
- Removal of legacy sourceRecipeId
- Fetch indexes for query optimization

**Bugs Fixed:**
1. Empty displayText in recipe ingredients (30 min)
2. Duplicate source text display (15 min)
3. Redundant quantity tags in recipe view (15 min)

**Test Results:**
- 11/11 tests passing ✅
- 6 test recipes created for validation
- Perfect integration with existing features
- Zero regressions

---

#### **✅ M4.3.2: Scaled Recipe to List Integration - COMPLETE**

**Completed**: November 22, 2025  
**Actual Time**: 1.25 hours  
**Status**: Production-ready, under estimate (-17%)

**What Was Built:**
- Servings adjustment UI with +/- stepper
- "Recipe makes: X servings" display
- "Adding for: Y servings" adjustable (0.25x to 4x range)
- Orange warning: "Quantities will be scaled X.X×"
- Real-time quantity scaling preview
- Blue text for scaled quantities
- Gray italic for original quantities
- Fraction formatting (½, ¼, ¾, etc.)
- RecipeScalingService integration

**Test Results:**
- All tests passing ✅
- 0.5x, 1.5x, 2.0x scaling validated
- Fraction handling perfect
- Recipe badges working (M4.3.1 integration)
- Non-parseable items handled correctly

---

#### **✅ M4.3.3: Bulk Add from Meal Plan - COMPLETE**

**Completed**: November 24, 2025  
**Actual Time**: 2.5 hours (est: 2h, +25% for enhancement)  
**Status**: Production-ready, 85% test coverage

**What Was Built:**

*Core Functionality:*
- "Add All to Shopping List" button in meal plan detail
- SelectListSheet for list selection and recipe review
- Progress overlay with recipe names and percentage
- Success messaging with accurate counts
- Background processing (async/await)
- Recipe source tracking integration (M4.3.1)
- Quantity scaling integration (M4.3.2)

*Enhancement - Servings Adjustment UI:*
- Collapsible "Recipes to Add" section
- Individual servings adjusters per recipe (+/- buttons)
- Scale factor indicators (e.g., "↕ 2.0x scale" in orange)
- State tracking via UUID → Int16 dictionary
- Min/max bounds enforcement (1-99 servings)
- Visual feedback when servings differ from defaults

**Files Modified:**
- MealPlanDetailView.swift (~230 lines added)
- SelectListSheet.swift (~180 lines enhanced)

**Test Results - 5 Core Tests Passing:**
1. **Basic Bulk Add**: ✅ 21 items from 3 recipes
2. **Recipe Source Badges**: ✅ All items tagged correctly
3. **Scaled Quantities**: ✅ 100% accurate (0.5x, 1.5x, 2.0x)
4. **Servings Adjustment UI**: ✅ Professional
5. **Consolidation Integration**: ✅ Perfect (21 → 18 items, math 100% accurate)

**Integration Validation:**
- M4.3.1 (Recipe Source Tracking): ✅ Perfect integration
- M4.3.2 (Quantity Scaling): ✅ Perfect integration
- M3 Phase 5 (Consolidation): ✅ Perfect with scaled recipes
- M2 (IngredientTemplateService): ✅ Name-based soft links working

**Performance:**
- 3 recipes: < 1 second ✓
- UI responsive: 60fps ✓
- Build quality: 0 errors, 0 warnings ✓

**User Experience Wins:**
- One-tap bulk add
- Flexible servings adjustments
- Visual progress feedback
- Clear success confirmation
- Recipe traceability via badges
- Smart automatic consolidation

---

#### **🚀 M4.3.4: Meal Completion Tracking - READY**

**Estimated**: 45 minutes  
**Status**: Prerequisites complete, ready to begin

**Planned Features:**
- isCompleted boolean property on PlannedMeal
- Checkbox/checkmark UI on meal rows
- Visual feedback (strikethrough, opacity)
- Core Data persistence
- Simple toggle behavior

---

#### **⏳ M4.3.5: Ingredient Normalization - PLANNED**

**Estimated**: 4 hours  
**Status**: PRD complete, detailed specification ready

**Planned Phases:**
1. Case Normalization (0.5h)
2. Singular/Plural (1h)
3. Abbreviations (1.5h)
4. Variations (1h)

**PRD**: docs/prds/M4.3.5-INGREDIENT-NORMALIZATION-PRD.md

---

### **⏳ M5: Production Infrastructure & CloudKit - PLANNED**

**Status**: ⏳ Planned  
**Estimated Time**: 12-17 hours  
**Dependencies**: M4 complete

**Phase 1: Apple Developer Account & App Store Setup** (2-3 hours)
- Apple Developer Program enrollment ($99/year)
- App Store Connect configuration
- Bundle identifier and certificates setup
- App icon and metadata preparation
- Privacy policy and terms of service

**Phase 2: TestFlight Deployment & Device Testing** (3-4 hours)
- TestFlight build configuration
- Internal testing group setup
- Real device testing and validation (3+ devices)
- Performance profiling on actual hardware
- User feedback collection and iteration

**Phase 3: CloudKit Schema Design & Integration** (4-6 hours)
- CloudKit record types for all entities
- Sync strategy and conflict resolution design
- Share permissions and access control
- Schema migration from local Core Data
- Bidirectional sync logic implementation
- Offline support with sync queue

**Phase 4: Family Sharing Features** (3-4 hours)
- Family account management UI
- Share invitation and acceptance flows
- Real-time collaboration notifications
- Shared list and recipe indicators
- Multi-device testing
- Conflict scenario validation

**Success Criteria:**
- [ ] Apple Developer Account activated
- [ ] TestFlight build deployed successfully
- [ ] Real device testing complete on 3+ devices
- [ ] CloudKit schema operational
- [ ] Real-time multi-user sync working
- [ ] Conflict resolution tested and reliable
- [ ] Family sharing flows intuitive
- [ ] Performance: < 2s sync for typical changes

---

### **⏳ M6: Testing Foundation & AI Augmentation - PLANNED**

**Status**: ⏳ Planned  
**Estimated Time**: 12-18 hours  
**Dependencies**: M5 complete (TestFlight validated, CloudKit tested)

**Phase 1: Human Test Baseline** (5-7 hours)
- **M6.1.1: Core Data & Model Tests** (2-3h)
  - Entity relationship validation
  - Data integrity tests
  - Migration and persistence tests
- **M6.1.2: Service Layer Tests** (2-3h)
  - IngredientParsingService tests
  - RecipeScalingService tests
  - QuantityMergeService tests
  - IngredientTemplateService tests
- **M6.1.3: Critical Workflow Tests** (1-2h)
  - Recipe-to-grocery flow
  - Meal plan to list generation
  - Category assignment workflows
- **Target**: 50%+ coverage on critical services

**Phase 2: AI Test Review Setup** (3-4 hours)
- **M6.2.1: CLI Refinement** (1-1.5h)
  - Enhance diff parsing for iOS project structure
  - Add context gathering (recent commits, PR description)
  - Improve prompt engineering for Given/When/Then format
- **M6.2.2: GitHub Actions Workflow** (1.5-2h)
  - Configure PR trigger workflow
  - Set up API key management via secrets
  - Add comment posting to PRs
  - Test on sample PRs
- **M6.2.3: Documentation & Integration** (0.5-1h)
  - Document usage and capabilities
  - Update development guidelines
  - Team onboarding materials
- **Target**: ≥90% PRs receive suggestions, ≥75% found useful

**Phase 3: Testing Standards & Infrastructure** (2-3 hours)
- **M6.3.1: Test Architecture Standards** (1-1.5h)
  - Document test organization patterns
  - XCTest best practices guide
  - Mock and fixture guidelines
- **M6.3.2: Coverage Monitoring** (0.5-1h)
  - Set up Xcode coverage reporting
  - Define coverage targets per layer
  - Create coverage dashboard
- **M6.3.3: CI/CD Test Foundation** (0.5-1h)
  - Configure automated test runs
  - Set up test result reporting
  - Define passing criteria

**Phase 4: Phase 3 Prep (Optional)** (2-4 hours)
- **M6.4.1: Domain Model Documentation** (1-1.5h)
  - Document business rules explicitly
  - Entity relationship diagrams with rules
  - Validation logic specifications
- **M6.4.2: Architecture Diagrams** (1-1.5h)
  - Service layer architecture
  - Data flow diagrams
  - Component interaction maps
- **M6.4.3: Gap Detection Experiments** (1-2h)
  - Prototype semantic gap detector
  - Test on historical PRs
  - Refine detection heuristics
- **Note**: Can be deferred to M6.5 or M7 if needed

**Success Criteria:**
- [ ] 50%+ service layer coverage achieved
- [ ] All Core Data entities have basic tests
- [ ] 5+ critical workflows validated
- [ ] AI reviewer operational (≥90% PR activation)
- [ ] ≥75% of AI suggestions found useful
- [ ] Testing standards documented
- [ ] CI/CD running tests on every commit
- [ ] Zero flaky tests, < 30s test suite
- [ ] Documentation through tests

---

### **⏳ M7: Analytics & Insights - PLANNED**

**Status**: ⏳ Planned  
**Estimated Time**: 8-12 hours  
**Dependencies**: M4 complete (structured data from meal planning)

**Phase 1: Analytics Infrastructure** (2-3 hours)
- Analytics service architecture
- Data aggregation and caching
- Query optimization for trends

**Phase 2: Insights Dashboard** (3-4 hours)
- Usage statistics visualization
- Cost tracking and trends
- Recipe popularity metrics
- Ingredient frequency analysis

**Phase 3: Recommendations** (2-3 hours)
- Smart recipe suggestions
- Seasonal ingredient highlights
- Budget optimization tips
- Meal plan optimization

**Phase 4: Export & Sharing** (1-2 hours)
- Data export capabilities
- Report generation
- Share insights with family

**Success Criteria:**
- [ ] Dashboard loads < 1s
- [ ] Meaningful insights generated
- [ ] Trend analysis over time
- [ ] Actionable recommendations
- [ ] Export functionality working
- [ ] Leverages M3 structured quantities

---

### **⏳ M8-M11: Advanced Intelligence Platform - PLANNED**

**Status**: ⏳ Future Development  
**Estimated Time**: 40-60 hours total  
**Dependencies**: M1-M7 complete

**M8: Health & Nutrition Integration** (10-15 hours)
- Apple Health integration
- Nutritional database
- Dietary goal tracking
- Health-aware recommendations
- Allergen and dietary restriction support

**M9: Budget Intelligence** (10-15 hours)
- Price tracking and history
- Budget planning tools
- Cost optimization suggestions
- Store price comparison
- Deal and coupon integration

**M10: AI-Powered Shopping Assistant** (10-15 hours)
- Natural language meal planning
- Smart recipe discovery
- Automated list generation
- Contextual recommendations
- Learning user preferences

**M11: Advanced Collaboration** (10-15 hours)
- Real-time shopping mode
- Assignment and delegation
- Shopping history and analytics
- Family preference learning
- Advanced sharing controls

---

## ⏱️ **TIME TRACKING & ESTIMATES**

### **Completed Work:**
- **M1**: 32 hours (estimated 30-35h) - ✅ 91% accuracy
- **M2**: 16.5 hours (estimated 15-18h) - ✅ 92% accuracy
- **M3**: 10.5 hours (estimated 8-12h) - ✅ 88% accuracy
- **M3.5**: 8.5 hours (estimated 7h) - ✅ 82% accuracy
- **M4.1**: 1.5 hours (estimated 1.5h) - ✅ 100% accuracy
- **M4.2**: ~4 hours (estimated 2.5-3h, extended for UX) - Enhanced implementation
- **Total**: 73 hours (67.5h baseline + 5.5h M4 progress)

### **Remaining Core Platform:**
- **M4.3**: 3.5-4.5 hours (M4.3.1: 2-2.5h, M4.3.2+: 1.5-2h)
- **M4.2.1-3 Enhancement**: 1 hour (optional UI polish)
- **M5**: 12-18 hours (CloudKit family collaboration)
- **M6**: 8-12 hours (comprehensive testing)
- **M7**: 8-12 hours (analytics and insights)
- **Remaining**: ~32-46 hours for M4.3-M7

**Total Core Platform (M1-M7)**: ~105-119 hours estimated (updated with M4.2 actual)

### **Planning Accuracy:**
- **Phase-level estimates**: Consistently accurate within ±15 minutes
- **Milestone estimates**: Excellent accuracy for M1-M4.1 (88-100%)
- **Risk mitigation**: Proactive problem identification preventing scope creep
- **Overall Average**: 88% accuracy across completed work

### **Quality Metrics:**
- **Build Success Rate**: 100% (zero breaking changes)
- **Performance Targets**: 100% met or exceeded
- **Data Integrity**: 100% (zero data loss)
- **Feature Completeness**: 100% (all acceptance criteria met)

### **Productivity Insights:**
- **Phase-based planning**: Highly effective for focus and progress tracking
- **Incremental validation**: Prevents compound errors and rework
- **Learning notes**: Valuable for pattern recognition and decision reference
- **Documentation-first**: Reduces ambiguity and improves execution speed
- **UX iterations**: M4.2 time extended for date picker enhancement - worthwhile investment

---

## 🎯 **SUCCESS CRITERIA BY MILESTONE**

### **M3: Structured Quantity Management** ✅
- ✅ Structured quantity data model operational
- ✅ 95%+ parsing accuracy for common quantity formats
- ✅ Recipe scaling from 0.25x to 4x
- ✅ Kitchen-friendly fraction display
- ✅ Intelligent shopping list consolidation
- ✅ Unit conversion support (volume and weight)
- ✅ Recipe ingredient autocomplete validated
- ✅ User-facing help documentation
- ✅ Sub-0.5s performance for all operations
- ✅ Comprehensive documentation complete

### **M4: Meal Planning & Enhanced Grocery Integration**
- [x] Settings infrastructure with meal planning preferences (M4.1) ✅
- [x] UserPreferences entity with duration and start day (M4.1) ✅
- [x] Calendar-based meal planning interface (M4.2) ✅
- [x] MealPlan and PlannedMeal Core Data entities (M4.2) ✅
- [x] Recipe assignment with tap-to-add workflow (M4.2) ✅
- [x] Recipe usage tracking (usageCount, lastUsed) (M4.2) ✅
- [ ] Many-to-many recipe source relationships (M4.3.1)
- [ ] Display Options settings section (M4.3.1)
- [ ] Recipe source tracking foundation (M4.3.1)
- [ ] "Add All to Shopping List" from meal plan (M4.3.2)
- [ ] Scaled recipe to list with servings (M4.3.3)
- [ ] Recipe source tags display (M4.3.4)
- [ ] Smart quantity consolidation for meal plans (M4.3)
- [ ] Sub-0.5s performance maintained

### **M5: Production Infrastructure & CloudKit**
- [ ] Apple Developer Account activated
- [ ] TestFlight build deployed successfully
- [ ] Real device testing complete on 3+ devices
- [ ] CloudKit schema operational
- [ ] Real-time multi-user sync working
- [ ] Conflict resolution tested and reliable
- [ ] Family sharing flows intuitive
- [ ] Performance: < 2s sync for typical changes

### **M6: Testing Foundation & AI Augmentation**
- [ ] 50%+ service layer coverage achieved
- [ ] All Core Data entities have basic tests
- [ ] 5+ critical workflows validated
- [ ] AI reviewer operational (≥90% PR activation)
- [ ] ≥75% of AI suggestions found useful
- [ ] Testing standards documented
- [ ] CI/CD running tests on every commit
- [ ] Zero flaky tests, < 30s test suite

### **M7: Analytics & Insights**
- [ ] Usage analytics tracking
- [ ] Insights dashboard with visualizations
- [ ] Trend analysis over time
- [ ] Smart recommendation engine
- [ ] Export capabilities
- [ ] Leverages structured quantity data
- [ ] Performance: < 1s for dashboard load

---

## 🔍 **RISK MANAGEMENT**

### **Current Risks: NONE**

All identified risks from M1-M3 have been successfully mitigated through:
- Phase-based incremental development
- Comprehensive validation at each step
- Performance monitoring throughout
- Transaction safety and rollback capabilities
- Professional architecture patterns

### **Future Considerations:**

**M4.3: Recipe Source Tracking**
- **Risk**: Core Data migration with many-to-many relationships
- **Mitigation**: Lightweight automatic migration, proper delete rules, comprehensive testing
- **Risk**: Performance with multiple recipe sources per item
- **Mitigation**: Fetch indexes, efficient queries, computed properties

**M5: CloudKit**
- **Risk**: Sync conflicts and network issues
- **Mitigation**: Conflict resolution strategy, offline-first design, comprehensive error handling

**M6: Testing**
- **Risk**: Time investment may exceed estimate
- **Mitigation**: Focus on critical paths first, expand coverage iteratively

### **Technical Debt: NONE**

Clean architecture maintained throughout M1-M4.3.4 with:
- Service layer separation
- Clear data models
- Performance optimization
- Comprehensive documentation
- Zero shortcuts or workarounds

---

## 📚 **RELATED DOCUMENTATION**

### **Current Milestone:**
- [M4 PRD](prds/milestone-4-meal-planning-and-settings-integration.md) - Complete requirements
- [M4.3.5 PRD](prds/milestone-4.3.5-ingredient-normalization.md) - Ingredient normalization (50+ pages)
- [M4 Current Story](current-story.md) - Current development state
- [M4.3.5 Next Prompt](next-prompt.md) - Ready for M4.3.5 implementation

### **Completed Milestones:**
- [M1 Learning Notes](learning-notes/01-10-milestone-1-phases.md)
- [M2 Learning Notes](learning-notes/11-m2.1-recipe-architecture.md through 13)
- [M3 Phase 1-2 Learning Notes](learning-notes/12-m3-phase1-2-structured-quantities.md)
- [M3 Phase 3 Learning Notes](learning-notes/13-m3-phase3-data-migration.md)
- [M3 Phase 4 Learning Notes](learning-notes/14-m3-phase4-recipe-scaling.md)
- [M3 Phase 5 Learning Notes](learning-notes/15-m3-phase5-quantity-consolidation.md)
- [M3 Phase 6 Learning Notes](learning-notes/16-m3-phase6-ui-polish.md)
- [M3.5 Learning Notes](learning-notes/17-m3.5-foundation-validation.md)
- [M4.1 Learning Notes](learning-notes/18-m4.1-settings-infrastructure.md)
- [M4.2 Learning Notes](learning-notes/19-m4.2-calendar-meal-planning.md)
- [M4.3.1 Learning Notes](learning-notes/22-m4.3.1-recipe-source-tracking.md)
- M4.3.3-4 Learning Notes - To be created

### **Architecture & Requirements:**
- [Requirements Document](requirements.md)
- [Project Index](project-index.md)
- [Architecture Decision Records](architecture/)
- [Product Requirements Documents](prds/)

---

## 🎉 **ACHIEVEMENTS TO DATE**

### **M1 Highlights:**
- Professional store-layout optimized grocery lists
- Custom category management with drag-and-drop
- Staple item system with auto-population
- Zero-error Core Data implementation
- Sub-0.1s query performance

### **M2 Highlights:**
- Complete recipe CRUD operations
- Unified IngredientTemplate normalization system
- Recipe-to-grocery integration with category preservation
- Parse-then-autocomplete for efficient ingredient entry
- Fuzzy matching and smart template alignment
- Multi-field search with intelligent ranking
- Usage analytics and favorite tracking

### **M3 Highlights:**
- Structured quantity system with 95%+ parsing accuracy
- Recipe scaling with kitchen-friendly fractions (0.25x-4x)
- Intelligent shopping list consolidation (30-50% redundancy reduction)
- Professional unit conversion system (volume and weight)
- Source tracking across recipes
- Sub-0.3s consolidation analysis for 50+ items
- Transaction safety with zero data loss
- 100% migration success rate
- Visual indicators and consolidation badges
- Comprehensive in-app help documentation (HelpView.swift)
- All performance targets exceeded

### **M4 Highlights (In Progress):**
- Professional settings infrastructure with UserPreferences ✅
- Calendar-based meal planning with date pickers ✅
- MealPlan and PlannedMeal entities operational ✅
- Recipe usage tracking (usageCount, lastUsed) ✅
- Recipe source tracking with many-to-many relationships ✅
- Scaled recipe to shopping list with servings adjustment ✅
- Bulk add from meal plan with progress overlay ✅
- Meal completion tracking with flexible UX ✅
- Sheet pattern discovery and fix ✅
- Ingredient normalization ready to implement 🚀

### **Platform Readiness:**
- Meal planning foundation complete ✅
- Recipe source tracking complete ✅
- Scaled recipe to list operational ✅
- Bulk add from meal plan operational ✅
- Meal completion tracking operational ✅
- Smart consolidation ready (M3 Phase 5) ✅
- Analytics-ready data structures ✅
- CloudKit-ready architecture ✅
- Comprehensive documentation ✅
- Professional UI throughout ✅
- Exceptional performance metrics ✅
- Production-ready quality ✅

---

**Next Action**: Begin M4.3.5 Ingredient Normalization (4 hours) or wrap up M4 for TestFlight

**Status**: M1-M4.3.4 complete with ~81.25 hours total. M4.3.5 ready to begin with complete 50+ page PRD, 4-phase implementation plan, and strong technical foundation. Normalization will improve data quality by eliminating 30-50% of duplicate ingredient templates through intelligent name standardization. Optional - can defer to post-TestFlight if desired.