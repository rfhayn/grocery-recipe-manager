# Product Requirements Document: M4.3.5 - Ingredient Normalization

**Document Version**: 1.0  
**Created**: November 19, 2025  
**Priority**: HIGH - Data Quality Foundation  
**Estimated Effort**: 3.5-4 hours  
**Approach**: Progressive normalization with four independent phases

---

## Executive Summary

Implement intelligent ingredient name normalization to eliminate duplicate templates caused by minor textual variations (case differences, singular/plural forms, abbreviations, and common variations). This behind-the-scenes enhancement ensures clean data without requiring user intervention, improving template reuse, recipe source tracking accuracy, and overall data quality.

---

## Problem Statement

### Current Limitations

**Duplicate Template Creation:**
- `egg` and `eggs` create separate templates despite being the same ingredient
- `Butter`, `butter`, and `BUTTER` treated as different items
- `tbsp`, `tablespoon`, and `tablespoons` fragment the same measurement
- `all-purpose flour`, `flour`, and `AP flour` create unnecessary duplicates

**Business Impact:**
- **Fragmented Usage Analytics**: Template usage counts split across duplicates (eggs: 4 uses + egg: 2 uses should be eggs: 6 uses)
- **Poor Recipe Source Tracking**: Recipe badges split across duplicate templates (user sees butter [Recipe A] and Butter [Recipe B] separately)
- **Cluttered Ingredient List**: Users see duplicate ingredients in Ingredients tab
- **Reduced Template Reuse**: Autocomplete less effective when duplicates exist
- **Data Quality Issues**: Analytics and insights degraded by duplicate data

### User Experience Problems

**Current State:**
```
Ingredients List:
• butter (4 uses)
• Butter (2 uses)
• egg (3 uses)
• eggs (5 uses)
• all-purpose flour (2 uses)
• flour (6 uses)
• tbsp (multiple meanings unclear)
```

**Pain Points:**
- User confusion about which template to use
- Recipe source badges don't aggregate properly
- Search results show duplicates
- Manual cleanup is tedious and error-prone

---

## Solution Overview

### Core Architecture Change

Implement **IngredientNormalizationService** that normalizes ingredient names at two critical points:

1. **Template Creation**: Normalize before storing in database
2. **Template Search**: Normalize search queries to find existing templates

### Design Principles

**Behind-the-Scenes Operation:**
- ✅ Completely transparent to users
- ✅ No manual review or confirmation required
- ✅ No UI changes needed (works with existing interfaces)
- ✅ Automatic application during normal workflows

**Progressive Enhancement:**
- ✅ Four independent phases (can deploy incrementally)
- ✅ Each phase adds one normalization rule
- ✅ No dependencies between phases (any order works)
- ✅ Low risk of breaking existing functionality

### Expected Results

**After Implementation:**
```
Ingredients List:
• butter (6 uses) ← merged from "butter" + "Butter"
• eggs (8 uses) ← merged from "egg" + "eggs"  
• flour (8 uses) ← merged from "all-purpose flour" + "flour"
• tablespoon ← standardized from "tbsp" + "tablespoon"
```

**Benefits:**
- Clean, deduplicated ingredient list
- Accurate usage analytics
- Better recipe source aggregation
- Improved autocomplete effectiveness

---

## Functional Requirements

### Phase 1: Case Normalization (0.5 hours)

**Objective**: Eliminate duplicates caused by case differences

**Normalization Rule:**
```swift
// Input: "Butter", "BUTTER", "butter"
// Output: "butter" (lowercase)
```

**Implementation:**
- Convert all ingredient names to lowercase before storage
- Apply lowercase to search queries
- Exception: Proper nouns that should stay capitalized (none for ingredients)

**Examples:**
| Input | Normalized Output |
|-------|------------------|
| `Butter` | `butter` |
| `SALT` | `salt` |
| `All-Purpose Flour` | `all-purpose flour` |
| `Chocolate Chips` | `chocolate chips` |

**Impact:**
- Merges case variations immediately
- Simplest rule to implement
- Lowest risk of unintended side effects

**Success Criteria:**
- ✅ All new templates stored in lowercase
- ✅ Case-insensitive template search working
- ✅ No visual changes to users (just fewer duplicates)

