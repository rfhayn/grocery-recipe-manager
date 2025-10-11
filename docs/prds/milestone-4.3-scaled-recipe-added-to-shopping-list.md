# Product Requirements Document: M4.3 - Scaled Recipe to Shopping List Integration

**Document Version**: 1.0  
**Created**: October 11, 2025  
**Priority**: MEDIUM - Nice-to-have enhancement for complete scaling workflow  
**Estimated Duration**: 1.5-2 hours  
**Milestone**: M4.3 (Enhanced Grocery Integration)

---

## Executive Summary

Complete the recipe scaling workflow by enabling users to add scaled recipe quantities directly to shopping lists. This feature bridges the gap between recipe scaling preview (M3 Phase 4) and grocery list generation, particularly valuable for meal planning and party planning scenarios where recipes need portion adjustments.

---

## Problem Statement

### Current User Pain Points
- Users can preview scaled recipes but cannot act on the scaled quantities
- Manual calculation and entry required to add scaled ingredients to lists
- Workflow breaks: preview scaling → close sheet → manually add items
- No way to preserve scaled quantities for meal planning events
- Party planning requires mental math while shopping

### Business Impact
- Incomplete user workflow reduces scaling feature value
- Missed opportunity to demonstrate recipe-to-list intelligence
- Users may abandon scaling feature due to lack of actionability
- Competitive gap compared to apps with complete scaling workflows

### User Scenarios
**Primary Use Case - Party Planning**: "I'm hosting 40 people and need to scale my recipe 2x. I want to add all the scaled quantities to my party shopping list without manual calculation."

**Secondary Use Cases**:
- **Meal Prep**: "I'm batch cooking 4x lasagna for the week and need scaled quantities on my Sunday shopping list"
- **Family Gatherings**: "Scaling up holiday recipes for extended family dinner"
- **Meal Planning Integration**: "Planning meals for different household sizes (kids visiting, guests staying)"

---

## Solution Overview

### Core Enhancement
Add "Add to List" button to recipe scaling sheet that passes scaled quantities to existing AddIngredientsToListView, reusing proven list selection and category assignment flows.

### Design Principles
- **Reuse Existing UI**: Leverage AddIngredientsToListView (proven in M2 Phase 2)
- **Non-Destructive**: Don't modify original recipe, create temporary scaled ingredients
- **Simple Integration**: Minimal new code, maximum reuse of established patterns
- **Optional Feature**: Nice-to-have enhancement, not critical path functionality
- **Meal Planning Bridge**: Foundation for M4 meal planning with scaled recipe notes

---

## Detailed Requirements

### Functional Requirements

#### FR-1: Add to List Button in Scaling Sheet
**Description**: Add action button to recipe scaling UI enabling direct list addition
**Acceptance Criteria**:
- Button appears at bottom of scaling sheet (alongside Cancel/Done)
- Button labeled "Add to List" with shopping cart icon
- Button enabled when scale factor > 0 and recipe has ingredients
- Tapping button opens list selection sheet
- Original scaling sheet remains in background (not dismissed)

#### FR-2: Scaled Ingredient Generation
**Description**: Generate temporary ingredient objects with scaled quantities
**Acceptance Criteria**:
- Use RecipeScalingService.scale() to get scaled quantities
- Create temporary Ingredient objects (not persisted to recipe)
- Preserve ingredient template relationships for category assignment
- Include scaling note for unparseable ingredients ("adjust to taste for X servings")
- Maintain original ingredient order and category grouping

#### FR-3: List Selection Integration
**Description**: Reuse AddIngredientsToListView with scaled ingredients
**Acceptance Criteria**:
- Present AddIngredientsToListView with scaled ingredients
- User can select existing list or create new list
- Category assignment flow works for scaled ingredients
- Quantity consolidation applies to scaled amounts (if M3 Phase 5 complete)
- Success confirmation shows count of items added

#### FR-4: Navigation Flow
**Description**: Proper sheet presentation and dismissal behavior
**Acceptance Criteria**:
- List selection presented as sheet over scaling sheet
- Cancel in list selection returns to scaling sheet
- Done in list selection dismisses both sheets, returns to recipe detail
- Scaling sheet preserves state if user cancels list selection
- Clear visual hierarchy (list selection on top, scaling behind)

