# M4.2: Calendar-Based Meal Planning Core - Development Prompt

**Copy and paste this prompt when ready to begin M4.2:**

---

I'm ready to begin **M4.2: Calendar-Based Meal Planning Core** for my Grocery & Recipe Manager iOS app.

## M4.1 COMPLETE ✅

**Completion Date**: October 23, 2025  
**Total Time**: [ACTUAL_HOURS] hours (target: 1.5 hours)  
**Status**: Production Ready

### **M4.1 Final Achievements:**
- ✅ UserPreferences Core Data entity with single-record pattern
- ✅ UserPreferencesService with singleton pattern and auto-save
- ✅ Meal Planning preferences UI in Settings (4 controls)
- ✅ Real-time validation and persistence
- ✅ All 5 tests passed
- ✅ Zero regressions, production quality

### **Key M4.1 Deliverables:**
- **UserPreferencesService.shared** - Accessible app-wide
- **mealPlanDuration** (3-14 days, default 7) - For calendar length
- **mealPlanStartDay** (0-6, default 0/Sunday) - For calendar start
- **autoNameMealPlans** (default true) - For automatic naming
- **showRecipeSourceInMealPlan** (default true) - For recipe source display

### **Foundation Ready for M4.2:**
- ✅ User preferences operational and tested
- ✅ Settings persist across app restarts
- ✅ Service accessible from any view
- ✅ Default values ready for immediate use
- ✅ Infrastructure expandable for future features

---

## M4.2 Overview: Calendar-Based Meal Planning Core

**Total Estimated Time**: 2.5 hours  
**Priority**: HIGH - Core user workflow  
**Dependencies**: M4.1 Complete ✅

### **Strategic Value:**
M4.2 implements calendar-based meal planning with recipe assignment, leveraging M4.1 user preferences for customizable planning periods. This completes the meal planning foundation, with M4.3 adding grocery integration.

### **What We're Building:**
- MealPlan and PlannedMeal Core Data entities
- Calendar view with user-configured duration (uses M4.1 preferences)
- "Add to Meal Plan" buttons in recipe views
- Modal calendar picker for date selection
- Meal plan management (create/edit/delete)
- Recipe assignment workflow with one-recipe-per-day

### **User Flow:**
1. User taps "Meal Planning" tab (new)
2. App checks for active meal plan
3. If none: Create plan with user's preferences (duration & start day from M4.1)
4. If exists: Show calendar with assigned recipes
5. User browses recipes → "Add to Meal Plan" button
6. Calendar picker appears showing available dates
7. User selects date → Recipe assigned
8. Calendar updates immediately
9. Auto-name applied if enabled (from M4.1)

---

## Phase 1: Core Data Model (60 minutes)

### **Entity 1: MealPlan**

**Purpose**: Represents a single meal planning period (e.g., "Week of Oct 23")

**Attributes:**
```
MealPlan Entity:
- id: UUID (primary key, required)
- name: String (e.g., "Week of Oct 23", optional for user override)
- startDate: Date (first day of plan, required)
- duration: Int16 (number of days, 3-14, required)
- isActive: Bool (only one active plan at a time, required, default true)
- createdDate: Date (audit trail, required)
- modifiedDate: Date (audit trail, required)
```

**Relationships:**
```
MealPlan → PlannedMeal (one-to-many)
- Name: plannedMeals
- Destination: PlannedMeal
- Inverse: mealPlan
- Delete Rule: Cascade (delete meals when plan deleted)
```

**Fetch Indexes:**
```
Index 1: byActivePlan
- isActive (Binary, Ascending)
- startDate (Binary, Descending)

Index 2: byDateRange
- startDate (Binary, Ascending)
- duration (Binary, Ascending)
```

**Codegen**: Class Definition (matches M4.1 UserPreferences pattern)

---

### **Entity 2: PlannedMeal**

**Purpose**: Links a recipe to a specific date in a meal plan

**Attributes:**
```
PlannedMeal Entity:
- id: UUID (primary key, required)
- date: Date (specific day for this meal, required)
- servings: Int16 (planned servings, optional, default from recipe)
- scaleFactor: Double (scaling applied, optional, default 1.0)
- isCompleted: Bool (meal consumed, default false)
- notes: String (optional user notes)
- createdDate: Date (audit trail, required)
```

