# Next Prompt: M4.3.5 - Ingredient Normalization

**Milestone**: M4.3.5 - Ingredient Normalization  
**Status**: 🚀 READY  
**Estimated Time**: 4 hours  
**Priority**: MEDIUM - Data quality enhancement  
**Prerequisites**: M4.3.1 (Recipe Source Tracking) ✅, M4.3.4 (Meal Completion) ✅

---

## 🚀 QUICK START

### **What We're Building**

Behind-the-scenes ingredient name normalization to eliminate duplicates caused by case differences, singular/plural forms, abbreviations, and common variations. Zero user intervention required - just improved data quality.

### **User Impact**

**Before Normalization:**
```
Shopping List:
- Butter (Recipe A)
- butter (Recipe B)
- Eggs (Recipe C)
- egg (Recipe D)
- Tbsp olive oil (Recipe E)
- tablespoon olive oil (Recipe F)
```

**After Normalization:**
```
Shopping List:
- butter (2 sources)
- eggs (2 sources)
- tablespoon olive oil (2 sources)
```

### **Key Technical Points**

- **Four Progressive Phases**: Case → Plural → Abbreviations → Variations
- **Behind-the-scenes**: Runs during ingredient parsing/template creation
- **No UI changes**: Users see cleaner lists automatically
- **Complete PRD available**: `prds/milestone-4.3.5-ingredient-normalization.md`

---

## 📋 FOUR PHASES OVERVIEW

### **Phase 1: Case Normalization** (30 min)
**Goal**: "Butter" → "butter", "EGGS" → "eggs"
- Lowercase all ingredient names at template creation
- Update existing templates in migration
- Simple, foundational change

### **Phase 2: Singular/Plural Handling** (1 hour)
**Goal**: "eggs" and "egg" → both map to "egg" template
- Smart plural detection (eggs→egg, tomatoes→tomato)
- Irregular plurals (children→child, feet→foot)
- Preserve original display text while normalizing template

### **Phase 3: Abbreviation Expansion** (1.5 hours)
**Goal**: "tbsp", "Tbsp", "tablespoon" → all map to "tablespoon"
- Common cooking abbreviations (tsp, tbsp, oz, lb, etc.)
- Regional variations (litre/liter, colour/color)
- Measurement unit normalization

### **Phase 4: Common Variations** (1 hour)
**Goal**: "all-purpose flour" and "flour" → same template
- Qualifier removal (fresh basil → basil, unsalted butter → butter)
- Brand name removal (Kerrygold butter → butter)
- Preparation methods (diced tomatoes → tomatoes)

---

## 📝 IMPLEMENTATION STRATEGY

### **Where Normalization Happens**

**Primary Location**: `IngredientTemplateService`
```swift
// When creating templates from ingredients
func findOrCreateTemplate(name: String) -> IngredientTemplate {
    let normalizedName = normalizeName(name)  // ← Apply all phases here
    // ... rest of template lookup/creation
}
```

**Secondary Location**: Data migration for existing templates

### **Recommended Approach**

**1. Build Incrementally** (Phase by Phase)
- Complete Phase 1 fully → Test → Commit
- Complete Phase 2 fully → Test → Commit
- Complete Phase 3 fully → Test → Commit
- Complete Phase 4 fully → Test → Commit

**2. Create Comprehensive Tests**
```swift
// Example test structure
func testCaseNormalization() {
    XCTAssertEqual(normalize("Butter"), "butter")
    XCTAssertEqual(normalize("EGGS"), "eggs")
    XCTAssertEqual(normalize("All-Purpose Flour"), "all-purpose flour")
}

func testPluralNormalization() {
    XCTAssertEqual(normalizePlural("eggs"), "egg")
    XCTAssertEqual(normalizePlural("tomatoes"), "tomato")
    XCTAssertEqual(normalizePlural("children"), "child")
}
```

**3. Preserve Display Text**
```swift
// Recipe ingredient: "2 Tbsp Butter"
ingredient.name = "2 Tbsp Butter"           // Original for display
ingredient.template = findTemplate("butter") // Normalized for grouping
```

---

## 🎯 PHASE-BY-PHASE GUIDE

### **Phase 1: Case Normalization** (30 min)

**Files to Modify:**
- `IngredientTemplateService.swift` - Add lowercase normalization
- Migration script (optional) - Update existing templates

**Implementation:**
```swift
// In IngredientTemplateService
private func normalizeCase(_ name: String) -> String {
    return name.lowercased()
}

func findOrCreateTemplate(name: String) -> IngredientTemplate {
    let normalized = normalizeCase(name)
    
    // Check if template exists with normalized name
    let fetchRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", normalized)
    
    if let existing = try? context.fetch(fetchRequest).first {
        return existing
    }
    
    // Create new template with normalized name
    let template = IngredientTemplate(context: context)
    template.name = normalized
    return template
}
```