#### FR-5: Meal Planning Note (Future-Ready)
**Description**: Add scaled recipe indicator for meal planning integration
**Acceptance Criteria**:
- When ingredients added via scaling, include scale factor in metadata
- Format: "Recipe scaled to X servings (Yx)" in notes field
- Note visible in grocery list item details (if implemented)
- Foundation for M4 meal planning recipe tracking
- Optional feature - graceful if notes not displayed

---

### Non-Functional Requirements

#### NFR-1: Performance
- Complete workflow (scaling + list selection + addition) < 1s total
- Ingredient generation from scaled recipe < 0.1s
- No UI lag during sheet transitions
- Memory efficient temporary ingredient creation
- Target: Same performance as non-scaled recipe addition

#### NFR-2: Code Quality
- Reuse RecipeScalingService (M3 Phase 4) without modification
- Reuse AddIngredientsToListView (M2 Phase 2) without changes
- Minimal new code (< 100 lines total)
- Follow existing SwiftUI sheet presentation patterns
- Maintain RecipeScalingView code organization

#### NFR-3: User Experience
- Intuitive button placement and labeling
- Smooth sheet transitions without flicker
- Clear feedback when items added to list
- Consistent with existing add-to-list workflows
- No learning curve for users familiar with recipe addition

#### NFR-4: Data Integrity
- Original recipe never modified
- Scaled ingredients temporary (not saved to Core Data)
- Each "Add to List" creates fresh scaled ingredients
- No side effects on scaling preview calculations
- Transaction safety for list additions

---

## User Stories

### Epic 1: Party Planning Workflow

**US-SRL-1**: As a party host, I want to scale my recipe and add the scaled ingredients to my party shopping list so that I can efficiently shop for the right quantities
**Acceptance Criteria**:
- Scale recipe to desired serving size (e.g., 2x for 48 servings)
- Tap "Add to List" button in scaling sheet
- Select "Party Shopping" list from list selection
- See all scaled quantities added to party list
- Return to recipe detail after successful addition

**US-SRL-2**: As a meal planner, I want to add scaled recipes to different lists for different events so that I can organize shopping by occasion
**Acceptance Criteria**:
- Scale recipe once, add to multiple lists if desired
- Can reopen scaling sheet and change scale factor
- Can add same recipe at different scales to different lists
- Each list addition uses current scale factor

### Epic 2: Batch Cooking Workflow

**US-SRL-3**: As a meal prepper, I want to scale recipes for batch cooking and add scaled quantities to my weekly shopping list
**Acceptance Criteria**:
- Scale recipe to large quantity (e.g., 4x)
- Add scaled ingredients to "Sunday Shopping" list
- Scaled quantities combine with other recipe quantities (if M3 Phase 5 complete)
- Can see which recipe contributed each ingredient

### Epic 3: Meal Planning Integration (Future-Ready)

**US-SRL-4**: As a meal planner, I want scaled recipes to include scale information so I remember which recipes I adjusted
**Acceptance Criteria**:
- Scaled recipe ingredients include scale factor note
- Note format: "Scaled to 48 servings (2x)"
- Note helps during shopping and cooking
- Foundation for meal planning recipe tracking (M4.2)

---

## User Experience Flow

### Primary Flow: Scale and Add to List

1. **User opens recipe detail view**
   - Recipe shows 24 servings (original)
   - User taps menu → "Scale Recipe"

2. **Scaling sheet opens**
   - Shows current 24 servings
   - Slider at 1x position
   - Preview shows original quantities
   - Cancel, Done, and "Add to List" buttons visible

3. **User adjusts scale factor**
   - Drags slider to 2x
   - Scaled servings update: 24 → 48
   - Ingredient preview updates in real-time
   - "2 cups flour" → "4 cups flour"
   - Summary: "8 ingredients auto-scaled"

4. **User taps "Add to List"**
   - List selection sheet presents over scaling sheet
   - Shows existing lists + "New List" option
   - Scaling sheet remains visible behind (dimmed)

5. **User selects list**
   - Taps "Party Shopping" list
   - Category assignment modal may appear (if uncategorized ingredients)
   - Success feedback: "8 ingredients added to Party Shopping"
   - Both sheets dismiss, returns to recipe detail

### Alternate Flow: Cancel List Selection

1-3. **Same as primary flow**

4. **User taps "Add to List"**
   - List selection sheet presents

5. **User taps "Cancel"**
   - List selection sheet dismisses
   - Returns to scaling sheet (still at 2x)
   - User can continue adjusting or tap Done

### Edge Case Flow: Multiple Additions