---

### Phase 2: Singular/Plural Normalization (1 hour)

**Objective**: Treat singular and plural forms as the same ingredient

**Normalization Rule:**
```swift
// Input: "egg", "eggs"
// Output: "eggs" (plural form)

// Input: "tomato", "tomatoes"  
// Output: "tomatoes" (plural form)
```

**Pluralization Algorithm:**

**Simple Rules:**
```swift
// Standard -s plural
"egg" → "eggs"
"chip" → "chips"

// -es plural
"tomato" → "tomatoes"
"potato" → "potatoes"

// -ies plural  
"berry" → "berries"

// Irregular plurals
"loaf" → "loaves"
```

**Edge Cases to Handle:**
- Words ending in 's' already: `lettuce` → `lettuce` (no change)
- Irregular plurals: use lookup table
- Compound words: `chocolate chip` → `chocolate chips`

**Note**: Normalize everything to plural. Don't worry about semantic differences (e.g., `pepper` vs `peppers`). User can manually fix edge cases if needed.

**Examples:**
| Input | Normalized Output |
|-------|------------------|
| `egg` | `eggs` |
| `tomato` | `tomatoes` |
| `strawberry` | `strawberries` |
| `loaf` | `loaves` |
| `lettuce` | `lettuce` |

**Implementation Details:**
- Use English pluralization library or rules-based approach
- Default to adding 's' if uncertain
- Store lookup table for irregular plurals
- Apply to last word in multi-word ingredients

**Success Criteria:**
- ✅ `egg` and `eggs` map to same template
- ✅ Common pluralization patterns work (90%+ accuracy)
- ✅ Compound ingredients handled (chocolate chip → chocolate chips)

---

### Phase 3: Abbreviation Expansion (1.5 hours)

**Objective**: Standardize measurement abbreviations to full words

**Normalization Rule:**
```swift
// Input: "tbsp", "tablespoon", "tablespoons"
// Output: "tablespoon"

// Input: "tsp", "teaspoon", "teaspoons"
// Output: "teaspoon"
```

**Abbreviation Dictionary:**

**Volume Measurements:**
| Abbreviation | Full Form |
|--------------|-----------|
| `tbsp`, `tbs`, `T` | `tablespoon` |
| `tsp`, `t` | `teaspoon` |
| `c`, `C` | `cup` |
| `pt` | `pint` |
| `qt` | `quart` |
| `gal` | `gallon` |
| `fl oz` | `fluid ounce` |
| `ml`, `mL` | `milliliter` |
| `L` | `liter` |

**Weight Measurements:**
| Abbreviation | Full Form |
|--------------|-----------|
| `oz` | `ounce` |
| `lb`, `lbs` | `pound` |
| `g` | `gram` |
| `kg` | `kilogram` |

**Other Common Abbreviations:**
| Abbreviation | Full Form |
|--------------|-----------|
| `pkg` | `package` |
| `env` | `envelope` |
| `can` | `can` (no change) |

**Context Handling:**
- Abbreviations usually appear in ingredient text: "2 tbsp butter"
- This phase normalizes the UNIT part during parsing
- Works with existing IngredientParsingService integration

**Examples:**
| Input | Normalized Output |
|-------|------------------|
| `2 tbsp butter` | `butter` (unit handled separately) |
| `1 tsp vanilla` | `vanilla` |
| `3 c flour` | `flour` |

**Note**: This phase focuses on normalizing units that might appear in ingredient names. Main unit handling is already done by IngredientParsingService.

**Success Criteria:**
- ✅ Common measurement abbreviations recognized
- ✅ Unit normalization doesn't create new duplicates
- ✅ Works alongside existing parsing service

---

### Phase 4: Common Variation Normalization (1 hour)

**Objective**: Handle common ingredient name variations

**Normalization Rule:**
```swift
// Input: "all-purpose flour", "AP flour", "all purpose flour"
// Output: "flour"

// Input: "extra virgin olive oil", "EVOO", "olive oil"
// Output: "olive oil"
```

**Variation Patterns:**