**Testing:**
- [ ] "Butter" creates template named "butter"
- [ ] "EGGS" creates template named "eggs"
- [ ] Existing templates migrated to lowercase
- [ ] Display text preserved in ingredients

---

### **Phase 2: Singular/Plural** (1 hour)

**Core Logic:**
```swift
private func normalizePlural(_ name: String) -> String {
    let lowercased = name.lowercased()
    
    // Irregular plurals first
    let irregulars: [String: String] = [
        "children": "child",
        "feet": "foot",
        "teeth": "tooth",
        "geese": "goose",
        "mice": "mouse"
    ]
    
    if let singular = irregulars[lowercased] {
        return singular
    }
    
    // Regular patterns
    if lowercased.hasSuffix("ies") {
        // berries → berry, cherries → cherry
        return String(lowercased.dropLast(3)) + "y"
    }
    
    if lowercased.hasSuffix("oes") {
        // tomatoes → tomato, potatoes → potato
        return String(lowercased.dropLast(2))
    }
    
    if lowercased.hasSuffix("ses") {
        // glasses → glass, buses → bus
        return String(lowercased.dropLast(2))
    }
    
    if lowercased.hasSuffix("s") && !lowercased.hasSuffix("ss") {
        // eggs → egg, apples → apple
        // but NOT: grass → gras
        return String(lowercased.dropLast())
    }
    
    return lowercased
}
```

**Testing:**
- [ ] eggs → egg
- [ ] tomatoes → tomato
- [ ] berries → berry
- [ ] children → child
- [ ] grass → grass (no change)

---

### **Phase 3: Abbreviations** (1.5 hours)

**Abbreviation Dictionary:**
```swift
private let abbreviationMap: [String: String] = [
    // Volume
    "tsp": "teaspoon",
    "tbsp": "tablespoon",
    "oz": "ounce",
    "fl oz": "fluid ounce",
    "c": "cup",
    "pt": "pint",
    "qt": "quart",
    "gal": "gallon",
    
    // Weight
    "lb": "pound",
    "lbs": "pound",
    "g": "gram",
    "kg": "kilogram",
    
    // Other
    "temp": "temperature",
    "approx": "approximately"
]

private func expandAbbreviations(_ text: String) -> String {
    var result = text.lowercased()
    
    // Sort by length (longest first) to avoid partial replacements
    let sorted = abbreviationMap.sorted { $0.key.count > $1.key.count }
    
    for (abbrev, full) in sorted {
        // Use word boundaries to avoid partial matches
        let pattern = "\\b\(abbrev)\\b"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(
                in: result,
                range: NSRange(result.startIndex..., in: result),
                withTemplate: full
            )
        }
    }
    
    return result
}
```

**Testing:**
- [ ] "2 tbsp butter" → template "tablespoon butter"
- [ ] "1 Tbsp oil" → template "tablespoon oil"
- [ ] "3 tsp vanilla" → template "teaspoon vanilla"
- [ ] "buttercup" unchanged (no word boundary match)

---

### **Phase 4: Variations** (1 hour)

**Qualifier Removal:**
```swift
private let qualifiersToRemove = [
    "fresh", "dried", "frozen", "canned",
    "organic", "raw", "cooked",
    "unsalted", "salted", "sweetened", "unsweetened",
    "all-purpose", "whole", "ground",
    "large", "medium", "small",
    "chopped", "diced", "sliced", "minced",
    "extra virgin", "virgin"
]

private func removeQualifiers(_ text: String) -> String {
    var result = text.lowercased()
    
    for qualifier in qualifiersToRemove {
        // Remove qualifier + optional separator
        let patterns = [
            "\\b\(qualifier)\\s+",      // "fresh basil" → "basil"
            "\\s+\(qualifier)\\b",      // "basil fresh" → "basil"
            "\\b\(qualifier)-",         // "all-purpose flour" → "flour"
            "-\(qualifier)\\b"          // "flour-purpose" → "flour"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                result = regex.stringByReplacingMatches(
                    in: result,
                    range: NSRange(result.startIndex..., in: result),
                    withTemplate: " "
                )
            }
        }
    }
    
    // Clean up extra whitespace
    result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    return result.trimmingCharacters(in: .whitespaces)
}
```

**Testing:**
- [ ] "fresh basil" → template "basil"
- [ ] "unsalted butter" → template "butter"
- [ ] "all-purpose flour" → template "flour"
- [ ] "extra virgin olive oil" → template "olive oil"

---

## ✅ ACCEPTANCE CRITERIA