1-5. **Complete primary flow** (add to Party Shopping)

6. **User reopens scaling sheet**
   - Returns to 1x scale factor (reset)
   - User can scale again and add to different list

---

## Technical Implementation

### Architecture Overview

```
RecipeDetailView
    ↓
RecipeScalingView (M3 Phase 4 - Existing)
    ↓ [Add to List Button - NEW]
AddIngredientsToListView (M2 Phase 2 - Existing)
    ↓
GroceryListDetailView (M1 - Existing)
```

### Service Integration

**Existing Services Used**:
- ✅ RecipeScalingService (M3 Phase 4)
- ✅ AddIngredientsToListView presentation
- ✅ Category assignment flow
- ✅ IngredientTemplateService for normalization

**New Integration Code** (~50 lines):
```swift
// In RecipeScalingView.swift

@State private var showingAddToListSheet = false
@State private var scaledIngredientsForList: [Ingredient] = []

// Add button to scaling sheet
Button {
    prepareScaledIngredientsForList()
} label: {
    Label("Add to List", systemImage: "cart.badge.plus")
}

// Generate temporary ingredients
private func prepareScaledIngredientsForList() {
    let scaled = scalingService.scale(
        recipe: recipe,
        scaleFactor: scaleFactor
    )
    
    scaledIngredientsForList = createTemporaryIngredients(from: scaled)
    showingAddToListSheet = true
}

// Sheet presentation
.sheet(isPresented: $showingAddToListSheet) {
    AddIngredientsToListView(
        recipe: recipe,
        preselectedIngredients: scaledIngredientsForList
    )
}
```

### Data Flow

**Step 1: Scale Calculation**
```
User adjusts slider → RecipeScalingService.scale()
→ ScaledRecipe with scaled quantities
→ Display in preview
```

**Step 2: Add to List Action**
```
User taps "Add to List" → Create temporary Ingredient objects
→ Pass to AddIngredientsToListView
→ Existing list selection flow
→ Category assignment (if needed)
→ Add to selected list
```

**Step 3: List Addition**
```
AddIngredientsToListView completes
→ GroceryListItems created with scaled quantities
→ Success feedback shown
→ Sheets dismiss → Recipe detail view
```

### Core Data Considerations

**Temporary Ingredient Creation**:
- Create Ingredient objects in memory only
- Set displayText to scaled quantities
- Link to original ingredientTemplate (read-only)
- **Not persisted** - discarded after list addition
- Each "Add to List" creates fresh temporary objects

**List Item Creation**:
- GroceryListItems created normally via AddIngredientsToListView
- Use scaled displayText for quantity display
- Standard category assignment flow applies
- Consolidation logic applies (if M3 Phase 5 complete)

---

## UI Specifications

### Scaling Sheet Layout (Updated)

```
┌─────────────────────────────────────┐
│ ← Scale Recipe                   × │
├─────────────────────────────────────┤
│                                     │
│  Original: 24 servings              │
│  Scaled: 48 servings                │
│                                     │
│  Scale Factor: 2x                   │
│  ┌───────────○─────────────┐        │
│  0.25x            2x      4x        │
│                                     │
│  ✓ 8 ingredients auto-scaled        │
│                                     │
│  [Scaled Ingredient Preview...]     │
│  • 4 cups all-purpose flour         │
│  • 2 cups granulated sugar          │
│  • 4 large eggs                     │
│  ...                                │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ┌──────┐  ┌──────┐  ┌───────────┐ │
│  │Cancel│  │ Done │  │🛒Add to List│ │ ← NEW
│  └──────┘  └──────┘  └───────────┘ │
└─────────────────────────────────────┘
```

### Button Styling

**Add to List Button**:
- Icon: `cart.badge.plus` (shopping cart with plus)
- Color: Green (matches existing "Add to List" buttons)
- Style: Prominent button
- Position: Bottom right (after Cancel/Done)
- Accessibility: "Add scaled recipe to shopping list"

---

## Dependencies

### Prerequisites (Must Be Complete)
- ✅ M3 Phase 4: Recipe Scaling Service
- ✅ M2 Phase 2: AddIngredientsToListView
- ✅ M1: Grocery list management
- ✅ M2: Category assignment flow

### Integration Points
- **RecipeScalingService**: Provides scaled quantities
- **AddIngredientsToListView**: Handles list selection
- **IngredientTemplateService**: Template normalization
- **Category Assignment**: May trigger for uncategorized ingredients