**Flour Variations:**
```
"all-purpose flour" → "flour"
"AP flour" → "flour"  
"all purpose flour" → "flour"
"plain flour" → "flour"
```

**Oil Variations:**
```
"extra virgin olive oil" → "olive oil"
"EVOO" → "olive oil"
"extra-virgin olive oil" → "olive oil"
```

**Chocolate Variations:**
```
"semi-sweet chocolate chips" → "chocolate chips"
"semisweet chocolate chips" → "chocolate chips"
"chocolate chip" → "chocolate chips" (also plural)
```

**Implementation Strategy:**
- Pattern matching for common modifiers
- Remove descriptive prefixes: "extra virgin", "all-purpose", "semi-sweet"
- Preserve core ingredient name
- Use allowlist approach (only normalize known patterns)

**Variation Patterns to Remove:**
- Descriptive adjectives: `fresh`, `ripe`, `organic`, `raw`
- Quality indicators: `extra virgin`, `premium`, `high-quality`
- Processing terms: `all-purpose`, `self-rising`, `pre-cooked`
- Size descriptors: `large`, `medium`, `small`, `jumbo`

**Examples:**
| Input | Normalized Output |
|-------|------------------|
| `all-purpose flour` | `flour` |
| `fresh basil` | `basil` |
| `large eggs` | `eggs` |
| `extra virgin olive oil` | `olive oil` |
| `unsalted butter` | `butter` |

**Success Criteria:**
- ✅ Common flour variations merge
- ✅ Oil type variations merge
- ✅ Descriptive modifiers removed
- ✅ Core ingredient name preserved

---

## Technical Architecture

### IngredientNormalizationService

**Location**: `Services/IngredientNormalizationService.swift`

**Core Interface:**
```swift
class IngredientNormalizationService {
    // MARK: - Public API
    
    /// Normalize an ingredient name using all active rules
    /// - Parameter name: Raw ingredient name from user input
    /// - Returns: Normalized ingredient name for storage/search
    func normalize(name: String) -> String
    
    // MARK: - Phase-Specific Normalization
    
    /// Phase 1: Convert to lowercase
    func normalizeCase(_ name: String) -> String
    
    /// Phase 2: Convert to plural form
    func normalizePlural(_ name: String) -> String
    
    /// Phase 3: Expand abbreviations to full words
    func expandAbbreviations(_ name: String) -> String
    
    /// Phase 4: Standardize common variations
    func normalizeVariations(_ name: String) -> String
}
```

**Pipeline Architecture:**
```swift
func normalize(name: String) -> String {
    var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Apply normalization phases in order
    normalized = normalizeCase(normalized)        // Phase 1
    normalized = normalizePlural(normalized)      // Phase 2  
    normalized = expandAbbreviations(normalized)  // Phase 3
    normalized = normalizeVariations(normalized)  // Phase 4
    
    return normalized
}
```

**Key Design Decisions:**

1. **Progressive Enhancement**: Each phase is independent
2. **Composable**: Phases apply in sequence (order matters)
3. **Stateless**: No internal state, pure functions
4. **Testable**: Each phase can be unit tested independently

---

### Integration Points

**1. Template Creation (IngredientTemplateService)**

```swift
// BEFORE:
func findOrCreateTemplate(name: String) -> IngredientTemplate {
    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    request.predicate = NSPredicate(format: "name ==[cd] %@", name)
    // ...
}

// AFTER (M4.3.5):
func findOrCreateTemplate(name: String) -> IngredientTemplate {
    let normalizedName = normalizationService.normalize(name: name)
    
    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    request.predicate = NSPredicate(format: "name ==[cd] %@", normalizedName)
    // ...
}
```

**2. Template Search (IngredientAutocompleteService)**

```swift
// BEFORE:
func searchTemplates(query: String) -> [IngredientTemplate] {
    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
    // ...
}

// AFTER (M4.3.5):
func searchTemplates(query: String) -> [IngredientTemplate] {
    let normalizedQuery = normalizationService.normalize(name: query)
    
    let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
    request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", normalizedQuery)
    // ...
}
```

**3. Recipe Ingredient Parsing (IngredientParsingService)**

