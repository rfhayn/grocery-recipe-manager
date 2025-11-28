# CLAUDE PROJECT INSTRUCTIONS - GROCERY & RECIPE MANAGER

> **🚀 ACTIVE WORK: M5.0 - Complete App Renaming & TestFlight Deployment**
> 
> **Current Phase**: M5.0.1 Name Selection (update as you progress)
> **Status**: Systematically renaming from "GroceryRecipeManager" to "Forager"
> 
> **Key M5.0 Documentation**:
> - [M5.0 PRD](docs/prds/M5.0-APP-RENAMING-TESTFLIGHT-PRD.md) - Complete plan
> - [M5.0 Next-Prompt](docs/M5.0-NEXT-PROMPT.md) - Step-by-step execution
> - [Current Story](docs/current-story.md) - Current progress
> 
> **⚠️ IMPORTANT**: References to "GroceryRecipeManager" below are actively being updated.
> Follow M5.0 documentation for current execution. Full instruction update at M5.0.4 completion.

**Project**: Grocery & Recipe Manager ⚠️ *Being renamed to "Forager"*  
**Version**: 3.0 - M5.0 Transition  
**Last Updated**: November 28, 2025

---

## 🚨 MANDATORY: START EVERY SESSION HERE

### **Session Startup Sequence (Non-Negotiable)**

**Claude MUST complete these actions at the start of EVERY session:**

1. **Search project knowledge**: `session-startup-checklist.md`
   - Read complete 7-point checklist
   - Follow Phase 1 (context loading) for ALL sessions
   - Follow Phase 2 (implementation prep) for development sessions

2. **Search project knowledge**: `project-naming-standards.md`
   - Verify current M#.#.# format (e.g., M4.1.2)
   - Confirm status indicators (✅ COMPLETE | 🔄 ACTIVE | 🚀 READY | ⏳ PLANNED)
   - Review quick reference card at top

3. **Search project knowledge**: `current-story.md`
   - Identify current active milestone and phase
   - Note what's 🔄 ACTIVE right now
   - Review recently completed work ✅

4. **If doing development work, search**: `next-prompt.md`
   - Get specific implementation guidance
   - Review phase breakdown and time estimates
   - Check technical requirements and acceptance criteria

**Why this matters**: These 4 searches take 5-10 minutes but prevent 6-14 hours of rework from duplicate services, naming inconsistencies, or architecture conflicts.

---

## 📋 PROJECT OVERVIEW

### **What We're Building**
iOS mobile app for grocery and recipe management with:
- Staple grocery items with auto-population to weekly lists
- Recipe catalog with ingredient tracking and usage analytics
- Structured quantity management with intelligent consolidation
- Recipe-to-grocery integration with smart automation
- Store-layout optimized grocery lists

### **Current Status**
- **Completed**: M1-M3.5 (67.5 hours total)
- **Active**: M4 (Meal Planning & Enhanced Grocery Integration)
- **Planning Accuracy**: 88% (consistently within estimates)
- **Build Success**: 100% (zero breaking changes)

### **Technology Stack**
- Swift + SwiftUI for UI
- Core Data for persistence
- iOS 18.5+ target
- Xcode project structure
- Proven service architecture patterns

---

## 🎯 CRITICAL RULES (Zero Tolerance)

### **1. Naming Convention (MANDATORY)**

**Always use M#.#.# format:**
```
✅ CORRECT: "M4.1.2" or "M4.1.2: Core Settings Service"
❌ WRONG: "Phase 2", "Step 2", "Story 1.2.3"
```

**Status indicators:**
- ✅ **COMPLETE** - Fully implemented and validated
- 🔄 **ACTIVE** - Currently being worked on
- 🚀 **READY** - Next in queue, ready to start
- ⏳ **PLANNED** - Future work, not ready yet

**Non-compliance action**: STOP immediately, search `project-naming-standards.md`, correct all instances across all documentation.

### **2. Documentation Updates (MANDATORY)**

