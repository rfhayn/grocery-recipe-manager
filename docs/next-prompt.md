# M7.1.3 Implementation Guide - CloudKit Sync Integrity

**Last Updated**: December 10, 2024  
**Current Phase**: M7.1.3 CloudKit Sync Integrity - Phase 1.1 Stage A Migration  
**Status**: M7.1.1 Complete ✅, M7.1.2 Complete ✅, M7.1.3 Ready to Start 🚀  
**Estimated Time**: 11-15 hours total (conservative: 12 hours)  
**Dependencies**: M7.0 Complete ✅, M7.1.1 Complete ✅, M7.1.2 Complete ✅  
**PRD**: `docs/prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md`

---

## 🎯 **M7.1.3 OVERVIEW**

### **CRITICAL: Scope Changed from Original Plan**

**Original M7.1.3 (3-4h):** Basic two-device sync testing

**⚠️ DISCOVERED ISSUE:** CloudKit creates duplicate entities when multiple devices create semantically identical objects (e.g., same Category name). This causes crashes: `"Duplicate values for key: 'Produce'"`.

**New M7.1.3 (11-15h):** Comprehensive architectural fix + testing

**This is the RIGHT approach - fixing the root cause, not patching symptoms.**

---

### **What You're Building**

**Three-Layer Semantic Uniqueness Architecture:**

**Layer 1: Core Data Model**
- Add semantic key fields (normalizedName, canonicalName, slotKey)
- Uniqueness constraints on semantic keys
- Standardize: `name` → `displayName` across ALL entities
- Two-stage migration for CloudKit safety

**Layer 2: Repository Pattern**
- CategoryRepository - Get-or-create for categories
- PlannedMealRepository - Slot protection for meal planning
- Enhanced IngredientTemplateService - Canonical names
- RecipeDuplicateDetector - User-assisted detection

**Layer 3: Application Layer**
- NO direct `Category(context:)` instantiation
- ALL creation through repositories
- User dialogs for ambiguous cases (Recipe duplicates, slot conflicts)

---

### **Entities Affected**

| Entity | Change | Semantic Key | Strategy |
|--------|--------|--------------|----------|
| **Category** | Add fields | `normalizedName` | Repository |
| **IngredientTemplate** | Add fields | `canonicalName` | Repository |
| **PlannedMeal** | Add fields + mealType | `slotKey` | Repository |
| **Recipe** | Add field | `titleKey` | Detection dialog |
| **WeeklyList** | Rename only | None | No constraint |
| **MealPlan** | Rename only | None | No constraint |
| **GroceryListItem** | Rename only | None | Allow duplicates |
| **Ingredient** | Rename only | None | No changes |
| **GroceryItem** | Rename only | None | No changes |

**All entities:** Rename `name`/`title` → `displayName` for consistency

---

## 🚀 **START HERE: PHASE 1.1 - STAGE A MIGRATION**

### **Purpose**
Add semantic key fields as OPTIONAL, populate them, prepare for Stage B constraints.

**Why Two Stages?**
- CloudKit can inject duplicates during migration
- Adding constraints before all devices sync causes crashes
- Stage A: Add fields → populate → sync
- Stage B: Make required → add constraints
- **This prevents `NSConstraintConflictError`**

---

### **Phase 1.1 Tasks (1.5 hours)**

**1. Create Model Version 2** (15 min)

```bash
# In Xcode
1. Select forager.xcdatamodeld in Project Navigator
2. Menu: Editor → Add Model Version
3. Name: "forager 2"
4. Based on: "forager" (current)
5. Click "Finish"

6. Select forager.xcdatamodeld
7. File Inspector (right panel)
8. Under "Versioned Core Data Model"
9. Set "Current": forager 2
```

**Verify:** Green checkmark appears next to "forager 2.xcdatamodel"

---

**2. Add Semantic Key Fields to Category** (10 min)

```
Select Category entity in "forager 2" model:

Add Attributes:
1. displayName: String, Optional ☑️
   - This replaces 'name' (we'll migrate data, then remove 'name')
   
2. normalizedName: String, Optional ☑️
   - Will become required in Stage B
   - Add index: Click "+" under Indexes → Add "normalizedName"

3. updatedAt: Date, Optional ☑️
   - For conflict resolution

Keep existing 'name' field for now (migration will copy data)
```

---

**3. Add Semantic Key Fields to IngredientTemplate** (10 min)