```swift
// Already extracts clean name, now normalize it:
func parseIngredient(text: String) -> ParsedIngredient {
    let parsed = extractComponents(from: text)
    let normalizedName = normalizationService.normalize(name: parsed.name)
    
    return ParsedIngredient(
        name: normalizedName,  // Use normalized name
        originalText: text,
        // ...
    )
}
```

---

### Data Migration Strategy

**Simple Approach**: Delete and regenerate

**Rationale:**
- Pre-production app (no user data to preserve)
- Cleanest slate for testing normalized templates
- Avoids complex merge logic
- Faster than building deduplication tool

**Migration Steps:**

1. **Delete All Existing Data:**
   ```swift
   // Delete all recipes (cascades to ingredients)
   let recipeFetch: NSFetchRequest<NSFetchRequestResult> = Recipe.fetchRequest()
   let recipeDelete = NSBatchDeleteRequest(fetchRequest: recipeFetch)
   try context.execute(recipeDelete)
   
   // Delete all templates
   let templateFetch: NSFetchRequest<NSFetchRequestResult> = IngredientTemplate.fetchRequest()
   let templateDelete = NSBatchDeleteRequest(fetchRequest: templateFetch)
   try context.execute(templateDelete)
   ```

2. **Regenerate Test Data:**
   - Use "Generate 6 Test Recipes" button
   - New templates created with normalization applied
   - Verify no duplicates appear

3. **Validation:**
   - Check ingredient list for duplicates
   - Verify recipe source tags aggregate properly
   - Confirm usage counts are accurate

**Alternative (If Needed Later):**
- Build deduplication tool in future milestone
- For now, clean slate is faster and safer

---

## Success Criteria

### Quantitative Metrics

**Phase 1: Case Normalization**
- ✅ Zero case-variant duplicates (Butter/butter/BUTTER → butter)
- ✅ < 0.01s normalization overhead per operation
- ✅ 100% of new templates use lowercase

**Phase 2: Singular/Plural**
- ✅ Zero singular/plural duplicates (egg/eggs → eggs)
- ✅ 90%+ accuracy for common pluralization patterns
- ✅ Compound ingredients handled correctly

**Phase 3: Abbreviations**
- ✅ Common measurement abbreviations standardized
- ✅ No new duplicates from abbreviation variations
- ✅ Works with existing parsing service

**Phase 4: Variations**
- ✅ Common ingredient variations merged
- ✅ Core ingredient names preserved
- ✅ Descriptive modifiers removed consistently

**Overall Performance:**
- ✅ < 0.05s total normalization time per ingredient
- ✅ No degradation to existing features
- ✅ 100% relationship preservation during data reset

### Qualitative Metrics

**User Experience:**
- ✅ Clean ingredient list (no visible duplicates)
- ✅ Recipe source tags aggregate properly
- ✅ Autocomplete more effective (finds templates reliably)
- ✅ Usage counts accurate and meaningful

**Data Quality:**
- ✅ Template reuse rate increases
- ✅ Analytics more accurate
- ✅ Search results cleaner
- ✅ Foundation for future features (meal planning, analytics)

### Testing Scenarios

**Scenario 1: Case Variations**
```
Input: Create recipes with "Butter", "butter", "BUTTER"
Expected: Single template "butter" created
Verify: Ingredient list shows one entry
```

**Scenario 2: Singular/Plural**
```
Input: Create recipes with "2 eggs" and "1 egg"
Expected: Single template "eggs" created
Verify: Usage count reflects both uses
```

**Scenario 3: Abbreviations**
```
Input: Create recipes with "1 tbsp" and "2 tablespoons"
Expected: Templates reference same standardized unit
Verify: No unit-based duplicates
```

**Scenario 4: Variations**
```
Input: Create recipes with "all-purpose flour" and "flour"
Expected: Single template "flour" created
Verify: Both recipes reference same template
```

**Scenario 5: Recipe Source Tags**
```
Input: Add 6 test recipes to grocery list
Expected: Items show all relevant recipe badges
Verify: "eggs [Recipe1] [Recipe2] [Recipe3]..." aggregates properly
```

---

## Implementation Guide

### Phase 1: Case Normalization (0.5 hours)