**Relationships:**
```
PlannedMeal → Recipe (many-to-one)
- Name: recipe
- Destination: Recipe
- Inverse: plannedMeals (add to Recipe entity)
- Delete Rule: Nullify (keep recipe if meal deleted)

PlannedMeal → MealPlan (many-to-one)
- Name: mealPlan
- Destination: MealPlan
- Inverse: plannedMeals
- Delete Rule: Nullify (orphan meal if plan deleted - shouldn't happen due to cascade)
```

**Fetch Indexes:**
```
Index 1: byDateInPlan
- date (Binary, Ascending)
- mealPlan (Binary)

Index 2: byRecipeUsage
- recipe (Binary)
- date (Binary, Descending)
```

**Codegen**: Class Definition

---

### **Recipe Entity Update**

**Add Relationship to Existing Recipe Entity:**
```
Recipe → PlannedMeal (one-to-many)
- Name: plannedMeals
- Destination: PlannedMeal
- Inverse: recipe
- Delete Rule: Nullify (don't delete meals if recipe deleted - allows orphan handling)
```

**Implementation Steps:**
1. Open GroceryRecipeManager.xcdatamodeld
2. Select Recipe entity
3. Add relationship: plannedMeals
4. Configure as above
5. Build to verify

---

### **Implementation Steps - Phase 1:**

1. **Create MealPlan Entity** (20 min):
   - Add entity with 7 attributes
   - Set Codegen to "Class Definition"
   - Add 2 fetch indexes
   - Configure default values

2. **Create PlannedMeal Entity** (20 min):
   - Add entity with 7 attributes
   - Set Codegen to "Class Definition"
   - Add 2 fetch indexes
   - Define both relationships

3. **Update Recipe Entity** (10 min):
   - Add plannedMeals relationship
   - Verify inverse configuration
   - Test build

4. **Build & Verify** (10 min):
   - Clean build folder (⌘⇧K)
   - Build project (⌘B)
   - Verify auto-generated classes
   - No errors or warnings

**Acceptance Criteria:**
- ✅ MealPlan entity with 7 attributes and 2 indexes
- ✅ PlannedMeal entity with 7 attributes and 2 indexes
- ✅ All relationships properly configured with inverses
- ✅ Recipe entity updated
- ✅ Build succeeds with Class Definition codegen
- ✅ Performance targets maintained

---

## Phase 2: Service Layer (60 minutes)

### **Service: MealPlanService**

**Purpose**: Manages meal plan CRUD operations and recipe assignments

**File**: `Services/MealPlanService.swift`

**Key Responsibilities:**
- Create meal plans with user preferences
- Fetch current active plan
- Add/remove recipes from dates
- Validate one-recipe-per-day constraint
- Auto-name generation (if user preference enabled)
- Archive completed plans

**Core Methods:**
```swift
class MealPlanService: ObservableObject {
    @Published var activePlan: MealPlan?
    @Published var plannedMeals: [PlannedMeal] = []
    
    // Initialization
    func fetchOrCreateActivePlan()
    
    // Meal Plan Management
    func createNewPlan(startDate: Date, duration: Int, name: String?) -> MealPlan
    func archiveCurrentPlan()
    func deletePlan(_ plan: MealPlan)
    
    // Recipe Assignment
    func assignRecipe(_ recipe: Recipe, to date: Date, servings: Int16?, scaleFactor: Double?) -> PlannedMeal?
    func removeRecipe(from date: Date)
    func getRecipe(for date: Date) -> Recipe?
    
    // Validation
    func isDateAvailable(_ date: Date) -> Bool  // Check if date already has recipe
    func getDatesInPlan() -> [Date]
    
    // Auto-naming
    func generatePlanName(startDate: Date) -> String  // "Week of Oct 23"
}
```

**Integration with M4.1:**
```swift
init(context: NSManagedObjectContext) {
    self.context = context
    
    // Use UserPreferencesService for defaults
    let prefs = UserPreferencesService.shared
    self.defaultDuration = prefs.mealPlanDuration
    self.defaultStartDay = prefs.mealPlanStartDay
    self.autoName = prefs.autoNameMealPlans
    
    fetchOrCreateActivePlan()
}
```

**Implementation Steps:**

1. **Create Service File** (20 min):
   - Create MealPlanService.swift in Services folder
   - Add @Published properties for reactive UI
   - Implement initialization with M4.1 preferences
   - Add Core Data context handling

