# DEVELOPMENT GUIDELINES FOR CLAUDE ASSISTANCE - V3.0

**Project**: forager iOS App  
**Last Updated**: October 23, 2025 (Enhanced with Session Startup Checklist & Naming Enforcement)  
**GitHub Repository**: https://github.com/rfhayn/grocery-recipe-manager.git

---

## 🎯 CRITICAL: MANDATORY REFERENCE DOCUMENTS

**Before ANY development work, Claude MUST review:**

1. **[session-startup-checklist.md](session-startup-checklist.md)** ← **START HERE EVERY SESSION**
2. **[project-naming-standards.md](project-naming-standards.md)** - M#.#.# naming hierarchy and status indicators
3. **[current-story.md](current-story.md)** - Current milestone status and active work
4. **[next-prompt.md](next-prompt.md)** - Implementation guide for current session

**These documents are mandatory context for ALL code and documentation work.**

**Failure to reference these documents breaks:**
- Naming consistency across the project
- Documentation continuity between sessions  
- Accurate progress tracking
- Efficient development workflow

---

## 📋 SESSION STARTUP CHECKLIST

**At the beginning of EVERY development session, Claude must:**

### **Phase 1: Context Loading (First 3 actions)**
1. ✅ **Read [session-startup-checklist.md](session-startup-checklist.md)** - Complete startup procedure
2. ✅ **Read [project-naming-standards.md](project-naming-standards.md)** - Verify M#.#.# naming conventions
3. ✅ **Read [current-story.md](current-story.md)** - Understand current milestone and phase

### **Phase 2: Implementation Preparation (If doing development work)**
4. ✅ **Read [next-prompt.md](next-prompt.md)** - Get implementation guidance for active work
5. ✅ **Search project knowledge for Core Data schema** - If working with data model
6. ✅ **Review relevant ADRs** - Check architecture decisions for similar work
7. ✅ **Search for existing services** - Find existing infrastructure before creating new

**This checklist ensures consistency and prevents duplicate work.**

---

## PROJECT CONTEXT

**Project Goal**: iOS mobile application for grocery and recipe management with the following core features:
- Maintain list of "staple" grocery purchases with auto-population to weekly lists
- Build and maintain recipe catalog with ingredient tracking
- Track recipe usage count and last used date
- Tag recipes with types (e.g., "leftovers", "quick and easy")
- Push recipe ingredients to weekly grocery lists

**Current Status**: M1, M2, M3, and M3.5 complete (67.5 hours total). Revolutionary grocery management with store-layout optimization, complete recipe integration, structured quantity management, and comprehensive validation testing operational.

---

## CRITICAL: Pre-Development Analysis Required

Before implementing ANY new features, Claude must **SEARCH PROJECT KNOWLEDGE** for:

### 1. NAMING COMPLIANCE CHECK
**Search query**: `current-story.md naming standards milestone`

