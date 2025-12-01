# Product Requirements Document: M4.2.4 - Multiple Meal Plans List View

**Document Version**: 1.0  
**Created**: October 28, 2025  
**Priority**: HIGH - Completes M4.2 meal planning foundation  
**Estimated Duration**: 1.5 hours  
**Milestone**: M4.2 (Calendar-Based Meal Planning Core)  
**Task**: M4.2.4 (Multiple Meal Plans List View)

---

## Executive Summary

Transform meal planning from a single "active plan" view to a comprehensive list-based architecture matching the proven WeeklyListsView pattern. Enable users to manage multiple concurrent meal plans (current week, upcoming weeks, special occasions), view historical plans, and seamlessly navigate between plan management and calendar details.

---

## Problem Statement

### Current State (M4.2.1-3)
- Single "active" meal plan view only
- No way to see multiple plans or history
- Cannot plan ahead for upcoming weeks
- No special occasion planning (holidays, parties)
- Doesn't match grocery list pattern (WeeklyListsView)

### User Pain Points
- "I want to plan next week while this week's plan is active"
- "I need a separate plan for my holiday dinner"
- "I can't see what I cooked last week"
- "Why does grocery lists have history but meal planning doesn't?"

### Business Impact
- Inconsistent UX patterns reduce usability
- Limited planning flexibility reduces feature value
- No historical data limits analytics potential (M7)
- Missing competitive feature (multi-week planning)

---

## Solution Overview

### Core Enhancement
Build MealPlansListView following proven WeeklyListsView architecture, enabling:
- List of all meal plans (active, upcoming, completed)
- Create new plans with smart defaults
- Navigate to plan-specific calendar detail view
- Collapsible "Completed Plans" section for history
- Date overlap validation to maintain data integrity

### Key User Flows

**Flow 1: View All Plans**
```
1. User taps "Meal Planning" tab
2. Sees list of all meal plans
3. Active plan highlighted at top
4. Upcoming plans below
5. Completed plans in collapsed section at bottom
```

**Flow 2: Create New Plan**
```
1. User taps "+" button
2. Creation sheet appears with smart defaults
3. User optionally customizes name/dates
4. System validates no date overlap
5. Plan created, navigates to calendar detail
```

**Flow 3: View Plan Details**
```
1. User taps plan from list
2. Navigates to MealPlanDetailView (existing calendar)
3. Views assigned recipes for that specific plan
4. Can add/remove recipes as normal
```

**Flow 4: Add Recipe to Plan**
```
1. User browsing recipes, taps "Add to Meal Plan"
2. SelectMealPlanSheet appears (like SelectListSheet)
3. Active plan pre-selected
4. User selects date within plan
5. Recipe assigned, confirmation shown
```

---

## Architecture Decisions

### Decision 1: Active Plan State Machine

**Problem**: How to manage which plan is "active" when multiple exist?

**Solution**: Smart auto-activation based on date ranges
```swift
Plan Status Logic:
- Active:    startDate <= today <= endDate && !isCompleted
- Upcoming:  startDate > today && !isCompleted  
- Completed: endDate < today OR isCompleted == true

Rules:
1. Only one plan can be active at a time
2. Plan containing today's date = active
3. If no plan contains today = no active plan
4. Auto-transition: Daily check updates isActive flags
```

**Rationale**: Automatic, predictable, no manual management required

### Decision 2: Date Overlap Prevention

**Problem**: What if user creates overlapping meal plans?

**Solution**: Hard block with validation
```swift
Validation Rules:
1. Check existing plans during creation/editing
2. Prevent any date overlap between plans
3. Show clear error: "Dates overlap with [Plan Name]"
4. Suggest alternative dates

Edge Case: Legacy data with overlaps
- Migration: Mark newest as active, others as completed
- Show warning in UI
```

**Rationale**: Maintains data integrity, simplifies logic, prevents confusion

### Decision 3: One Recipe Per Day

**Problem**: Should users be able to assign multiple recipes to same day?

**Solution**: One recipe per day (M4.2.4 scope)
```swift
Behavior:
- Assigning recipe to date with existing recipe
- Option 1: Replace (with confirmation)
- Option 2: Select different date
- NO: Multiple meals per day (future enhancement)

Future: M5+ could add breakfast/lunch/dinner
```

**Rationale**: Simple, clear, sufficient for MVP, matches user mental model

### Decision 4: Plan Naming

