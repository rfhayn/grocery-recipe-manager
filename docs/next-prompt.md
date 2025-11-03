# Next Prompt: M4.2.1-3 Enhancement - RecipePickerSheet UI Redesign

**Status**: 🚀 READY  
**Estimated Time**: 1.0 hours  
**Last Updated**: November 3, 2025

---

## 📋 Session Startup Checklist

**Before starting, complete these steps:**

1. ✅ Read [session-startup-checklist.md](session-startup-checklist.md)
2. ✅ Read [project-naming-standards.md](project-naming-standards.md)
3. ✅ Read [current-story.md](current-story.md)
4. ✅ Read this file (next-prompt.md)
5. ✅ Read PRD: [milestone-4.2.1-3-enhancement-recipe-picker-ui-redesign.md](prds/milestone-4.2.1-3-enhancement-recipe-picker-ui-redesign.md)

---

## 🎯 What We're Building

**Enhancement**: RecipePickerSheet UI Polish  
**Goal**: Transform cluttered recipe list into clean, scannable interface with inline expansion

**Current State**: ✅ Functional but cluttered - every recipe shows servings adjuster  
**Target State**: Clean list that expands inline when tapped, revealing servings + Add button

---

## 📁 Files to Modify

**Primary**:
- `RecipePickerSheet.swift` - Main redesign work happens here

**No Changes Needed**:
- `MealPlanDetailView.swift` - Sheet presentation already fixed
- `MealPlanService.swift` - Service layer unchanged
- Core Data - No data model changes

---

## 🏗️ Implementation Plan

### **Phase 1: Simplify Collapsed Rows** (20 min)

**Goal**: Remove servings adjuster, clean up recipe rows

**Changes to RecipePickerSheet.swift:**

1. **Extract New Component**: `CollapsedRecipeRow`
```swift
// M4.2.1-3 Enhancement: Simplified recipe row (collapsed state)
struct CollapsedRecipeRow: View {
    let recipe: Recipe
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.blue)
                    
                    Text(recipe.title ?? "Untitled Recipe")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(recipe.ingredients?.count ?? 0) ingredients • Serves \(Int(recipe.servings))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
```

2. **Update Recipe List Section**:
```swift
// Replace existing recipeList computed property
private var recipeList: some View {
    List {
        ForEach(filteredRecipes, id: \.id) { recipe in
            if selectedRecipeID == recipe.id {
                ExpandedRecipeRow(...)  // Will create in Phase 2
            } else {
                CollapsedRecipeRow(
                    recipe: recipe,
                    onTap: { handleRecipeTap(recipe) }
                )
            }
        }
    }
    .listStyle(.plain)
}
```

3. **Enhance Date Banner**:
```swift
private var dateContextBanner: some View {
    HStack(spacing: 8) {
        Image(systemName: "calendar")
            .font(.title3)  // Larger icon
            .foregroundColor(.blue)
        
        Text("Adding to \(formattedShortDate)")  // New formatter
            .font(.headline)  // More prominent
        
        Spacer()
    }
    .padding()
    .background(Color.blue.opacity(0.1))  // Light blue background
}

// Add new date formatter
private var formattedShortDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d"  // "Thu, Nov 6"
    return formatter.string(from: date)
}
```

**Validation**:
- ✅ Recipe list renders cleanly
- ✅ No servings adjusters visible
- ✅ Rows are scannable
- ✅ Date banner more prominent

---

### **Phase 2: Add Expansion Logic** (25 min)

**Goal**: Implement inline expansion when recipe tapped

**Changes to RecipePickerSheet.swift:**

1. **Add State Variable**:
```swift
// M4.2.1-3 Enhancement: Track selected recipe for expansion
@State private var selectedRecipeID: UUID?
```

2. **Create Tap Handler**:
```swift
// M4.2.1-3 Enhancement: Handle recipe selection
// Toggles expansion: tap same = collapse, tap different = switch
private func handleRecipeTap(_ recipe: Recipe) {
    withAnimation(.easeInOut(duration: 0.25)) {
        if selectedRecipeID == recipe.id {
            // Tapping same recipe = collapse
            selectedRecipeID = nil
        } else {
            // Tapping different recipe = expand (auto-collapses previous)
            selectedRecipeID = recipe.id
        }
    }
}
```