### Future Enhancements (Out of Scope)
- M4.2: Meal planning with scaled recipe notes
- M3 Phase 5: Quantity consolidation (works if present, not required)
- M7: Analytics on scaling usage patterns

---

## Success Criteria

### Functional Criteria
- [ ] "Add to List" button appears in scaling sheet
- [ ] Button opens list selection with scaled quantities
- [ ] Scaled ingredients display correct quantities in list
- [ ] Parseable quantities scaled mathematically (2x: "2 cups" → "4 cups")
- [ ] Unparseable quantities include adjustment note
- [ ] Category assignment works for scaled ingredients
- [ ] Cancel returns to scaling sheet without adding items
- [ ] Done dismisses both sheets after successful addition

### User Experience Criteria
- [ ] Button placement intuitive (no user confusion)
- [ ] Sheet transitions smooth (no flicker or lag)
- [ ] Clear success feedback after addition
- [ ] Consistent with existing add-to-list workflows
- [ ] No additional steps vs. non-scaled addition

### Performance Criteria
- [ ] Complete workflow < 1s (scaling → selection → addition)
- [ ] Ingredient generation < 0.1s
- [ ] No memory leaks from temporary ingredients
- [ ] Sheet animations smooth (60fps)

### Technical Criteria
- [ ] Code reuse >80% (existing services and views)
- [ ] No modifications to RecipeScalingService
- [ ] No modifications to AddIngredientsToListView
- [ ] Clean separation of concerns
- [ ] Follows existing SwiftUI patterns

---

## Risk Analysis

### Technical Risks

**Risk**: Temporary ingredient creation causes memory issues
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**: 
- Temporary ingredients discarded after list addition
- Small objects (~8 ingredients typical)
- iOS handles short-lived objects efficiently

**Risk**: Sheet presentation conflicts or visual glitches
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Follow SwiftUI sheet presentation best practices
- Test on multiple iOS versions
- Use existing proven sheet patterns

**Risk**: Category assignment breaks with temporary ingredients
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Temporary ingredients link to real templates
- Category assignment uses template relationships
- Test category assignment flow thoroughly

### User Experience Risks

**Risk**: Users confused by multiple "Add to List" entry points
**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**:
- Clear button labeling in context
- Consistent visual design across entry points
- Help text if needed

**Risk**: Low feature adoption due to niche use case
**Likelihood**: High  
**Impact**: Low  
**Mitigation**:
- Expected - this is a "nice-to-have" feature
- Low development cost (1.5-2 hours)
- Adds value for specific scenarios (parties, batch cooking)
- No harm if unused

### Business Risks

**Risk**: Feature adds complexity without sufficient value
**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Minimal code addition (< 100 lines)
- High code reuse (>80%)
- Easy to remove if needed
- Completes logical workflow

---

## Success Metrics

### Feature Adoption (Optional - Nice-to-Have)
- Scaling feature usage: Track baseline first
- "Add to List" from scaling: 10-20% of scaling sessions
- Expected low usage - niche but valuable scenarios
- Success if >5% of scaling sessions use feature

### User Engagement (Secondary)
- Party/event shopping list creation
- Batch cooking grocery list patterns
- Meal planning with scaled recipes (post-M4.2)

### Technical Performance (Primary)
- Workflow completion time < 1s: 100% of attempts
- Zero crashes during workflow: 100% reliability
- Memory usage stable: No leaks detected
- Sheet transitions smooth: 60fps maintained

### User Satisfaction (Qualitative)
- Feature "feels natural" to users who discover it
- No confusion about button purpose
- Smooth integration with existing workflows
- Positive feedback on party planning scenarios

---

## Implementation Plan

### Phase 1: Core Integration (60 minutes)

**Tasks**:
1. Add "Add to List" button to RecipeScalingView (15 min)
2. Implement temporary ingredient generation (20 min)
3. Wire up AddIngredientsToListView presentation (15 min)
4. Test basic flow (10 min)

**Validation**:
- Button appears and is clickable
- List selection sheet presents correctly
- Can add scaled ingredients to list
- Sheets dismiss properly

### Phase 2: Edge Cases & Polish (30-45 minutes)

**Tasks**:
1. Handle unparseable ingredients gracefully (10 min)
2. Test category assignment with scaled ingredients (10 min)
3. Verify cancel/done navigation flows (10 min)
4. Add scaling note metadata (future-ready) (10-15 min)