**Problem**: How should plans be named?

**Solution**: Allow custom, default to auto-generate
```swift
Naming Logic:
1. User can provide custom name (optional)
2. If empty, auto-generate from M4.1 preferences
3. Auto-generated format: "Week of Oct 28 - Nov 3"
4. Special format for custom: Show custom name prominently

From M4.1 UserPreferences:
- autoNameMealPlans: Bool (default: true)
- If true: Always auto-generate unless user types custom
- If false: Prompt for name during creation
```

**Rationale**: Flexibility with smart defaults, matches user expectation

### Decision 5: Completed Plans Display

**Problem**: How to show historical plans without cluttering UI?

**Solution**: Collapsible section, collapsed by default
```swift
List Structure:
┌────────────────────────┐
│ Active Plans           │
│  • Week of Oct 28 (5/7)│ ← Active, always at top
│                        │
│ Upcoming Plans         │
│  • Week of Nov 4       │
│  • Holiday Dinner      │
│                        │
│ ▸ Completed Plans (12) │ ← Collapsed by default
│   [Tap to expand]      │
└────────────────────────┘

When expanded:
│ ▾ Completed Plans (12) │
│  • Week of Oct 21      │
│  • Week of Oct 14      │
│  • ...                 │

Benefits:
- Historical data preserved
- Recipe usage tracking maintained
- UI not cluttered
- Easy access when needed
```

**Rationale**: Balances history access with clean UI, matches iOS patterns

---

## Core Data Schema Changes

### New Properties on MealPlan

```swift
MealPlan {
    // Existing
    id: UUID
    name: String?
    startDate: Date
    duration: Int32
    isActive: Bool
    
    // NEW - M4.2.4 Additions
    isCompleted: Bool        // Completion status
    completedDate: Date?     // When completed (auto or manual)
    
    // Relationships (existing)
    plannedMeals: [PlannedMeal]
}
```

### Migration Notes
- Add isCompleted (default: false)
- Add completedDate (optional)
- Run completion check on existing plans
- No destructive changes

---

## Service Layer Enhancements

### MealPlanService New Methods

```swift
// Date Validation
func validatePlanDates(
    startDate: Date, 
    duration: Int, 
    excludingPlan: MealPlan?
) -> ValidationResult {
    // Returns .valid or .overlapsWithPlan(name: String)
}

// Status Management
func updateActivePlanStatus(in context: NSManagedObjectContext) {
    // Run on app launch and plan transitions
    // Updates isActive based on dates
}

func updateCompletedStatus(in context: NSManagedObjectContext) {
    // Auto-complete plans where endDate < today
    // Updates isCompleted and completedDate
}

// Query Helpers
func getActivePlan(in context: NSManagedObjectContext) -> MealPlan? {
    // Returns current active plan (if any)
}

func getUpcomingPlans(in context: NSManagedObjectContext) -> [MealPlan] {
    // Returns future plans, sorted by start date
}

func getCompletedPlans(in context: NSManagedObjectContext) -> [MealPlan] {
    // Returns completed plans, sorted by completion date desc
}
```

---

## User Interface Specifications

### MealPlansListView (New)

**Layout**:
```
NavigationView {
    List {
        Section(header: "Active") {
            // Active plan (if any)
        }
        
        Section(header: "Upcoming") {
            // Future plans
            // Empty state: "No upcoming plans"
        }
        
        Section(header: "Completed Plans") {
            DisclosureGroup(isExpanded: $showCompleted) {
                // Completed plans
            }
        }
    }
    .navigationTitle("Meal Plans")
    .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: createNewPlan) {
                Image(systemName: "plus")
            }
        }
    }
}
```

**Empty State** (No plans at all):
```
VStack {
    Image(systemName: "calendar.badge.plus")
        .font(.system(size: 60))
        .foregroundColor(.blue)
    
    Text("No Meal Plans Yet")
        .font(.title2)
        .fontWeight(.semibold)
    
    Text("Create your first meal plan to start organizing your weekly meals")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
    
    Button("Create Meal Plan") {
        // Show creation sheet
    }
}
```

### MealPlanRowView (New)

**Display Elements**:
```
┌─────────────────────────────────────┐
│ 📅 Week of Oct 28 - Nov 3           │  ← Plan name
│ 5 of 7 days planned                 │  ← Progress
│ Active • 7 days                     │  ← Status & duration
│                                     │
│ [→]                                 │  ← Navigation indicator
└─────────────────────────────────────┘
```

