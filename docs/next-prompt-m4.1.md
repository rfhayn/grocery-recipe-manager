# M4 Phase 1: Settings Infrastructure Foundation - Development Prompt

**Copy and paste this prompt when ready to begin M4:**

---

I'm ready to begin **M4: Meal Planning & Enhanced Grocery Integration** for my Grocery & Recipe Manager iOS app.

## M3 COMPLETE ✅

**Completion Date**: October 20, 2025  
**Total Time**: 10.5 hours (target: 8-12 hours) ✅  
**Status**: Production Ready

### **M3 Final Achievements:**
- ✅ Structured quantity system operational (Phases 1-2)
- ✅ Data migration complete with 100% success (Phase 3)
- ✅ Recipe scaling with kitchen-friendly fractions (Phase 4)
- ✅ Intelligent shopping list consolidation with unit conversion (Phase 5)
- ✅ UI polish and comprehensive help documentation (Phase 6)
- ✅ All performance targets met or exceeded
- ✅ Production-ready quality achieved

### **Key M3 Deliverables:**
- **Structured Data Model**: numericValue, standardUnit, displayText, isParseable, parseConfidence
- **RecipeScalingService**: Scale recipes 0.25x-4x with fraction conversion
- **QuantityMergeService**: Intelligent consolidation reducing list redundancy by 30-50%
- **UnitConversionService**: Volume and weight conversions (cups ↔ tbsp ↔ tsp, lb ↔ oz)
- **HelpView**: Comprehensive in-app user documentation
- **Enhanced GroceryListDetailView**: Consolidation button with opportunity badge

### **Foundation Ready for M4:**
- ✅ Recipe scaling service operational
- ✅ Consolidation service ready for meal plan lists
- ✅ Settings infrastructure exists (created in M3 Phase 3)
- ✅ Structured quantities enable smart grocery automation
- ✅ Template system for ingredient consistency

---

## M4 Overview: Meal Planning & Enhanced Grocery Integration

**Total Estimated Time**: 7.5-10 hours  
**Priority**: HIGH - Completes core user workflow  
**Dependencies**: M3 Complete ✅

### **Strategic Value:**
M4 completes the core grocery-recipe workflow by adding calendar-based meal planning with automated grocery list generation. This milestone leverages M3's structured quantities and scaling service to provide powerful meal planning capabilities.

### **M4 Phase Breakdown:**

**M4.1: Settings Infrastructure Foundation (1.5 hours)** ← **STARTING NOW**
- Expand Settings tab with meal planning preferences
- UserPreferences Core Data entity
- Duration, start day, auto-naming, recipe source display settings
- Real-time validation

**M4.2: Calendar-Based Meal Planning Core (2.5 hours)**
- MealPlan and PlannedMeal entities
- Clean one-week calendar with recipe assignment
- "Add to Meal Plan" buttons throughout app
- User-configurable planning periods (3-14 days)

**M4.3: Enhanced Grocery Integration + Scaled Recipe to List (3.5-4 hours)**
- Generate grocery list from meal plan
- Recipe source tags ("Ground beef [Tacos] [Spaghetti]")
- Smart consolidation leveraging M3
- Meal completion tracking
- NEW: Add scaled recipes directly to shopping lists

---

## M4.1: Settings Infrastructure Foundation (1.5 hours)

### **Goal:**
Establish user preference management foundation supporting meal planning and future features. Expand existing Settings tab created in M3 Phase 3.

### **What's Already Ready:**

**From M3 Phase 3** ✅
- Settings tab exists in main TabView
- Professional iOS settings interface structure
- Migration service and UI (can remain as reference)
- Clean navigation patterns established

**What We're Adding:**
- Meal planning preferences section
- UserPreferences Core Data entity
- Real-time settings validation
- Persistent configuration storage

---

## Phase 1 Implementation Plan

### **Task 1: Core Data Model - UserPreferences Entity (30 min)**

**Purpose**: Create persistent storage for user meal planning preferences.