**Step 1.1: Create Service** (15 min)
```swift
// File: Services/IngredientNormalizationService.swift

import Foundation

class IngredientNormalizationService {
    // Phase 1: Case normalization
    func normalizeCase(_ name: String) -> String {
        return name.lowercased()
    }
    
    // Main normalize function (grows with each phase)
    func normalize(name: String) -> String {
        var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        normalized = normalizeCase(normalized)
        return normalized
    }
}
```

**Step 1.2: Integrate with TemplateService** (15 min)
```swift
// File: Services/IngredientTemplateService.swift

class IngredientTemplateService {
    private let normalizationService = IngredientNormalizationService()
    
    func findOrCreateTemplate(name: String, context: NSManagedObjectContext) -> IngredientTemplate {
        // Apply normalization before search
        let normalizedName = normalizationService.normalize(name: name)
        
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", normalizedName)
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        // Create with normalized name
        let template = IngredientTemplate(context: context)
        template.name = normalizedName
        return template
    }
}
```

**Step 1.3: Test & Validate** (10 min)
- Delete all recipes and templates
- Generate 6 test recipes
- Verify no case-variant duplicates

---

### Phase 2: Singular/Plural Normalization (1 hour)

**Step 2.1: Add Pluralization Logic** (30 min)
```swift
// Add to IngredientNormalizationService

func normalizePlural(_ name: String) -> String {
    // Handle compound words (pluralize last word)
    let words = name.split(separator: " ").map(String.init)
    guard let lastWord = words.last else { return name }
    
    let pluralized = pluralize(lastWord)
    
    if words.count == 1 {
        return pluralized
    } else {
        var result = words
        result[result.count - 1] = pluralized
        return result.joined(separator: " ")
    }
}

private func pluralize(_ word: String) -> String {
    // Already plural (ends in 's')
    if word.hasSuffix("s") && !word.hasSuffix("ss") {
        return word
    }
    
    // Irregular plurals
    let irregulars: [String: String] = [
        "loaf": "loaves",
        "knife": "knives",
        "leaf": "leaves",
        "half": "halves"
    ]
    if let irregular = irregulars[word] {
        return irregular
    }
    
    // -y → -ies
    if word.hasSuffix("y") && word.count > 2 {
        let beforeY = word[word.index(word.endIndex, offsetBy: -2)]
        if !"aeiou".contains(beforeY) {
            return String(word.dropLast()) + "ies"
        }
    }
    
    // -o → -oes
    if word.hasSuffix("o") {
        return word + "es"
    }
    
    // -s, -x, -z, -ch, -sh → -es
    if word.hasSuffix("s") || word.hasSuffix("x") || word.hasSuffix("z") ||
       word.hasSuffix("ch") || word.hasSuffix("sh") {
        return word + "es"
    }
    
    // Default: add 's'
    return word + "s"
}

// Update main normalize function
func normalize(name: String) -> String {
    var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
    normalized = normalizeCase(normalized)        // Phase 1
    normalized = normalizePlural(normalized)      // Phase 2
    return normalized
}
```

**Step 2.2: Test Pluralization** (15 min)
- Unit tests for common patterns
- Test compound words
- Verify irregular plurals

**Step 2.3: Integration Test** (15 min)
- Delete data, regenerate recipes
- Verify egg/eggs merge
- Check usage counts

---

### Phase 3: Abbreviation Expansion (1.5 hours)

**Step 3.1: Build Abbreviation Dictionary** (30 min)
```swift
// Add to IngredientNormalizationService

private let abbreviationMap: [String: String] = [
    // Volume
    "tbsp": "tablespoon",
    "tbs": "tablespoon",
    "t": "tablespoon",
    "tsp": "teaspoon",
    "c": "cup",
    "pt": "pint",
    "qt": "quart",
    "gal": "gallon",
    "fl oz": "fluid ounce",
    "oz": "ounce",
    "ml": "milliliter",
    "l": "liter",
    
    // Weight
    "lb": "pound",
    "lbs": "pounds",
    "g": "gram",
    "kg": "kilogram",
    
    // Other
    "pkg": "package",
    "env": "envelope"
]

func expandAbbreviations(_ name: String) -> String {
    var result = name
    
    // Replace abbreviations with full forms
    for (abbrev, full) in abbreviationMap {
        // Word boundary matching to avoid partial replacements
        let pattern = "\\b\(abbrev)\\b"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                range: range,
                withTemplate: full
            )
        }
    }
    
    return result
}

// Update main normalize function
func normalize(name: String) -> String {
    var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
    normalized = normalizeCase(normalized)
    normalized = normalizePlural(normalized)
    normalized = expandAbbreviations(normalized)   // Phase 3
    return normalized
}
```

