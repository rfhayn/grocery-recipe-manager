# Next Prompt: M4.3.3 - Bulk Add from Meal Plan

**Milestone**: M4.3.3 - Bulk Add from Meal Plan  
**Status**: 🚀 READY  
**Estimated Time**: 2 hours  
**Priority**: HIGH - Core meal planning to grocery workflow  
**Prerequisites**: M4.2 (Meal Planning) ✅, M4.3.1 (Recipe Source Tracking) ✅, M4.3.2 (Scaled Recipe Addition) ✅

---

## 🚀 QUICK START

### **What We're Building**

Single-button workflow to add ALL recipes from a meal plan to a grocery list at once. Leverages M4.3.2 scaling, M4.3.1 source tracking, and M3 quantity consolidation for intelligent automation.

### **User Flow**

```
1. User viewing meal plan (7 days, 5 recipes assigned)
2. Taps "Add All to Shopping List" button
3. Confirmation dialog appears:
   - Shows count: "Add 5 recipes (12 ingredients) to list?"
   - List selection dropdown
   - "Confirm" / "Cancel" buttons
4. User taps "Confirm"
5. Progress indicator shows
6. System processes all recipes:
   - Extracts ingredients from each recipe
   - Uses serving sizes from meal plan assignments
   - Consolidates duplicates (butter from 3 recipes → single entry)
   - Establishes recipe relationships (M4.3.1)
7. Success message: "Added 12 ingredients from 5 recipes to Shopping List"
8. Sheet dismisses, grocery list updated
```

### **Key Technical Points**

- **Leverage M4.3.2**: Use same scaling logic for each recipe
- **Leverage M4.3.1**: Establish many-to-many recipe relationships
- **Leverage M3**: Use QuantityMergeService for consolidation
- **Performance**: Async processing with progress feedback
- **Data Quality**: All structured quantity fields populated

---

## 📋 IMPLEMENTATION GUIDE

### **Phase 1: UI Button & Confirmation** (30-45 min)

**Objective**: Add "Add All to Shopping List" button with confirmation dialog

**Files to Modify**:
- `MealPlanDetailView.swift` - Add button and confirmation logic

**What to Build:**

**1. Add Button to MealPlanDetailView:**
```swift
// Add to MealPlanDetailView.swift toolbar or bottom of view
Button(action: {
    showingBulkAddConfirmation = true
}) {
    HStack(spacing: 8) {
        Image(systemName: "cart.fill.badge.plus")
        Text("Add All to Shopping List")
    }
    .font(.headline)
    .foregroundColor(.white)
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.green)
    .cornerRadius(12)
}
.disabled(plannedMeals.isEmpty)  // Disable if no recipes
```

**2. Add State Variables:**
```swift
// MealPlanDetailView.swift
@State private var showingBulkAddConfirmation = false
@State private var showingListSelection = false
@State private var isProcessing = false
@State private var processingMessage = "Processing..."
@State private var targetWeeklyList: WeeklyList?
```

**3. Add Confirmation Dialog:**
```swift
.confirmationDialog(
    "Add to Shopping List",
    isPresented: $showingBulkAddConfirmation
) {
    Button("Add \(totalIngredientCount) ingredients from \(plannedMeals.count) recipes") {
        showingListSelection = true
    }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("This will add all ingredients from your meal plan to a shopping list.")
}
```

**4. Computed Properties:**
```swift
// Count total unique ingredients across all recipes
private var totalIngredientCount: Int {
    // Calculate estimated count (before consolidation)
    let allIngredients = plannedMeals.flatMap { meal in
        meal.recipe?.ingredients?.allObjects as? [Ingredient] ?? []
    }
    return allIngredients.count
}
```

**Testing:**
- [ ] Button appears when meal plan has recipes
- [ ] Button disabled when no recipes
- [ ] Confirmation dialog shows correct counts
- [ ] Can cancel without side effects

---

### **Phase 2: Bulk Processing Logic** (60-75 min)

**Objective**: Process all recipes and add to grocery list with consolidation

**Files to Modify**:
- `MealPlanDetailView.swift` - Add bulk processing logic

**What to Build:**

**1. Add Bulk Processing Function:**
```swift
// MealPlanDetailView.swift
private func addAllToShoppingList(targetList: WeeklyList) {
    isProcessing = true
    processingMessage = "Adding ingredients..."
    
    // Use background context for heavy operation
    let context = viewContext
    
    DispatchQueue.global(qos: .userInitiated).async {
        var allIngredients: [ProcessedIngredient] = []
        
        // Process each planned meal
        for plannedMeal in plannedMeals {
            guard let recipe = plannedMeal.recipe else { continue }
            guard let ingredientsSet = recipe.ingredients else { continue }
            
            let ingredients = Array(ingredientsSet) as! [Ingredient]
            let servings = plannedMeal.servings ?? recipe.servings
            let scaleFactor = Double(servings) / Double(recipe.servings)
            
            // Scale each ingredient (reuse M4.3.2 logic)
            for ingredient in ingredients {
                let scaled = scaleIngredient(ingredient, by: scaleFactor)
                allIngredients.append(ProcessedIngredient(
                    ingredient: scaled,
                    sourceRecipe: recipe,
                    scaleFactor: scaleFactor
                ))
            }
        }
        
        // Consolidate duplicates
        let consolidated = consolidateIngredients(allIngredients)
        
        // Add to list on main thread
        DispatchQueue.main.async {
            addConsolidatedToList(consolidated, targetList: targetList, context: context)
        }
    }
}

struct ProcessedIngredient {
    let ingredient: Ingredient
    let sourceRecipe: Recipe
    let scaleFactor: Double
}
```