```
Select IngredientTemplate entity:

Add Attributes:
1. displayName: String, Optional ☑️
   - This replaces 'name'
   
2. canonicalName: String, Optional ☑️
   - Will become required in Stage B
   - Add index: Click "+" under Indexes → Add "canonicalName"

3. createdAt: Date, Optional ☑️
   - Already exists? Verify present

4. updatedAt: Date, Optional ☑️
   - For conflict resolution

Keep existing 'name' field for now
```

---

**4. Add Fields to PlannedMeal** (10 min)

```
Select PlannedMeal entity:

Add Attributes:
1. mealType: String, Optional ☑️
   - NEW field for "breakfast", "lunch", "dinner", "snack"
   
2. slotKey: String, Optional ☑️
   - Will become required in Stage B
   - Add index: Click "+" under Indexes → Add "slotKey"

3. createdAt: Date, Optional ☑️
   - Already may exist - verify or add

Keep all existing fields
```

---

**5. Add titleKey to Recipe** (5 min)

```
Select Recipe entity:

Add Attributes:
1. displayName: String, Optional ☑️
   - This replaces 'title'

2. titleKey: String, Optional ☑️
   - For duplicate detection (no constraint)
   - Add index: Click "+" under Indexes → Add "titleKey"

Keep existing 'title' field for now
```

---

**6. Add displayName to Other Entities** (15 min)

```
For each of these entities, add:
- displayName: String, Optional ☑️

Entities to update:
- WeeklyList (has 'name')
- MealPlan (has 'name')
- GroceryItem (has 'name')
- GroceryListItem (has 'name')
- Ingredient (has 'name')

Keep existing 'name' fields for now (we'll migrate then remove)
```

---

**7. Add Migration Code** (20 min)

Create file: `forager/Persistence+Migration.swift`

```swift
import CoreData

extension PersistenceController {
    
    /// Stage A Migration: Populate semantic keys for existing entities
    func performStageAMigration(in context: NSManagedObjectContext) {
        let stageAKey = "M7.1.3.StageA.Completed"
        
        guard !UserDefaults.standard.bool(forKey: stageAKey) else {
            print("ℹ️ Stage A migration already completed")
            return
        }
        
        print("🚀 Stage A Migration: Populating semantic keys...")
        
        do {
            // Populate Category semantic keys
            try populateCategorySemanticKeys(in: context)
            
            // Populate IngredientTemplate semantic keys
            try populateIngredientTemplateSemanticKeys(in: context)
            
            // Populate PlannedMeal semantic keys (if any exist)
            try populatePlannedMealSemanticKeys(in: context)
            
            // Populate Recipe semantic keys
            try populateRecipeSemanticKeys(in: context)
            
            // Populate other displayName fields
            try populateDisplayNames(in: context)
            
            // Save changes
            if context.hasChanges {
                try context.save()
                print("✅ Stage A migration completed successfully")
            }
            
            // Mark as completed
            UserDefaults.standard.set(true, forKey: stageAKey)
            UserDefaults.standard.set(Date(), forKey: "M7.1.3.StageA.Date")
            
        } catch {
            print("❌ Stage A migration failed: \\(error)")
        }
    }
    
    private func populateCategorySemanticKeys(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let categories = try context.fetch(request)
        
        for category in categories {
            if let name = category.name {
                category.displayName = name
                category.normalizedName = name.lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                category.updatedAt = Date()
            }
        }
        
        print("  ✅ Populated semantic keys for \\(categories.count) categories")
    }
    
    private func populateIngredientTemplateSemanticKeys(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        let templates = try context.fetch(request)
        
        for template in templates {
            if let name = template.name {
                template.displayName = name
                // Use existing normalization if available, otherwise simple lowercase
                template.canonicalName = name.lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                template.updatedAt = Date()
                
                if template.createdAt == nil {
                    template.createdAt = template.dateCreated ?? Date()
                }
            }
        }
        
        print("  ✅ Populated semantic keys for \\(templates.count) templates")
    }
    
    private func populatePlannedMealSemanticKeys(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<PlannedMeal> = PlannedMeal.fetchRequest()
        let meals = try context.fetch(request)
        
        // PlannedMeal likely empty in development, but handle if exists
        for meal in meals {
            // Default mealType to "dinner" for existing meals
            if meal.mealType == nil {
                meal.mealType = "dinner"
            }
            
            if let date = meal.date, let mealType = meal.mealType {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateString = formatter.string(from: date)
                meal.slotKey = "\\(dateString)-\\(mealType.lowercased())"
            }
            
            if meal.createdAt == nil {
                meal.createdAt = meal.createdDate ?? Date()
            }
        }
        
        print("  ✅ Populated semantic keys for \\(meals.count) planned meals")
    }
    
    private func populateRecipeSemanticKeys(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let recipes = try context.fetch(request)
        
        for recipe in recipes {
            if let title = recipe.title {
                recipe.displayName = title
                recipe.titleKey = title.lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        print("  ✅ Populated semantic keys for \\(recipes.count) recipes")
    }
    
    private func populateDisplayNames(in context: NSManagedObjectContext) throws {
        // WeeklyList
        let weeklyListRequest: NSFetchRequest<WeeklyList> = WeeklyList.fetchRequest()
        let weeklyLists = try context.fetch(weeklyListRequest)
        for list in weeklyLists {
            if let name = list.name {
                list.displayName = name
            }
        }
        
        // MealPlan
        let mealPlanRequest: NSFetchRequest<MealPlan> = MealPlan.fetchRequest()
        let mealPlans = try context.fetch(mealPlanRequest)
        for plan in mealPlans {
            if let name = plan.name {
                plan.displayName = name
            }
        }
        
        // Similar for GroceryItem, GroceryListItem, Ingredient
        // (Add as needed based on your model)
        
        print("  ✅ Populated displayName for other entities")
    }
}
```