3. **Create Expanded Row Component**:
```swift
// M4.2.1-3 Enhancement: Expanded recipe row with servings adjuster and add button
struct ExpandedRecipeRow: View {
    let recipe: Recipe
    let servings: Int
    let onServingsChange: (Int) -> Void
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.blue)
                
                Text(recipe.title ?? "Untitled Recipe")
                    .font(.body)
                    .fontWeight(.semibold)  // Bold when selected
                
                Spacer()
            }
            
            // Metadata
            Text("\(recipe.ingredients?.count ?? 0) ingredients • Serves \(Int(recipe.servings))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Servings Adjuster
            HStack {
                Text("Servings:")
                    .font(.subheadline)
                
                Spacer()
                
                // Minus Button
                Button {
                    if servings > 1 {
                        onServingsChange(servings - 1)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(servings > 1 ? .blue : .gray)
                }
                .disabled(servings <= 1)
                
                // Current Value
                Text("\(servings)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 40)
                
                // Plus Button
                Button {
                    if servings < 99 {
                        onServingsChange(servings + 1)
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(servings < 99 ? .blue : .gray)
                }
                .disabled(servings >= 99)
            }
            
            // Add Button
            Button(action: onAdd) {
                Text("Add to Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))  // Blue tint
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)  // Blue border
        )
    }
}
```

4. **Update Recipe List with Conditional Rendering**:
```swift
private var recipeList: some View {
    List {
        ForEach(filteredRecipes, id: \.id) { recipe in
            if selectedRecipeID == recipe.id {
                // Expanded state
                ExpandedRecipeRow(
                    recipe: recipe,
                    servings: getServings(for: recipe),
                    onServingsChange: { newServings in
                        setServings(newServings, for: recipe)
                    },
                    onAdd: {
                        handleRecipeSelection(recipe)
                    }
                )
            } else {
                // Collapsed state
                CollapsedRecipeRow(
                    recipe: recipe,
                    onTap: { handleRecipeTap(recipe) }
                )
            }
        }
    }
    .listStyle(.plain)
}
```

**Validation**:
- ✅ Tapping recipe expands it
- ✅ Tapping another recipe collapses previous
- ✅ Animation smooth (< 0.3s)
- ✅ Servings adjuster works
- ✅ Add button calls existing handler

---

### **Phase 3: Polish & Test** (15 min)

**Goal**: Final polish and validation

**Tasks**:

1. **Test Workflow**:
   - Open meal plan
   - Tap day
   - Search for recipe
   - Tap recipe (should expand)
   - Adjust servings
   - Tap "Add to Plan"
   - Verify recipe appears on calendar

2. **Test Edge Cases**:
   - No recipes (empty state)
   - Search with no results
   - 1 recipe in list
   - 50+ recipes in list
   - Rapid tapping between recipes

3. **Performance Check**:
   - Smooth scrolling with many recipes
   - Animation doesn't drop frames
   - No memory issues

4. **Visual Polish**:
   - Colors match design spec
   - Spacing feels right
   - Typography hierarchy clear
   - Blue selection treatment visible

**Validation**:
- ✅ All workflows functional
- ✅ No crashes or errors
- ✅ Performance smooth
- ✅ Visual design polished

---

## 📝 Code Documentation Requirements

**Function Headers**:
```swift
// M4.2.1-3 Enhancement: Handles recipe selection and expansion
// Toggles between collapsed and expanded states
// Only one recipe can be expanded at a time
private func handleRecipeTap(_ recipe: Recipe) {
    // Implementation
}
```

**Component Headers**:
```swift
// M4.2.1-3 Enhancement: Simplified recipe row (collapsed state)
// Shows only name and metadata for quick scanning
// Tapping expands to show servings adjuster and add button
struct CollapsedRecipeRow: View {
    // Implementation
}
```