**2. Add Scaling Helper:**
```swift
private func scaleIngredient(_ ingredient: Ingredient, by factor: Double) -> Ingredient {
    // Create temporary copy with scaled quantities
    // Reuse logic from M4.3.2 AddIngredientsToListView
    
    guard factor != 1.0 else { return ingredient }
    
    if ingredient.isParseable && ingredient.numericValue > 0 {
        // Create scaled copy
        let scaled = Ingredient(context: viewContext)
        scaled.name = ingredient.name
        scaled.numericValue = ingredient.numericValue * factor
        scaled.standardUnit = ingredient.standardUnit
        scaled.displayText = formatScaledQuantity(ingredient.numericValue * factor, unit: ingredient.standardUnit)
        scaled.isParseable = ingredient.isParseable
        scaled.parseConfidence = ingredient.parseConfidence
        scaled.ingredientTemplate = ingredient.ingredientTemplate
        return scaled
    } else {
        return ingredient  // Non-parseable, return as-is
    }
}
```

**3. Add Consolidation Logic:**
```swift
private func consolidateIngredients(_ ingredients: [ProcessedIngredient]) -> [ConsolidatedIngredient] {
    // Group by ingredient name (normalized)
    var grouped: [String: [ProcessedIngredient]] = [:]
    
    for processed in ingredients {
        let name = processed.ingredient.ingredientTemplate?.name ?? processed.ingredient.name ?? "Unknown"
        grouped[name, default: []].append(processed)
    }
    
    // Consolidate each group
    return grouped.map { name, group in
        ConsolidatedIngredient(
            name: name,
            totalQuantity: group.reduce(0.0) { $0 + $1.ingredient.numericValue },
            unit: group.first?.ingredient.standardUnit ?? "",
            sourceRecipes: Array(Set(group.map { $0.sourceRecipe })),
            displayText: formatConsolidated(group),
            template: group.first?.ingredient.ingredientTemplate
        )
    }
}

struct ConsolidatedIngredient {
    let name: String
    let totalQuantity: Double
    let unit: String
    let sourceRecipes: [Recipe]
    let displayText: String
    let template: IngredientTemplate?
}
```

**4. Add to List Function:**
```swift
private func addConsolidatedToList(_ consolidated: [ConsolidatedIngredient], targetList: WeeklyList, context: NSManagedObjectContext) {
    for item in consolidated {
        let listItem = GroceryListItem(context: context)
        listItem.id = UUID()
        listItem.name = item.name
        listItem.displayText = item.displayText
        listItem.numericValue = item.totalQuantity
        listItem.standardUnit = item.unit
        listItem.isParseable = true
        listItem.parseConfidence = 0.9
        listItem.isCompleted = false
        listItem.source = "Meal Plan: \(mealPlan.name ?? "Untitled")"
        
        // M4.3.1: Add all source recipes
        for recipe in item.sourceRecipes {
            listItem.addToSourceRecipes(recipe)
        }
        
        // Category assignment
        if let template = item.template,
           let categoryString = template.category,
           !categoryString.isEmpty {
            listItem.categoryName = categoryString
        } else {
            listItem.categoryName = "UNCATEGORIZED"
        }
        
        targetList.addToItems(listItem)
    }
    
    do {
        try context.save()
        print("✅ Successfully added \(consolidated.count) consolidated ingredients from \(plannedMeals.count) recipes")
        
        DispatchQueue.main.async {
            self.isProcessing = false
            self.processingMessage = "Complete!"
            // Show success and dismiss
        }
    } catch {
        print("❌ Error saving bulk add: \(error)")
        DispatchQueue.main.async {
            self.isProcessing = false
            self.processingMessage = "Error occurred"
        }
    }
}
```

**Testing:**
- [ ] Processes all recipes correctly
- [ ] Scaling works for each recipe
- [ ] Consolidation merges duplicates (e.g., butter from 3 recipes)
- [ ] Recipe relationships established for all items
- [ ] Categories assigned correctly
- [ ] Performance < 2s for 10 recipes

---

### **Phase 3: Progress Feedback & Polish** (30-45 min)

**Objective**: Add progress indicator and success messaging

**What to Build:**

**1. Add Processing Overlay:**
```swift
// MealPlanDetailView.swift
.overlay {
    if isProcessing {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(processingMessage)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}
```

