# Next Prompt: M4.3.2 - Scaled Recipe to List Integration

**Milestone**: M4.3.2 - Scaled Recipe to List Integration  
**Status**: 🚀 READY  
**Estimated Time**: 1.5-2 hours  
**Priority**: HIGH - Core meal planning to grocery workflow  
**Prerequisites**: M3 Phase 4 (RecipeScalingService) ✅, M4.3.1 (Recipe Source Tracking) ✅

---

## 🚀 QUICK START

### **What We're Building**

Enable users to add recipe ingredients to grocery list with **custom serving sizes**. Users can:
- Adjust servings before adding to list (e.g., recipe serves 4, but need 8)
- See real-time preview of scaled quantities
- Add scaled ingredients with proper recipe source tracking
- Leverage existing RecipeScalingService from M3

### **User Flow**

```
1. User views recipe (Chocolate Chip Cookies - Serves 24)
2. Taps "Add to List" button
3. Sheet appears with servings adjuster
   - Original: 24 servings
   - Adjustable: Stepper or picker (6-96 servings)
   - Preview: Shows scaled quantities
4. User adjusts to 48 servings (2x scale)
5. Taps "Add to List"
6. Ingredients added with 2x quantities
7. Recipe relationship established (M4.3.1)
8. Success feedback shown
```

### **Key Technical Points**

- **Leverage M3 Phase 4**: RecipeScalingService already handles math
- **Use M4.3.1**: Recipe relationships for source tracking
- **Maintain Data Quality**: All structured quantity fields populated
- **Performance**: < 0.5s for scaling + adding

---

## 📋 PHASE BREAKDOWN

### **Phase 1: Servings UI in RecipeDetailView** (30-45 min)

**Objective**: Add servings adjustment UI to "Add to List" flow

**Current State:**
```swift
// RecipeDetailView.swift - Current "Add to List" button
Button(action: {
    showingAddToListSheet = true
}) {
    HStack(spacing: 4) {
        Image(systemName: "cart.badge.plus")
        Text("Add to List")
    }
}
```

**What to Build:**

**1. Add State Variables:**
```swift
// RecipeDetailView.swift
@State private var showingAddToListSheet = false
@State private var selectedServings: Int = 0  // NEW: Default to recipe servings
@State private var showingScaledPreview = false  // NEW: For preview sheet
```

**2. Update Sheet Presentation:**
```swift
.sheet(isPresented: $showingAddToListSheet) {
    AddIngredientsToListView(
        recipe: recipe,
        targetServings: selectedServings  // NEW: Pass servings
    )
    .environment(\.managedObjectContext, viewContext)
}
```

**3. Add Servings Picker in Sheet Header:**
```swift
// Inside AddIngredientsToListView
Section {
    VStack(alignment: .leading, spacing: 8) {
        Text("Servings")
            .font(.headline)
        
        HStack {
            Text("Original: \(recipe.servings)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Stepper("\(targetServings) servings", value: $targetServings, in: minServings...maxServings)
                .labelsHidden()
            
            Text("\(targetServings)")
                .font(.body)
                .fontWeight(.medium)
        }
        
        if scaleFactor != 1.0 {
            Text("Scaling by \(scaleFactor, specifier: "%.2f")x")
                .font(.caption)
                .foregroundColor(.orange)
        }
    }
}

// Computed properties
var minServings: Int {
    max(1, Int(Double(recipe.servings) * 0.25))  // 0.25x minimum
}

var maxServings: Int {
    Int(Double(recipe.servings) * 4.0)  // 4x maximum
}

var scaleFactor: Double {
    Double(targetServings) / Double(recipe.servings)
}
```

**Files to Modify:**
- `RecipeDetailView.swift` - Pass targetServings parameter
- `AddIngredientsToListView.swift` - Add servings UI section

**Testing:**
- [ ] Servings picker appears in sheet
- [ ] Default servings = recipe.servings
- [ ] Can adjust servings with stepper
- [ ] Scale factor displays correctly
- [ ] Min/max ranges work (0.25x to 4x)

---

### **Phase 2: Scaled Quantity Calculation** (30-45 min)

