# Implementation Guide: M4.3.1 - Recipe Source Tracking Foundation

**Phase 1 of 5**: Core Data Relationship Migration  
**Estimated Time**: 20 minutes  
**Last Updated**: November 11, 2025  
**Status**: 🚀 READY TO START

---

## 🎯 What We're Building (M4.3.1 Complete)

Enable grocery list items to track which recipe(s) contributed ingredients, with user-controlled display:
- Many-to-many relationship: GroceryListItem ↔ Recipe
- Recipe source tags: `"Ground beef [Tacos] [Spaghetti]"`
- Settings toggle: Show/hide recipe sources
- Foundation for M4.3.2 (Scaled Recipe to List) and M4.3.3 (Bulk Add from Meal Plan)

---

## 📋 Phase 1: Core Data Relationship Migration

**Goal**: Add many-to-many relationship, remove legacy UUID tracking

**Time**: 20 minutes  
**Complexity**: Low (lightweight migration, well-tested pattern)

---

### **Tasks**

#### **1. Open Core Data Model** (2 min)

**Location**: `GroceryRecipeManager.xcdatamodeld`

**Action**: Open in Xcode:
- Navigate to project root
- Find `GroceryRecipeManager.xcdatamodeld`
- Click to open Core Data model editor

---

#### **2. Add Relationship to GroceryListItem** (5 min)

**Entity**: GroceryListItem

**Add Relationship**:
1. Select GroceryListItem entity
2. Click "+" under Relationships section
3. Configure:
   - **Name**: `sourceRecipes`
   - **Destination**: Recipe
   - **Type**: To Many
   - **Inverse**: groceryListItems (will create next)
   - **Delete Rule**: Nullify
   - **Optional**: Yes (checked)

**Why Nullify**: Recipe deletion removes tag from item but keeps item on list

**Validation**:
- [ ] Relationship name exactly `sourceRecipes` (plural)
- [ ] Destination is Recipe entity
- [ ] Type is "To Many" (checkbox checked)
- [ ] Delete Rule is "Nullify"

---

#### **3. Add Inverse Relationship to Recipe** (5 min)

**Entity**: Recipe

**Add Relationship**:
1. Select Recipe entity
2. Click "+" under Relationships section
3. Configure:
   - **Name**: `groceryListItems`
   - **Destination**: GroceryListItem
   - **Type**: To Many
   - **Inverse**: sourceRecipes
   - **Delete Rule**: Nullify
   - **Optional**: Yes (checked)

**Why Nullify**: List item deletion doesn't affect recipe

**Validation**:
- [ ] Relationship name exactly `groceryListItems` (plural)
- [ ] Destination is GroceryListItem entity
- [ ] Inverse is sourceRecipes
- [ ] Type is "To Many"
- [ ] Delete Rule is "Nullify"

---

#### **4. Remove Legacy Attributes** (3 min)

**Entity**: GroceryListItem

**Delete Attributes**:
1. Select GroceryListItem entity
2. Find and delete:
   - `sourceRecipeID` (UUID? - no longer needed)
   - `sourceType` (String? - no longer needed)
3. Confirm deletion

**Why Remove**: Replaced by proper Core Data relationship

**Validation**:
- [ ] `sourceRecipeID` attribute deleted
- [ ] `sourceType` attribute deleted
- [ ] No compilation errors about missing attributes

---

#### **5. Save and Build** (5 min)

**Actions**:
1. **Save**: Cmd+S to save Core Data model
2. **Clean Build**: Cmd+Shift+K
3. **Build**: Cmd+B

**Expected Outcome**:
- Xcode auto-generates Core Data classes
- `GroceryListItem+CoreDataProperties.swift` regenerated with `sourceRecipes`
- `Recipe+CoreDataProperties.swift` regenerated with `groceryListItems`
- Lightweight migration applied automatically