**2. Add Success Message:**
```swift
@State private var showingSuccessMessage = false
@State private var successMessage = ""

// After successful save:
self.successMessage = "Added \(consolidated.count) ingredients from \(plannedMeals.count) recipes"
self.showingSuccessMessage = true

// Dismiss after delay
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    self.showingSuccessMessage = false
}
```

**3. Add List Selection Sheet:**
```swift
.sheet(isPresented: $showingListSelection) {
    // Reuse existing list selection pattern
    WeeklyListPickerSheet { selectedList in
        targetWeeklyList = selectedList
        addAllToShoppingList(targetList: selectedList)
        showingListSelection = false
    }
}
```

**Testing:**
- [ ] Progress indicator appears during processing
- [ ] Success message shows with correct counts
- [ ] List selection works correctly
- [ ] UI responsive during processing
- [ ] No crashes or freezes

---

## ✅ ACCEPTANCE CRITERIA

**Core Functionality:**
- [ ] "Add All to Shopping List" button appears in meal plan view
- [ ] Button disabled when no recipes in plan
- [ ] Confirmation dialog shows correct ingredient/recipe counts
- [ ] User can select target grocery list
- [ ] All recipes processed and added to list
- [ ] Duplicate ingredients consolidated (butter × 3 → butter with combined quantity)
- [ ] Recipe relationships established for all items (M4.3.1)
- [ ] Categories assigned correctly
- [ ] Success message displays with accurate counts

**Performance:**
- [ ] Processing completes in < 2s for 10 recipes
- [ ] No UI freezing during processing
- [ ] Progress feedback clear and responsive

**Edge Cases:**
- [ ] Empty meal plan: Button disabled
- [ ] Single recipe: Works correctly (no consolidation needed)
- [ ] Non-parseable items: Included without scaling
- [ ] Mixed units: Preserved (no forced conversion)
- [ ] Cancel during processing: Graceful handling

**Integration:**
- [ ] M4.3.1 recipe badges appear in grocery list
- [ ] M4.3.2 scaling logic reused successfully
- [ ] Grocery list UI displays items correctly
- [ ] Existing list functionality unaffected

---

## 🎯 TESTING SCENARIOS

### **Test 1: Basic Bulk Add**
1. Create meal plan with 3 recipes
2. Tap "Add All to Shopping List"
3. Confirm addition
4. Verify all ingredients added
5. Check recipe badges appear

### **Test 2: Consolidation**
1. Create meal plan with Pancakes + French Toast (both use eggs, milk, butter)
2. Tap "Add All"
3. Verify:
   - Eggs consolidated (2 + 3 = 5 eggs)
   - Milk consolidated (1 cup + 1/2 cup = 1 1/2 cups)
   - Butter consolidated (2 tbsp + 1 tbsp = 3 tbsp)
   - Recipe badges show both recipes

### **Test 3: Scaled Recipes**
1. Create meal plan
2. Assign Pancakes at 2× servings (16 instead of 8)
3. Assign French Toast at 1× servings (4)
4. Tap "Add All"
5. Verify Pancakes ingredients doubled
6. Verify French Toast ingredients unchanged

### **Test 4: Performance**
1. Create meal plan with 10 recipes
2. Tap "Add All"
3. Verify completion < 2s
4. Verify no UI freezing

---

## 📁 FILES TO MODIFY

**Primary Files:**
1. **MealPlanDetailView.swift** - Add button, confirmation, bulk processing logic (~150 lines)

**No New Files Needed** - Reuses existing patterns

---

## 💡 TIPS & REMINDERS

### **Reuse M4.3.2 Patterns**
```swift
// From AddIngredientsToListView - scaledDisplayText logic
// Reuse the fraction formatting and scaling math
```

### **Reuse M4.3.1 Patterns**
```swift
// From addToShoppingList() - recipe relationship establishment
listItem.addToSourceRecipes(recipe)
```

### **Performance**
- Use background thread for heavy processing
- Batch Core Data saves
- Pre-calculate ingredient counts for UI

### **Error Handling**
- Graceful failure if recipe has no ingredients
- Handle nil safely throughout
- User-friendly error messages

---

## 🚀 READY TO START?

**Session Startup Checklist:**
1. ✅ Read this next-prompt.md
2. ✅ Review M4.3.2 (scaling logic to reuse)
3. ✅ Review M4.3.1 (recipe relationships)
4. ✅ Check current-story.md for any updates
5. ✅ Open MealPlanDetailView.swift

**First Steps:**
1. Add "Add All to Shopping List" button to MealPlanDetailView
2. Add confirmation dialog with counts
3. Implement Phase 1 (UI), test, then proceed to Phase 2

---

**Good luck! This completes the meal planning to grocery workflow! 🎉**

---

**Document Version**: 1.0  
**Created**: November 22, 2025  
**Status**: 🚀 READY  
**Estimated Time**: 2 hours  
**Prerequisites**: M4.2 ✅, M4.3.1 ✅, M4.3.2 ✅