**Status Indicators**:
- **Active**: Green dot + "Active" label
- **Upcoming**: Blue dot + start date
- **Completed**: Gray checkmark + completion date

**Progress Display**:
- "X of Y days planned"
- Optional: Progress bar (75% filled)
- Show recipe names on hover/long-press (future)

### SelectMealPlanSheet (New)

**Purpose**: Choose which plan to add recipe to (like SelectListSheet)

**Layout**:
```
┌─────────────────────────────────┐
│ Add to Meal Plan                │
├─────────────────────────────────┤
│ Select Plan:                    │
│                                 │
│ ⦿ Week of Oct 28 (Active)       │ ← Pre-selected
│ ○ Week of Nov 4                 │
│ ○ Holiday Dinner                │
│                                 │
│ [+ Create New Meal Plan]        │
│                                 │
│ Select Date:                    │
│ [Oct 29, 2025 ▼]               │
│                                 │
│        [Cancel]    [Add]        │
└─────────────────────────────────┘
```

**Behavior**:
1. Active plan pre-selected
2. Date picker shows dates within selected plan
3. Grayed out dates already have recipes
4. "Create New" expands inline form
5. After selection, recipe assigned + confirmation

### CreateMealPlanSheet (New)

**Purpose**: Quick plan creation (from list or recipe flow)

**Layout**:
```
┌─────────────────────────────────┐
│ Create Meal Plan                │
├─────────────────────────────────┤
│ Name (optional):                │
│ [Week of Oct 28 - Nov 3]       │ ← Auto-generated
│                                 │
│ Start Date:                     │
│ [Oct 28, 2025]                 │
│                                 │
│ Duration:                       │
│ [7 days ▼]                     │ ← From M4.1 prefs
│                                 │
│        [Cancel]  [Create]       │
└─────────────────────────────────┘
```

**Smart Defaults** (from M4.1):
- Duration: `UserPreferencesService.shared.mealPlanDuration`
- Start day: Next occurrence of preferred start day
- Name: Auto-generate if empty

**Validation**:
- Check date overlap before creation
- Show error: "Dates overlap with [Plan Name]"
- Suggest next available dates

### MealPlanDetailView (Refactored)

**Changes from current MealPlanView**:
```swift
// BEFORE (M4.2.1-3):
struct MealPlanView: View {
    @FetchRequest(
        predicate: NSPredicate(format: "isActive == YES")
    ) private var activePlans: FetchedResults<MealPlan>
    
    var activePlan: MealPlan? { activePlans.first }
}

// AFTER (M4.2.4):
struct MealPlanDetailView: View {
    @ObservedObject var mealPlan: MealPlan  // Passed from list
    
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    init(mealPlan: MealPlan) {
        self.mealPlan = mealPlan
        // Filter plannedMeals for THIS specific plan
    }
}
```

**Navigation Title**:
- Show plan name or auto-generated date range
- Add edit button for name/dates

**No other changes** - calendar logic stays the same

---

## Recipe Usage Tracking Enhancement

### Critical Change: When to Track Usage

**CURRENT (M2)**:
```swift
// Recipe usage tracked when added to grocery list
func addIngredientsToList(...) {
    recipe.usageCount += 1
    recipe.lastUsed = Date()  // Today
}
```

**NEW (M4.2.4)**:
```swift
// Recipe usage tracked when added to meal plan
func addRecipeToMealPlan(recipe: Recipe, date: Date, mealPlan: MealPlan) {
    // Create planned meal
    let plannedMeal = PlannedMeal(context: context)
    plannedMeal.date = date
    plannedMeal.mealPlan = mealPlan
    plannedMeal.recipe = recipe
    
    // Update recipe tracking - CHANGED
    recipe.usageCount += 1
    recipe.lastUsed = date  // Planned meal date, not today!
    
    try context.save()
}
```

### Why This Change Makes Sense

**Problem with old approach**:
- Adding to grocery list ≠ cooking
- Multiple grocery list additions = inflated count
- No connection to actual meal planning

**Benefits of new approach**:
- ✅ Meal plan = intent to cook (better signal)
- ✅ One assignment per day = accurate count
- ✅ `lastUsed` = when you plan to cook it (meaningful date)
- ✅ Future analytics: "You made tacos on Nov 1, Nov 15, Dec 3"

