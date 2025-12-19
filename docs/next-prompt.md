# Next Prompt: M7.1.3 Phase 1.2 - Repository Pattern Implementation

**Milestone**: M7.1.3 CloudKit Sync Integrity  
**Current Phase**: Phase 1.2 - Repository Pattern Implementation  
**Status**: 🚀 READY TO START  
**Estimated Time**: 3-4 hours  
**Prerequisites**: Phase 1.1 Complete ✅ (semantic keys added, populated, helpers created)

---

## 🎯 PHASE 1.2 OBJECTIVE

**Goal**: Implement repository pattern for all 4 entities to prevent duplicates when creating new records.

**Approach**: Use semantic keys to query before creating, ensuring uniqueness at application level. This prevents CloudKit from ever receiving duplicate entities in the first place.

**Critical Note**: Recipes ALLOW duplicates by design - RecipeRepository only warns users, does not prevent.

---

## 📋 IMPLEMENTATION PLAN

### **Part 1: CategoryRepository (45-60 min)**

**File**: `CategoryRepository.swift`

**Core Function**:
```swift
func findOrCreate(name: String, context: NSManagedObjectContext) throws -> Category
```

**Implementation**:
1. Normalize name using `Category.normalizedName(from:)`
2. Query by `normalizedName` using NSFetchRequest
3. If found, return existing Category
4. If not found, create new Category with all semantic fields populated
5. Return Category

**Update Locations**:
- `Persistence.swift` - Sample data creation
- `AddCategoryView` - User category creation
- Anywhere else categories are created

### **Part 2: IngredientTemplateRepository (45-60 min)**

**File**: `IngredientTemplateRepository.swift`

**Core Function**:
```swift
func findOrCreate(name: String, category: Category, context: NSManagedObjectContext) throws -> IngredientTemplate
```

**Implementation**:
1. Normalize name using `IngredientTemplate.canonicalName(from:)`
2. Query by `canonicalName` using NSFetchRequest
3. If found, return existing IngredientTemplate
4. If not found, create new with all semantic fields + category
5. Return IngredientTemplate

**Update Locations**:
- `IngredientParsingService` - Ingredient parsing
- `Persistence.swift` - Sample data creation
- Anywhere else templates are created

### **Part 3: PlannedMealRepository (45-60 min)**

**File**: `PlannedMealRepository.swift`

**Core Function**:
```swift
func findOrCreate(date: Date, mealType: String, recipe: Recipe, context: NSManagedObjectContext) throws -> PlannedMeal
```

**Implementation**:
1. Generate slotKey using `PlannedMeal.generateSlotKey(date:mealType:)`
2. Query by `slotKey` using NSFetchRequest
3. If found, return existing PlannedMeal
4. If not found, create new with all semantic fields + recipe
5. Return PlannedMeal

**Update Locations**:
- `MealPlanService` - Meal planning
- `Persistence.swift` - Sample data creation
- Anywhere else planned meals are created

### **Part 4: RecipeRepository (45-60 min)**

**File**: `RecipeRepository.swift`

**Core Function**:
```swift
func findSimilar(title: String, context: NSManagedObjectContext) throws -> [Recipe]
```

**WARNING**: Recipes ALLOW duplicates (by design)
- Does NOT have `findOrCreate()` 
- Only has `findSimilar()` for user warnings
- titleKey used for detection, NOT prevention

**Implementation**:
1. Normalize title using `Recipe.titleKey(from:)`
2. Query by `titleKey` using NSFetchRequest
3. Return array of matching recipes (may be empty)
4. View layer uses this to warn user: "Recipe 'Chocolate Cookies' already exists (2). Continue anyway?"

**Update Locations**:
- `AddRecipeView` - Show warning if similar recipes exist
- User can choose to create anyway (duplicates allowed)

---

## 🔧 REPOSITORY PATTERN TEMPLATE

```swift
import CoreData

class CategoryRepository {
    
    // MARK: - Find or Create
    
    /// Finds existing category by normalizedName or creates new one
    /// Prevents duplicates by querying semantic key first
    /// - Parameters:
    ///   - name: Display name for category
    ///   - context: NSManagedObjectContext to use
    /// - Returns: Existing or newly created Category
    /// - Throws: Core Data errors
    func findOrCreate(name: String, context: NSManagedObjectContext) throws -> Category {
        // Normalize using helper
        let normalizedName = Category.normalizedName(from: name)
        
        // Query by semantic key
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "normalizedName == %@", normalizedName)
        request.fetchLimit = 1
        
        // Return existing if found
        if let existing = try context.fetch(request).first {
            return existing
        }
        
        // Create new with all semantic fields
        let category = Category(context: context)
        category.name = name
        category.normalizedName = normalizedName
        category.updatedAt = Date()
        // ... set other fields as needed
        
        return category
    }
}
```

