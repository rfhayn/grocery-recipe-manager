# Next Implementation Prompt - M7.1.3 Phase 1.3

**Phase**: M7.1.3 - CloudKit Sync Integrity  
**Sub-Phase**: Phase 1.3 - Uniqueness Constraints  
**Estimated Time**: 1-2 hours  
**Status**: 🚀 READY TO START  
**Prerequisites**: Phase 1.1 ✅ COMPLETE, Phase 1.2 ✅ COMPLETE  
**Date**: December 19, 2025

---

## 🚨 **CRITICAL: GIT WORKFLOW CLEANUP FIRST**

**Before starting Phase 1.3, we need to fix the git workflow:**

### **Current Situation**
- ⚠️ Phase 1.2 changes committed directly to `main` branch
- ✅ Should have been on feature branch `feature/M7.1.3-phase1.2`
- ⚠️ Need to clean this up before continuing

### **Decision Point**

You have two options:

#### **Option A: Commit Phase 1.2 to Main (RECOMMENDED)**
Since Phase 1.2 is complete and working, commit it to main with a comprehensive message:

```bash
git status  # Check what's uncommitted
git add -A
git commit -m "M7.1.3 Phase 1.2 COMPLETE: Repository pattern implemented

✅ Created repositories:
- CategoryRepository (get-or-create by normalizedName)
- IngredientTemplateRepository (get-or-create by canonicalName)
- PlannedMealRepository (get-or-create by slotKey)

✅ Updated application code:
- AddIngredientView uses repository
- IngredientTemplateService uses repository
- MealPlanService uses repository

✅ Removed conflicting validation:
- Removed duplicate name check from IngredientTemplate+Validation
- Repository now sole source of duplicate prevention

✅ Fixed extension methods:
- PlannedMeal+Extensions.swift complete with helpers
- Category+Extensions.swift normalized name helper
- IngredientTemplate+Extensions.swift canonical name helper

✅ Testing:
- Zero 'duplicateName' errors
- Templates created and found correctly
- Recipe-to-grocery flow working
- Meal planning working
- All existing features work

⚠️ Known minor issues (non-blocking):
- CloudKit attempts background sync in Debug (cosmetic)
- Some template normalization edge cases

🔧 Technical fixes:
- Build configuration: Release → Debug
- Repository target membership added
- Extension methods completed
- Validation layer conflicts removed

Time: 1 hour (50% of 2-3h estimate)

🎯 Next: Phase 1.3 (Uniqueness Constraints, 1-2h)"

git push origin main
```

#### **Option B: Create Retroactive Feature Branch**
If you want to preserve pure main branch history:

```bash
# Create branch from current HEAD
git checkout -b feature/M7.1.3-phase1.2-retroactive

# All uncommitted changes move to this branch
git add -A
git commit -m "[message from Option A]"
git push origin feature/M7.1.3-phase1.2-retroactive

# Create PR
gh pr create --fill

# Merge with squash
gh pr merge --squash --delete-branch

# Update local main
git checkout main
git pull origin main
```

---

## 🎯 **PHASE 1.3 OVERVIEW**

### **Goal**
Add Core Data uniqueness constraints to semantic key fields, enforcing database-level duplicate prevention.

### **Why This Matters**
- **Layer 1** (Phase 1.1): Semantic keys exist ✅
- **Layer 2** (Phase 1.2): Repository prevents duplicates ✅
- **Layer 3** (Phase 1.3): Database enforces uniqueness ← YOU ARE HERE

### **What Gets Constrained**
- ✅ **Category.normalizedName** - One category per normalized name
- ✅ **IngredientTemplate.canonicalName** - One template per canonical name
- ✅ **PlannedMeal.slotKey** - One meal per date+mealType slot
- ❌ **Recipe.titleKey** - NO constraint (users can have duplicate recipe names)

---

## ⚠️ **IMPORTANT PREREQUISITES**

**Only proceed if:**
- ✅ Phase 1.2 repository pattern working
- ✅ Zero duplicate creation observed in testing
- ✅ App running smoothly with no errors

**If any issues:**
1. Fix Phase 1.2 issues first
2. Test thoroughly before adding constraints
3. Constraints are PERMANENT - can't be removed easily

---

## 📋 **IMPLEMENTATION STEPS**

