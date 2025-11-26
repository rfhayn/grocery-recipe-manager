# Next Implementation Prompt - M4.3.5 Phase 4: Variation Handling

**Last Updated**: November 25, 2025  
**Phase**: M4.3.5 Phase 4 - Variation Handling  
**Estimated Time**: 1 hour  
**Prerequisites**: Phases 1-3 Complete ✅

---

## 🎯 Phase 4 Goal

Remove qualifiers and descriptors from ingredient names to consolidate variations:
- "diced tomato" → "tomato"
- "fresh basil" → "basil"
- "all-purpose flour" → "flour"  
- "unsalted butter" → "butter"

---

## 📋 Implementation Plan

### **Step 1: Create removeVariations() Function** (30 min)

Add to `IngredientTemplateService.swift`:
```swift
// Phase 4: Variation Handling
// Removes qualifiers and descriptors to consolidate ingredient variations
// Handles: "diced tomato" → "tomato", "fresh basil" → "basil"
private func removeVariations(_ name: String) -> String {
    let lowercased = name.lowercased()
    
    // Common qualifiers to remove (order matters - check longer phrases first)
    let qualifiers = [
        // Preparation descriptors
        "diced ", "chopped ", "sliced ", "minced ", "crushed ", "grated ",
        "shredded ", "ground ", "whole ", "halved ", "quartered ",
        
        // Freshness descriptors
        "fresh ", "frozen ", "canned ", "dried ", "raw ",
        
        // Quality descriptors
        "organic ", "free-range ", "grass-fed ", "wild-caught ",
        
        // Type/variety descriptors (common ones)
        "all-purpose ", "self-rising ", "unsalted ", "salted ",
        "extra-virgin ", "light ", "dark ", "heavy ", "lite ",
        
        // Size descriptors
        "large ", "medium ", "small ", "baby ", "jumbo "
    ]
    
    var result = lowercased
    
    // Remove qualifiers from start of name
    for qualifier in qualifiers {
        if result.hasPrefix(qualifier) {
            result = String(result.dropFirst(qualifier.count))
        }
    }
    
    return result.trimmingCharacters(in: .whitespaces)
}
```

### **Step 2: Integrate into normalize() Pipeline** (10 min)

Update the `normalize()` function:
```swift
// M4.3.5: Complete normalization pipeline
// Runs all normalization phases to create consistent template names
func normalize(_ name: String) -> String {
    var normalized = name
    
    // Phase 1: Case normalization
    normalized = normalizeCase(normalized)
    
    // Phase 2: Singular/plural normalization
    normalized = normalizePlural(normalized)
    
    // Phase 3: Abbreviation expansion
    normalized = expandAbbreviations(normalized)
    
    // Phase 4: Variation removal
    normalized = removeVariations(normalized)
    
    return normalized.trimmingCharacters(in: .whitespaces)
}
```

### **Step 3: Update Test Recipes** (10 min)

Modify existing test recipes in `RecipeListView.swift` to include variations:

Update Recipe 7 (Guacamole):
```swift
("3", "", "avocados"),
("2 tbsp", "", "lime juice"),
("1 tsp", "", "salt"),
("1/2 tsp", "", "pepper"),
("1 c", "", "diced tomatoes"),  // Will consolidate with "tomato"
("1/4 c", "", "diced onions")   // Will consolidate with "onion"
```

Or create a new Recipe 9 to test variations:
```swift
Recipe(context: viewContext)
recipe.title = "Caprese Salad"
recipe.instructions = "Slice tomatoes and mozzarella. Layer with fresh basil."
recipe.servings = 4
recipe.notes = "Simple and delicious"

// Ingredients with variations
let testIngredients = [
    ("2", "", "large tomatoes"),      // → "tomato"
    ("8 oz", "", "fresh mozzarella"), // → "mozzarella"
    ("1/4 cup", "", "fresh basil"),   // → "basil"
    ("2 tbsp", "", "extra-virgin olive oil"), // → "olive oil"
    ("", "", "salt and pepper to taste")
]
```

