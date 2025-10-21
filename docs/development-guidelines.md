# DEVELOPMENT GUIDELINES FOR CLAUDE ASSISTANCE - V2.0

**Project**: Grocery & Recipe Manager iOS App  
**Last Updated**: October 20, 2025 (Added Code Documentation Standards)

---

## PROJECT CONTEXT

**GitHub Repository**: https://github.com/rfhayn/grocery-recipe-manager.git

**Project Goal**: iOS mobile application for grocery and recipe management with the following core features:
- Maintain list of "staple" grocery purchases with auto-population to weekly lists
- Build and maintain recipe catalog with ingredient tracking
- Track recipe usage count and last used date
- Tag recipes with types (e.g., "leftovers", "quick and easy")
- Push recipe ingredients to weekly grocery lists

**Current Status**: M1, M2, and M3 complete (59 hours total). Revolutionary grocery management with store-layout optimization, complete recipe integration, and structured quantity management operational.

---

## CRITICAL: Pre-Development Analysis Required

Before implementing ANY new features, Claude must:

### 1. COMPLETE CORE DATA AUDIT
- Search project knowledge for current Core Data entity definitions
- Document existing properties and their types (verify, never assume)
- Map all relationships and their inverse relationships
- Identify Codegen settings: Manual/None vs Class Definition
- **Check for existing parsing/service infrastructure before creating new ones**

### 2. LEVERAGE EXISTING PATTERNS
Your project has **proven successful patterns** - use them:

**Proven Service Architecture:**
- OptimizedRecipeDataService pattern for Core Data operations
- IngredientParsingService for text parsing (regex-based, sub-0.05s)
- IngredientTemplateService for normalization
- Performance tracking with @Published properties

**Proven UI Patterns:**
- @FetchRequest with predicate-based filtering
- SwiftUI navigation with sheets/NavigationStack
- Category-aware organization throughout
- Real-time search with native iOS patterns

**Proven Data Patterns:**
- Template normalization (IngredientTemplate prevents duplication)
- READ-ONLY template relationships
- Single-save transactions with rollback
- Sub-0.1s response time targets

### 3. ARCHITECTURE DECISION FRAMEWORK
**When extending existing functionality:**
- ✅ Enhance existing services rather than create parallel ones
- ✅ Follow established naming conventions
- ✅ Maintain performance targets (< 0.1s for queries, < 0.5s for complex operations)

**When adding new functionality:**
- Start with Core Data model if needed
- Build service layer following existing patterns
- Add UI last, reusing existing components where possible

---

## IMPLEMENTATION APPROACH

### STRUCTURED DEVELOPMENT PHASES

**Phase-Based Planning (Your Proven Method):**
1. **Document the plan** - Break into 45-90 minute phases
2. **Implement one phase** - Complete and test
3. **Validate before proceeding** - Ensure it works
4. **Move to next phase** - Build incrementally

**Phase Size Guidelines:**
- 45-60 min: Core Data model changes
- 60-90 min: Service layer implementation
- 90-120 min: Complex features with multiple integration points
- 30-45 min: UI polish and enhancement

### CORE DATA RULES

**Your Successful Patterns:**
1. **IngredientTemplate uses Class Definition codegen** - works perfectly
2. **Recipe/Ingredient use Manual/None** - proven stable
3. **Always add fetch indexes** for frequently queried fields
4. **Migration patterns** - you've successfully done IngredientTemplate.isStaple migration

**For Future Development:**
- When removing fields: Document what's being removed and why
- When adding fields: Add, test, then migrate data
- For new entities: Follow IngredientTemplate pattern (Class Definition codegen)
- Always verify build success after schema changes

### QUALITY GATES

**Stop and reassess if:**
- More than 5 build errors occur consecutively
- Spending > 20 minutes on a single compilation issue
- Breaking existing working features
- Performance degrades below targets (> 0.5s for any operation)

**Success indicators:**
- Build succeeds first try or with minor fixes
- All existing tests/features continue working
- New feature meets performance targets
- Code follows established patterns

---

## YOUR PROVEN DEVELOPMENT VELOCITY

**Actual Results:**
- M1: 32 hours over 12 days - **Professional grocery management**
- M2: 16.5 hours - **Complete recipe integration**
- M3: 10.5 hours - **Structured quantity management**
- **Total**: 59 hours with excellent accuracy

**Planning Accuracy:** Excellent - consistently within estimates