**Core Data Entity Definition:**
```swift
UserPreferences Entity:
- id: UUID (primary key)
- defaultMealPlanDuration: Int16 (default: 7, range: 3-14)
- defaultStartDay: Int16 (0=Sunday, 1=Monday, etc., default: 0)
- autoNameMealPlans: Bool (default: true)
- showRecipeSourceTags: Bool (default: true)
- createdDate: Date
- modifiedDate: Date
```

**Implementation Steps:**
1. **Open GroceryRecipeManager.xcdatamodeld** (10 min):
   - Add new UserPreferences entity
   - Set Codegen to "Class Definition" (like IngredientTemplate pattern)
   - Add all properties with correct types
   - Set default values in entity inspector
   - Add fetch index on id field
   - Build to verify schema compiles

2. **Create UserPreferencesService** (15 min):
   - Create new file: `Services/UserPreferencesService.swift`
   - Singleton pattern for app-wide access
   - Methods: getPreferences(), updatePreferences(), validateSettings()
   - Create default preferences on first access
   - Real-time Core Data save on updates
   - Follow established service patterns (like IngredientTemplateService)

3. **Test Core Data Integration** (5 min):
   - Build project successfully
   - Verify entity appears in Core Data model
   - Test service initialization in app launch
   - Verify default preferences created on first run

**Acceptance Criteria:**
- ✅ UserPreferences entity in Core Data model
- ✅ UserPreferencesService operational
- ✅ Default preferences created automatically
- ✅ Build succeeds without errors
- ✅ Follows established service patterns

### **Task 2: Settings UI - Meal Planning Preferences Section (45 min)**

**Purpose**: Add meal planning preferences to existing SettingsView.

**UI Components to Add:**
```swift
Section(header: Text("Meal Planning")) {
    // Default meal plan duration (3-14 days)
    Stepper("Planning Duration: \(duration) days", 
            value: $duration, in: 3...14)
    
    // Default start day (Sunday/Monday)
    Picker("Start Day", selection: $startDay) {
        ForEach(DayOfWeek.allCases) { day in
            Text(day.name).tag(day.rawValue)
        }
    }
    
    // Auto-naming toggle
    Toggle("Auto-Name Meal Plans", isOn: $autoName)
    
    // Recipe source tags toggle
    Toggle("Show Recipe Sources in Lists", isOn: $showSources)
}
```

**Implementation Steps:**
1. **Update SettingsView.swift** (25 min):
   - Add @StateObject for UserPreferencesService
   - Add @State variables for all preferences bound to UI
   - Create new "Meal Planning" section in existing Form
   - Add Stepper for duration (3-14 days range)
   - Add Picker for start day (enum: Sunday-Saturday)
   - Add Toggle for auto-naming
   - Add Toggle for recipe source display
   - Wire all controls to save via service

2. **Add DayOfWeek Enum** (10 min):
   - Create enum for days of week (0=Sunday through 6=Saturday)
   - CaseIterable for Picker
   - Display names for UI
   - Helper methods for date calculations

3. **Add Real-Time Validation** (5 min):
   - Validate duration range (3-14) on change
   - Immediate save on any preference change
   - Toast/feedback for successful save (optional)

4. **Add Help Text** (5 min):
   - Add explanatory text below each setting
   - Example: "Meal plans will default to X days starting on Y"
   - Use .font(.caption) and .foregroundColor(.secondary)

**Acceptance Criteria:**
- ✅ Meal Planning section appears in Settings
- ✅ All four preference controls functional
- ✅ Settings persist across app launches
- ✅ Validation prevents invalid values
- ✅ Real-time save without "Save" button
- ✅ Professional iOS settings interface maintained
- ✅ Help text provides clarity

### **Task 3: Integration Testing & Validation (15 min)**

**Purpose**: Ensure settings infrastructure works end-to-end.

**Testing Checklist:**
1. **Default Preferences** (3 min):
   - Launch app fresh (delete app if needed)
   - Verify Settings tab accessible
   - Confirm default values appear:
     - Duration: 7 days
     - Start Day: Sunday
     - Auto-name: ON
     - Show sources: ON

2. **Preference Updates** (5 min):
   - Change duration to 5 days → Save → Relaunch app → Verify persisted
   - Change start day to Monday → Save → Relaunch → Verify persisted
   - Toggle auto-name OFF → Relaunch → Verify persisted
   - Toggle show sources OFF → Relaunch → Verify persisted