2. **Implement Plan Management** (20 min):
   - createNewPlan() with auto-naming logic
   - fetchOrCreateActivePlan() with active plan query
   - archiveCurrentPlan() setting isActive = false
   - deletePlan() with cascade handling

3. **Implement Recipe Assignment** (15 min):
   - assignRecipe() with date validation
   - removeRecipe() with relationship cleanup
   - getRecipe() for date lookup
   - isDateAvailable() for conflict prevention

4. **Build & Test** (5 min):
   - Build project (⌘B)
   - Verify service compiles
   - Check for warnings

**Acceptance Criteria:**
- ✅ Service follows singleton/observable pattern
- ✅ Integration with UserPreferencesService
- ✅ All CRUD operations functional
- ✅ One-recipe-per-day validation
- ✅ Auto-naming based on user preference
- ✅ Performance < 0.1s for operations

---

## Phase 3: UI Implementation (30 minutes)

### **View 1: MealPlanView (Main Calendar)**

**Location**: `Views/MealPlanView.swift`

**Purpose**: Main meal planning interface with calendar display

**Structure:**
```swift
struct MealPlanView: View {
    @StateObject private var mealPlanService: MealPlanService
    @StateObject private var prefs = UserPreferencesService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let plan = mealPlanService.activePlan {
                    // Calendar grid showing dates
                    CalendarGridView(plan: plan, service: mealPlanService)
                } else {
                    // Empty state
                    EmptyMealPlanView()
                }
            }
            .navigationTitle("Meal Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Plan") {
                        // Create new plan with prefs
                    }
                }
            }
        }
    }
}
```

**Calendar Grid:**
- Shows duration days (from M4.1 prefs)
- Starts on user's preferred day (from M4.1 prefs)
- Each cell shows date and assigned recipe (if any)
- Tappable cells to add/remove recipes
- Visual indicators for assigned vs empty dates

---

### **View 2: Recipe Integration**

**Update RecipeListView:**
```swift
// Add "Add to Meal Plan" button in recipe row
Button(action: { showMealPlanPicker(recipe) }) {
    Image(systemName: "calendar.badge.plus")
}
```

**Update RecipeDetailView:**
```swift
// Add section for meal planning
Section {
    Button("Add to Meal Plan") {
        showMealPlanPicker(recipe)
    }
}
```

**Date Picker Modal:**
```swift
struct DatePickerSheet: View {
    let recipe: Recipe
    @ObservedObject var mealPlanService: MealPlanService
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(mealPlanService.getDatesInPlan(), id: \.self) { date in
                    Button(action: { assignToDate(date) }) {
                        HStack {
                            Text(date.formatted(.dateTime.month().day().weekday()))
                            Spacer()
                            if !mealPlanService.isDateAvailable(date) {
                                Text("Occupied")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(!mealPlanService.isDateAvailable(date))
                }
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
```

---

### **View 3: Empty State**