**Objective**: Use RecipeScalingService to calculate scaled quantities

**What to Build:**

**1. Add RecipeScalingService:**
```swift
// AddIngredientsToListView.swift
@StateObject private var scalingService: RecipeScalingService

// Initialization
init(recipe: Recipe, targetServings: Int) {
    self.recipe = recipe
    self._targetServings = State(initialValue: targetServings)
    self._scalingService = StateObject(wrappedValue: RecipeScalingService())
    // ... other inits
}
```

**2. Calculate Scaled Ingredients:**
```swift
// Computed property for scaled ingredients
var scaledIngredients: [Ingredient] {
    guard targetServings != recipe.servings else {
        // No scaling needed
        return Array(recipe.ingredients?.allObjects as? [Ingredient] ?? [])
    }
    
    // Use RecipeScalingService from M3
    return scalingService.scaleIngredients(
        ingredients: Array(recipe.ingredients?.allObjects as? [Ingredient] ?? []),
        originalServings: Int(recipe.servings),
        targetServings: targetServings
    )
}
```

**3. Display Scaled Quantities in Preview:**
```swift
// Update ingredient list display
ForEach(scaledIngredients, id: \.objectID) { ingredient in
    HStack {
        Toggle(isOn: binding(for: ingredient)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.ingredientDisplayName)
                    .font(.body)
                
                // Show scaled quantity
                if let displayText = ingredient.displayText, !displayText.isEmpty {
                    Text(displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Show original if scaled
                    if scaleFactor != 1.0, let original = originalDisplayText(ingredient) {
                        Text("(was: \(original))")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}
```

**Key Integration Points:**

**RecipeScalingService Methods to Use:**
```swift
// From M3 Phase 4 - Already implemented!
func scaleIngredients(
    ingredients: [Ingredient],
    originalServings: Int,
    targetServings: Int
) -> [Ingredient]

func scaleQuantity(
    numericValue: Double,
    unit: String?,
    scaleFactor: Double
) -> (value: Double, unit: String?)
```

**Files to Modify:**
- `AddIngredientsToListView.swift` - Add scaling logic

**Testing:**
- [ ] Scaled quantities display correctly
- [ ] Original quantities shown for reference
- [ ] 2x scaling doubles quantities (e.g., 1 cup → 2 cups)
- [ ] 0.5x scaling halves quantities
- [ ] Fractions handled properly (1/2 cup → 1 cup)
- [ ] Non-scalable items unchanged (e.g., "pinch of salt")

---

### **Phase 3: Add Scaled Items to List** (30-45 min)

**Objective**: Create GroceryListItems with scaled quantities and recipe relationships

**What to Build:**

**1. Update addToShoppingList() Function:**
```swift
// AddIngredientsToListView.swift
private func addToShoppingList() {
    guard !selectedIngredients.isEmpty else { return }
    
    let ingredientsToAdd = scaledIngredients.filter { selectedIngredients.contains($0.objectID) }
    
    for ingredient in ingredientsToAdd {
        let listItem = GroceryListItem(context: viewContext)
        listItem.id = UUID()
        listItem.name = ingredient.ingredientDisplayName
        listItem.isCompleted = false
        
        // M4.3.2: Use SCALED quantities
        if scaleFactor != 1.0 {
            // Ingredient already scaled by RecipeScalingService
            listItem.displayText = ingredient.displayText
            listItem.numericValue = ingredient.numericValue
            listItem.standardUnit = ingredient.standardUnit
            listItem.isParseable = ingredient.isParseable
            listItem.parseConfidence = ingredient.parseConfidence
        } else {
            // No scaling, use original values
            listItem.displayText = ingredient.displayText
            listItem.numericValue = ingredient.numericValue
            listItem.standardUnit = ingredient.standardUnit
            listItem.isParseable = ingredient.isParseable
            listItem.parseConfidence = ingredient.parseConfidence
        }
        
        // M4.3.1: Establish recipe relationship
        listItem.addToSourceRecipes(recipe)
        
        // Set category and other properties
        if let template = ingredient.ingredientTemplate {
            listItem.category = template.category
        }
        
        // Add to selected list
        targetList.addToItems(listItem)
    }
    
    // Save context
    do {
        try viewContext.save()
        showSuccess = true
        
        // Analytics (optional)
        print("✅ Added \(ingredientsToAdd.count) scaled ingredients (scale: \(scaleFactor)x)")
    } catch {
        print("❌ Error adding ingredients: \(error)")
    }
}
```