### **Step 1: Create Model Version 3** (15 minutes)

1. **Open Core Data model in Xcode**
   - Navigate to `forager.xcdatamodeld`
   - File should show "forager 2" as current version

2. **Add new model version**
   - Editor → Add Model Version
   - Name: "forager 3"
   - Based on: "forager 2"

3. **Set as current version**
   - Select `forager.xcdatamodeld` in Project Navigator
   - File Inspector → Model Version → Current: "forager 3"

4. **Verify**
   - Build (Command+B)
   - Should succeed with no changes yet

5. **Commit**
```bash
git add forager.xcdatamodeld
git commit -m "M7.1.3 Phase 1.3: Create Model Version 3"
git push
```

---

### **Step 2: Add Uniqueness Constraints** (30 minutes)

**For Each Entity (Category, IngredientTemplate, PlannedMeal):**

#### **Category Constraint**

1. **Open forager 3.xcdatamodel**
2. **Select Category entity**
3. **Constraints section** (bottom of entity editor)
4. **Click "+" to add constraint**
5. **Add: `normalizedName`**
6. **Build and test** (Command+B)
7. **Commit**
```bash
git add forager.xcdatamodeld
git commit -m "M7.1.3 Phase 1.3: Add uniqueness constraint to Category.normalizedName"
git push
```

#### **IngredientTemplate Constraint**

1. **Select IngredientTemplate entity**
2. **Constraints section**
3. **Add: `canonicalName`**
4. **Build and test**
5. **Commit**
```bash
git add forager.xcdatamodeld
git commit -m "M7.1.3 Phase 1.3: Add uniqueness constraint to IngredientTemplate.canonicalName"
git push
```

#### **PlannedMeal Constraint**

1. **Select PlannedMeal entity**
2. **Constraints section**
3. **Add: `slotKey`**
4. **Build and test**
5. **Commit**
```bash
git add forager.xcdatamodeld
git commit -m "M7.1.3 Phase 1.3: Add uniqueness constraint to PlannedMeal.slotKey"
git push
```

#### **Recipe - NO Constraint**
- **Do not add constraint to Recipe.titleKey**
- Users can intentionally create recipes with same name
- titleKey is for detection/warning only, not prevention

---

### **Step 3: Make Fields Required** (15 minutes)

**For Each Entity, make semantic keys required:**

1. **Category**
   - `normalizedName`: Optional → Required
   - `updatedAt`: Optional → Required

2. **IngredientTemplate**
   - `canonicalName`: Optional → Required
   - `createdAt`: Already required (verify)
   - `updatedAt`: Optional → Required

3. **PlannedMeal**
   - `slotKey`: Optional → Required
   - `mealType`: Optional → Required
   - `createdDate`: Already required (verify)

4. **Recipe**
   - `titleKey`: Optional → Required
   - `dateCreated`: Already required (verify)

**Build and test after each entity**

**Commit**
```bash
git add forager.xcdatamodeld
git commit -m "M7.1.3 Phase 1.3: Make semantic key fields required"
git push
```

---

### **Step 4: Stage B Migration Code** (30 minutes)

**Location**: `forager/Persistence.swift`

**Add new migration function:**