**If Build Fails**:
- Check for any code referencing `sourceRecipeID` or `sourceType`
- Search project (Cmd+Shift+F) for these properties
- Remove or comment out any references (we'll fix properly in later phases)

**Validation**:
- [ ] Build succeeds (zero errors)
- [ ] No Core Data warnings in console
- [ ] App launches successfully
- [ ] Sample data loads (grocery lists visible)

---

### **Verification Steps**

**After successful build:**

1. **Run App**: Launch in simulator
2. **Check App Launch**: Should open without errors
3. **Navigate to Lists**: Verify grocery lists load
4. **Check Recipes**: Verify recipes load
5. **No Crashes**: App should function normally

**What's Changed**:
- Core Data schema updated
- Managed object classes regenerated
- Lightweight migration applied
- Legacy attributes removed

**What's NOT Changed Yet**:
- No UI changes (that's Phase 3-5)
- No Settings changes (that's Phase 2-3)
- No display logic (that's Phase 4)
- Relationship not yet populated (that's future M4.3.2/M4.3.3)

---

## 🔍 Core Data Schema Reference

**Before (Legacy)**:
```swift
// GroceryListItem
sourceRecipeID: UUID?      // Single recipe only
sourceType: String?        // Manual vs Recipe

// Recipe
// No relationship to list items
```

**After (M4.3.1 Phase 1)**:
```swift
// GroceryListItem
sourceRecipes: Set<Recipe>  // Multiple recipes (many-to-many)

// Recipe  
groceryListItems: Set<GroceryListItem>  // Inverse relationship
```

---

## 🚨 Troubleshooting

### **Issue**: Build errors about sourceRecipeID

**Cause**: Code still references deleted attribute  
**Fix**: 
```bash
# Search for references
Cmd+Shift+F → search "sourceRecipeID"
# Comment out or remove references
# Will fix properly in later phases
```

### **Issue**: Core Data validation warnings

**Cause**: Relationship misconfigured  
**Fix**:
- Check inverse relationships match
- Verify delete rules are "Nullify"
- Ensure both are "To Many"

### **Issue**: App crashes on launch

**Cause**: Migration issue  
**Fix**:
1. Delete app from simulator
2. Clean build folder (Cmd+Shift+K + Cmd+Option+Shift+K)
3. Rebuild and run
4. Sample data will recreate

### **Issue**: Managed object classes not regenerated

**Cause**: Xcode needs explicit regeneration  
**Fix**:
1. Editor → Create NSManagedObject Subclass
2. Select GroceryRecipeManager model
3. Select GroceryListItem and Recipe entities
4. Generate (will overwrite existing)

---

## ✅ Phase 1 Completion Checklist

**Before moving to Phase 2:**

- [ ] `sourceRecipes` relationship added to GroceryListItem
- [ ] `groceryListItems` relationship added to Recipe
- [ ] Both relationships are "To Many"
- [ ] Both have "Nullify" delete rule
- [ ] Inverse relationships correctly configured
- [ ] `sourceRecipeID` attribute deleted from GroceryListItem
- [ ] `sourceType` attribute deleted from GroceryListItem
- [ ] Core Data model saved
- [ ] Build succeeds with zero errors
- [ ] App launches without crashes
- [ ] Grocery lists and recipes load normally

**Time Tracking**:
- [ ] Note actual time spent (target: 20 min)
- [ ] Compare to estimate for planning accuracy

---

## 📝 Documentation Requirements

**After Phase 1:**

1. **Update current-story.md**:
```markdown
### M4.3.1 Phase 1: Core Data Migration ✅ COMPLETE (XX min)
- Added sourceRecipes many-to-many relationship
- Removed legacy sourceRecipeID and sourceType
- Lightweight migration successful
- Build succeeds, app functional
```

2. **No learning note yet** (wait until all 5 phases complete)

3. **Inline Comments**: None needed (schema changes self-documenting)

---

## 🚀 Next Steps

**After Phase 1 Complete:**

Update `next-prompt.md` for Phase 2:
- UserPreferences property rename
- Settings UI reorganization  
- Estimated: 25 minutes (15 min + 10 min combined)

**Do NOT proceed until**:
- [ ] Phase 1 acceptance criteria all met
- [ ] Build succeeds with zero errors
- [ ] App launches and functions normally

---

## 🎯 Phase 2 Preview

**Next: UserPreferences Enhancement (15 min)**

**What we'll do:**
1. Rename `showRecipeSourceInMealPlan` → `showRecipeSources`
2. Update UserPreferencesService
3. Create new "Display Options" section in Settings
4. Move recipe source toggle to new section

**Why wait**: Core Data foundation must be solid before UI changes

---

## 📚 Reference Materials

**Similar Patterns**:
- Learning Note 03: Core Data Fundamentals (relationship patterns)
- Learning Note 09: M1 Completion (many-to-many relationships)
- M3 Phase 3: isStaple migration (lightweight migration pattern)

**Key Files Modified**:
- `GroceryRecipeManager.xcdatamodeld/GroceryRecipeManager.xcdatamodel/contents`
- `GroceryListItem+CoreDataProperties.swift` (auto-regenerated)
- `Recipe+CoreDataProperties.swift` (auto-regenerated)

**PRD Reference**:
- Full PRD: `docs/prds/milestone-4.3.1-recipe-source-tracking-foundation.md`
- Section: "Implementation Plan → Phase 1"

---

## 💬 Ready to Start?

**Copy-paste this to begin:**

```
I'm ready to implement M4.3.1 Phase 1: Core Data Relationship Migration.

I've completed the mandatory session startup:
✅ Read session-startup-checklist.md
✅ Read project-naming-standards.md
✅ Read current-story.md (M4.3.1 is 🚀 READY)
✅ Read next-prompt.md (this file)
✅ Reviewed PRD: milestone-4.3.1-recipe-source-tracking-foundation.md

I understand we're:
1. Adding sourceRecipes (to-many) relationship to GroceryListItem
2. Adding groceryListItems (to-many) inverse to Recipe
3. Deleting legacy sourceRecipeID and sourceType attributes
4. Both delete rules: Nullify
5. Expecting lightweight migration and clean build

Please guide me through Phase 1 step-by-step.
Time estimate: 20 minutes.
```

---

**Ready When You Are!** 🚀

This is a straightforward Core Data change following proven migration patterns from M3. The relationship addition is low-risk because:
- ✅ Lightweight migration (automatic)
- ✅ No data loss (new relationships start empty)
- ✅ Pre-production (can rebuild if needed)
- ✅ Proven pattern (similar to M1-M3 work)

---

**Version**: 1.0  
**Created**: November 11, 2025  
**Phase**: 1 of 5 (Core Data Migration)  
**Next Phase**: UserPreferences + Settings UI (25 min)  
**Total M4.3.1**: 60 minutes (5 phases)