**Verify:**
- [ ] Correct milestone/phase numbering (M#.#.# format from project-naming-standards.md)
- [ ] Proper status indicators (✅ COMPLETE | 🔄 ACTIVE | 🚀 READY | ⏳ PLANNED)
- [ ] Work is documented in current-story.md with correct naming
- [ ] All references use full identifier (e.g., "M4.1.2" not "Phase 2" or "Step 2")

**Action if non-compliant**: Stop and correct naming before proceeding with implementation.

### 2. COMPLETE CORE DATA AUDIT (if touching data model)
**Search queries**: 
- `Core Data entity [EntityName] properties relationships`
- `[EntityName] codegen fetch indexes`

**Document:**
- [ ] Existing properties and their exact types (verify, never assume)
- [ ] All relationships and their inverse relationships  
- [ ] Codegen settings: Manual/None vs Class Definition
- [ ] Fetch indexes for frequently queried fields
- [ ] Migration history and patterns used

**Reference**: See successful patterns in M3 Phase 3 data migration

### 3. CHECK FOR EXISTING INFRASTRUCTURE
**Search queries**: 
- `Service [functionality] implementation`
- `Parse [data type] service`
- `[Feature] pattern architecture`

**Verify:**
- [ ] No existing parsing/service infrastructure before creating new ones
- [ ] Review similar implementations in learning notes
- [ ] Identify reusable patterns from completed milestones (M1-M3.5)
- [ ] Check for existing UI components that can be reused

**Reference**: Your proven service patterns from M2.1 and M3 are excellent - reuse them!

---

## LEVERAGE EXISTING PATTERNS

Your project has **proven successful patterns** - use them:

### **Proven Service Architecture (M2.1, M3):**
- **OptimizedRecipeDataService** pattern for Core Data operations
- **IngredientParsingService** for text parsing (regex-based, sub-0.05s)
- **IngredientTemplateService** for normalization
- **QuantityMergeService** for intelligent consolidation
- **UnitConversionService** for measurement handling
- **Performance tracking** with @Published properties

### **Proven UI Patterns (M1, M2, M3):**
- **@FetchRequest** with predicate-based filtering for live data
- **SwiftUI navigation** with sheets/NavigationStack
- **Category-aware organization** throughout app
- **Real-time search** with native iOS patterns
- **Form validation** with unsaved changes detection
- **Accessibility compliance** throughout

### **Proven Data Patterns:**
- **Template normalization** (IngredientTemplate prevents duplication)
- **READ-ONLY template relationships** (no cascade deletes)
- **Single-save transactions** with rollback capability
- **Sub-0.1s response time** targets consistently achieved
- **Computed properties** for derived data (75+ added in M3.5)

### **Architecture Decision Framework**

**When extending existing functionality:**
- ✅ Enhance existing services rather than create parallel ones
- ✅ Follow established naming conventions from project-naming-standards.md
- ✅ Maintain performance targets (< 0.1s for queries, < 0.5s for complex operations)
- ✅ Reference similar patterns from completed milestones

**When adding new functionality:**
1. Start with Core Data model if needed (follow M3 patterns)
2. Build service layer following existing patterns (M2.1 architecture)
3. Add UI last, reusing existing components where possible (M1/M2 patterns)

---

## IMPLEMENTATION APPROACH

### STRUCTURED DEVELOPMENT PHASES

**Phase-Based Planning (Your Proven Method):**
1. **Document the plan** - Break into 45-90 minute phases with clear deliverables
2. **Implement one phase** - Complete and test thoroughly
3. **Validate before proceeding** - Ensure it works, meets performance targets
4. **Move to next phase** - Build incrementally with no regressions

**Phase Size Guidelines:**
- **45-60 min**: Core Data model changes (including impact analysis)
- **60-90 min**: Service layer implementation with tests
- **90-120 min**: Complex features with multiple integration points
- **30-45 min**: UI polish and enhancement

**Your Actual Success:** M1-M3.5 completed with 67.5 hours (consistently within estimates!)

---

## CORE DATA RULES

### **Your Successful Patterns:**

1. **Codegen Approach:**
   - ✅ **IngredientTemplate uses Class Definition** - works perfectly, generates code
   - ✅ **Recipe/Ingredient use Manual/None** - proven stable, manual extensions
   - ✅ **New entities**: Follow IngredientTemplate pattern (Class Definition recommended)

2. **Performance Optimization:**
   - ✅ **Always add fetch indexes** for frequently queried fields
   - ✅ **Use predicates** for filtering at database level
   - ✅ **Batch operations** for multiple changes
   - ✅ **Background contexts** for heavy operations

3. **Migration Patterns:**
   - ✅ **Successful M3 Phase 3** - IngredientTemplate.isStaple migration
   - ✅ **Data integrity maintained** through all migrations
   - ✅ **Migration service pattern** documented in learning notes

### **For Future Development:**

**When removing fields:**
- Document what's being removed and why (in ADR if significant)
- Check all code references (use Xcode search)
- Update related documentation
- Test migration path

**When adding fields:**
- Add to Core Data model first
- Test with sample data
- Then migrate existing data if needed
- Verify build success after schema changes

**When creating new entities:**
- Follow IngredientTemplate pattern (Class Definition codegen)
- Add fetch indexes for common queries
- Define all relationships with inverses
- Document in Core Data impact analysis (see ADR 007)

**Always verify build success after schema changes** - Zero tolerance for build breaks.

---

## QUALITY GATES

### **Stop and reassess if:**

- ❌ More than 5 build errors occur consecutively
- ❌ Spending > 20 minutes on a single compilation issue
- ❌ Breaking existing working features
- ❌ Performance degrades below targets (> 0.5s for any operation)
- ❌ **Using incorrect milestone/phase numbering** (not following project-naming-standards.md)
- ❌ **Creating documentation without updating project-index.md**
- ❌ **Making Core Data changes without impact analysis** (see ADR 007)
- ❌ **Creating new services without checking for existing ones**
- ❌ **Committing code without inline documentation** (see Code Documentation Standards)

### **Success indicators:**

- ✅ Build succeeds first try or with minor fixes (< 3 attempts)
- ✅ All existing tests/features continue working (no regressions)
- ✅ New feature meets performance targets consistently
- ✅ Code follows established patterns from M1-M3.5
- ✅ Documentation updated per checklist
- ✅ Naming conventions followed throughout

---

## YOUR PROVEN DEVELOPMENT VELOCITY

**Actual Results:**
- **M1**: 32 hours over 12 days - Professional grocery management ✅
- **M2**: 16.5 hours - Complete recipe integration ✅
- **M3**: 10.5 hours - Structured quantity management ✅
- **M3.5**: 8.5 hours - Foundation validation & testing ✅
- **Total**: 67.5 hours with **excellent planning accuracy** (< 10% variance)

**Key Success Factors:**
- Phase-based planning with time estimates
- Incremental validation at each phase
- Learning notes documenting decisions and problems solved
- Leveraging existing working patterns
- **Consistent naming conventions throughout**
- **Documentation updated after every session**

---

## COMPLEXITY ASSESSMENT FRAMEWORK

**Simple (1-2 hours):** 
- UI enhancement using existing components
- Service method additions to existing services
- Basic Core Data queries with existing patterns

**Moderate (3-6 hours):**
- New service creation following established patterns
- Multi-view UI features with navigation
- Data migrations using proven patterns (see M3 Phase 3)

**Complex (8-12 hours):**
- Core Data schema changes + migration + service layer + UI
- Multiple integrated services (see M3 Phase 5)
- New architectural patterns requiring ADR

**Very Complex (16+ hours):**
- Complete feature with multiple subsystems (see M2)
- Significant architectural changes
- Extensive integration work across app

**Use this framework** to set realistic time estimates and phase breakdowns.

---

## CODE DOCUMENTATION STANDARDS

### Documentation Hierarchy

**From most to least detailed:**
1. **Architecture Decision Records (ADRs)** - High-level architectural choices
2. **PRDs** - Feature requirements and design decisions
3. **Learning Notes** - Implementation journey and lessons learned
4. **Function Header Comments** - What functions do and why
5. **Inline Comments** - Explain specific logic and decisions
6. **Variable Names** - Self-documenting when possible

**Principle**: Code should be self-documenting through clear naming, with comments explaining the "why" behind non-obvious decisions.

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
- Review comments during code review (if team grows)

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
├── session-startup-checklist.md # Session startup procedure (NEW)
├── current-story.md             # Active milestone status and next steps
├── next-prompt.md              # Implementation guide for next session
├── prds/                       # Product Requirements Documents
│   └── milestone-X-feature.md
├── learning-notes/             # Problem-solving and implementation notes
│   └── XX-milestone-feature.md
└── architecture/               # Architecture Decision Records
    └── XXX-decision-title.md
```

### Documentation Compliance

**Every Development Session Must Update:**
1. **Code comments** - Following standards in this document
2. **current-story.md** - Progress on current phase with correct M#.#.# naming
3. **Learning notes** - Problems solved and decisions made

**After Each Phase Completion:**
1. **current-story.md** - Mark phase complete (✅), update metrics
2. **next-prompt.md** - Set up guidance for next phase
3. **Learning notes** - Comprehensive implementation notes with code examples

**After Milestone Completion:**
1. **roadmap.md** - Mark milestone complete with actual hours vs estimated
2. **project-index.md** - Add links to new documentation
3. **requirements.md** - Update if requirements evolved during milestone

**Failure to update documentation breaks project continuity and disrupts future sessions.**

### Documentation Maintenance by Activity

#### **After Each Development Session:**
1. **docs/learning-notes/** - Create/update implementation notes
   - Document problems encountered and solutions
   - Record performance metrics achieved
   - Note any deviations from plan and why
   - Include code examples for key decisions

2. **docs/current-story.md** - Update progress
   - Mark completed phases/tasks with ✅
   - Update "Current Development" section
   - Document achievement metrics
   - Update strategic milestone sequence if needed

#### **After Milestone Completion:**
1. **docs/roadmap.md** - Mark milestone complete with:
   - Actual hours spent vs estimated
   - Key achievements summary
   - Completion date
   - Link to detailed learning notes

2. **docs/project-index.md** - Add links to:
   - New learning notes
   - PRD if created
   - Any ADRs written
   - Update "Recent Activity" section

3. **docs/requirements.md** - Update if:
   - Core app requirements evolved
   - New user needs discovered
   - Feature scope changed

#### **When Making Architectural Decisions:**
1. **docs/architecture/** - Create ADR when:
   - Choosing between competing approaches
   - Making decisions with long-term impact
   - Establishing patterns for future features
   - Resolving technical debt or complexity

2. **Update docs/current-story.md** - Reference ADR in relevant sections

#### **For New Features (Before Starting):**
1. **docs/prds/** - Create PRD for complex features (6+ hours)
   - Problem statement and user value
   - Functional and non-functional requirements
   - Technical architecture
   - Success metrics

2. **docs/next-prompt.md** - Create implementation guide
   - Copy-paste ready prompt for next session
   - Phase breakdown with time estimates
   - Technical requirements and integration points

---

## COMMUNICATION PATTERNS

**What works well:**
- Detailed technical explanations when requested
- Step-by-step implementation plans with phase breakdowns
- Code artifacts with complete implementations
- Performance analysis and optimization suggestions
- **Explicit references to existing patterns** from M1-M3.5

**Enhanced approach:**
- Flag when existing infrastructure can be leveraged vs creating new
- Call out when technical debt would be created
- Reference your own successful patterns from previous milestones
- Principal engineer perspective when architecture decisions needed
- **Always mention relevant learning notes** when suggesting approaches

---

## REALITY CHECKS

**Your actual constraints:**
- Pre-production app - breaking changes acceptable now (but avoid unnecessary breaks)
- Single developer - optimize for long-term maintainability
- Learning-focused - balance between learning and pragmatism
- Quality over speed - but demonstrated **excellent velocity** (67.5 hours for 4 complete milestones)

**Red flags to challenge:**
- ❌ Proposals that contradict your proven patterns (M1-M3.5)
- ❌ Dual-storage or backward compatibility for pre-production app
- ❌ Complex architecture before simple solution proven
- ❌ Any suggestion that would create technical debt
- ❌ **Creating new infrastructure when existing services can be extended**
- ❌ **Ignoring project-naming-standards.md in any documentation**

---

## KEY PRINCIPLES

1. **Always prioritize working features with clean architecture** over perfect architecture that doesn't work
2. **Build incrementally, validate continuously**, and leverage proven patterns
3. **Follow session-startup-checklist.md at the beginning of every session**
4. **Use project-naming-standards.md for all milestone/phase/task references**
5. **Document as you go** - don't defer documentation to "later"
6. **Search before creating** - check for existing services, patterns, components
7. **Performance matters** - maintain < 0.5s targets for all operations
8. **Zero regressions** - never break existing working features

---

**Last Updated**: October 23, 2025  
**Version**: 3.0 - Enhanced with Session Startup Checklist & Naming Enforcement  
**Next Review**: After M4 completion