**Step 3.2: Test Abbreviations** (30 min)
- Unit tests for common abbreviations
- Test word boundary matching
- Verify no false positives

**Step 3.3: Integration Test** (30 min)
- Test with ingredient parsing
- Verify unit handling
- Check for conflicts with existing parsing

---

### Phase 4: Common Variation Normalization (1 hour)

**Step 4.1: Pattern Matching Logic** (30 min)
```swift
// Add to IngredientNormalizationService

func normalizeVariations(_ name: String) -> String {
    var result = name
    
    // Remove common modifiers
    let modifiersToRemove = [
        "all-purpose", "all purpose", "ap",
        "extra virgin", "extra-virgin",
        "semi-sweet", "semisweet",
        "fresh", "ripe", "organic", "raw",
        "large", "medium", "small", "jumbo",
        "unsalted", "salted"
    ]
    
    for modifier in modifiersToRemove {
        // Remove modifier if followed by space
        let pattern = "\\b\(modifier)\\s+"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                range: range,
                withTemplate: ""
            )
        }
    }
    
    // Trim whitespace again after removal
    result = result.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Collapse multiple spaces
    result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    
    return result
}

// Update main normalize function
func normalize(name: String) -> String {
    var normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
    normalized = normalizeCase(normalized)
    normalized = normalizePlural(normalized)
    normalized = expandAbbreviations(normalized)
    normalized = normalizeVariations(normalized)  // Phase 4
    return normalized
}
```

**Step 4.2: Test Variations** (15 min)
- Unit tests for common patterns
- Test flour variations
- Test oil variations
- Verify core names preserved

**Step 4.3: Final Integration Test** (15 min)
- Delete data, regenerate all recipes
- Verify all normalization phases work together
- Check ingredient list is clean
- Verify recipe source tags aggregate properly

---

## Risk Assessment

### Low Risk

**Progressive Phases:**
- ✅ Each phase independent and incremental
- ✅ Can test each phase separately
- ✅ Easy to rollback individual phases if issues

**Simple Integration:**
- ✅ Two clear integration points (template creation, search)
- ✅ No UI changes required
- ✅ Existing code paths unchanged (just add normalization)

**Data Reset Strategy:**
- ✅ Clean slate avoids complex merge logic
- ✅ No production data to preserve
- ✅ Fast regeneration with test recipes

### Medium Risk

**Edge Cases:**
- ⚠️ Pluralization rules won't be 100% accurate
- **Mitigation**: Good enough approach, user can manually fix rare cases
- **Impact**: Low - most ingredients follow standard patterns

**Semantic Differences:**
- ⚠️ "pepper" vs "peppers" are technically different ingredients
- **Mitigation**: Normalize everything, edge cases handled manually if discovered
- **Impact**: Low - benefits outweigh rare edge cases

### Negligible Risk

**Performance:**
- String operations are fast (< 0.05s total)
- No database schema changes
- No additional queries

**Breaking Changes:**
- Behind-the-scenes operation
- No API changes
- Existing features unaffected

---

## Future Enhancements

**Not in M4.3.5 Scope:**

1. **Deduplication Tool**: Manual UI for finding and merging existing duplicates
   - Could be M5.5 or M6.5 if needed
   - Not critical with data reset strategy

2. **Machine Learning**: Learn from user corrections
   - Advanced feature for post-launch
   - Requires significant usage data

3. **Multi-Language Support**: Pluralization for other languages
   - International expansion feature
   - English-only sufficient for MVP

