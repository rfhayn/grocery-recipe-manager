# M4.2.4: Multiple Meal Plans List View - Development Prompt

**Copy and paste this prompt when ready to begin M4.2.4:**

---

I'm ready to begin **M4.2.4: Multiple Meal Plans List View** for my Grocery & Recipe Manager iOS app.

## M4.2.1-3 COMPLETE ✅

**Completion Date**: [TO BE FILLED]  
**Total Time**: [ACTUAL_HOURS] hours (target: 2.5 hours)  
**Status**: Production Ready

### **M4.2.1-3 Final Achievements:**
- ✅ MealPlan and PlannedMeal Core Data entities operational
- ✅ MealPlanService with CRUD operations
- ✅ MealPlanView with calendar display
- ✅ Recipe assignment workflow functional
- ✅ M4.1 preferences integrated
- ✅ All tests passed
- ✅ Zero regressions, production quality

### **Key M4.2.1-3 Deliverables:**
- **Core Data Entities**: MealPlan, PlannedMeal with relationships
- **MealPlanService** - Plan management and recipe assignment
- **MealPlanView** - Calendar showing assigned recipes
- **Recipe Integration** - "Add to Meal Plan" from recipe views
- **Performance** - All operations < 0.1s

### **Foundation Ready for M4.2.4:**
- ✅ Entities operational and tested
- ✅ Service layer functional
- ✅ Calendar view working
- ✅ Recipe assignment tested
- ✅ Ready to add list management layer

---

## M4.2.4 Overview: Multiple Meal Plans List View

**Total Estimated Time**: 1.5 hours (90 minutes)  
**Priority**: HIGH - Completes meal planning foundation  
**Dependencies**: M4.2.1-3 Complete ✅  
**PRD**: `docs/prds/m4.2.4-multiple-meal-plans-list-view-prd.md` ✅

### **Strategic Value:**
Transform meal planning from single "active plan" view to comprehensive list-based architecture matching proven WeeklyListsView pattern. Enables multiple concurrent plans, historical tracking, and improved recipe usage analytics.

### **What We're Building:**
- MealPlansListView (main entry point) matching WeeklyListsView
- MealPlanRowView (row component) with progress indicators
- SelectMealPlanSheet (plan picker) for recipe deep linking
- CreateMealPlanSheet (quick creation) with smart defaults
- MealPlanDetailView (refactored from MealPlanView)
- Active plan state machine with auto-transition
- Date overlap validation (hard block)
- Recipe usage tracking enhancement

### **Architecture Pattern:**
```
Before (M4.2.1-3):               After (M4.2.4):
                                 
Meal Planning Tab                Meal Planning Tab
      ↓                                ↓
MealPlanView                     MealPlansListView (NEW)
├── Single active plan           ├── All meal plans listed
├── Calendar display             ├── Active/Upcoming/Completed
└── Recipe assignment            ├── Create new plan button
                                 └── Tap → MealPlanDetailView
                                          ├── Calendar display
                                          └── Recipe assignment
```

### **Critical Enhancements:**

**1. Active Plan State Machine:**
```swift
Status Logic:
- Active:    startDate <= today <= endDate && !isCompleted
- Upcoming:  startDate > today && !isCompleted  
- Completed: endDate < today OR isCompleted == true

Rules:
- Only one plan active at a time
- Plan containing today = active
- Auto-transition on app launch
```

**2. Recipe Usage Tracking (CHANGED):**
```swift
// OLD (M2): Track when added to grocery list
// NEW (M4.2.4): Track when added to meal plan

func addRecipeToMealPlan(recipe: Recipe, date: Date, plan: MealPlan) {
    // ... create PlannedMeal
    recipe.usageCount += 1
    recipe.lastUsed = date  // Planned meal date, not today!
}

// REMOVE tracking from AddIngredientsToListView
```

**3. Date Overlap Prevention:**
- Hard block: No overlapping dates
- Validation during creation/editing
- Clear error messages

**4. One Recipe Per Day:**
- Enforced in UI
- Replace or pick different date
- Simple, clear user model

---

## Implementation Plan (1.5 hours)

### **Phase 1: Core Data Updates** (15 min)