---

**8. Wire Up Migration in Persistence.swift** (10 min)

```swift
// In Persistence.swift, modify init() to call migration

init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "forager")
    
    #if !DEBUG
    // ... CloudKit configuration (existing code)
    #endif
    
    container.loadPersistentStores { description, error in
        if let error = error {
            fatalError("Core Data failed to load: \\(error)")
        }
    }
    
    // Configure merge policy
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    // RUN STAGE A MIGRATION
    container.performBackgroundTask { backgroundContext in
        self.performStageAMigration(in: backgroundContext)
    }
}
```

---

**9. Build and Test** (15 min)

```bash
# Build
⌘B (should succeed)

# Run on Simulator (Debug mode - local only)
⌘R

# Check console for:
"🚀 Stage A Migration: Populating semantic keys..."
"  ✅ Populated semantic keys for X categories"
"  ✅ Populated semantic keys for X templates"
"✅ Stage A migration completed successfully"

# Verify in Core Data Debug:
1. Add breakpoint after migration
2. Check Category entities have:
   - displayName populated
   - normalizedName populated
   - updatedAt populated

# Run on Device (Release mode - CloudKit enabled)
1. Archive → Distribute → Debugging
2. Install on iPhone
3. Launch and verify migration runs
4. No crashes, no errors
```

---

### **Phase 1.1 Acceptance Criteria**

- [ ] Model Version 2 created successfully
- [ ] All semantic key fields added as optional
- [ ] All indexes created
- [ ] Migration code compiles
- [ ] Migration code wired into Persistence.swift
- [ ] Build succeeds on simulator
- [ ] Migration runs successfully (check console)
- [ ] Semantic keys populated for existing data
- [ ] UserDefaults flag set (prevents re-run)
- [ ] No crashes, no errors
- [ ] Ready for Phase 1.2 (Stage B)

---

### **After Phase 1.1 Success**

**✅ Git Commit:**
```bash
git add .
git commit -m "M7.1.3 Phase 1.1: Stage A migration - Add optional semantic keys

- Created Model Version 2 (forager 2.xcdatamodel)
- Added optional semantic key fields to Category, IngredientTemplate, PlannedMeal, Recipe
- Added displayName to all entities
- Implemented migration code to populate semantic keys
- Migration validated on simulator and device
- UserDefaults flag prevents re-run
- Zero crashes, zero data loss"

git push
```

**Next:** Phase 1.2 - Stage B Migration (make fields required, add constraints)

---

## 📋 **COMPLETE PHASE BREAKDOWN**

### **Phase 1: Core Data Model (2-3 hours)**
- **Phase 1.1**: Stage A Migration - Add optional fields ✅ ← **YOU ARE HERE**
- **Phase 1.2**: Stage B Migration - Make required, add constraints (45 min)