**After EVERY development session:**
- Update `current-story.md` with progress (use correct M#.#.# naming)
- Create/update learning notes in `docs/learning-notes/`
- Add inline code comments explaining "why" not "what"

**After EVERY phase completion:**
- Mark phase ✅ COMPLETE in `current-story.md` with actual hours
- Update `next-prompt.md` for next phase
- Update `project-index.md` Recent Activity section

**After EVERY milestone completion:**
- Update `roadmap.md` with completion summary
- Update `project-index.md` with links to new docs
- Create comprehensive learning note

**Failure to update documentation**: Breaks project continuity and future session efficiency.

### **3. Pre-Development Analysis (MANDATORY)**

**Before implementing ANY feature, search project knowledge for:**

**A. Naming Compliance:**
```
Search: "current-story.md naming standards milestone"
Verify: Correct M#.#.# format and status indicators
```

**B. Core Data Schema (if touching data model):**
```
Search: "Core Data entity [EntityName] properties relationships"
Document: Properties, types, relationships, codegen settings, fetch indexes
```

**C. Existing Services (before creating new ones):**
```
Search: "Service [functionality] implementation"
Check: Can existing service be extended instead of creating new?
```

**Why this matters**: M1-M3.5 have established proven patterns - always leverage them instead of reinventing.

---

## 🏗️ PROVEN ARCHITECTURE PATTERNS

### **Service Layer (Reuse These)**
```
OptimizedRecipeDataService    - Core Data operations
IngredientParsingService       - Text parsing (regex, <0.05s)
IngredientTemplateService      - Normalization & deduplication
QuantityMergeService          - Intelligent consolidation
UnitConversionService         - Measurement handling
RecipeScalingService          - Recipe quantity scaling
```

**Before creating a new service**: Search for existing services that can be extended.

### **UI Patterns (Reuse These)**
```
@FetchRequest                 - Live data updates from Core Data
SwiftUI sheets/NavigationStack - Standard navigation
Category-aware organization    - Consistent throughout app
Real-time search              - Native iOS patterns
Form validation               - Unsaved changes detection
```

### **Data Patterns (Follow These)**
```
Template normalization        - IngredientTemplate prevents duplication
READ-ONLY relationships       - No cascade deletes on templates
Single-save transactions      - With rollback capability
Computed properties           - 75+ added in M3.5 for data integrity
Performance targets           - <0.1s queries, <0.5s complex operations
```

---

## 🔧 DEVELOPMENT APPROACH

### **Phase-Based Planning (Your Proven Method)**
1. Document the plan - Break into 45-90 minute phases
2. Implement one phase - Complete and test
3. Validate before proceeding - Ensure it works
4. Move to next phase - Build incrementally

**Phase Size Guidelines:**
- 45-60 min: Core Data model changes
- 60-90 min: Service layer implementation
- 90-120 min: Complex features with multiple integration points
- 30-45 min: UI polish and enhancement

### **Quality Gates (Stop if...)**
- ❌ More than 5 build errors consecutively
- ❌ Spending > 20 minutes on single compilation issue
- ❌ Breaking existing working features
- ❌ Performance degrades below targets (>0.5s)
- ❌ Using incorrect M#.#.# naming
- ❌ Creating documentation without updating project-index.md
- ❌ Making Core Data changes without impact analysis
- ❌ Creating new services without checking for existing ones

### **Success Indicators (Continue if...)**
- ✅ Build succeeds first try or with minor fixes
- ✅ All existing tests/features continue working
- ✅ New feature meets performance targets
- ✅ Code follows established patterns
- ✅ Documentation updated per checklist

---

## 📝 CODE DOCUMENTATION STANDARDS

### **Function Header Comments (Required)**
```swift
// Analyzes the current grocery list for consolidation opportunities
// Updates consolidationOpportunities count which drives badge display
// Called on view appear and whenever list items change
private func updateConsolidationAnalysis() {
    // Implementation
}
```

### **Section Organization (Use MARK)**
```swift
// MARK: - Service Initialization
// MARK: - View Components  
// MARK: - User Actions
// MARK: - M4.1: Settings Functions
```

### **State Management Comments (Required)**
```swift
// M4.1: User preferences service
// Manages meal planning settings and preferences
@StateObject private var preferencesService: UserPreferencesService

// Number of days in meal plan (3-14)
// User-configurable, defaults to 7
@State private var planDuration: Int = 7
```

### **What NOT to Comment**
```swift
// ❌ BAD: Obvious comments that repeat code
// Set name to parsed name
listItem.name = parsed.name

// ✅ GOOD: Explains why and provides context
// Use parsed name to ensure consistency with template matching
// This enables fuzzy search to work correctly
listItem.name = parsed.name
```

---

## 🗂️ CORE DATA RULES

### **Successful Patterns (Follow These)**

**Codegen Approach:**
- ✅ IngredientTemplate uses **Class Definition** - generates code automatically
- ✅ Recipe/Ingredient use **Manual/None** - manual extensions for custom logic
- ✅ New entities: Default to **Class Definition** unless need custom extensions

**Performance:**
- ✅ Always add **fetch indexes** for frequently queried fields
- ✅ Use **predicates** for filtering at database level
- ✅ **Batch operations** for multiple changes
- ✅ **Background contexts** for heavy operations

**Migration:**
- ✅ Follow M3 Phase 3 pattern (successful isStaple migration)
- ✅ Test with sample data before migrating production
- ✅ Document migration in learning notes
- ✅ Verify build success after schema changes

### **Before Changing Core Data Schema**

1. **Search project knowledge**: `core-data-impact-analysis.md template`
2. **Search project knowledge**: `ADR 007 core-data-change-process`
3. **Document impact**: Which entities, properties, relationships affected
4. **Plan migration**: How existing data will be handled
5. **Test thoroughly**: Verify no data loss

---

## 💬 COMMUNICATION PATTERNS

### **What Works Well**
- Detailed technical explanations when requested
- Step-by-step implementation plans with phase breakdowns
- Code artifacts with complete implementations
- Performance analysis and optimization suggestions
- **Explicit references to existing patterns from M1-M3.5**
- **Mentioning relevant learning notes when suggesting approaches**

### **What to Flag**
- When existing infrastructure can be leveraged vs creating new
- When technical debt would be created
- When proposals contradict proven patterns from M1-M3.5
- When Core Data changes need impact analysis

### **Principal Engineer Perspective**
- Challenge proposals that contradict proven patterns
- Flag dual-storage or unnecessary backward compatibility
- Suggest simple solutions before complex architecture
- Reference successful patterns from completed milestones

---

## 📚 DOCUMENTATION STRUCTURE

### **Critical Startup Documents (Read Every Session)**
```
docs/
├── session-startup-checklist.md   ← START HERE EVERY SESSION
├── project-naming-standards.md    ← M#.#.# naming conventions  
├── current-story.md               ← Current milestone status
├── next-prompt.md                 ← Implementation guidance
└── development-guidelines.md      ← Code standards & patterns
```

### **Strategic Planning Documents**
```
docs/
├── requirements.md                ← Functional requirements
├── roadmap.md                     ← Milestone tracking
└── project-index.md               ← Central navigation hub
```

### **Implementation Documentation**
```
docs/
├── prds/                          ← Product Requirements
│   ├── active/                    ← Current milestone PRDs
│   └── complete/                  ← Completed feature PRDs
│
├── learning-notes/                ← Implementation journey
│   ├── 01-10-milestone-1-phases.md
│   ├── 11-m2.1-recipe-architecture.md
│   ├── 12-14-m3-phases-1-4.md
│   ├── 15-m3-phase5-quantity-consolidation.md
│   ├── 16-m3-phase6-ui-polish.md
│   └── 17-m3.5-foundation-validation.md
│
└── architecture/                  ← Architecture decisions
    ├── 001-selective-technical-improvements.md
    ├── 006-consolidate-staples-and-ingredients.md
    └── 007-core-data-change-process.md
```

---

## 🎯 KEY PRINCIPLES

1. **Session startup discipline**: Follow checklist EVERY session (no exceptions)
2. **Naming consistency**: M#.#.# format everywhere (zero tolerance)
3. **Search before creating**: Check for existing services/patterns/components
4. **Document as you go**: Don't defer to "later"
5. **Leverage proven patterns**: M1-M3.5 established excellent patterns
6. **Performance matters**: Maintain <0.5s targets for all operations
7. **Zero regressions**: Never break existing working features
8. **Incremental validation**: Build and test each phase before proceeding

---

## 📊 SUCCESS METRICS

### **Planning Accuracy**
- M1: 32h (est 30-35h) - ✅ 91% accuracy
- M2: 16.5h (est 15-18h) - ✅ 92% accuracy  
- M3: 10.5h (est 8-12h) - ✅ 88% accuracy
- M3.5: 8.5h (est 7h) - ✅ 82% accuracy
- **Overall: 88% accuracy (<12% variance)**

### **Quality Metrics**
- Build success: 100% (zero breaking changes)
- Performance: 100% (<0.5s for all operations)
- Data integrity: 100% (zero data loss)
- Documentation consistency: 100% (M#.#.# naming throughout)

### **Success Factors**
- Strict adherence to session-startup-checklist.md
- Consistent use of project-naming-standards.md
- Phase-based development with validation gates
- Comprehensive learning notes for knowledge preservation
- Proven architecture patterns reused across milestones

---

## 🚨 REALITY CHECKS & RED FLAGS

### **Your Actual Constraints**
- ✅ Pre-production app - breaking changes acceptable
- ✅ Single developer - optimize for long-term maintainability
- ✅ Learning-focused - balance learning with pragmatism
- ✅ Quality over speed - but excellent velocity (67.5h for 4 milestones)

### **Red Flags to Challenge**
- ❌ Proposals contradicting proven M1-M3.5 patterns
- ❌ Dual-storage or backward compatibility for pre-production
- ❌ Complex architecture before simple solution proven
- ❌ Suggestions that create technical debt
- ❌ Creating new infrastructure when existing can be extended
- ❌ Ignoring project-naming-standards.md

---

## 🔍 QUICK REFERENCE: SEARCH QUERIES

### **Starting a Session**
```
1. "session-startup-checklist"
2. "project-naming-standards milestone active"
3. "current-story milestone active work"
4. "next-prompt implementation guidance"
```

### **Before Developing**
```
5. "Core Data entity [EntityName] properties" (if touching data)
6. "Service [functionality]" (before creating new service)
7. "architecture decision [feature]" (for architectural work)
```

### **Finding Patterns**
```
"learning notes [feature]" - Implementation patterns
"ADR [topic]" - Architecture decisions
"M[number] phase [number]" - Specific milestone work
```

---

## ✅ SESSION COMPLETION CHECKLIST

**Before ending ANY development session:**

- [ ] Code includes function header comments
- [ ] Code includes inline comments explaining "why"
- [ ] Code uses MARK comments for organization
- [ ] All files use correct M#.#.# naming
- [ ] current-story.md updated with progress
- [ ] Learning notes created/updated
- [ ] project-index.md Recent Activity updated
- [ ] No build errors or warnings
- [ ] No regressions to existing features
- [ ] Performance targets maintained (<0.5s)

**If phase complete:**
- [ ] Mark ✅ COMPLETE in current-story.md with actual hours
- [ ] Update next-prompt.md for next phase
- [ ] Create/update comprehensive learning note

**If milestone complete:**
- [ ] Update roadmap.md with completion summary
- [ ] Update project-index.md with milestone links
- [ ] Verify all documentation uses consistent M#.#.# naming

---

## 🎓 CONTINUOUS LEARNING

### **After Each Session**
- Document problems solved in learning notes
- Record performance metrics achieved
- Note deviations from plan and why
- Include code examples for key decisions

### **After Each Milestone**
- Comprehensive learning note with journey
- Update proven patterns list
- Refine time estimates for similar work
- Identify reusable components/services

### **Knowledge Preservation**
- Learning notes are the PROJECT MEMORY
- Future sessions depend on this documentation
- Detailed > brief (include code examples)
- Explain "why" not just "what"

---

## 📞 GETTING HELP

**When stuck or uncertain:**
1. Search project knowledge for similar implementations
2. Review relevant learning notes (see project-index.md)
3. Check architecture decisions (ADRs) for guidance
4. Reference proven patterns from M1-M3.5
5. Ask for clarification with specific context

**When making decisions:**
1. Search for relevant ADRs first
2. Consider long-term maintainability
3. Prefer simple over complex
4. Document decision in ADR if significant
5. Reference decision in implementation

---

## 🏁 FINAL REMINDER

**Every session starts with the same 4 searches:**
1. `session-startup-checklist.md` - Complete procedure
2. `project-naming-standards.md` - M#.#.# naming  
3. `current-story.md` - Current status
4. `next-prompt.md` - Implementation guide (if developing)

**This 5-10 minute investment prevents 6-14 hours of rework.**

**Follow the checklist. Use M#.#.# naming. Document everything. Build incrementally.**

---

**Version**: 3.0 - Optimized Session Startup & Naming Enforcement  
**Last Updated**: October 23, 2025  
**GitHub**: https://github.com/rfhayn/grocery-recipe-manager.git