```swift
// MARK: - M7.1.3 Stage B Migration

/// Stage B: Add uniqueness constraints and make fields required
/// Only runs after Stage A complete and all devices synced
private func performStageBMigration(in context: NSManagedObjectContext) {
    let stageBKey = "M7.1.3.StageB.Completed"
    guard !UserDefaults.standard.bool(forKey: stageBKey) else {
        print("ℹ️ M7.1.3 Stage B: Migration already completed, skipping...")
        return
    }
    
    print("🚀 M7.1.3 Stage B: Starting uniqueness constraints migration...")
    
    // Verify all entities have semantic keys populated
    let issues = validateSemanticKeys(in: context)
    
    if !issues.isEmpty {
        print("❌ M7.1.3 Stage B: Cannot add constraints - found entities without semantic keys:")
        issues.forEach { print("  - \($0)") }
        print("⚠️ Run Stage A migration first")
        return
    }
    
    // If validation passes, constraints are already in model
    // Just need to mark complete
    UserDefaults.standard.set(true, forKey: stageBKey)
    UserDefaults.standard.set(Date(), forKey: "M7.1.3.StageB.Date")
    print("✅ M7.1.3 Stage B: Migration complete - constraints active")
}

/// Validate all entities have semantic keys before adding constraints
private func validateSemanticKeys(in context: NSManagedObjectContext) -> [String] {
    var issues: [String] = []
    
    // Validate Categories
    let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
    if let categories = try? context.fetch(categoryRequest) {
        for category in categories {
            if category.normalizedName == nil || category.normalizedName?.isEmpty == true {
                issues.append("Category '\(category.name ?? "unknown")' missing normalizedName")
            }
        }
    }
    
    // Validate IngredientTemplates
    let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    if let templates = try? context.fetch(templateRequest) {
        for template in templates {
            if template.canonicalName == nil || template.canonicalName?.isEmpty == true {
                issues.append("Template '\(template.name ?? "unknown")' missing canonicalName")
            }
        }
    }
    
    // Validate PlannedMeals
    let mealRequest: NSFetchRequest<PlannedMeal> = PlannedMeal.fetchRequest()
    if let meals = try? context.fetch(mealRequest) {
        for meal in meals {
            if meal.slotKey == nil || meal.slotKey?.isEmpty == true {
                issues.append("PlannedMeal missing slotKey")
            }
        }
    }
    
    // Validate Recipes
    let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
    if let recipes = try? context.fetch(recipeRequest) {
        for recipe in recipes {
            if recipe.titleKey == nil || recipe.titleKey?.isEmpty == true {
                issues.append("Recipe '\(recipe.title ?? "unknown")' missing titleKey")
            }
        }
    }
    
    return issues
}
```

**Wire up in performOneTimeSetup():**

```swift
private func performOneTimeSetup() {
    container.performBackgroundTask { context in
        // ... existing steps ...
        
        // Step 6: Stage A - Add semantic keys (already exists)
        self.performStageAMigration(in: context)
        
        // Step 7: Stage B - Add constraints (NEW)
        self.performStageBMigration(in: context)
        
        print("✅ One-time setup completed successfully")
    }
}
```

**Commit**
```bash
git add forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.3: Add Stage B migration with validation"
git push
```

---

### **Step 5: Test Constraint Enforcement** (15 minutes)

#### **Test 1: Try to Create Duplicate Directly (Should Fail)**

Add temporary test code to `Persistence.swift` or a test view:

```swift
// TEMPORARY TEST CODE - Remove after testing
func testConstraintViolation(in context: NSManagedObjectContext) {
    // Try to create duplicate category directly (bypassing repository)
    let category1 = Category(context: context)
    category1.id = UUID()
    category1.name = "Produce"
    category1.normalizedName = "produce"
    category1.sortOrder = 0
    category1.updatedAt = Date()
    
    do {
        try context.save()
        print("✅ First category saved")
    } catch {
        print("❌ Unexpected error: \(error)")
    }
    
    // Try to create duplicate (should fail with constraint error)
    let category2 = Category(context: context)
    category2.id = UUID()
    category2.name = "PRODUCE"
    category2.normalizedName = "produce"  // Same normalized name!
    category2.sortOrder = 1
    category2.updatedAt = Date()
    
    do {
        try context.save()
        print("❌ ERROR: Constraint not working - duplicate saved!")
    } catch let error as NSError {
        if error.code == 133021 { // NSConstraintConflictError
            print("✅ Constraint working: Duplicate rejected as expected")
        } else {
            print("❌ Unexpected error: \(error)")
        }
    }
}
```

**Expected console output:**
```
✅ First category saved
✅ Constraint working: Duplicate rejected as expected
```

#### **Test 2: Create via Repository (Should Work)**

```swift
// Test repository properly returns existing
func testRepositoryWithConstraints(in context: NSManagedObjectContext) {
    let cat1 = CategoryRepository.getOrCreate(displayName: "Produce", in: context)
    let cat2 = CategoryRepository.getOrCreate(displayName: "produce", in: context)
    let cat3 = CategoryRepository.getOrCreate(displayName: "PRODUCE", in: context)
    
    // All three should return the same object
    if cat1 === cat2 && cat2 === cat3 {
        print("✅ Repository working correctly with constraints")
    } else {
        print("❌ Repository created multiple objects - check logic")
    }
}
```