**Key Success Factors:**
- Phase-based planning with time estimates
- Incremental validation at each phase
- Learning notes documenting decisions and problems solved
- Leveraging existing working patterns

---

## COMPLEXITY ASSESSMENT FRAMEWORK

**Simple (1-2 hours):** 
- UI enhancement using existing components
- Service method additions to existing services
- Basic Core Data queries

**Moderate (3-6 hours):**
- New service creation following patterns
- Multi-view UI features
- Data migrations with existing patterns

**Complex (8-12 hours):**
- Core Data schema changes + migration + service layer + UI
- Multiple integrated services
- New architectural patterns

**Very Complex (16+ hours):**
- Complete feature with multiple subsystems
- Significant architectural changes
- Extensive integration work

---

## CODE DOCUMENTATION STANDARDS

### Purpose
All code produced should include descriptive comments that explain the intent and functionality, making it easier for developers to understand, maintain, and extend the codebase.

### Inline Comments

**When to Add Comments:**
- Complex logic or algorithms
- Non-obvious decisions or workarounds
- Integration points between systems
- State management or side effects
- Performance-critical sections

**Comment Style:**
```swift
// GOOD: Explains the "why" and provides context
// Check if user has consolidation opportunities before showing badge
// This prevents unnecessary UI updates when no merges are possible
if consolidationOpportunities > 0 {
    showBadge()
}

// BAD: Just repeats what the code says
// If consolidation opportunities is greater than zero
if consolidationOpportunities > 0 {
    showBadge()
}
```

**Examples of Good Inline Comments:**
```swift
// Parse ingredient text and extract structured quantity data
// Returns nil for unparseable quantities like "to taste"
let structured = parsingService.parseToStructured(text: trimmedText)

// Try to find existing template to avoid creating duplicates
// Exact match required (case-insensitive) for template linking
if selectedTemplate == nil {
    selectedTemplate = templateService.searchTemplates(query: parsed.name, limit: 1)
        .first(where: { $0.name?.lowercased() == parsed.name.lowercased() })
}

// Update consolidation analysis when items change
// Triggers badge update to show current merge opportunities
.onChange(of: listItems.count) { _, _ in
    updateConsolidationAnalysis()
}
```

### Function Documentation

**Function Header Comments:**
Every non-trivial function should have a comment block describing:
1. What the function does
2. Any side effects or state changes
3. Special conditions or edge cases (if applicable)

**Format:**
```swift
// Analyzes the current grocery list for consolidation opportunities
// Updates consolidationOpportunities count which drives badge display
// Called on view appear and whenever list items change
private func updateConsolidationAnalysis() {
    let analysis = mergeService.analyzeMergeOpportunities(for: weeklyList)
    consolidationAnalysis = analysis
    consolidationOpportunities = analysis.totalSavings
}
```

### Section Headers (MARK Comments)

**Use MARK comments to organize code:**
```swift
// MARK: - Service Initialization
// MARK: - View Components
// MARK: - User Actions
// MARK: - Helper Functions
// MARK: - Core Data Operations
// MARK: - M3 Phase 6: Consolidation Functions
```

**Pattern:**
- Use `// MARK: -` for major sections (adds separator line in Xcode)
- Use `// MARK:` for subsections
- Include phase/milestone info when relevant (e.g., "M3 Phase 6")

### State Management Comments

**Document @State, @StateObject, and @Published variables:**
```swift
// M3 PHASE 6: Consolidation service
// Analyzes grocery list items for merge opportunities
@StateObject private var mergeService: QuantityMergeService

// Number of duplicate items that can be consolidated
// Drives badge display in toolbar button
@State private var consolidationOpportunities: Int = 0
```

### SwiftUI View Comments

**Document view builders and modifiers:**
```swift
// Quick add section allows inline item entry without modal
// Includes autocomplete dropdown for template matching
private var quickAddSection: some View {
    VStack(alignment: .leading, spacing: 0) {
        // TextField with autocomplete trigger
        HStack(spacing: 8) {
            TextField("Quick add (e.g., \"2 cups flour\")", text: $quickAddText)
                .onChange(of: quickAddText) { oldValue, newValue in
                    // Trigger autocomplete after 2 characters typed
                    // This balances responsiveness with API efficiency
                    if newValue.count >= 2 {
                        autocompleteService.debouncedSearch(fullText: newValue)
                        showingAutocomplete = true
                    }
                }
        }
    }
}
```