**Phase 1: Case**
- [ ] All new templates created in lowercase
- [ ] Existing templates migrated to lowercase
- [ ] Case-insensitive template lookup works
- [ ] Display text preserves original case

**Phase 2: Plural**
- [ ] Regular plurals normalized (eggs → egg)
- [ ] Irregular plurals handled (children → child)
- [ ] "ies" suffix handled (berries → berry)
- [ ] "oes" suffix handled (tomatoes → tomato)
- [ ] False positives avoided (grass ≠ gras)

**Phase 3: Abbreviations**
- [ ] Common abbreviations expanded
- [ ] Word boundaries respected
- [ ] No partial replacements
- [ ] Case-insensitive matching

**Phase 4: Variations**
- [ ] Common qualifiers removed
- [ ] Multiple qualifiers handled
- [ ] Hyphenated qualifiers handled
- [ ] Core ingredient names preserved

**Overall:**
- [ ] Duplicate ingredient count reduced
- [ ] Shopping list consolidation improved
- [ ] Recipe ingredient matching enhanced
- [ ] No user-visible breaking changes
- [ ] Performance maintained (<0.5s operations)

---

## 🧪 TESTING STRATEGY

### **Unit Tests**
Create `IngredientNormalizationTests.swift`:
```swift
class IngredientNormalizationTests: XCTestCase {
    func testPhase1_CaseNormalization() {
        // Test all case combinations
    }
    
    func testPhase2_PluralNormalization() {
        // Test regular and irregular plurals
    }
    
    func testPhase3_AbbreviationExpansion() {
        // Test all common abbreviations
    }
    
    func testPhase4_VariationHandling() {
        // Test qualifier removal
    }
    
    func testIntegration_CompleteNormalization() {
        // Test full pipeline
        // "2 Tbsp Fresh Unsalted Butter" → "butter"
    }
}
```

### **Integration Tests**
1. Create recipes with intentional variations
2. Add to shopping list
3. Verify consolidation works correctly
4. Check recipe source tracking intact

### **Performance Tests**
- [ ] Normalization <0.05s per ingredient
- [ ] Template lookup <0.1s
- [ ] Batch processing <1s for 100 ingredients

---

## 📚 REFERENCE: COMPLETE PRD

**Full documentation available at:**
`docs/prds/milestone-4.3.5-ingredient-normalization.md`

**Contents:**
- Detailed algorithm descriptions
- Comprehensive test cases
- Edge case handling
- Performance considerations
- Future enhancement ideas

---

## 💡 TIPS & BEST PRACTICES

### **Order Matters**
Apply normalization in this order:
1. Case (lowercase everything first)
2. Abbreviations (expand before plural check)
3. Plural (singularize after expansion)
4. Qualifiers (remove modifiers last)

### **Preserve Original**
```swift
// ALWAYS keep original for display
ingredient.name = originalText
ingredient.template = findTemplate(normalizedName)
```

### **Test Edge Cases**
- Empty strings
- Single characters
- Numbers only
- Special characters
- Unicode characters

### **Performance**
```swift
// Cache normalized results
private var normalizationCache: [String: String] = [:]

func normalize(_ name: String) -> String {
    if let cached = normalizationCache[name] {
        return cached
    }
    
    let result = applyAllPhases(name)
    normalizationCache[name] = result
    return result
}
```

---

## 🎯 SUCCESS METRICS

**Before M4.3.5:**
- 100 ingredients might create 85 templates (15% duplicates)

**After M4.3.5:**
- Same 100 ingredients create 65 templates (35% duplicates eliminated)

**Target Improvements:**
- 30-50% reduction in duplicate templates
- Improved shopping list consolidation
- Better recipe ingredient matching
- Maintained performance (<0.5s all operations)

---

## 🚀 READY TO START?

**Session Startup Checklist:**
1. ✅ Read this next-prompt.md
2. ✅ Review M4.3.5 PRD (optional but helpful)
3. ✅ Check session-startup-checklist.md
4. ✅ Open IngredientTemplateService.swift
5. ✅ Create test file: IngredientNormalizationTests.swift

**Recommended Order:**
1. Phase 1: Case (30 min) → Test → Commit
2. Phase 2: Plural (1 hr) → Test → Commit
3. Phase 3: Abbreviations (1.5 hr) → Test → Commit
4. Phase 4: Variations (1 hr) → Test → Commit

**Total Time**: ~4 hours

---

## 🎉 THIS COMPLETES M4!

After M4.3.5:
- Core grocery-recipe workflow complete
- Ready for TestFlight deployment
- Foundation set for M5 (CloudKit sync)

---

**Document Version**: 1.0  
**Created**: November 24, 2025  
**Status**: 🚀 READY  
**Estimated Time**: 4 hours  
**Prerequisites**: M4.3.1 ✅, M4.3.4 ✅