**Migration**: No data migration needed (fresh feature)

**Note**: Remove tracking from AddIngredientsToListView (M2 code)

---

## Implementation Phases

### Phase 1: Core Data Updates (15 min)

**Tasks**:
1. Add `isCompleted: Bool` to MealPlan entity
2. Add `completedDate: Date?` to MealPlan entity
3. Update model version and create mapping model
4. Build and verify schema

**Files Modified**:
- `forager.xcdatamodeld`

### Phase 2: Service Layer Enhancements (25 min)

**Tasks**:
1. Add date validation methods
2. Add status update methods
3. Add query helper methods
4. Update recipe tracking in addRecipeToMealPlan

**New Methods**:
```swift
MealPlanService {
    func validatePlanDates(...) -> ValidationResult
    func updateActivePlanStatus(...)
    func updateCompletedStatus(...)
    func getActivePlan() -> MealPlan?
    func addRecipeToMealPlan(recipe: Recipe, date: Date, plan: MealPlan)
}
```

**Files Modified**:
- `Services/MealPlanService.swift`

### Phase 3: Create MealPlansListView (30 min)

**Tasks**:
1. Create main list view structure
2. Add sections (Active/Upcoming/Completed)
3. Implement empty state
4. Add create button and navigation
5. Add collapsible completed section

**Files Created**:
- `Views/MealPlansListView.swift`

**Pattern**: Follow WeeklyListsView architecture exactly

### Phase 4: Create MealPlanRowView (15 min)

**Tasks**:
1. Create row component
2. Display plan name/date range
3. Show progress (X of Y days)
4. Add status indicator
5. Configure @FetchRequest for plan's meals

**Files Created**:
- `Views/MealPlanRowView.swift`

### Phase 5: Refactor to MealPlanDetailView (10 min)

**Tasks**:
1. Rename MealPlanView → MealPlanDetailView
2. Change from "fetch active" to "passed plan"
3. Update @FetchRequest to filter by plan ID
4. Update navigation title

**Files Modified**:
- `Views/MealPlanView.swift` → `Views/MealPlanDetailView.swift`

### Phase 6: Create Supporting Views (15 min)

**Tasks**:
1. Create SelectMealPlanSheet (for recipe deep linking)
2. Create CreateMealPlanSheet (quick creation)
3. Wire up navigation flows

**Files Created**:
- `Views/SelectMealPlanSheet.swift`
- `Views/CreateMealPlanSheet.swift`

### Phase 7: Update Tab Structure & Integration (10 min)

**Tasks**:
1. Update foragerApp.swift
2. Change tab to MealPlansListView
3. Update RecipeListView "Add to Meal Plan" button
4. Update RecipeDetailView "Add to Meal Plan" section
5. Test navigation flows

**Files Modified**:
- `foragerApp.swift`
- `Views/RecipeListView.swift`
- `Views/RecipeDetailView.swift`

**Total Time**: 120 minutes (2 hours) - includes buffer

---

## Acceptance Criteria

### Functional Requirements

**List Management**:
- [ ] MealPlansListView displays all meal plans
- [ ] Plans organized into Active/Upcoming/Completed sections
- [ ] Completed section collapsed by default
- [ ] Empty state for new users
- [ ] Create new plan button functional
- [ ] Tap plan navigates to detail view
- [ ] Swipe to delete plans

**Active Plan Logic**:
- [ ] Only one plan marked active at a time
- [ ] Plan containing today's date = active
- [ ] Auto-transition when dates change
- [ ] isActive flag updated on app launch

**Date Validation**:
- [ ] Cannot create overlapping plans
- [ ] Clear error message when overlap detected
- [ ] Validation during creation and editing

**Plan Completion**:
- [ ] Plans auto-complete when end date passes
- [ ] Manual "Mark Complete" action available
- [ ] Completed plans move to collapsed section
- [ ] Can reopen completed plans

**Recipe Tracking** (CHANGED):
- [ ] usageCount increments when added to meal plan
- [ ] lastUsed set to planned meal date (not today)
- [ ] Tracking removed from AddIngredientsToListView
- [ ] One increment per meal plan assignment

**Recipe Deep Linking**:
- [ ] "Add to Meal Plan" shows plan picker
- [ ] Active plan pre-selected
- [ ] Can create new plan from picker
- [ ] Date selection within chosen plan
- [ ] Assigns recipe and confirms

### Non-Functional Requirements