4. **Semantic Understanding**: Context-aware normalization
   - Distinguish "pepper" (spice) from "peppers" (vegetables)
   - Advanced NLP feature for future

---

## Appendices

### Appendix A: Normalization Examples

**Complete Pipeline Example:**

```
Input: "2 Tbsp All-Purpose Flour"

After Phase 1 (Case):
→ "2 tbsp all-purpose flour"

After Phase 2 (Plural):  
→ "2 tbsp all-purpose flours"

After Phase 3 (Abbreviations):
→ "2 tablespoon all-purpose flours"

After Phase 4 (Variations):
→ "2 tablespoon flours"

Final Template Name: "flours"
(Note: Quantity "2 tablespoon" handled by IngredientParsingService separately)
```

**More Examples:**

| Raw Input | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Final |
|-----------|---------|---------|---------|---------|-------|
| `Butter` | `butter` | `butters` | `butters` | `butters` | `butters` |
| `1 egg` | `1 egg` | `1 eggs` | `1 eggs` | `1 eggs` | `eggs` |
| `2 tsp vanilla` | `2 tsp vanilla` | `2 tsp vanillas` | `2 teaspoon vanillas` | `2 teaspoon vanillas` | `vanillas` |
| `EVOO` | `evoo` | `evoos` | `evoos` | `evoos` | `evoos` |
| `Fresh Tomatoes` | `fresh tomatoes` | `fresh tomatoes` | `fresh tomatoes` | `tomatoes` | `tomatoes` |

---

### Appendix B: Testing Checklist

**Phase 1: Case**
- [ ] "Butter" and "butter" create same template
- [ ] "SALT" normalizes to "salt"
- [ ] Search is case-insensitive

**Phase 2: Plural**
- [ ] "egg" and "eggs" create same template
- [ ] Irregular plurals work (loaf → loaves)
- [ ] Compound words pluralize correctly (chocolate chip → chocolate chips)

**Phase 3: Abbreviations**
- [ ] "tbsp" expands to "tablespoon"
- [ ] "tsp" expands to "teaspoon"
- [ ] Common measurement abbreviations recognized

**Phase 4: Variations**
- [ ] "all-purpose flour" normalizes to "flour"
- [ ] "fresh basil" normalizes to "basil"
- [ ] "unsalted butter" normalizes to "butter"

**Integration**
- [ ] Recipe ingredient parsing works correctly
- [ ] Template creation uses normalized names
- [ ] Template search uses normalized queries
- [ ] Autocomplete finds normalized templates
- [ ] Recipe source tags aggregate properly
- [ ] Usage counts are accurate

**Performance**
- [ ] < 0.05s normalization per ingredient
- [ ] No degradation to existing features
- [ ] < 0.1s template creation/search

---

### Appendix C: Quick Reference

**Service Interface:**
```swift
let service = IngredientNormalizationService()
let normalized = service.normalize(name: "2 Tbsp Fresh Butter")
// Returns: "butters"
```

**Integration Points:**
1. IngredientTemplateService.findOrCreateTemplate()
2. IngredientAutocompleteService.searchTemplates()
3. IngredientParsingService.parseIngredient()

**Phase Timeline:**
- Phase 1: 0.5 hours (case normalization)
- Phase 2: 1.0 hour (singular/plural)
- Phase 3: 1.5 hours (abbreviations)
- Phase 4: 1.0 hour (variations)
- **Total: 4.0 hours**

---

## Conclusion

M4.3.5 delivers intelligent ingredient normalization that eliminates duplicate templates without user intervention. The four-phase progressive approach ensures low risk while systematically addressing case variations, singular/plural forms, abbreviations, and common ingredient variations. This behind-the-scenes enhancement improves data quality, recipe source tracking accuracy, and template reuse—establishing a clean foundation for future analytics and intelligence features.

**Status**: Ready for Implementation  
**Estimated Effort**: 3.5-4 hours  
**Risk Level**: Low  
**User Impact**: High (cleaner data, better UX)  
**Technical Debt**: None (progressive enhancement)

---

**END OF PRD v1.0**

**Created**: November 19, 2025  
**Author**: Development Team  
**Next Steps**: Add to current-story.md, implement after M4.3.4 complete