**2. Success Feedback with Scale Info:**
```swift
// Update success message
if showSuccess {
    VStack {
        Image(systemName: "checkmark.circle.fill")
            .font(.largeTitle)
            .foregroundColor(.green)
        
        if scaleFactor != 1.0 {
            Text("Added \(selectedIngredients.count) ingredients (scaled \(scaleFactor, specifier: "%.1f")x)")
                .font(.headline)
        } else {
            Text("Added \(selectedIngredients.count) ingredients")
                .font(.headline)
        }
    }
}
```

**Critical Data Quality Check:**
```swift
// IMPORTANT: Verify ALL structured fields populated
// This prevents empty quotes bug from M4.3.1
assert(listItem.displayText != nil, "displayText must be populated")
assert(listItem.isParseable != nil, "isParseable must be set")
```

**Files to Modify:**
- `AddIngredientsToListView.swift` - Update addToShoppingList()

**Testing:**
- [ ] Scaled items added to list correctly
- [ ] Quantities are scaled (2x recipe → 2x quantities)
- [ ] Recipe relationships established (badges appear)
- [ ] No empty displayText (`""` quotes)
- [ ] All structured fields populated
- [ ] Success message shows scale factor
- [ ] Performance: < 0.5s for adding

---

## 🎯 TECHNICAL REQUIREMENTS

### **Integration with M3 Phase 4 (RecipeScalingService)**

**Service Already Exists - Just Use It!**
```swift
// From M3 Phase 4 - RecipeScalingService.swift
class RecipeScalingService: ObservableObject {
    // Scale all ingredients in a recipe
    func scaleIngredients(
        ingredients: [Ingredient],
        originalServings: Int,
        targetServings: Int
    ) -> [Ingredient]
    
    // Scale a single quantity
    func scaleQuantity(
        numericValue: Double,
        unit: String?,
        scaleFactor: Double
    ) -> (value: Double, unit: String?)
    
    // Convert to display-friendly format
    func formatScaledQuantity(
        value: Double,
        unit: String?
    ) -> String
}
```

**What RecipeScalingService Handles:**
- ✅ Numeric scaling (multiply by scale factor)
- ✅ Fraction conversion (1.5 → "1 1/2")
- ✅ Unit conversion (48 tsp → 1 cup)
- ✅ Rounding to sensible values
- ✅ Display formatting

**What You Need to Do:**
- Initialize the service
- Pass ingredients + servings
- Use scaled results
- That's it!

### **Integration with M4.3.1 (Recipe Source Tracking)**

**Recipe Relationships - Already Working!**
```swift
// From M4.3.1
listItem.addToSourceRecipes(recipe)  // Establishes many-to-many relationship

// Recipe badges will automatically appear in grocery list
// No additional work needed!
```

### **Data Quality Requirements**

**CRITICAL: Populate ALL Structured Fields**
```swift
// Learned from M4.3.1 bugs - MUST populate everything:
listItem.displayText = ingredient.displayText           // ✅ Required
listItem.numericValue = ingredient.numericValue         // ✅ Required
listItem.standardUnit = ingredient.standardUnit         // ✅ Required
listItem.isParseable = ingredient.isParseable           // ✅ Required
listItem.parseConfidence = ingredient.parseConfidence   // ✅ Required

// This prevents empty "" quotes in quantities
```

---

## 📁 FILES TO MODIFY

### **Primary Files**

**1. RecipeDetailView.swift**
- Add selectedServings state
- Pass targetServings to sheet
- Update sheet presentation
- ~20 lines changed

**2. AddIngredientsToListView.swift** (Major changes)
- Add targetServings parameter
- Add RecipeScalingService
- Add servings picker UI
- Update ingredient display with scaling
- Update addToShoppingList() for scaled quantities
- ~100 lines changed