**Add Completion Fields:**
```swift
MealPlan {
    // Existing
    id, name, startDate, duration, isActive
    
    // NEW
    isCompleted: Bool (default: false)
    completedDate: Date? (optional)
}
```

**Tasks:**
1. Open GroceryRecipeManager.xcdatamodeld
2. Add isCompleted: Bool attribute
3. Add completedDate: Date (optional)
4. Update model version
5. Build and verify (⌘B)

**Validation:**
- ✅ Build succeeds
- ✅ No migration errors
- ✅ New properties accessible

---

### **Phase 2: Service Layer Enhancements** (25 min)

**MealPlanService New Methods:**
```swift
// Date Validation
func validatePlanDates(
    startDate: Date,
    duration: Int,
    excludingPlan: MealPlan?
) -> ValidationResult {
    // Check for overlaps with existing plans
    // Return .valid or .overlapsWithPlan(name: String)
}

// Status Management  
func updateActivePlanStatus(in context: NSManagedObjectContext) {
    // Update isActive based on dates
    // Run on app launch
}

func updateCompletedStatus(in context: NSManagedObjectContext) {
    // Auto-complete plans where endDate < today
}

// Query Helpers
func getActivePlan() -> MealPlan?
func getUpcomingPlans() -> [MealPlan]
func getCompletedPlans() -> [MealPlan]
```

**Update Recipe Tracking:**
```swift
// In addRecipeToMealPlan method:
func addRecipeToMealPlan(recipe: Recipe, date: Date, mealPlan: MealPlan) {
    let plannedMeal = PlannedMeal(context: context)
    plannedMeal.date = date
    plannedMeal.mealPlan = mealPlan
    plannedMeal.recipe = recipe
    
    // NEW: Update recipe tracking
    recipe.usageCount += 1
    recipe.lastUsed = date  // Planned date, not today!
    
    try context.save()
}
```

**Remove Old Tracking:**
- Find AddIngredientsToListView
- Remove: `recipe.usageCount += 1`
- Remove: `recipe.lastUsed = Date()`

**Validation:**
- ✅ All methods compile
- ✅ Date validation works
- ✅ Status updates work
- ✅ Recipe tracking changed

---

### **Phase 3: Create MealPlansListView** (30 min)

**Follow WeeklyListsView Pattern:**
```swift
struct MealPlansListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.startDate, ascending: false)],
        animation: .default
    ) private var mealPlans: FetchedResults<MealPlan>
    
    @State private var showingCreateSheet = false
    @State private var showCompleted = false
    
    var body: some View {
        contentView
            .navigationTitle("Meal Plans")
            .toolbar { toolbarContent }
    }
    
    private var contentView: some View {
        // Empty state if no plans
        // List with sections: Active, Upcoming, Completed
    }
}
```

**Sections:**
1. **Active Plans** (green indicator)
2. **Upcoming Plans** (blue indicator)  
3. **Completed Plans** (collapsible, collapsed by default)

**Empty State:**
```swift
VStack {
    Image(systemName: "calendar.badge.plus")
        .font(.system(size: 60))
    Text("No Meal Plans Yet")
    Text("Create your first meal plan...")
    Button("Create Meal Plan") { ... }
}
```

**Validation:**
- ✅ Displays all plans correctly
- ✅ Empty state shows when appropriate
- ✅ Sections organized properly
- ✅ Create button works

---

### **Phase 4: Create MealPlanRowView** (15 min)

**Follow WeeklyListRowView Pattern:**
```swift
struct MealPlanRowView: View {
    @ObservedObject var mealPlan: MealPlan
    
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    init(mealPlan: MealPlan) {
        self.mealPlan = mealPlan
        
        // Configure FetchRequest for this plan's meals
        let planID = mealPlan.id ?? UUID()
        let predicate = NSPredicate(format: "mealPlan.id == %@", planID as CVarArg)
        self._plannedMeals = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \PlannedMeal.date, ascending: true)],
            predicate: predicate
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(mealPlan.displayName)
            Text("\(plannedMeals.count) of \(mealPlan.duration) days planned")
            Text(statusText)
        }
    }
}
```

**Display:**
- Plan name or date range
- Progress (X of Y days)
- Status badge

**Validation:**
- ✅ Shows plan info correctly
- ✅ Progress updates live
- ✅ Status indicator correct

---