3. **Validation** (3 min):
   - Try to set duration < 3 (blocked by stepper)
   - Try to set duration > 14 (blocked by stepper)
   - Verify stepper shows current value correctly

4. **Performance** (2 min):
   - Settings screen loads < 0.1s
   - Preference changes save immediately
   - No UI lag or delays
   - Memory usage appropriate

5. **Integration Points** (2 min):
   - UserPreferencesService accessible app-wide
   - Can call getPreferences() from any view
   - Settings changes immediately available
   - Ready for M4.2 meal planning integration

**Acceptance Criteria:**
- ✅ All default values correct
- ✅ All preferences persist correctly
- ✅ Validation prevents invalid values
- ✅ Performance targets met
- ✅ Ready for M4.2 integration
- ✅ Zero crashes or errors

---

## Success Criteria - M4.1 Completion

### **Functional Requirements:**
- ✅ UserPreferences Core Data entity operational
- ✅ UserPreferencesService with CRUD operations
- ✅ Meal planning preferences section in Settings
- ✅ Four preference controls (duration, start day, auto-name, show sources)
- ✅ Real-time validation and persistence
- ✅ Default preferences created on first launch

### **Non-Functional Requirements:**
- ✅ Settings load < 0.1s
- ✅ Preference saves immediate
- ✅ All settings persist across app restarts
- ✅ Professional iOS UI maintained
- ✅ Zero build errors or warnings
- ✅ Follows established service patterns

### **Integration Readiness:**
- ✅ UserPreferencesService accessible app-wide
- ✅ Default duration (7 days) ready for M4.2
- ✅ Default start day (Sunday) ready for M4.2
- ✅ Settings infrastructure expandable for future features

---

## After M4.1 Completion

### **Immediate Next Steps:**
1. Create learning note: `docs/learning-notes/17-m4-phase1-settings-infrastructure.md`
2. Update `docs/current-story.md` with M4.1 completion
3. Update `docs/next-prompt.md` for M4.2 Calendar-Based Meal Planning Core

### **M4.2 Preview:**
**Goal**: Calendar-based meal planning with recipe assignment  
**Time**: 2.5 hours  
**Dependencies**: M4.1 Complete ✅

**What We'll Build:**
- MealPlan and PlannedMeal Core Data entities
- Clean one-week calendar view
- "Add to Meal Plan" buttons in recipe views
- Modal calendar picker for date selection
- Meal plan management (create/edit/delete)

**Foundation Ready:**
- ✅ User preferences for duration and start day
- ✅ Settings service for configuration
- ✅ Recipe catalog with full CRUD
- ✅ Navigation patterns established

---

## What You'll Need

### **Files to Create:**
- `Services/UserPreferencesService.swift` - Preference management service
- Modify: `GroceryRecipeManager.xcdatamodeld` - Add UserPreferences entity
- Create enum in Models folder (if not exists): `DayOfWeek.swift`

### **Files to Modify:**
- `GroceryRecipeManager/SettingsView.swift` - Add Meal Planning section

### **Documentation to Create:**
- `docs/learning-notes/17-m4-phase1-settings-infrastructure.md` (after completion)

### **Documentation to Update:**
- `docs/current-story.md` - Mark M4.1 complete
- `docs/next-prompt.md` - Prepare M4.2 prompt
- `docs/project-index.md` - Add M4.1 learning note reference

---

## Current Progress

**M3**: Complete (10.5 hours) ✅  
**M4 Timeline:**
- **Phase 1**: 1.5 hours ← **STARTING NOW**
- **Phase 2**: 2.5 hours (Calendar planning)
- **Phase 3**: 3.5-4 hours (Enhanced integration + scaled to list)
- **Total**: 7.5-10 hours

**Milestone Status**: Ready to begin M4.1

**Next Action**: Create UserPreferences Core Data entity and settings UI for meal planning preferences.

---

**Please help me implement M4.1: Settings Infrastructure Foundation with Core Data entity, settings service, and meal planning preferences UI.**