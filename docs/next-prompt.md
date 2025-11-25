# Next Prompt: M4.3.5 Phase 2 - Singular/Plural Normalization

**Milestone**: M4.3.5 - Ingredient Normalization  
**Current Phase**: Phase 2 - Singular/Plural Handling  
**Status**: 🚀 READY  
**Estimated Time**: 1.0 hour  
**Prerequisites**: Phase 1 (Case Normalization) ✅ COMPLETE

---

## 🎯 PHASE 1 RECAP

### **What We Accomplished**

✅ **Case Normalization Working**
- All ingredient templates stored in lowercase
- "Butter" → "butter", "EGGS" → "eggs"
- Implemented in `IngredientTemplateService.swift`

✅ **Four Critical Bugs Fixed**
1. **Missing Template Creation**: Sample recipes weren't creating templates
2. **Core Data Race Condition**: `withAnimation` wrapper causing conflicts  
3. **Regex Parsing Bug**: Greedy unit capture creating "egg s" instead of "eggs"
4. **Validation Bug**: `isParseable` required `standardUnit` unnecessarily

✅ **Validation Complete**
- All 6 test recipes created successfully
- 14 unique templates in Ingredients tab (all lowercase)
- No duplicate or malformed templates
- Clean console logs (zero errors)

### **Current State**
Templates: baking powder, bread, butter, chocolate chips, cinnamon, cocoa powder, **egg**, **eggs**, flour, milk, pepper, salt, sugar, vanilla extract

Notice: "egg" (singular) and "eggs" (plural) are separate templates ← **Phase 2 will fix this**

---

## 🚀 PHASE 2: SINGULAR/PLURAL HANDLING

### **Goal**

Consolidate singular and plural forms into single templates:
- "egg" + "eggs" → "egg"
- "tomato" + "tomatoes" → "tomato"
- "berry" + "berries" → "berry"

### **Expected Result**

**Before**: 14 templates, "egg" and "eggs" separate  
**After**: 13 templates, only "egg" (6 recipes consolidated)

---

## 📋 IMPLEMENTATION (1 hour)

### **Step 1: Add normalizePlural() Function** (20 min)

**Location**: `IngredientTemplateService.swift`

**Add this function:**
```swift
// MARK: - M4.3.5 Phase 2: Singular/Plural Normalization

/// Converts plural ingredient names to singular form
/// Handles regular plurals (eggs → egg) and irregular plurals (children → child)
private func normalizePlural(_ name: String) -> String {
    let lowercased = name.lowercased()
    
    // Irregular plurals mapping (check these first)
    let irregularPlurals: [String: String] = [
        "children": "child",
        "feet": "foot",
        "teeth": "tooth",
        "geese": "goose",
        "mice": "mouse",
        "people": "person",
        "men": "man",
        "women": "woman",
        "oxen": "ox"
    ]
    
    if let singular = irregularPlurals[lowercased] {
        return singular
    }
    
    // Regular plural patterns
    
    // Pattern 1: -ies → -y (berries → berry, cherries → cherry)
    if lowercased.hasSuffix("ies") && lowercased.count > 3 {
        let base = String(lowercased.dropLast(3))
        return base + "y"
    }
    
    // Pattern 2: -oes → -o (tomatoes → tomato, potatoes → potato)
    if lowercased.hasSuffix("oes") && lowercased.count > 3 {
        return String(lowercased.dropLast(2))
    }
    
    // Pattern 3: -ses → -s (glasses → glass)
    if lowercased.hasSuffix("ses") && lowercased.count > 3 {
        return String(lowercased.dropLast(2))
    }
    
    // Pattern 4: -ves → -f (knives → knife, loaves → loaf)
    if lowercased.hasSuffix("ves") && lowercased.count > 3 {
        let base = String(lowercased.dropLast(3))
        return base + "f"
    }
    
    // Pattern 5: -s → remove (eggs → egg, apples → apple)
    // BUT NOT: -ss words (grass, glass, etc.)
    if lowercased.hasSuffix("s") && 
       !lowercased.hasSuffix("ss") && 
       !lowercased.hasSuffix("us") &&  // Don't touch: asparagus, hummus
       lowercased.count > 1 {
        return String(lowercased.dropLast())
    }
    
    // No plural pattern matched, return as-is
    return lowercased
}
```

### **Step 2: Update normalize() Function** (10 min)

**Modify your existing `normalize()` function** to add the plural normalization step:
```swift
// MARK: - M4.3.5: Complete Normalization Pipeline

/// Applies all normalization phases to an ingredient name
/// Phase 1: Case normalization (lowercase)
/// Phase 2: Singular/plural normalization
/// Phase 3: Abbreviation expansion (future)
/// Phase 4: Variation handling (future)
private func normalize(_ name: String) -> String {
    var normalized = name
    
    // Phase 1: Case normalization
    normalized = normalizeCase(normalized)
    
    // Phase 2: Singular/plural normalization
    normalized = normalizePlural(normalized)
    
    // Future phases will be added here
    
    return normalized
}
```

### **Step 3: Testing** (30 min)

**Testing Procedure:**

1. **Clean Build**: ⌘⇧K
2. **Reset simulator**: Device → Erase All Content and Settings
3. **Build & Run**: ⌘R
4. **Generate 6 test recipes**
5. **Verify in Ingredients Tab**:
   - Should see only "egg" (not both "egg" and "eggs")
   - Count should be 13 templates (down from 14)
   - "egg" should show it's used in 6 recipes