### **Phase 2: Repositories (2-3 hours)**
- **Phase 2.1**: CategoryRepository (45 min)
- **Phase 2.2**: PlannedMealRepository (1 hour)
- **Phase 2.3**: Enhanced IngredientTemplateService (45 min)
- **Phase 2.4**: RecipeDuplicateDetector (30 min)

### **Phase 3: Code Integration (2-3 hours)**
- **Phase 3.1**: Wire up repositories (30 min)
- **Phase 3.2**: Update Category creation (45 min)
- **Phase 3.3**: Update IngredientTemplate creation (30 min)
- **Phase 3.4**: Update PlannedMeal creation (1 hour)
- **Phase 3.5**: Add Recipe duplicate detection (1 hour)

### **Phase 4: Two-Device Testing (2-3 hours)**
- **Phase 4.1**: Environment setup (30 min)
- **Phase 4.2**: Repository pattern testing (1 hour)
- **Phase 4.3**: Simultaneous creation (critical) (30 min)
- **Phase 4.4**: CloudKit Dashboard verification (30 min)

### **Phase 5: Basic Documentation (1 hour)**
- **Phase 5.1**: Create learning notes (30 min)
- **Phase 5.2**: Update project documentation (30 min)

### **Phase 6: ADRs & Learning Documents (1.5-2 hours)**
- **Phase 6.1**: Create 11 ADR documents (1 hour)
- **Phase 6.2**: Comprehensive learning notes (30 min)
- **Phase 6.3**: Update architecture index (15 min)
- **Phase 6.4**: Cross-reference documentation (15 min)

**Total: 11-15 hours (conservative: 12 hours)**

---

## 🎯 **SUCCESS METRICS**

### **Phase 1 Metrics**
- Migration succeeds: ✅ / ❌
- Semantic keys populated: _____ entities
- Build success: ✅ / ❌
- Zero crashes: ✅ / ❌
- Time spent: _____ hours (estimated: 2-3h)

### **Overall M7.1.3 Metrics** (track as you go)
- Planning accuracy: _____ % (actual / estimated × 100)
- Target: 85-95% (historical: 89%)
- Performance: All operations < 0.5s? ✅ / ❌
- CloudKit sync < 5s? ✅ / ❌

---

## ⚠️ **CRITICAL REMINDERS**

1. **Two-Stage Migration is Non-Negotiable**
   - Stage A: Optional fields → populate → sync
   - Stage B: Required + constraints
   - Skipping Stage A causes crashes

2. **Keep Old Fields During Stage A**
   - Don't delete `name` or `title` fields yet
   - Migration copies data to new fields
   - Stage B removes old fields

3. **Merge Policy Required**
   - `NSMergeByPropertyObjectTrumpMergePolicy`
   - Handles edge-case constraint conflicts
   - Last-write-wins (acceptable for M7.1.3)

4. **Physical Devices for Testing**
   - Phase 4 requires 2 iPhones on same iCloud account
   - Simulators unreliable for multi-device sync
   - Plan ahead for device availability

5. **No Shortcuts**
   - This is production-ready architecture
   - Shortcuts create technical debt
   - 11 ADRs document "why" not just "what"

---

## 📚 **KEY RESOURCES**

**PRD:** `docs/prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md`

**Sections to Reference:**
- Architectural Decisions (11 ADRs documented)
- Detailed Entity Specifications (code examples)
- Two-Stage Migration Strategy (critical safety)
- Complete relationship migration table

**Apple Documentation:**
- [Core Data Model Versioning](https://developer.apple.com/documentation/coredata/core_data_model_versioning_and_data_migration)
- [NSPersistentCloudKitContainer](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [Merge Policies](https://developer.apple.com/documentation/coredata/nsmergebypolicytype)

---

## 🚨 **QUALITY GATES**

**Stop if:**
- ❌ Migration fails or crashes
- ❌ More than 5 build errors consecutively
- ❌ Breaking existing features
- ❌ Data loss during migration
- ❌ Spending > 30 min on single issue (escalate)

**Continue if:**
- ✅ Build succeeds
- ✅ Migration runs successfully
- ✅ Semantic keys populated
- ✅ Console logs show success
- ✅ No regressions

---

**Ready to start Phase 1.1? Let's build production-ready CloudKit sync! 🚀**

**Version**: 3.0 - M7.1.3 CloudKit Sync Integrity  
**Last Updated**: December 10, 2024  
**Current Phase**: Phase 1.1 - Stage A Migration  
**Estimated Total**: 11-15 hours (conservative: 12 hours)