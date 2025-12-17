# M7.1.3 Phase 1.1 Part 2 Implementation Guide - Populate Semantic Keys

**Last Updated**: December 17, 2025  
**Current Phase**: M7.1.3 Phase 1.1 Part 2 - 🚀 READY TO START  
**Status**: Part 1 Complete ✅ (2.5h), Part 2 Ready (2-3h)  
**Estimated Time**: 2-3 hours  
**Dependencies**: Phase 1.1 Part 1 Complete ✅

---

## 🎯 **PHASE 1.1 PART 2 OVERVIEW**

**Purpose**: Create migration functions to populate semantic keys for existing Core Data entities

**What Part 1 Gave Us:**
- ✅ Model Version 2 with semantic key fields (all Optional)
- ✅ Category.normalizedName, updatedAt
- ✅ IngredientTemplate.canonicalName, updatedAt
- ✅ PlannedMeal.mealType, slotKey
- ✅ Recipe.titleKey
- ✅ All fetch indexes created

**What Part 2 Will Do:**
- Create 4 population functions in `Persistence.swift`
- Wire up migration with idempotency (UserDefaults flag)
- Test migration on fresh install
- Verify semantic keys populated in Core Data

**What We're NOT Doing Yet:**
- ❌ NO normalization helper extensions (that's Part 3)
- ❌ NO repository pattern (that's Phase 1.2)
- ❌ NO uniqueness constraints (that's Phase 1.3)
- ❌ NO multi-device testing (that's Phase 2)

---

## 📋 **IMPLEMENTATION STEPS**

### **Step 1: Create Category Population Function (30 minutes)**

**Location**: `forager/Persistence.swift`

**Function to add:**

```swift
// M7.1.3 Phase 1.1 Part 2: Populate semantic keys for existing entities
private func populateCategorySemanticKeys(in context: NSManagedObjectContext) {
    let request: NSFetchRequest<Category> = Category.fetchRequest()
    
    guard let categories = try? context.fetch(request) else { 
        print("⚠️ M7.1.3: Failed to fetch categories for population")
        return 
    }
    
    var populatedCount = 0
    for category in categories {
        guard let displayName = category.displayName, 
              !displayName.isEmpty else { 
            print("⚠️ M7.1.3: Skipping category with nil/empty displayName")
            continue 
        }
        
        // Normalize: lowercase, trim whitespace
        // (Part 3 will create helper function for this)
        let normalized = displayName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        category.normalizedName = normalized
        category.updatedAt = Date()
        populatedCount += 1
    }
    
    print("✅ M7.1.3: Populated normalizedName for \(populatedCount) categories")
}
```

**Test**:
- Add temporary call in `init` after `loadPersistentStores`
- Delete app from simulator/device
- Run app
- Check console: Should see "✅ M7.1.3: Populated normalizedName for X categories"
- Open Core Data inspector: Verify `normalizedName` values exist
- Comment out the temporary call

**Commit**:
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.1 Part 2: Add Category semantic key population

- Created populateCategorySemanticKeys() function
- Normalizes displayName to lowercase, trimmed
- Sets updatedAt to current timestamp
- Tested: Successfully populated X categories
- Next: IngredientTemplate population"
git push
```

---

### **Step 2: Create IngredientTemplate Population Function (30 minutes)**

**Function to add to Persistence.swift:**

```swift
private func populateIngredientTemplateSemanticKeys(in context: NSManagedObjectContext) {
    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    
    guard let templates = try? context.fetch(request) else {
        print("⚠️ M7.1.3: Failed to fetch templates for population")
        return
    }
    
    var populatedCount = 0
    for template in templates {
        guard let displayName = template.displayName,
              !displayName.isEmpty else {
            print("⚠️ M7.1.3: Skipping template with nil/empty displayName")
            continue
        }
        
        // Normalize: lowercase, trim whitespace
        // TODO Phase 1.1 Part 3: Add stemming/plural handling helper
        let canonical = displayName
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        template.canonicalName = canonical
        
        // Set createdAt if missing (reusing existing dateCreated field)
        if template.dateCreated == nil {
            template.dateCreated = Date()
        }
        
        template.updatedAt = Date()
        populatedCount += 1
    }
    
    print("✅ M7.1.3: Populated canonicalName for \(populatedCount) templates")
}
```

**Test** (same as Step 1):
- Temporary call, delete app, run, verify console + Core Data inspector
- Comment out temporary call

**Commit**:
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.1 Part 2: Add IngredientTemplate semantic key population

- Created populateIngredientTemplateSemanticKeys() function
- Normalizes displayName to canonical form
- Sets dateCreated if missing, updates updatedAt
- Tested: Successfully populated X templates
- Next: PlannedMeal population"
git push
```

---

### **Step 3: Create PlannedMeal Population Function (30 minutes)**

**Function to add to Persistence.swift:**

```swift
private func populatePlannedMealSemanticKeys(in context: NSManagedObjectContext) {
    let request: NSFetchRequest<PlannedMeal> = PlannedMeal.fetchRequest()
    
    guard let meals = try? context.fetch(request) else {
        print("⚠️ M7.1.3: Failed to fetch planned meals for population")
        return
    }
    
    var populatedCount = 0
    for meal in meals {
        guard let date = meal.date else {
            print("⚠️ M7.1.3: Skipping planned meal with nil date")
            continue
        }
        
        // Infer mealType if not set (default to "dinner")
        if meal.mealType == nil || meal.mealType?.isEmpty == true {
            meal.mealType = "dinner"
        }
        
        guard let mealType = meal.mealType else { continue }
        
        // Create slotKey: "YYYY-MM-DD-mealType"
        // TODO Phase 1.1 Part 3: Move to PlannedMeal.slotKey(date:mealType:) helper
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dateString = formatter.string(from: date)
        let slotKey = "\(dateString)-\(mealType.lowercased())"
        
        meal.slotKey = slotKey
        
        // Set createdAt if missing (reusing existing createdDate field)
        if meal.createdDate == nil {
            meal.createdDate = Date()
        }
        
        populatedCount += 1
    }
    
    print("✅ M7.1.3: Populated slotKey for \(populatedCount) planned meals")
}
```

**Test** (same as Steps 1-2):
- Temporary call, delete app, run, verify console + Core Data inspector
- Verify slotKey format: "2025-12-17-dinner"
- Comment out temporary call

**Commit**:
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.1 Part 2: Add PlannedMeal semantic key population

- Created populatePlannedMealSemanticKeys() function
- Infers mealType as 'dinner' if missing
- Generates slotKey in format: YYYY-MM-DD-mealType
- Sets createdDate if missing
- Tested: Successfully populated X planned meals
- Next: Recipe population"
git push
```

---

### **Step 4: Create Recipe Population Function (30 minutes)**

**Function to add to Persistence.swift:**

```swift
private func populateRecipeSemanticKeys(in context: NSManagedObjectContext) {
    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    
    guard let recipes = try? context.fetch(request) else {
        print("⚠️ M7.1.3: Failed to fetch recipes for population")
        return
    }
    
    var populatedCount = 0
    for recipe in recipes {
        // Recipe uses 'title' field, not 'displayName'
        guard let title = recipe.title,
              !title.isEmpty else {
            print("⚠️ M7.1.3: Skipping recipe with nil/empty title")
            continue
        }
        
        // Normalize: lowercase, trim whitespace
        // TODO Phase 1.1 Part 3: Move to Recipe.titleKey(from:) helper
        let titleKey = title
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        recipe.titleKey = titleKey
        
        // Set createdAt if missing (reusing existing dateCreated field)
        if recipe.dateCreated == nil {
            recipe.dateCreated = Date()
        }
        
        populatedCount += 1
    }
    
    print("✅ M7.1.3: Populated titleKey for \(populatedCount) recipes")
}
```

**Test** (same as Steps 1-3):
- Temporary call, delete app, run, verify console + Core Data inspector
- Comment out temporary call

**Commit**:
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.1 Part 2: Add Recipe semantic key population

- Created populateRecipeSemanticKeys() function
- Normalizes title to titleKey
- Sets dateCreated if missing
- Tested: Successfully populated X recipes
- Next: Wire up migration with idempotency"
git push
```

---

### **Step 5: Wire Up Migration with Idempotency (30 minutes)**

**Add main migration function to Persistence.swift:**

```swift
// M7.1.3 Phase 1.1 Part 2: Stage A Migration
// Populates semantic keys for existing entities
private func performStageAMigration(in context: NSManagedObjectContext) {
    let stageAKey = "M7.1.3.StageA.Completed"
    
    // Only run once per installation
    guard !UserDefaults.standard.bool(forKey: stageAKey) else {
        print("ℹ️ M7.1.3: Stage A migration already completed")
        return
    }
    
    print("🚀 M7.1.3: Starting Stage A migration (semantic key population)...")
    
    // Populate semantic keys for all entities
    populateCategorySemanticKeys(in: context)
    populateIngredientTemplateSemanticKeys(in: context)
    populatePlannedMealSemanticKeys(in: context)
    populateRecipeSemanticKeys(in: context)
    
    // Save changes
    do {
        try context.save()
        UserDefaults.standard.set(true, forKey: stageAKey)
        print("✅ M7.1.3: Stage A migration complete - all semantic keys populated")
    } catch {
        print("❌ M7.1.3: Stage A migration failed: \(error.localizedDescription)")
    }
}
```

**Wire into init (after loadPersistentStores completes):**

Find the `loadPersistentStores` completion handler and add migration call:

```swift
container.loadPersistentStores { description, error in
    if let error = error {
        fatalError("Unable to load persistent stores: \(error)")
    }
    
    // M7.1.3 Phase 1.1 Part 2: Run Stage A migration
    self.performStageAMigration(in: self.container.viewContext)
}
```

**Test Migration Flow**:

1. **Fresh Install Test**:
   - Delete app from device/simulator
   - Run app
   - Check console:
     ```
     🚀 M7.1.3: Starting Stage A migration...
     ✅ M7.1.3: Populated normalizedName for X categories
     ✅ M7.1.3: Populated canonicalName for X templates
     ✅ M7.1.3: Populated slotKey for X planned meals
     ✅ M7.1.3: Populated titleKey for X recipes
     ✅ M7.1.3: Stage A migration complete
     ```
   - App should launch successfully

2. **Idempotency Test**:
   - Run app again (don't delete)
   - Check console:
     ```
     ℹ️ M7.1.3: Stage A migration already completed
     ```
   - Should NOT see population messages
   - App should launch successfully

3. **Data Verification Test**:
   - Open Core Data inspector (Debug → View Debugging → Core Data)
   - Check Category entities: `normalizedName` should be populated
   - Check IngredientTemplate entities: `canonicalName` should be populated
   - Check PlannedMeal entities: `slotKey` should be populated
   - Check Recipe entities: `titleKey` should be populated

**Commit**:
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.1 Part 2 COMPLETE: Wire up Stage A migration

- Created performStageAMigration() with idempotency flag
- Integrated into loadPersistentStores completion
- Uses UserDefaults key: M7.1.3.StageA.Completed
- Tested: Fresh install populates all semantic keys
- Tested: Subsequent runs skip migration (idempotent)
- Tested: All entities verified in Core Data inspector

✅ Phase 1.1 Part 2 COMPLETE
✅ All semantic keys populated for existing data
✅ Migration is idempotent (runs once per installation)
✅ Zero build errors, zero crashes
✅ Ready for Part 3: Normalization Helpers

Time: 2-3 hours (estimated), X hours (actual)
Next: Phase 1.1 Part 3 - Normalization Helper Extensions"
git push
```

---

## ✅ **ACCEPTANCE CRITERIA**

**Part 2 is complete when:**

- ✅ All 4 population functions implemented
  - populateCategorySemanticKeys()
  - populateIngredientTemplateSemanticKeys()
  - populatePlannedMealSemanticKeys()
  - populateRecipeSemanticKeys()

- ✅ Migration wired up with idempotency
  - performStageAMigration() function created
  - UserDefaults flag: "M7.1.3.StageA.Completed"
  - Called from loadPersistentStores completion

- ✅ Fresh install test passed
  - Migration runs on first launch
  - All semantic keys populated
  - Console shows success messages

- ✅ Idempotency test passed
  - Second launch skips migration
  - Console shows "already completed" message

- ✅ Data verification passed
  - Core Data inspector shows populated fields
  - Category.normalizedName values correct
  - IngredientTemplate.canonicalName values correct
  - PlannedMeal.slotKey values correct (YYYY-MM-DD-mealType)
  - Recipe.titleKey values correct

- ✅ Quality checks
  - App launches without crashes
  - Existing features work (no regressions)
  - All changes committed with clear messages
  - All commits pushed to GitHub

---

## 🚨 **COMMON PITFALLS TO AVOID**

### **1. Don't Create Helper Functions Yet**
- Part 2 does inline normalization
- Part 3 will extract to helper functions
- Reason: Keep Part 2 focused on population logic

### **2. Handle Nil/Empty Values Gracefully**
- Always check `displayName != nil && !displayName.isEmpty`
- Skip entities with missing data, log warning
- Don't crash on bad data

### **3. Test Idempotency**
- MUST test that migration runs only once
- UserDefaults flag is critical
- Second launch should skip ALL population

### **4. Verify Date Field Existence**
- Recipe uses `title` not `displayName`
- IngredientTemplate has `dateCreated`
- PlannedMeal has `createdDate`
- Recipe has `dateCreated`
- Use existing fields, don't add new ones

### **5. Console Logging is Your Friend**
- Print counts for each entity type
- Makes debugging easy
- Shows migration succeeded

---

## 📊 **TIME TRACKING**

**Estimated Breakdown:**
- Category population: 30 min
- IngredientTemplate population: 30 min
- PlannedMeal population: 30 min
- Recipe population: 30 min
- Wire up migration: 30 min
- Testing & verification: 15 min
- **Total: 2.5-3 hours**

**Track actual time and update completion summary!**

---

## 🎯 **NEXT STEPS AFTER PART 2**

**Phase 1.1 Part 3: Normalization Helper Extensions** (1-2 hours)
- Extract normalization logic to static helper functions
- `Category.normalizedName(from:)` 
- `IngredientTemplate.canonicalName(from:)`
- `PlannedMeal.slotKey(date:mealType:)`
- `Recipe.titleKey(from:)`
- Update population functions to use helpers
- Add extension files with documentation

**Phase 1.1 Part 4: Test Migration** (1 hour)
- Comprehensive testing checklist
- Fresh install, idempotency, data validation
- Performance testing
- Edge cases (nil values, special characters)
- Mark Phase 1.1 ✅ COMPLETE!

---

## 📝 **START PROMPT FOR PART 2**

```
M7.1.3 Phase 1.1 Part 1 complete ✅ (2.5h, 100% accuracy)

Completed:
- Model Version 2 with semantic key fields (all Optional)
- 4 entities updated: Category, IngredientTemplate, PlannedMeal, Recipe
- All fetch indexes added
- 5 commits pushed to GitHub
- Zero build errors, zero regressions

Next: Phase 1.1 Part 2 - Populate Semantic Keys (2-3h)

Tasks:
1. Add populateCategorySemanticKeys() to Persistence.swift
2. Add populateIngredientTemplateSemanticKeys()
3. Add populatePlannedMealSemanticKeys()
4. Add populateRecipeSemanticKeys()
5. Create performStageAMigration() with idempotency
6. Wire into loadPersistentStores completion
7. Test: Fresh install (delete app, run, verify)
8. Test: Idempotency (run again, should skip)
9. Verify: Core Data inspector shows populated values

Branch: feature/M7.1.3-phase1.1-fresh-start
PRD: docs/prds/m7.1.3-cloudkit-sync-integrity.md (Phase 1.1 Part 2)

Ready to implement population functions!
```

---

**Version**: 1.0  
**Last Updated**: December 17, 2025  
**For Milestone**: M7.1.3 Phase 1.1 Part 2  
**Estimated Time**: 2-3 hours  
**Current Status**: 🚀 READY TO START