### **Phase 5: Refactor to MealPlanDetailView** (10 min)

**Rename and Update:**
```swift
// BEFORE: MealPlanView
struct MealPlanView: View {
    @FetchRequest(predicate: NSPredicate(format: "isActive == YES"))
    private var activePlans: FetchedResults<MealPlan>
    
    var activePlan: MealPlan? { activePlans.first }
}

// AFTER: MealPlanDetailView
struct MealPlanDetailView: View {
    @ObservedObject var mealPlan: MealPlan  // Passed parameter
    
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    init(mealPlan: MealPlan) {
        self.mealPlan = mealPlan
        // Filter plannedMeals for THIS plan
    }
}
```

**Changes:**
1. Rename file
2. Add mealPlan parameter
3. Update @FetchRequest to filter by plan ID
4. Remove isActive filtering
5. Update navigation title

**Validation:**
- ✅ Compiles without errors
- ✅ Calendar shows correct plan
- ✅ All features still work

---

### **Phase 6: Create Supporting Views** (15 min)

**SelectMealPlanSheet:**
```swift
struct SelectMealPlanSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    var onSelect: (MealPlan, Date) -> Void
    
    @State private var selectedPlan: MealPlan?
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                // Plan picker (active pre-selected)
                // Date picker (within plan range)
                // Create new plan option
            }
        }
    }
}
```

**CreateMealPlanSheet:**
```swift
struct CreateMealPlanSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var startDate = Date()
    @State private var duration = UserPreferencesService.shared.mealPlanDuration
    
    var body: some View {
        Form {
            // Name field (optional, auto-generates)
            // Start date picker
            // Duration picker (from prefs)
        }
    }
}
```

**Validation:**
- ✅ Sheets present correctly
- ✅ Smart defaults work
- ✅ Date validation works
- ✅ Creates plans successfully

---

### **Phase 7: Update Tab & Integration** (10 min)

**GroceryRecipeManagerApp.swift:**
```swift
// BEFORE:
TabView {
    MealPlanView()
        .tabItem { ... }
}

// AFTER:
TabView {
    NavigationView {
        MealPlansListView()
    }
    .tabItem { ... }
}
```

**RecipeListView & RecipeDetailView:**
```swift
// Update "Add to Meal Plan" to use SelectMealPlanSheet
Button("Add to Meal Plan") {
    showingMealPlanSheet = true
}
.sheet(isPresented: $showingMealPlanSheet) {
    SelectMealPlanSheet(recipe: recipe) { plan, date in
        // Add recipe to plan
    }
}
```

**Validation:**
- ✅ Tab shows list view
- ✅ Navigation works smoothly
- ✅ Recipe deep linking works
- ✅ All flows tested

---

## Testing & Validation (Included in phases)

### **Test Scenarios:**

**Test 1: List Display**
- Create 3 plans (past, current, future)
- Verify active at top
- Verify upcoming below
- Verify completed in collapsed section

**Test 2: Active Plan Logic**
- Create plan containing today
- Verify marked active
- Create second plan containing today
- Verify newest is active
- Relaunch app, verify persists

**Test 3: Date Overlap**
- Create plan Oct 28 - Nov 3
- Try to create Oct 30 - Nov 6
- Verify error shown
- Create non-overlapping, verify success

**Test 4: Recipe Tracking (CRITICAL)**
- Create plan for Nov 1-7
- Add "Tacos" to Nov 1
- Verify usageCount = 1
- Verify lastUsed = Nov 1 (not today!)
- Add same recipe to Nov 5
- Verify usageCount = 2, lastUsed = Nov 5

**Test 5: Navigation**
- List → Detail → back (smooth)
- Create plan → auto-navigate
- Recipe → picker → add → return

**Test 6: Performance**
- All operations < 0.1s
- List scrolls smoothly
- No UI lag (60fps)

---

## Success Criteria - M4.2.4 Completion

### **Functional Requirements:**
- ✅ MealPlansListView shows all plans
- ✅ Plans organized (Active/Upcoming/Completed)
- ✅ Only one active plan at a time
- ✅ Date overlap validation prevents conflicts
- ✅ Recipe tracking changed to meal plan assignment
- ✅ lastUsed = planned date (not today)
- ✅ Create new plan with smart defaults
- ✅ Navigate to detail view
- ✅ Recipe deep linking with picker
- ✅ Completed section collapsible