**Expected console output:**
```
📦 CategoryRepository: Found existing 'Produce' (normalized: 'produce')
📦 CategoryRepository: Found existing 'Produce' (normalized: 'produce')
✅ Repository working correctly with constraints
```

**Remove test code after validation**

---

## ✅ **ACCEPTANCE CRITERIA**

### **Build & Deployment**
- [ ] Model Version 3 created
- [ ] Constraints added to 3 entities (not Recipe)
- [ ] Fields made required (4 entities)
- [ ] Stage B migration implemented
- [ ] Migration validation logic working
- [ ] All changes committed to feature branch
- [ ] App builds successfully (Command+B)
- [ ] App launches successfully (Command+R)

### **Functional Testing**
- [ ] Constraint test shows duplicate rejected (NSConstraintConflictError)
- [ ] Repository test shows same object returned for duplicates
- [ ] Creating category via UI works (uses repository)
- [ ] Creating ingredient template works (uses repository)
- [ ] Planning meal works (uses repository)
- [ ] No regressions to existing features

### **Data Integrity**
- [ ] Zero data loss
- [ ] All existing entities have semantic keys populated
- [ ] Validation logic catches missing keys
- [ ] Migration is idempotent (runs only once)

### **Documentation**
- [ ] Console output clear and informative
- [ ] All commits follow M#.#.# naming
- [ ] Phase completion documented
- [ ] Learning notes updated
- [ ] current-story.md updated
- [ ] next-prompt.md ready for Phase 2

---

## 🚨 **QUALITY GATES (STOP IF...)**

- ❌ Migration fails validation (entities missing semantic keys)
- ❌ Constraint test doesn't reject duplicate
- ❌ Repository test creates multiple objects for same name
- ❌ Any existing features break
- ❌ App crashes or errors during testing
- ❌ Data loss observed

**If any quality gate fails:**
1. Stop immediately
2. Revert last change
3. Debug and fix issue
4. Rebuild and retest
5. Only proceed when passing

---

## 📊 **TIME ESTIMATES**

| Step | Task | Estimated Time |
|------|------|----------------|
| 1 | Create Model Version 3 | 15 min |
| 2 | Add Uniqueness Constraints | 30 min |
| 3 | Make Fields Required | 15 min |
| 4 | Stage B Migration Code | 30 min |
| 5 | Test Constraint Enforcement | 15 min |
| - | **Total** | **1-2 hours** |

---

## 🎯 **COMPLETION CHECKLIST**

### **Phase 1.3 Complete When:**
- [ ] All 5 steps completed
- [ ] All acceptance criteria met
- [ ] All quality gates passed
- [ ] Documentation updated
- [ ] Learning note created
- [ ] Feature branch merged via PR
- [ ] Ready for Phase 2 (Multi-Device Sync Testing)

---

## 📚 **REFERENCE DOCUMENTS**

**Essential Reading:**
- `docs/prds/m7.1.3-cloudkit-sync-integrity.md` - Complete PRD
- `docs/architecture/007-core-data-change-process.md` - Core Data rules
- `docs/git-workflow-for-milestones.md` - Feature branch workflow
- `docs/current-story.md` - Current status

**Completed Work:**
- `docs/m7-docs/M7.1.3-PHASE1.1-PART1-COMPLETION.md`
- `docs/m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md`
- `docs/m7-docs/M7.1.3-PHASE1.2-COMPLETION.md` (to be created)

---

## 💡 **STRATEGIC NOTES**

### **Why Constraints Last?**
Phase 1.1 added fields → Phase 1.2 added repositories → Phase 1.3 adds constraints

**Order matters:**
1. Can't add constraints before fields exist
2. Can't enforce constraints before data populated
3. Can't test constraints before repositories working

**CloudKit Consideration:**
- Stage A (Phases 1.1-1.2) prepares data
- Stage B (Phase 1.3) enforces constraints
- Multi-device needs time between stages

### **After Phase 1.3**
- **Phase 2**: Multi-device sync testing (2-3 hours)
- Two physical devices required
- Test all duplicate scenarios
- Verify constraints work across devices

---

**Status**: 🚀 READY TO START  
**Prerequisites**: Phase 1.1 ✅, Phase 1.2 ✅  
**Next Action**: Fix git workflow, then start Step 1  
**Estimated Completion**: December 19, 2025 (same day)