### **Supporting Files**

**3. RecipeScalingService.swift** (No changes needed!)
- Already exists from M3 Phase 4
- Already handles all scaling math
- Just import and use

---

## ✅ TESTING CHECKLIST

### **Phase 1: Servings UI**
- [ ] Servings picker appears in AddIngredientsToListView
- [ ] Default servings equals recipe.servings
- [ ] Can adjust servings with stepper
- [ ] Min/max ranges enforced (0.25x to 4x)
- [ ] Scale factor displays when != 1.0
- [ ] UI responsive, no lag

### **Phase 2: Scaling Calculation**
- [ ] 2x scaling doubles quantities (1 cup → 2 cups)
- [ ] 0.5x scaling halves quantities (2 cups → 1 cup)
- [ ] Fractions handled (1/2 → 1, 1 → 2, etc.)
- [ ] Unit conversion works (48 tsp → 1 cup)
- [ ] Non-numeric items unchanged ("pinch", "to taste")
- [ ] Original quantities shown for reference

### **Phase 3: Adding to List**
- [ ] Scaled items added correctly
- [ ] Recipe relationships established
- [ ] Recipe badges appear in grocery list
- [ ] No empty displayText ("" quotes)
- [ ] All structured fields populated
- [ ] Success feedback shows scale factor
- [ ] List updates immediately

### **Integration Testing**
- [ ] Works with multiple recipes
- [ ] Recipe source badges show all sources (M4.3.1)
- [ ] Quantity merging works (M3 Phase 5)
- [ ] Settings toggle controls badge visibility
- [ ] Performance: < 0.5s for complete flow

### **Edge Cases**
- [ ] Scaling 1x (no change)
- [ ] Scaling 0.25x (minimum)
- [ ] Scaling 4x (maximum)
- [ ] Recipe with no quantities (non-numeric)
- [ ] Recipe with mixed parseable/non-parseable
- [ ] Very large quantities (100+ cups)

---

## 🎨 UI/UX GUIDELINES

### **Servings Picker Design**

**Layout:**
```
┌────────────────────────────────────┐
│ Servings                           │
│                                    │
│ Original: 24    [-] 48 [+]        │
│ Scaling by 2.00x                   │
└────────────────────────────────────┘
```

**Colors:**
- Scale factor text: `.orange` (when != 1.0)
- Stepper: System blue
- Headers: `.headline` font

**Behavior:**
- Stepper increments by recipe.servings/4 (smart steps)
- Immediate visual feedback
- No "Apply" button needed (live updates)

### **Ingredient Display with Scaling**

**Layout:**
```
☐ butter
   1 cup
   (was: 1/2 cup)    ← Orange text when scaled
```

**Visual Indicators:**
- Original quantity in parentheses (orange)
- Scaled quantity prominent
- Clear differentiation

---

## 🚦 SUCCESS CRITERIA

### **Must Have**
- ✅ User can adjust servings before adding
- ✅ Quantities scale correctly (math verified)
- ✅ Recipe relationships established
- ✅ All structured fields populated
- ✅ No empty displayText
- ✅ Recipe badges appear in grocery list

### **Should Have**
- ✅ Scale factor displayed clearly
- ✅ Original quantities shown for reference
- ✅ Success feedback with scale info
- ✅ Smart stepper increments

### **Nice to Have**
- ✅ Keyboard input for servings (instead of just stepper)
- ✅ Preview of scaled quantities before adding
- ✅ Validation of extreme scales

---

## 🐛 COMMON PITFALLS TO AVOID

### **1. Forgetting to Populate Structured Fields**
```swift
// ❌ BAD (causes empty quotes)
listItem.name = ingredient.name
listItem.displayText = nil  // Missing!

// ✅ GOOD
listItem.displayText = ingredient.displayText
listItem.numericValue = ingredient.numericValue
listItem.standardUnit = ingredient.standardUnit
// ... etc
```