**Performance**:
- [ ] List loads < 0.1s
- [ ] Navigation < 0.1s
- [ ] All operations < 0.5s
- [ ] No UI lag (60fps)

**Pattern Compliance**:
- [ ] Matches WeeklyListsView architecture
- [ ] Follows established navigation patterns
- [ ] Uses proven @FetchRequest patterns
- [ ] Professional iOS UI maintained

**Code Quality**:
- [ ] Function header comments
- [ ] MARK section comments
- [ ] M4.2.4 references in code
- [ ] No build warnings or errors

**Integration**:
- [ ] M4.1 preferences used for defaults
- [ ] Existing M4.2 calendar features work
- [ ] Recipe assignment from list view works
- [ ] Zero regressions to existing features

---

## Testing Plan

### Test 1: List Display
1. Create 3 meal plans (past, current, future)
2. Verify active plan at top
3. Verify upcoming plans in order
4. Verify completed in collapsed section
5. Tap completed section, verify expands

### Test 2: Plan Creation
1. Tap "+" button
2. Verify smart defaults from M4.1
3. Create plan with auto-generated name
4. Create plan with custom name
5. Verify appears in list

### Test 3: Date Overlap Validation
1. Create plan Oct 28 - Nov 3
2. Try to create plan Oct 30 - Nov 6
3. Verify error shown
4. Verify suggests next available dates
5. Create non-overlapping plan, verify success

### Test 4: Active Plan Logic
1. Create plan for today
2. Verify marked active
3. Create second plan containing today
4. Verify newest is active
5. Kill app, relaunch
6. Verify active status persists

### Test 5: Recipe Tracking (CHANGED)
1. Create meal plan for Nov 1-7
2. Add "Tacos" recipe to Nov 1
3. Verify recipe.usageCount = 1
4. Verify recipe.lastUsed = Nov 1 (not today)
5. Add same recipe to Nov 5
6. Verify recipe.usageCount = 2
7. Verify recipe.lastUsed = Nov 5

### Test 6: Recipe Deep Linking
1. Browse recipes, tap "Add to Meal Plan"
2. Verify SelectMealPlanSheet appears
3. Verify active plan pre-selected
4. Select date, add recipe
5. Navigate to plan, verify recipe assigned

### Test 7: Plan Completion
1. Create plan with past dates
2. Launch app
3. Verify plan auto-completed
4. Verify moved to completed section
5. Swipe plan, tap "Mark Complete"
6. Verify manual completion works

### Test 8: Navigation
1. List → Detail → back = smooth
2. Create plan → auto-navigate to detail
3. Add recipe → picker → add → returns correctly
4. All transitions smooth (60fps)

### Test 9: Performance
1. Create 20 meal plans
2. Verify list loads < 0.1s
3. Scroll list, verify smooth
4. Navigate to detail < 0.1s
5. All operations meet targets

### Test 10: Edge Cases
1. No plans exist → empty state
2. Only completed plans → show message
3. Delete active plan → no active plan
4. Device rotation → layout adapts
5. Memory warnings → no crashes

---

## Migration & Rollout

### Core Data Migration
```swift
// Add new properties
MealPlan:
  + isCompleted: Bool (default: false)
  + completedDate: Date? (default: nil)

// Run status check on existing plans
func migrateExistingPlans() {
    let plans = fetch all plans
    for plan in plans {
        let endDate = plan.startDate + plan.duration days
        if endDate < Date() {
            plan.isCompleted = true
            plan.completedDate = endDate
        }
    }
}
```

### Recipe Tracking Migration
```swift
// Remove tracking from AddIngredientsToListView
// Lines to remove:
- recipe.usageCount += 1
- recipe.lastUsed = Date()

// Add tracking to addRecipeToMealPlan in MealPlanService
+ recipe.usageCount += 1
+ recipe.lastUsed = plannedMeal.date
```

### User Communication
- First launch after update: No special messaging needed
- Feature just works better
- Historical usage counts unchanged
- Future tracking more accurate

---

## Future Enhancements (Out of Scope)

**For M4.3**:
- Bulk add all recipes to shopping list
- Recipe source tracking in lists
- Smart quantity consolidation

**For M5+**:
- Multiple meals per day (breakfast/lunch/dinner)
- CloudKit sync for family sharing
- Drag-and-drop recipe reordering
- Duplicate/template plans
- Recipe suggestions based on history