**MARK Comments**:
```swift
// MARK: - M4.2.1-3 Enhancement: Collapsed Row Component
// MARK: - M4.2.1-3 Enhancement: Expanded Row Component
// MARK: - M4.2.1-3 Enhancement: Selection Logic
```

---

## 🎯 Acceptance Criteria

**Must Pass**:
- [ ] Recipe list displays cleanly without clutter
- [ ] Tapping recipe expands it inline
- [ ] Servings adjuster appears in expanded state
- [ ] "Add to Plan" button functional
- [ ] Only one recipe expanded at a time
- [ ] Smooth animation (< 0.3s)
- [ ] Selected recipe has blue border + tint
- [ ] Date banner enhanced with better styling
- [ ] Performance smooth with 50+ recipes
- [ ] Code follows project naming standards

**Quality Gates**:
- [ ] Build succeeds with zero warnings
- [ ] No regressions to existing functionality
- [ ] VoiceOver labels present (if time permits)
- [ ] Code documented with M4.2.1-3 Enhancement references

---

## 🔧 Troubleshooting

**Issue**: Animation jerky or slow
- **Fix**: Check that animation only applies to selectedRecipeID changes
- **Fix**: Ensure List uses .listStyle(.plain)

**Issue**: Multiple rows expanded
- **Fix**: Verify selectedRecipeID is UUID? (singular, not Set)
- **Fix**: Check conditional rendering logic

**Issue**: Tapping doesn't expand
- **Fix**: Verify handleRecipeTap is called
- **Fix**: Check @State variable is properly declared
- **Fix**: Ensure animation wrapper present

**Issue**: Blue border not visible
- **Fix**: Check z-order of overlay
- **Fix**: Verify Color.blue stroke width (should be 2pt)

---

## 📚 Reference Materials

**Similar Patterns**:
- Learning Note 07: Professional staples management (inline patterns)
- iOS Settings app: Expandable rows
- CategoryAssignmentModal: Selection patterns

**Key Files**:
- `RecipePickerSheet.swift` - Main file to modify
- `MealPlanDetailView.swift` - Already correct (no changes)
- PRD: `milestone-4.2.1-3-enhancement-recipe-picker-ui-redesign.md`

**Design Specs**:
- Colors: Blue tint 0.1 opacity, border 2pt
- Typography: .body/.medium collapsed, .body/.semibold expanded
- Spacing: 12pt between sections, 16pt padding
- Animation: .easeInOut, 0.25s duration

---

## ✅ Completion Checklist

**After implementation:**

- [ ] Code compiles without warnings
- [ ] All acceptance criteria met
- [ ] Manual testing complete
- [ ] Update current-story.md: Mark M4.2.1-3 Enhancement ✅ COMPLETE with hours
- [ ] Update project-index.md: Add to Recent Activity
- [ ] Create learning note with:
  - [ ] Inline expansion pattern details
  - [ ] Visual design decisions
  - [ ] Code examples for reference
  - [ ] Any challenges encountered

**Files to update:**
1. `docs/current-story.md` - Status + hours
2. `docs/project-index.md` - Recent Activity
3. `docs/learning-notes/XX-m4.2.1-3-recipe-picker-ui-enhancement.md` - New note

---

## 🚀 Ready to Start?

**Copy-paste this to begin:**

```
I'm ready to implement M4.2.1-3 Enhancement: RecipePickerSheet UI Redesign.

I've reviewed:
- session-startup-checklist.md
- project-naming-standards.md  
- current-story.md
- next-prompt.md (this file)
- PRD: milestone-4.2.1-3-enhancement-recipe-picker-ui-redesign.md

Let's start with Phase 1: Simplifying the collapsed recipe rows. 
Please create the updated RecipePickerSheet.swift with Phase 1 changes.
```

---

**Estimated Time**: 1.0 hours  
**Phase Breakdown**:
- Phase 1: Simplify (20 min)
- Phase 2: Expansion (25 min)  
- Phase 3: Polish (15 min)

**Total**: 60 minutes

Good luck! This is a straightforward enhancement that will make a big UX difference! 🎨

---

**Version**: 1.0  
**Created**: November 3, 2025  
**Last Updated**: November 3, 2025  
**Status**: 🚀 READY