---

## ✅ ACCEPTANCE CRITERIA

**Per Repository**:
- [ ] File created in project root (e.g., `CategoryRepository.swift`)
- [ ] Core function(s) implemented (findOrCreate or findSimilar)
- [ ] Uses semantic key helpers from Phase 1.1
- [ ] Proper error handling
- [ ] Code comments explaining "why"

**Integration**:
- [ ] All entity creation updated to use repositories
- [ ] Persistence.swift sample data uses repositories
- [ ] View models use repositories
- [ ] No direct `Entity(context:)` calls remain (except in repositories)

**Testing**:
- [ ] App builds successfully
- [ ] Manual test: Try creating duplicate category → Returns existing ✅
- [ ] Manual test: Try creating duplicate template → Returns existing ✅
- [ ] Manual test: Try creating duplicate planned meal → Returns existing ✅
- [ ] Manual test: Try creating duplicate recipe → Shows warning, allows creation ✅
- [ ] Zero regressions

---

## 🚨 CRITICAL NOTES

### **1. Recipes Are Different**

**Category/Template/PlannedMeal**: PREVENT duplicates
- Use `findOrCreate()` pattern
- Return existing if found
- Only create if doesn't exist

**Recipe**: ALLOW duplicates
- Use `findSimilar()` pattern  
- Return array of matches
- View layer warns user
- User can create anyway

**Why**: Users legitimately have multiple "Chocolate Chip Cookies" recipes from different sources.

### **2. Repository Pattern Benefits**

- **Application-level duplicate prevention**: Works even without Core Data constraints
- **Consistent logic**: All creation goes through same path
- **Testable**: Repositories can be unit tested
- **Prepares for Phase 1.3**: Constraints will be easy to add after this

### **3. Phase Sequencing Matters**

- **Phase 1.1** (Complete): Added semantic keys, populated existing data
- **Phase 1.2** (Now): Use repositories to prevent NEW duplicates
- **Phase 1.3** (Next): Add Core Data constraints for database-level enforcement

Each phase builds on the previous. Don't skip!

---

## 📝 IMPLEMENTATION SEQUENCE

**Recommended order**:

1. **CategoryRepository first** (simplest - no relationships)
2. **Test it thoroughly** (try creating duplicates)
3. **IngredientTemplateRepository** (has category relationship)
4. **Test it thoroughly**
5. **PlannedMealRepository** (has recipe relationship + date logic)
6. **Test it thoroughly**
7. **RecipeRepository last** (different pattern - findSimilar not findOrCreate)
8. **Final integration testing**

**Build and test after EACH repository!**

---

## 🎯 SUCCESS METRICS

**Time**:
- Estimated: 3-4 hours
- Target accuracy: 90%+ (based on Phase 1.1 performance)

**Quality**:
- Zero build errors
- Zero regressions
- Duplicate prevention working
- Clean git history (frequent commits)

**Performance**:
- findOrCreate queries < 0.01s (indexed semantic keys)
- No performance degradation

---

## 🔀 GIT WORKFLOW

**Create Feature Branch**:
```bash
git checkout main
git pull origin main
git checkout -b feature/M7.1.3-phase1.2-repositories
```

**Commit Frequently** (after each repository):
```bash
git add CategoryRepository.swift forager/Persistence.swift
git commit -m "M7.1.3 Phase 1.2: Implement CategoryRepository

- findOrCreate(name:context:) using normalizedName
- Updated Persistence.swift to use repository
- Updated AddCategoryView to use repository
- Manual test: Duplicate prevention working ✅"
git push origin feature/M7.1.3-phase1.2-repositories
```

**After Phase 1.2 Complete**:
```bash
gh pr create --title "M7.1.3 Phase 1.2: Repository Pattern" --body "..." --base main
gh pr merge --squash --delete-branch
git checkout main
git pull origin main
```

---

## 📚 REFERENCE

**From Phase 1.1** (use these helpers):
- `Category.normalizedName(from:)` 
- `IngredientTemplate.canonicalName(from:)`
- `PlannedMeal.generateSlotKey(date:mealType:)`
- `Recipe.titleKey(from:)`

**Learning Note**: `docs/learning-notes/25-m7.1.3-phase1.1-semantic-keys-foundation.md`

**Current Story**: `docs/current-story.md`

---

**Version**: 1.0  
**Last Updated**: December 18, 2025  
**For Milestone**: M7.1.3 CloudKit Sync Integrity  
**Estimated Time**: 3-4 hours  
**Status**: 🚀 READY TO START