### **Step 4: Testing** (10 min)

1. **Clean Build**: ⌘⇧K
2. **Reset Simulator**: Device → Erase All Content and Settings
3. **Build & Run**: ⌘R
4. **Generate test recipes**
5. **Check Ingredients Tab**

**Expected Results:**
- "diced tomato" and "tomato" consolidated to "tomato" ✅
- "diced onion" and "onion" consolidated to "onion" ✅
- "fresh basil" and "basil" consolidated to "basil" ✅
- "all-purpose flour" and "flour" consolidated to "flour" ✅
- Template count further reduced ✅

---

## 🎯 Acceptance Criteria

✅ **removeVariations() function implemented**
- Removes preparation qualifiers (diced, chopped, sliced, etc.)
- Removes freshness qualifiers (fresh, frozen, canned, etc.)
- Removes quality qualifiers (organic, free-range, etc.)
- Removes type/variety qualifiers (all-purpose, unsalted, etc.)
- Removes size qualifiers (large, medium, small, etc.)

✅ **Integrated into normalize() pipeline**
- Phase 4 runs after Phases 1-3
- All normalization phases work together

✅ **Templates properly consolidated**
- "diced tomato" + "tomato" → single "tomato" template
- "fresh basil" + "basil" → single "basil" template
- Other variations consolidated correctly

✅ **No regressions**
- Phases 1-3 still working (case, plural, abbreviations)
- "chocolate chips" still stays plural
- All recipes display correctly

✅ **Performance maintained**
- Normalization < 0.05s
- No user-visible delays

---

## 📝 Files to Modify

1. **IngredientTemplateService.swift**
   - Add `removeVariations()` function (~40 lines)
   - Update `normalize()` to call Phase 4

2. **RecipeListView.swift** (optional)
   - Add Recipe 9 with variations
   - Update button text to "Generate 9 Test Recipes"

---

## 🎓 Implementation Notes

**Qualifier Ordering Matters:**
- Check longer phrases before shorter ones
- "all-purpose " before "all "
- "extra-virgin " before "extra "

**Whitespace Handling:**
- Include trailing space in qualifiers
- Trim result after removal
- Handle multiple qualifiers (e.g., "fresh diced tomato")

**Edge Cases:**
- Don't remove if it's the entire name (e.g., "fresh" by itself stays "fresh")
- Don't remove from compound words (e.g., "all-spice" should not become "spice")

**Conservative Approach:**
- Start with common qualifiers
- Can expand list based on real-world usage
- Better to under-consolidate than over-consolidate

---

## ✅ Session Completion Checklist

After implementing Phase 4:

- [ ] Code compiles without errors
- [ ] All test recipes load successfully
- [ ] Template consolidation working (verify in Ingredients tab)
- [ ] No regressions (Phases 1-3 still working)
- [ ] Performance targets met
- [ ] Screenshots taken for validation
- [ ] Update `current-story.md` - Mark M4.3.5 ✅ COMPLETE with total hours
- [ ] Update `roadmap.md` - Mark M4.3.5 complete
- [ ] Update `project-index.md` - Add to Recent Activity
- [ ] Create `23-m4.3.5-ingredient-normalization.md` learning note

---

## 🎉 After M4.3.5 Complete

M4.3.5 is the **FINAL** component of M4! After Phase 4:

1. **Update roadmap.md** with M4 completion summary
2. **Create comprehensive learning note** documenting full normalization journey
3. **Decide next priority**:
   - Option A: M5 (Recipe Tags & Organization)
   - Option B: TestFlight Preparation
   - Option C: M4.2.1-3 Enhancement (RecipePickerSheet UI Polish)

---

**Ready to implement Phase 4?** 🚀

**Start Time**: _______  
**End Time**: _______  
**Actual Duration**: _______