6. **Check console logs**:
   - Should see: "Parsing '2 eggs' -> template name: 'egg'"
   - Should see: "Parsing '1 egg' -> template name: 'egg'"

**Test Cases to Verify:**

✅ Regular Plurals (Simple -s)
- "eggs" → "egg"
- "apples" → "apple"
- "carrots" → "carrot"

✅ Irregular Plurals
- "children" → "child"
- "feet" → "foot"
- "mice" → "mouse"

✅ -ies Pattern
- "berries" → "berry"
- "cherries" → "cherry"

✅ -oes Pattern
- "tomatoes" → "tomato"
- "potatoes" → "potato"

✅ -ses Pattern
- "glasses" → "glass"

✅ -ves Pattern
- "knives" → "knife"
- "loaves" → "loaf"

✅ False Positives (Should NOT Change)
- "grass" → "grass" (not "gras")
- "glass" → "glass" (not "glas")
- "asparagus" → "asparagus"
- "hummus" → "hummus"

---

## ✅ ACCEPTANCE CRITERIA

### **Functional Requirements**

- [ ] `normalizePlural()` function implemented
- [ ] `normalize()` function updated to call `normalizePlural()`
- [ ] All regular plurals handled (-s, -ies, -oes, -ses, -ves)
- [ ] All common irregular plurals handled
- [ ] False positives avoided (grass, glass, asparagus, hummus)

### **Validation Tests**

- [ ] Test recipes regenerated with Phase 2 active
- [ ] "egg" and "eggs" consolidated to "egg" template
- [ ] Total template count reduced (14 → 13)
- [ ] All recipes still display correct ingredient lists
- [ ] Console shows normalized template names

### **Integration Checks**

- [ ] Case normalization (Phase 1) still working
- [ ] Recipe source tracking intact
- [ ] Quantity scaling intact
- [ ] Shopping list consolidation working
- [ ] No performance degradation (<0.5s operations)

---

## 📚 FILES TO MODIFY

### **Primary File**

**`GroceryRecipeManager/Services/IngredientTemplateService.swift`**
- Add `normalizePlural()` function (~45 lines)
- Update `normalize()` function (~8 lines)

### **No Other Files Need Changes**

Phase 2 is entirely within the service layer. No UI changes, no Core Data schema changes, no other services affected.

---

## 💡 IMPLEMENTATION TIPS

### **Order of Pattern Checks Matters**

Check patterns from most specific to most general:
1. Irregular plurals first (exact matches)
2. -ies, -oes, -ses, -ves patterns (specific suffixes)
3. Simple -s removal last (most general)

### **Avoid Over-Normalization**
```swift
// ❌ BAD: This would break "grass"
if lowercased.hasSuffix("s") {
    return String(lowercased.dropLast())
}

// ✅ GOOD: Check for -ss first
if lowercased.hasSuffix("s") && !lowercased.hasSuffix("ss") {
    return String(lowercased.dropLast())
}
```

### **Length Checks Prevent Crashes**
```swift
// ✅ GOOD: Ensure enough characters exist
if lowercased.hasSuffix("ies") && lowercased.count > 3 {
    return String(lowercased.dropLast(3)) + "y"
}
```

---

## 🎯 SUCCESS METRICS

**Before Phase 2:**
- 14 templates in test data
- "egg" and "eggs" separate

**After Phase 2:**
- 13 templates in test data (1 consolidated)
- Only "egg" exists (consolidates 6 recipes)
- All recipe displays unchanged
- Shopping list consolidation improved

---

## 🚀 READY TO START?

### **Quick Checklist**

- [ ] Read this next-prompt.md
- [ ] Open `IngredientTemplateService.swift`
- [ ] Add `normalizePlural()` function
- [ ] Update `normalize()` function
- [ ] Clean build + reset simulator
- [ ] Generate test recipes
- [ ] Verify in Ingredients tab

### **Expected Session Flow**

1. **Implementation** (20 min): Add functions
2. **Testing** (30 min): Generate recipes + verify
3. **Documentation** (10 min): Update current-story.md

**Total Time**: ~1 hour

---

## 📈 PROGRESS TRACKING

**M4.3.5 Phases:**
- ✅ Phase 1: Case Normalization (2.5h actual vs 0.5h est - bugs discovered)
- 🔄 Phase 2: Singular/Plural (1h estimated) ← **CURRENT**
- ⏳ Phase 3: Abbreviations (1.5h estimated)
- ⏳ Phase 4: Variations (1h estimated)

**Total M4.3.5 Progress**: 1/4 phases complete (25%)

---

## 🎉 AFTER PHASE 2

Once Phase 2 is complete:
- Update `current-story.md` with Phase 2 results
- Update `next-prompt.md` for Phase 3 (Abbreviations)
- Consider whether Phase 3-4 are needed based on your usage patterns

**Phase 3 Preview**: Abbreviations (tbsp → tablespoon, tsp → teaspoon, etc.)

---

**Document Version**: 2.0  
**Created**: November 25, 2025  
**Status**: 🚀 READY for Phase 2  
**Estimated Time**: 1 hour  
**Prerequisites**: Phase 1 ✅ COMPLETE