```swift
struct EmptyMealPlanView: View {
    @StateObject private var prefs = UserPreferencesService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Meal Plan Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first \(prefs.mealPlanDuration)-day meal plan starting on \(prefs.startDayName)")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Create Meal Plan") {
                // Create plan with prefs
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

---

### **Implementation Steps - Phase 3:**

1. **Create MealPlanView** (15 min):
   - New file in Views folder
   - Calendar grid with date cells
   - Empty state handling
   - Integration with MealPlanService
   - Uses M4.1 preferences for display

2. **Add Recipe Integration** (10 min):
   - "Add to Meal Plan" buttons in RecipeListView
   - "Add to Meal Plan" section in RecipeDetailView
   - Date picker modal
   - Assignment confirmation

3. **Add Tab Bar Item** (3 min):
   - Update GroceryRecipeManagerApp.swift
   - Add MealPlanView() to TabView
   - Icon: "calendar"
   - Label: "Meal Planning"

4. **Build & Test** (2 min):
   - Build and run (⌘R)
   - Navigate to Meal Planning tab
   - Verify UI appears

**Acceptance Criteria:**
- ✅ Meal Planning tab accessible
- ✅ Calendar shows user-configured duration
- ✅ Calendar starts on user-configured day
- ✅ Empty state shows helpful guidance
- ✅ Recipe assignment workflow functional
- ✅ One-recipe-per-day enforced visually
- ✅ Auto-naming works if enabled

---

## Testing & Validation (Included in phases)

### **Test 1: Plan Creation (Phase 2)**
- Create new plan
- Verify uses M4.1 preferences (duration, start day)
- Verify auto-naming if enabled
- **Expected**: Plan created with correct defaults

### **Test 2: Recipe Assignment (Phase 3)**
- Add recipe to date
- Verify appears in calendar
- Try to add second recipe to same date
- **Expected**: Second assignment rejected or replaces first

### **Test 3: Preference Integration (Phase 3)**
- Change duration in Settings (e.g., 5 days)
- Create new meal plan
- **Expected**: Calendar shows 5 days

### **Test 4: Persistence (Phase 2-3)**
- Create plan, add recipes
- Kill app, relaunch
- **Expected**: Meal plan and assignments persist

### **Test 5: Performance (All phases)**
- All operations < 0.1s
- Calendar renders quickly
- No UI lag

---

## Success Criteria - M4.2 Completion

### **Functional Requirements:**
- ✅ MealPlan and PlannedMeal entities operational
- ✅ Calendar view displays meal plans
- ✅ User can assign recipes to dates
- ✅ One-recipe-per-day constraint enforced
- ✅ M4.1 preferences integrated (duration, start day, auto-naming)
- ✅ Recipe views have "Add to Meal Plan" buttons
- ✅ Empty state provides guidance

### **Non-Functional Requirements:**
- ✅ Calendar loads < 0.1s
- ✅ Recipe assignment < 0.1s
- ✅ All operations performant
- ✅ Professional iOS UI maintained
- ✅ Zero build errors or warnings
- ✅ Follows established service patterns

### **Integration Readiness:**
- ✅ MealPlanService accessible for M4.3
- ✅ Meal plan data ready for grocery list generation
- ✅ Recipe assignments ready for source tracking
- ✅ Calendar infrastructure expandable

---

## After M4.2 Completion

### **Immediate Next Steps:**
1. Create learning note: `docs/learning-notes/19-m4.2-calendar-meal-planning.md`
2. Update `docs/current-story.md` with M4.2 completion
3. Update `docs/next-prompt.md` for M4.3
4. Update `docs/project-index.md` Recent Activity section

### **M4.3 Preview:**
**Goal**: Enhanced grocery integration with meal plan automation  
**Time**: 3.5-4 hours  
**Dependencies**: M4.2 Complete ✅

**What We'll Build:**
- Generate grocery lists from meal plans
- Recipe source tracking in lists
- Smart consolidation leveraging M3
- Scaled recipe to list feature (FEAT-001)
- Meal completion tracking

**Foundation Ready:**
- ✅ M4.1 preferences for list scope and display
- ✅ M4.2 meal plan data for processing
- ✅ M3 Phase 4 scaling service for serving adjustments
- ✅ M3 Phase 5 consolidation for list optimization

---

## What You'll Need

### **Files to Create:**
- `Services/MealPlanService.swift` - Meal plan management service
- `Views/MealPlanView.swift` - Main calendar view
- `Views/DatePickerSheet.swift` - Date selection modal
- `Views/EmptyMealPlanView.swift` - Empty state view

### **Files to Modify:**
- `GroceryRecipeManager.xcdatamodeld` - Add MealPlan and PlannedMeal entities
- `Views/RecipeListView.swift` - Add "Add to Meal Plan" button
- `Views/RecipeDetailView.swift` - Add "Add to Meal Plan" section
- `GroceryRecipeManagerApp.swift` - Add Meal Planning tab

### **Documentation to Create:**
- `docs/learning-notes/19-m4.2-calendar-meal-planning.md` (after completion)

### **Documentation to Update:**
- `docs/current-story.md` - Mark M4.2 complete
- `docs/next-prompt.md` - Prepare M4.3 prompt
- `docs/project-index.md` - Add M4.2 learning note reference

---

## Current Progress

**M4 Timeline:**
- **M4.1**: [ACTUAL_HOURS] hours ✅ COMPLETE
- **M4.2**: 2.5 hours ← **STARTING NOW**
- **M4.3**: 3.5-4 hours (after M4.2)
- **Total**: [UPDATED_TOTAL] hours

**Milestone Status**: M4.1 complete with production quality. Ready to begin M4.2 calendar implementation.

**Next Action**: Create MealPlan and PlannedMeal Core Data entities with relationships and fetch indexes.

---

**Please help me implement M4.2: Calendar-Based Meal Planning Core with Core Data entities, meal plan service, and calendar UI leveraging M4.1 user preferences.**