### **Non-Functional Requirements:**
- ✅ List loads < 0.1s
- ✅ Navigation < 0.1s
- ✅ All operations < 0.5s
- ✅ Professional iOS UI
- ✅ Matches WeeklyListsView pattern
- ✅ Zero regressions to M4.2.1-3
- ✅ Code documentation complete

### **Integration Requirements:**
- ✅ M4.1 preferences used for defaults
- ✅ M4.2.1-3 calendar features work unchanged
- ✅ Recipe views updated for multi-plan support
- ✅ Ready for M4.3 grocery integration

---

## After M4.2.4 Completion

### **Immediate Next Steps:**
1. Create/update learning note: `docs/learning-notes/19-m4.2-calendar-meal-planning.md`
   - Include both calendar (M4.2.1-3) and list (M4.2.4) patterns
   - Document recipe tracking change rationale
   - Active plan state machine logic
   - WeeklyListsView pattern replication

2. Update `docs/current-story.md`:
   - Mark M4.2 (all components) ✅ COMPLETE
   - Add actual time for M4.2.4
   - Total M4.2 time (M4.2.1-3 + M4.2.4)

3. Update `docs/next-prompt.md` for M4.3:
   - Enhanced grocery integration prompt
   - Bulk add to shopping list
   - Recipe source tracking
   - Scaled recipe to list

4. Update `docs/project-index.md`:
   - Add M4.2 completion to Recent Activity
   - Update milestone tracking

### **M4.3 Preview:**
**Goal**: Enhanced grocery integration with meal plan automation  
**Time**: 3.5-4 hours  
**Dependencies**: M4.2 Complete ✅

**What We'll Build:**
- Bulk add all recipes from plan to shopping list
- Recipe source tracking ("Ground beef [Tacos] [Spaghetti]")
- Smart consolidation leveraging M3
- Scaled recipe to list feature (FEAT-001)
- Meal completion tracking

**Foundation Ready:**
- ✅ M4.2.4 multiple plans for flexible grocery generation
- ✅ M4.1 preferences for list scope and display
- ✅ M3 Phase 4 scaling service for serving adjustments
- ✅ M3 Phase 5 consolidation for list optimization
- ✅ Improved recipe tracking for better analytics

---

## What You'll Need

### **Files to Create:**
- `Views/MealPlansListView.swift` - Main list view
- `Views/MealPlanRowView.swift` - Row component
- `Views/SelectMealPlanSheet.swift` - Plan picker
- `Views/CreateMealPlanSheet.swift` - Quick creation

### **Files to Modify:**
- `GroceryRecipeManager.xcdatamodeld` - Add completion fields
- `Services/MealPlanService.swift` - Add validation and status methods
- `Views/MealPlanView.swift` → `Views/MealPlanDetailView.swift` - Rename and refactor
- `GroceryRecipeManagerApp.swift` - Update tab to list view
- `Views/RecipeListView.swift` - Update "Add to Meal Plan" button
- `Views/RecipeDetailView.swift` - Update "Add to Meal Plan" section
- `Views/AddIngredientsToListView.swift` - Remove old tracking

### **Documentation to Update:**
- `docs/current-story.md` - Mark M4.2 complete
- `docs/learning-notes/19-m4.2-calendar-meal-planning.md` - Complete journey
- `docs/next-prompt.md` - Prepare M4.3 prompt
- `docs/project-index.md` - Update recent activity

---

## Current Progress

**M4 Timeline:**
- **M4.1**: 1.5 hours ✅ COMPLETE
- **M4.2**: [M4.2.1-3 HOURS] + 1.5 hours (M4.2.4) ← **IN PROGRESS**
- **M4.3**: 3.5-4 hours (after M4.2)
- **Total**: ~9-10 hours

**Milestone Status**: M4.1 complete with production quality. M4.2.1-3 calendar complete and tested. Ready to add M4.2.4 list management layer.

**Next Action**: Implement M4.2.4 following phase breakdown, leveraging WeeklyListsView pattern.

---

**Please help me implement M4.2.4: Multiple Meal Plans List View with list management, active plan logic, recipe tracking enhancement, and date validation following the proven WeeklyListsView architecture.**