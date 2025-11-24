# Next Prompt: M4.3.4 - Meal Completion Tracking

**Milestone**: M4.3.4 - Meal Completion Tracking  
**Status**: 🚀 READY  
**Estimated Time**: 45 minutes  
**Priority**: MEDIUM - Workflow enhancement  
**Prerequisites**: M4.2 (Meal Planning) ✅, M4.3.3 (Bulk Add) ✅

---

## 🚀 QUICK START

### **What We're Building**

Simple completion toggle for meals in the meal plan. Mark meals as "completed" to track which have been consumed, with visual feedback (strikethrough, reduced opacity). Persistence in Core Data.

### **User Flow**

```
1. User viewing meal plan
2. Each meal row shows checkbox (circle when uncompleted, checkmark when completed)
3. User taps checkbox to mark meal as completed
4. Visual feedback: Meal text gets strikethrough, reduced opacity
5. User taps again to un-complete (toggle behavior)
6. Status persists across app restarts
```

### **Key Technical Points**

- **Core Data**: Add `isCompleted: Bool` property to PlannedMeal
- **UI**: Checkbox/checkmark icon, strikethrough text, opacity changes
- **Persistence**: Automatic Core Data save on toggle
- **Simple**: No complex logic, just toggle + visual feedback

---

## 📋 IMPLEMENTATION GUIDE

### **Phase 1: Core Data Model Update** (10-15 min)

**Objective**: Add isCompleted property to PlannedMeal entity

**Files to Modify**:
- `GroceryRecipeManager.xcdatamodeld` - Add property to PlannedMeal entity

**What to Do:**

**1. Open Core Data Model:**
```
1. Open GroceryRecipeManager.xcdatamodeld in Xcode
2. Select PlannedMeal entity
3. Click "+" under Attributes section
```

**2. Add isCompleted Property:**
```
Attribute Name: isCompleted
Type: Boolean
Default Value: NO (false)
Optional: Unchecked (make it required with default)
```

**3. Verify Settings:**
```
- Codegen: Manual/None (since PlannedMeal likely uses manual extensions)
- Indexed: Not needed for boolean flags
- Transient: No
```

**Testing:**
- [ ] Build succeeds after adding property
- [ ] No migration required (new property with default value)
- [ ] Can access plannedMeal.isCompleted in code

---

### **Phase 2: UI Implementation** (25-30 min)

**Objective**: Add completion checkbox and visual feedback

**Files to Modify**:
- `MealPlanDetailView.swift` - Add checkbox to meal rows

**What to Build:**

**1. Update Meal Row UI:**
```swift
// In MealPlanDetailView.swift, find the meal row component
// Add checkbox before the meal details

HStack(spacing: 12) {
    // MARK: M4.3.4 - Completion Checkbox
    Button(action: {
        toggleCompletion(for: plannedMeal)
    }) {
        Image(systemName: plannedMeal.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundColor(plannedMeal.isCompleted ? .green : .gray)
    }
    .buttonStyle(.plain)  // Prevent entire row from being tappable
    
    VStack(alignment: .leading, spacing: 4) {
        Text(plannedMeal.recipe?.name ?? "No Recipe")
            .font(.headline)
            .strikethrough(plannedMeal.isCompleted)
        
        Text("\(plannedMeal.servings) servings")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    Spacer()
    
    // Badge for day name, if applicable
    Text(dayName(for: plannedMeal))
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
}
.opacity(plannedMeal.isCompleted ? 0.6 : 1.0)
.padding(.vertical, 8)
```

**2. Add Toggle Function:**
```swift
// MARK: M4.3.4 - Completion Tracking

/// Toggles the completion status of a planned meal
/// Updates Core Data and saves immediately for persistence
private func toggleCompletion(for plannedMeal: PlannedMeal) {
    withAnimation {
        plannedMeal.isCompleted.toggle()
        
        do {
            try viewContext.save()
            print("✅ M4.3.4: Toggled completion for \(plannedMeal.recipe?.name ?? "Unknown") to \(plannedMeal.isCompleted)")
        } catch {
            print("❌ M4.3.4: Failed to save completion status: \(error)")
            // Revert on error
            plannedMeal.isCompleted.toggle()
        }
    }
}
```

**3. Optional Helper Function:**
```swift
/// Returns day name for a planned meal (e.g., "Mon", "Tue")
/// Useful for displaying in meal row
private func dayName(for plannedMeal: PlannedMeal) -> String {
    guard let date = plannedMeal.date else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"  // Mon, Tue, Wed, etc.
    return formatter.string(from: date)
}
```

**Testing:**
- [ ] Checkbox appears before meal name
- [ ] Empty circle when not completed
- [ ] Filled green checkmark when completed
- [ ] Tap toggles state correctly
- [ ] Strikethrough appears/disappears
- [ ] Opacity changes (100% → 60%)
- [ ] Status persists after app restart
- [ ] Animation smooth

---

## ✅ ACCEPTANCE CRITERIA