**Validation**:
- All edge cases handled
- Navigation flows work correctly
- No visual glitches
- Performance targets met

### Phase 3: Testing & Documentation (15 minutes)

**Tasks**:
1. Test with various scale factors (5 min)
2. Test with different recipe sizes (5 min)
3. Update learning notes (5 min)

**Validation**:
- All acceptance criteria met
- Documentation complete
- Ready for M4.3 completion sign-off

---

## Acceptance Criteria

### Must Have (Required for Sign-Off)
- [ ] Add to List button functional in scaling sheet
- [ ] Scaled quantities correctly added to grocery lists
- [ ] Sheet navigation works without errors
- [ ] Performance < 1s for complete workflow
- [ ] Category assignment functional for scaled ingredients
- [ ] Cancel and Done buttons work correctly
- [ ] No crashes or memory leaks
- [ ] Code follows existing patterns

### Should Have (Preferred)
- [ ] Success feedback after addition
- [ ] Scaling note metadata for meal planning
- [ ] Works with quantity consolidation (if M3 Phase 5 done)
- [ ] Smooth sheet transitions (60fps)

### Nice to Have (Optional)
- [ ] Multiple additions from same scaling session
- [ ] Visual indicator of scale factor in list item
- [ ] Analytics tracking for feature usage

---

## Related Documentation

### Prerequisites
- **M3 Phase 4**: `docs/learning-notes/XX-m3-phase4-recipe-scaling.md` (when complete)
- **M2 Phase 2 Story 3a**: `docs/prds/complete/milestone-2-phase-2-story-3a-enhanced-add-to-ingredient-list.md`

### Integration Points
- **RecipeScalingView**: `GroceryRecipeManager/RecipeScalingView.swift` (M3 Phase 4)
- **RecipeScalingService**: `Services/RecipeScalingService.swift` (M3 Phase 4)
- **AddIngredientsToListView**: `GroceryRecipeManager/AddIngredientsToListView.swift` (M2)

### Future Enhancements
- **M4.2 Meal Planning**: Will leverage scaled recipe metadata
- **M7 Analytics**: May track scaling and party planning patterns

---

## Appendix A: Alternative Approaches Considered

### Alternative 1: Modify Original Recipe
**Approach**: Save scaled quantities back to recipe
**Rejected Because**:
- Destructive operation on original recipe
- User loses original quantities
- Complex undo/revert logic needed
- Against non-destructive scaling principle

### Alternative 2: Create "Scaled Recipe" Copy
**Approach**: Save scaled version as new recipe
**Rejected Because**:
- Database bloat with duplicate recipes
- Recipe management complexity
- User confusion about which recipe to use
- Over-engineering for niche feature

### Alternative 3: Separate Scaling + Addition Flows
**Approach**: Keep scaling preview-only, add scaling to AddIngredientsToListView
**Rejected Because**:
- Fragments scaling functionality
- Duplicate scaling UI in multiple places
- More complex than single integration point
- Poor user experience (multiple steps)

### Why Our Solution Is Better
- ✅ Completes logical workflow in one place
- ✅ Minimal new code (< 100 lines)
- ✅ High reuse of existing services
- ✅ Non-destructive to original recipes
- ✅ Natural user experience

---

## Appendix B: Development Checklist

### Before Starting
- [ ] M3 Phase 4 (Recipe Scaling) complete and tested
- [ ] M4.1-4.2 (Meal Planning Core) complete
- [ ] 1.5-2 hours available for implementation
- [ ] RecipeScalingView code reviewed and understood

### During Implementation
- [ ] Create feature branch: `feature/m4.3-scaled-recipe-to-list`
- [ ] Add "Add to List" button to RecipeScalingView
- [ ] Implement temporary ingredient generation
- [ ] Wire up sheet presentation
- [ ] Test basic flow
- [ ] Handle edge cases
- [ ] Add scaling note metadata
- [ ] Test performance
- [ ] Update learning notes

### After Implementation
- [ ] All acceptance criteria met
- [ ] No new warnings or errors
- [ ] Performance targets achieved
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Merge to main branch
- [ ] Mark M4.3 complete in roadmap

---

**Document Status**: ✅ **READY FOR IMPLEMENTATION**  
**Next Action**: Complete M3 Phases 5-6, then M4.1-4.2, then implement this feature  
**Implementation Window**: During M4.3 (Enhanced Grocery Integration)  
**Estimated Completion**: After M4.2 complete