### **2. Scaling Unscalable Items**
```swift
// ❌ BAD (tries to scale "pinch of salt")
let scaled = ingredient.numericValue * scaleFactor

// ✅ GOOD (check if parseable first)
if ingredient.isParseable {
    let scaled = ingredient.numericValue * scaleFactor
} else {
    // Use original for non-numeric
}
```

### **3. Not Establishing Recipe Relationships**
```swift
// ❌ BAD (no recipe tracking)
targetList.addToItems(listItem)

// ✅ GOOD (establishes relationship)
listItem.addToSourceRecipes(recipe)
targetList.addToItems(listItem)
```

### **4. UI Not Updating After Servings Change**
```swift
// ❌ BAD (scaledIngredients not computed)
var scaledIngredients = /* calculated once */

// ✅ GOOD (recomputes when servings change)
var scaledIngredients: [Ingredient] {
    // Computed property updates automatically
}
```

---

## 📊 PERFORMANCE TARGETS

### **Operation Times**
- Servings UI rendering: < 0.05s
- Scaling calculation (20 ingredients): < 0.1s
- Adding to list (20 ingredients): < 0.3s
- **Total flow (adjust + add)**: < 0.5s ✅

### **Optimization Tips**
- RecipeScalingService already optimized (M3)
- Use computed properties for live updates
- Batch Core Data saves
- No need for background threads (fast enough)

---

## 🔗 RELATED DOCUMENTATION

**Prerequisites:**
- M3 Phase 4 Learning Notes: Recipe scaling implementation
- M4.3.1 Learning Notes: Recipe source tracking
- RecipeScalingService.swift: Scaling algorithms

**References:**
- `docs/learning-notes/14-m3-phase4-recipe-scaling.md`
- `docs/learning-notes/22-m4.3.1-recipe-source-tracking.md`
- `Services/RecipeScalingService.swift`

**Related PRDs:**
- M3 Structured Quantity Management
- M4 Meal Planning & Enhanced Grocery Integration

---

## 💡 IMPLEMENTATION TIPS

### **Tip 1: Start with UI, Then Logic**
1. Add servings picker (visual feedback)
2. Add scaling display (see it work)
3. Wire up scaling service (math works)
4. Add to list (complete flow)

### **Tip 2: Use RecipeScalingService Liberally**
```swift
// It's already tested and works!
// Just pass ingredients and servings
let scaled = scalingService.scaleIngredients(...)
```

### **Tip 3: Test with Real Recipes**
- Use the 6 test recipes from M4.3.1
- Try different scales (0.5x, 1x, 2x, 4x)
- Verify fractions display correctly
- Check unit conversions

### **Tip 4: Leverage M4.3.1 Foundation**
```swift
// Recipe relationships "just work"
listItem.addToSourceRecipes(recipe)

// Badges appear automatically in grocery list
// Settings toggle already controls visibility
// No additional UI work needed!
```

---

## 🎯 PHASE SUMMARY

| Phase | Time | Key Deliverable |
|-------|------|-----------------|
| **Phase 1** | 30-45 min | Servings picker UI |
| **Phase 2** | 30-45 min | Scaled quantity calculation |
| **Phase 3** | 30-45 min | Add scaled items to list |
| **Total** | **1.5-2 hours** | Complete scaled recipe to list |

---

## 🚀 READY TO START?

### **Session Startup Checklist:**
1. ✅ Read this next-prompt.md
2. ✅ Review M3 Phase 4 (RecipeScalingService)
3. ✅ Review M4.3.1 (Recipe relationships)
4. ✅ Check current-story.md for any updates
5. ✅ Open RecipeDetailView.swift and AddIngredientsToListView.swift

### **First Steps:**
1. Add `@State private var selectedServings` to RecipeDetailView
2. Pass `targetServings` parameter to AddIngredientsToListView
3. Add servings picker UI section
4. Test UI before moving to Phase 2

---

**Good luck! You've got proven foundations (M3 + M4.3.1) to build on. This should be straightforward! 🚀**

---

**Document Version**: 1.0  
**Created**: November 22, 2025  
**Status**: 🚀 READY  
**Estimated Time**: 1.5-2 hours  
**Prerequisite Reading**: M3 Phase 4, M4.3.1 learning notes