### Performance-Related Comments

**Document performance considerations:**
```swift
// Use @FetchRequest instead of relationship for live progress updates
// Ensures progress bar updates immediately when items are completed
@FetchRequest private var listItemsFetch: FetchedResults<GroceryListItem>

// Lazy evaluation - only compute when user requests preview
// Prevents unnecessary merge analysis on every list change
private func showConsolidationPreview() {
    updateConsolidationAnalysis()
}
```

### Integration Point Comments

**Document connections between systems:**
```swift
// M3 PHASE 6: Consolidation sheet
// Integrates with QuantityMergeService from Phase 5
// Shows preview before executing merge operation
.sheet(isPresented: $showingConsolidation) {
    if let analysis = consolidationAnalysis {
        ConsolidationPreviewView(
            analysis: analysis,
            mergeService: mergeService,
            onComplete: {
                // Refresh analysis after merge completes
                // This updates badge with new opportunities (if any)
                updateConsolidationAnalysis()
            }
        )
    }
}
```

### What NOT to Comment

**Avoid these types of comments:**
```swift
// BAD: Obvious comments that just repeat the code
// Set name to parsed name
listItem.name = parsed.name

// BAD: Commented-out code (remove instead)
// let oldApproach = doSomethingOld()

// BAD: TODO comments without context or dates
// TODO: fix this

// GOOD: Actionable TODOs with context
// TODO (M4): Integrate with meal planning service
// TODO (Performance): Consider caching for lists > 100 items
```

### Comment Maintenance

**Keep comments up to date:**
- Update comments when code logic changes
- Remove obsolete comments during refactoring
- Add comments when adding complexity

### Documentation Hierarchy

**From most to least detailed:**
1. **Architecture Decision Records (ADRs)** - High-level architectural choices
2. **PRDs** - Feature requirements and design decisions
3. **Learning Notes** - Implementation journey and lessons learned
4. **Function Header Comments** - What functions do and why
5. **Inline Comments** - Explain specific logic and decisions
6. **Variable Names** - Self-documenting when possible

**Principle**: Code should be self-documenting through clear naming, with comments explaining the "why" behind non-obvious decisions.

---

## DOCUMENTATION REQUIREMENTS

### Core Documentation Structure

```
docs/
├── requirements.md              # High-level app requirements and goals
├── roadmap.md                   # Milestone sequence and completion tracking
├── project-index.md             # Navigation hub for all documentation
├── project-naming-standards.md  # File naming, entity naming, conventions
├── development-guidelines.md    # This file - how Claude should work
├── current-story.md             # Active milestone status and next steps
├── next-prompt.md              # Implementation guide for next session
├── prds/                       # Product Requirements Documents
│   └── milestone-X-feature.md
├── learning-notes/             # Problem-solving and implementation notes
│   └── XX-milestone-feature.md
└── architecture/               # Architecture Decision Records
    └── XXX-decision-title.md
```

### Documentation Maintenance by Activity

#### **After Each Development Session:**
1. **docs/learning-notes/** - Create/update implementation notes
2. **docs/current-story.md** - Update progress

#### **After Milestone Completion:**
1. **docs/roadmap.md** - Mark milestone complete
2. **docs/project-index.md** - Add links to new documents

#### **When Making Architectural Decisions:**
1. **docs/architecture/** - Create ADR
2. **Update docs/current-story.md** - Reference ADR

---

## COMMUNICATION PATTERNS

**What works well:**
- Detailed technical explanations when requested
- Step-by-step implementation plans
- Code artifacts with complete implementations
- Performance analysis and optimization suggestions

**Enhanced approach:**
- Flag when existing infrastructure can be leveraged vs creating new
- Call out when technical debt would be created
- Reference your own successful patterns from previous work
- Principal engineer perspective when architecture decisions needed

---

## REALITY CHECKS

**Your actual constraints:**
- Pre-production app - breaking changes acceptable now
- Single developer - optimize for long-term maintainability
- Learning-focused - balance between learning and pragmatism
- Quality over speed - but demonstrated good velocity (59 hours for 3 complete milestones)

**Red flags to challenge:**
- Proposals that contradict your proven patterns
- Dual-storage or backward compatibility for pre-production app
- Complex architecture before simple solution proven
- Any suggestion that would create technical debt

---

**Key Principle:** Always prioritize working features with clean architecture over perfect architecture that doesn't work. Build incrementally, validate continuously, and leverage proven patterns.