**For M7+**:
- Analytics: most cooked recipes
- Seasonal pattern analysis
- Shopping cost projections
- Nutrition summaries per plan

---

## Success Metrics

**Functional Success**:
- All acceptance criteria met
- Zero regressions to M4.2.1-3 features
- Recipe tracking works correctly
- Date validation prevents overlaps

**Technical Success**:
- Performance targets met (< 0.1s)
- Code follows established patterns
- WeeklyListsView architecture replicated
- Zero technical debt introduced

**User Experience Success**:
- Clear plan organization
- Intuitive navigation
- Helpful empty states
- Professional iOS polish

---

## Related Documentation

### Dependencies
- **M4.1**: UserPreferencesService for defaults ✅
- **M4.2.1-3**: MealPlan/PlannedMeal entities, service, calendar ✅
- **M1**: WeeklyListsView pattern reference ✅

### Impacts
- **M4.3**: Uses completed list view architecture
- **M7**: Recipe usage analytics from new tracking
- **M5**: Family sharing uses multi-plan structure

### Files to Update After Implementation
- `docs/current-story.md` - Mark M4.2.4 complete
- `docs/learning-notes/19-m4.2-calendar-meal-planning.md` - Add list view pattern
- `docs/next-prompt.md` - Update for M4.3

---

## Appendix: Design Mockups

### List View States

**Empty State**:
```
┌───────────────────────────────────┐
│                                   │
│         🗓️                        │
│                                   │
│    No Meal Plans Yet              │
│                                   │
│  Create your first meal plan to   │
│  start organizing your weekly     │
│  meals                            │
│                                   │
│    [Create Meal Plan]             │
│                                   │
└───────────────────────────────────┘
```

**With Plans**:
```
┌───────────────────────────────────┐
│ Meal Plans              [+]       │
├───────────────────────────────────┤
│ ACTIVE                            │
│ ┌─────────────────────────────┐   │
│ │ 📅 Week of Oct 28 - Nov 3   │   │
│ │ 5 of 7 days planned         │   │
│ │ Active • 7 days          →  │   │
│ └─────────────────────────────┘   │
│                                   │
│ UPCOMING                          │
│ ┌─────────────────────────────┐   │
│ │ 📅 Week of Nov 4 - Nov 10   │   │
│ │ 2 of 7 days planned         │   │
│ │ Starts in 7 days         →  │   │
│ └─────────────────────────────┘   │
│ ┌─────────────────────────────┐   │
│ │ 🎉 Holiday Dinner           │   │
│ │ 3 of 5 days planned         │   │
│ │ Dec 20 • 5 days          →  │   │
│ └─────────────────────────────┘   │
│                                   │
│ ▸ COMPLETED PLANS (12)            │
│                                   │
└───────────────────────────────────┘
```

**Expanded Completed**:
```
│ ▾ COMPLETED PLANS (12)            │
│ ┌─────────────────────────────┐   │
│ │ ✓ Week of Oct 21 - Oct 27   │   │
│ │ 6 of 7 days planned         │   │
│ │ Completed Oct 27         →  │   │
│ └─────────────────────────────┘   │
│ ┌─────────────────────────────┐   │
│ │ ✓ Week of Oct 14 - Oct 20   │   │
│ │ 7 of 7 days planned         │   │
│ │ Completed Oct 20         →  │   │
│ └─────────────────────────────┘   │
```

### Plan Selection Sheet

```
┌───────────────────────────────────┐
│ Add Tacos to Meal Plan       [X]  │
├───────────────────────────────────┤
│                                   │
│ Select Plan:                      │
│                                   │
│ ⦿ Week of Oct 28 - Nov 3          │
│   Active • 5 of 7 days            │
│                                   │
│ ○ Week of Nov 4 - Nov 10          │
│   Upcoming • 2 of 7 days          │
│                                   │
│ ┌─────────────────────────────┐   │
│ │ + Create New Meal Plan      │   │
│ └─────────────────────────────┘   │
│                                   │
│ Select Date:                      │
│ ┌─────────────────────────────┐   │
│ │ October 29, 2025        ▼   │   │
│ └─────────────────────────────┘   │
│                                   │
│                                   │
│        [Cancel]      [Add Recipe] │
└───────────────────────────────────┘
```

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Next Action**: Update current-story.md and next-prompt.md  
**Implementation Window**: During M4.2 (after M4.2.3 calendar complete)