**Core Functionality:**
- [ ] PlannedMeal.isCompleted property exists in Core Data
- [ ] Checkbox appears on each meal row
- [ ] Empty circle icon when meal not completed
- [ ] Filled checkmark icon (green) when completed
- [ ] Tap checkbox toggles completion state
- [ ] Visual feedback applied immediately:
  - [ ] Strikethrough on meal name
  - [ ] Reduced opacity (60%)
  - [ ] Green checkmark color
- [ ] Status persists in Core Data
- [ ] Can toggle back (un-complete a meal)

**Edge Cases:**
- [ ] Empty meal plan: No crashes
- [ ] Meal with no recipe: Checkbox still works
- [ ] Multiple toggles: No state confusion
- [ ] App restart: Completion status preserved

**Polish:**
- [ ] Animation smooth (withAnimation)
- [ ] No impact on existing meal plan functionality
- [ ] Checkbox doesn't interfere with recipe navigation
- [ ] Professional iOS appearance

---

## 🎯 TESTING SCENARIOS

### **Test 1: Basic Completion**
1. Open meal plan with 3 meals
2. Tap checkbox on first meal
3. Verify:
   - Checkmark appears (green)
   - Text has strikethrough
   - Opacity reduced
   - Can still navigate to recipe

### **Test 2: Toggle Back**
1. Mark meal as completed (test 1)
2. Tap checkbox again
3. Verify:
   - Checkmark → empty circle
   - Strikethrough removed
   - Full opacity restored

### **Test 3: Persistence**
1. Mark 2 meals as completed
2. Close app completely (force quit)
3. Reopen app
4. Navigate to meal plan
5. Verify: 2 meals still marked completed

### **Test 4: Multiple Meals**
1. Mark all meals in plan as completed
2. Verify each updates independently
3. Unmark first meal
4. Verify others remain completed

### **Test 5: Integration with Bulk Add**
1. Mark some meals as completed
2. Tap "Add All to Shopping List"
3. Verify: Both completed and uncompleted meals included
4. Completion status unaffected by bulk add

---

## 📝 FILES TO MODIFY

**Primary Files:**
1. **GroceryRecipeManager.xcdatamodeld** - Add isCompleted to PlannedMeal (~2 min)
2. **MealPlanDetailView.swift** - Add checkbox UI and toggle logic (~30 lines)

**No New Files Needed**

---

## 💡 TIPS & REMINDERS

### **Core Data Best Practices**
```swift
// Always wrap Core Data changes in do-catch
do {
    try viewContext.save()
} catch {
    // Handle error, possibly revert changes
}
```

### **Animation**
```swift
// Use withAnimation for smooth state transitions
withAnimation {
    plannedMeal.isCompleted.toggle()
}
```

### **Button Style**
```swift
// Prevent entire row from being tappable, only checkbox
.buttonStyle(.plain)
```

### **Strikethrough Modifier**
```swift
// SwiftUI built-in modifier
Text("Meal Name")
    .strikethrough(isCompleted)
```

### **Opacity Modifier**
```swift
// Reduce visibility for completed items
.opacity(isCompleted ? 0.6 : 1.0)
```

---

## 🎨 DESIGN NOTES

### **Visual States**

**Uncompleted (Default):**
- Empty circle icon (gray)
- Full opacity (1.0)
- No strikethrough
- Normal text color

**Completed:**
- Filled checkmark icon (green)
- Reduced opacity (0.6)
- Strikethrough text
- Dimmed appearance

### **Icon System Names**
```swift
"circle"                    // Uncompleted
"checkmark.circle.fill"     // Completed
```

### **Color Scheme**
```swift
.foregroundColor(isCompleted ? .green : .gray)
```

---

## 🔍 FUTURE ENHANCEMENTS (Not in Scope)

- [ ] Filter to show only active/completed meals
- [ ] Completion date tracking (when meal was completed)
- [ ] Undo completion with confirmation
- [ ] Completion statistics (X of Y meals completed)
- [ ] Auto-mark as completed when ingredients added to list
- [ ] Swipe to complete gesture

**These are NOT part of M4.3.4** - Keep it simple for now!

---

## 🚀 READY TO START?

**Session Startup Checklist:**
1. ✅ Read this next-prompt.md
2. ✅ Review current-story.md for M4.3.3 completion status
3. ✅ Check session-startup-checklist.md
4. ✅ Open GroceryRecipeManager.xcdatamodeld
5. ✅ Open MealPlanDetailView.swift

**First Steps:**
1. Add `isCompleted: Bool` to PlannedMeal in Core Data model
2. Build to verify schema change successful
3. Add checkbox UI to meal rows
4. Implement toggle function
5. Test thoroughly

---

**This is a quick win - should take ~45 minutes! 🎉**

---

**Document Version**: 1.0  
**Created**: November 24, 2025  
**Status**: 🚀 READY  
**Estimated Time**: 45 minutes  
**Prerequisites**: M4.2 ✅, M4.3.3 ✅