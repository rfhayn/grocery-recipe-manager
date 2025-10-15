# Grocery & Recipe Manager - Project Index

**Last Updated**: October 14, 2025  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M3 Phase 6 (UI Polish & Documentation)

---

## 🚀 **QUICK START**

### **For Development Sessions:**
1. Read [Current Story](current-story.md) - Current state and next actions
2. Read [Next Prompt](next-prompt.md) - Ready-to-use prompt for current phase
3. Review relevant learning notes from recent phases
4. Check [Roadmap](roadmap.md) for strategic context

### **For Planning:**
1. Review [Requirements](requirements.md) - All functional requirements
2. Check [Roadmap](roadmap.md) - Milestone sequence and timing
3. Read relevant PRDs in `prds/` folder
4. Review Architecture Decision Records in `architecture/`

### **For Reference:**
1. [Naming Standards](project-naming-standards.md) - File and entity conventions
2. [Project Index](project-index.md) - This document
3. [Learning Notes](learning-notes/) - Implementation patterns and lessons
4. [Architecture](architecture/) - Key design decisions

---

## 📋 **CORE DOCUMENTATION**

### **Strategic Documents**

**[requirements.md](requirements.md)**
- All functional and non-functional requirements
- Requirements organized by milestone
- Traceability to implementation
- Acceptance criteria for each requirement

**[roadmap.md](roadmap.md)**
- Milestone sequence and status
- Timeline estimates and actuals
- Success criteria by milestone
- Strategic integration points
- Risk management

**[current-story.md](current-story.md)**
- Detailed current milestone progress
- Phase-by-phase status
- Next actions and priorities
- Recent completions summary

**[next-prompt.md](next-prompt.md)**
- Copy-paste ready prompt for next session
- Current phase implementation guide
- Technical requirements
- Acceptance criteria

**[project-naming-standards.md](project-naming-standards.md)**
- File naming conventions
- Entity naming standards
- Documentation structure
- Consistency guidelines

---

## 📊 **CURRENT STATE - October 2025**

### **Completed Work**

**M1: Professional Grocery Management (32 hours) - August 2025** ✅
- Store-layout optimized grocery lists
- Custom category management
- Staple item system
- Professional iOS UI

**M2: Recipe Integration (16.5 hours) - September-October 2025** ✅
- Complete recipe catalog
- Recipe CRUD operations
- Recipe-to-grocery integration
- Recipe ingredient autocomplete with parse-then-search
- Fuzzy matching and template alignment
- Enhanced search and navigation

**M3: Structured Quantity Management (9.5 hours / ~10.5 target) - October 2025** 🔄
- Phase 1-2: Core Data model & enhanced parsing (3 hours) ✅
- Phase 3: Data migration (1.5 hours) ✅
- Phase 4: Recipe scaling service (2.5 hours) ✅
- Phase 5: Quantity consolidation (2.5 hours) ✅
- Phase 6: UI polish & documentation (1 hour) ← **NEXT**

**Progress**: 83% complete, all major features operational

---

## 🎯 **M3: STRUCTURED QUANTITY MANAGEMENT - CURRENT FOCUS**

### **✅ Completed Phases**

**Phase 1-2: Core Data Model & Enhanced Parsing (3 hours)**
- Structured data model with numericValue, standardUnit, displayText, isParseable, parseConfidence
- Enhanced IngredientParsingService with numeric conversion and unit standardization
- 10 files systematically updated across entire codebase
- Zero build errors with type-safe implementation

**Phase 3: Data Migration (1.5 hours)**
- QuantityMigrationService with batch processing
- Professional migration UI with Preview → Migration → Results flow
- Settings infrastructure created
- 100% success rate: 32 items processed, 24 parsed (75%), 8 text-only (25%)

**Phase 4: Recipe Scaling Service (2.5 hours)**
- RecipeScalingService with mathematical quantity scaling
- Kitchen-friendly fraction conversion (1.5 → "1 1/2")
- Professional scaling UI with slider and quick buttons
- Graceful degradation for unparseable ingredients
- Performance: < 0.5s for 20+ ingredient recipes

**Phase 5: Quantity Merge Service (2.5 hours)** ✅ **NEW**
- QuantityMergeService with intelligent consolidation logic
- UnitConversionService for volume/weight conversions
- ConsolidationPreviewView with professional preview UI
- Source tracking for recipe provenance
- Performance: < 0.3s analysis for 50+ items
- User value: Reduces list redundancy by 30-50%

**Key Achievements:**
- Intelligent ingredient grouping by name
- Unit conversion (cups ↔ tbsp ↔ tsp, lb ↔ oz)
- Mixed type handling (incompatible stays separate)
- Preview before merge with summary
- Complete source provenance tracking
- Transaction safety with zero data loss

### **⏳ Remaining Phases**

**Phase 6: UI Polish & Documentation (1 hour) - NEXT**
- Recipe ingredient autocomplete validation with M3 features
- Visual enhancements (opportunity badges, quantity indicators)
- User-facing help documentation
- Completion documentation and milestone close-out

---

## 📋 **M4: MEAL PLANNING & SETTINGS - UPDATED TIMELINE**

### **Timeline Update**
**Previous**: 6-8 hours across 3 phases  
**Updated**: 7.5-10 hours across 3 phases (includes M4.3 PRD)

### **Phase Breakdown**

**M4.1: Settings Infrastructure Foundation (1.5 hours)**
- Dedicated Settings tab with professional iOS interface
- Meal planning preferences (duration, start day, auto-naming, recipe source display)
- UserPreferences entity for persistent configuration
- Real-time settings validation

**M4.2: Calendar-Based Meal Planning Core (2.5 hours)**
- MealPlan and PlannedMeal entities with date relationships
- Clean one-week calendar with recipe assignment
- "Add to Meal Plan" buttons with modal calendar picker
- User-configurable 3-14 day planning periods

**M4.3: Enhanced Grocery Integration (3.5-4 hours)** - EXPANDED
- **Original M4.3 scope (2 hours)**:
  - Smart list generation from meal plans
  - Recipe source tags ("Ground beef [Tacos] [Spaghetti]")
  - Quantity consolidation leveraging M3 structured quantities
  - Meal completion tracking
  
- **NEW: Scaled Recipe to Shopping List (1.5-2 hours)** - From M4.3 PRD:
  - Add "Add to List" button to recipe scaling sheet
  - Generate temporary ingredients with scaled quantities
  - Integrate with existing AddIngredientsToListView
  - Proper sheet navigation (list selection over scaling sheet)
  - Scaling metadata for meal planning integration

**Strategic Dependencies:**
- M3 Phase 4 (Recipe Scaling) enables M4.3 scaled-to-list feature ✅
- M3 Phase 5 (Quantity Merge) enhances M4.3 consolidation (optional)
- Structured quantities enable smart meal plan grocery generation

---

## 🔄 **STRATEGIC MILESTONE SEQUENCE**

### **Immediate Development Path**
1. **M3 Phase 6**: UI Polish & Documentation (1 hour) ← NEXT
2. **M3 Completion**: Mark milestone complete with learning notes
3. **M4 Implementation**: Meal Planning & Settings (7.5-10 hours)
   - M4.1: Settings Infrastructure (1.5 hours)
   - M4.2: Meal Planning Core (2.5 hours)
   - M4.3: Enhanced Grocery Integration + Scaled Recipe to List (3.5-4 hours)

### **Strategic Integration Points**
- **M3 Phase 4 → M4.3**: Recipe scaling service enables scaled-to-list feature
- **M3 Phase 5 → M4.3**: Quantity consolidation enhances grocery automation
- **M3 → M7**: Structured quantity data foundation for analytics
- **M4 → M5**: Meal planning data architecture ready for CloudKit family sharing

---

## 📚 **DOCUMENTATION MAINTENANCE GUIDE**

### **After Each Development Session**
1. **Update docs/current-story.md**:
   - Mark completed phases/tasks
   - Update progress percentages
   - Document achievement metrics
   
2. **Create/Update Learning Notes** in `docs/learning-notes/`:
   - Document problems and solutions
   - Record performance metrics
   - Note deviations from plan
   - Capture architecture insights

3. **Update docs/next-prompt.md**:
   - Prepare prompt for next session
   - Include current context
   - List ready-to-use technical requirements

### **After Milestone Completion**
1. **Update docs/roadmap.md**:
   - Mark milestone complete
   - Record actual vs estimated hours
   - Update completion date
   - Add achievements summary

2. **Update docs/project-index.md** (this file):
   - Add learning note references
   - Update "Recent Activity" section
   - Update milestone status

3. **Update docs/requirements.md** (if needed):
   - Mark requirements as implemented
   - Update requirement status
   - Add completion notes

### **When Making Architectural Decisions**
1. **Create ADR** in `docs/architecture/`:
   - Use numbered format (001-title.md)
   - Document context, decision, consequences
   - List alternatives considered
   
2. **Update relevant documentation**:
   - Reference ADR in current-story.md
   - Link from related PRDs or learning notes

### **For New Features (Before Starting)**
1. **Create PRD** in `docs/prds/`:
   - Problem statement and user value
   - Technical requirements
   - Success metrics
   - Implementation phases

2. **Create Implementation Prompt** in `docs/next-prompt.md`:
   - Copy-paste ready for next session
   - Phase breakdown with time estimates
   - Technical requirements

---

## 📁 **DOCUMENTATION STRUCTURE**

```
docs/
├── requirements.md              # High-level app requirements and goals
├── roadmap.md                   # Milestone sequence and completion tracking
├── project-index.md             # Navigation hub (this file)
├── project-naming-standards.md  # File naming, entity naming, conventions
├── current-story.md             # Active milestone status and next steps
├── next-prompt.md              # Implementation guide for next session
├── prds/                       # Product Requirements Documents
│   ├── complete/               # Completed feature PRDs
│   │   ├── m2.3-recipe-creation-and-editing.md
│   │   ├── milestone-2-phase-2-story-3a-enhanced-add-to-ingredient-list.md
│   │   └── ...
│   └── milestone-4.3-scaled-recipe-added-to-shopping-list.md
├── learning-notes/             # Problem-solving and implementation notes
│   ├── 01-10-milestone-1-phases.md
│   ├── 11-m2.1-recipe-architecture.md
│   ├── 12-m3-phase1-2-structured-quantities.md
│   ├── 13-m3-phase3-data-migration.md
│   ├── 14-m3-phase4-recipe-scaling.md
│   └── 15-m3-phase5-quantity-consolidation.md  ← **NEW**
└── architecture/               # Architecture Decision Records
    ├── 001-selective-technical-improvements.md
    ├── 006-consolidate-staples-and-ingredients.md
    └── ...
```

---

## 📝 **LEARNING NOTES INDEX**

### **M1: Professional Grocery Management**
- [01-10: Milestone 1 Phases](learning-notes/01-10-milestone-1-phases.md) - Complete M1 journey

### **M2: Recipe Integration**
- [11: M2.1 Recipe Architecture](learning-notes/11-m2.1-recipe-architecture.md) - Initial recipe system
- [12: M2.2 Enhanced Recipe Features](learning-notes/12-m2.2-enhanced-recipe-features.md) - Recipe catalog
- [13: M2.3 Recipe Creation & Editing](learning-notes/13-m2.3-recipe-creation-editing.md) - CRUD with autocomplete

### **M3: Structured Quantity Management**
- [12: M3 Phase 1-2 Structured Quantities](learning-notes/12-m3-phase1-2-structured-quantities.md) - Data model
- [13: M3 Phase 3 Data Migration](learning-notes/13-m3-phase3-data-migration.md) - Migration service
- [14: M3 Phase 4 Recipe Scaling](learning-notes/14-m3-phase4-recipe-scaling.md) - Scaling service
- [15: M3 Phase 5 Quantity Consolidation](learning-notes/15-m3-phase5-quantity-consolidation.md) ← **NEW** - Merge service

---

## 🏗️ **ARCHITECTURE DECISION RECORDS**

### **Core ADRs**
- [001: Selective Technical Improvements](architecture/001-selective-technical-improvements.md) - When to optimize
- [006: Consolidate Staples and Ingredients](architecture/006-consolidate-staples-and-ingredients.md) - IngredientTemplate system

### **When to Create an ADR**
- Choosing between competing technical approaches
- Making decisions with long-term architectural impact
- Establishing patterns for future features
- Resolving technical debt or complexity

---

## 📦 **PRODUCT REQUIREMENTS DOCUMENTS**

### **Completed Features**
- [M2.3: Recipe Creation & Editing](prds/complete/m2.3-recipe-creation-and-editing.md) - CRUD with autocomplete
- [M2 Phase 2 Story 3a: Enhanced Add to List](prds/complete/milestone-2-phase-2-story-3a-enhanced-add-to-ingredient-list.md)
- [M2 Phase 2 Story 2.1 Step 4: Ingredients View Consolidation](prds/complete/milestone-2-phase-2-story-2.1-step-4-ingredients-view-consolidation.md)

### **In Progress**
- [M4.3: Scaled Recipe Added to Shopping List](prds/milestone-4.3-scaled-recipe-added-to-shopping-list.md) - Ready for M4

---

## 🎯 **DEVELOPMENT VELOCITY TRACKING**

### **Phase-Level Estimates vs Actuals**

| Milestone | Phase | Estimated | Actual | Variance |
|-----------|-------|-----------|--------|----------|
| M1 | All | 30-35h | 32h | ✅ On target |
| M2 | All | 15-18h | 16.5h | ✅ On target |
| M3 | Phase 1-2 | 3-4h | 3h | ✅ On target |
| M3 | Phase 3 | 1.5-2h | 1.5h | ✅ On target |
| M3 | Phase 4 | 2-3h | 2.5h | ✅ On target |
| M3 | Phase 5 | 2-3h | 2.5h | ✅ On target |
| M3 | Phase 6 | 1h | TBD | - |

**Planning Accuracy**: Consistently accurate within ±15 minutes
- **Milestone estimates**: On target for M1, M2, and M3 phases 1-5
- **Risk mitigation**: Proactive problem identification preventing scope creep

---

## 🔍 **RECENT ACTIVITY**

### **October 14, 2025**
- **Completed**: M3 Phase 5 - Quantity Consolidation (2.5 hours)
- **Created**: Learning note 15-m3-phase5-quantity-consolidation.md
- **Updated**: current-story.md, roadmap.md, project-index.md, next-prompt.md, requirements.md
- **Next**: M3 Phase 6 - UI Polish & Documentation (1 hour)

### **October 11, 2025**
- **Completed**: M3 Phase 4 - Recipe Scaling Service (2.5 hours)
- **Completed**: M3 Phase 3 - Data Migration (1.5 hours)
- **Created**: Learning notes for phases 3 and 4

### **October 10, 2025**
- **Completed**: M3 Phase 1-2 - Structured Quantity Foundation (3 hours)
- **Started**: M3 Structured Quantity Management milestone

### **October 3, 2025**
- **Completed**: M2 Phase 3 - Recipe Creation & Editing (5 hours)
- **Feature**: Parse-then-autocomplete ingredient entry implemented

---

## 🚦 **QUICK REFERENCE: PROJECT STATUS**

### **Current State**
- **Active Milestone**: M3 (Structured Quantity Management)
- **Current Phase**: Phase 6 of 6 (UI Polish & Documentation)
- **Progress**: 83% complete (9.5 of ~10.5 hours)
- **Status**: On track, all major features operational

### **Next Milestone**
- **M4**: Meal Planning & Settings
- **Estimated**: 7.5-10 hours
- **Phases**: 3 (Settings, Planning Core, Enhanced Integration)
- **Status**: Ready to begin after M3 completion

### **Performance Metrics**
- **All Operations**: < 0.5s target maintained ✅
- **Parse Accuracy**: 95%+ ✅
- **Unit Conversion**: 100% accurate ✅
- **Data Integrity**: Zero data loss ✅
- **Build Success**: 100% (zero breaking changes) ✅

### **Technical Debt**
- **Status**: NONE
- Clean architecture maintained throughout
- No shortcuts or workarounds
- Comprehensive documentation

---

## 💡 **TIPS FOR USING THIS INDEX**

### **Starting a New Session**
1. Read [current-story.md](current-story.md) for context
2. Read [next-prompt.md](next-prompt.md) for implementation guide
3. Review relevant learning notes from recent phases

### **Planning a New Feature**
1. Check [requirements.md](requirements.md) for existing requirements
2. Review [roadmap.md](roadmap.md) for strategic fit
3. Check relevant ADRs in `architecture/`
4. Create PRD in `prds/` if complex feature (6+ hours)

### **Making Architectural Decisions**
1. Review similar decisions in `architecture/`
2. Document decision in new ADR
3. Reference ADR in relevant documentation
4. Update architecture section in learning notes

### **Completing a Phase**
1. Create/update learning note in `learning-notes/`
2. Update [current-story.md](current-story.md)
3. Update [next-prompt.md](next-prompt.md) for next phase
4. Update this index with new learning note reference

### **Completing a Milestone**
1. Update [roadmap.md](roadmap.md) with completion
2. Update this index with milestone status
3. Create comprehensive learning note
4. Prepare next milestone's first prompt

---

## 📞 **DOCUMENTATION CONTACTS**

For questions about:
- **Requirements**: See [requirements.md](requirements.md)
- **Timeline**: See [roadmap.md](roadmap.md)
- **Current Work**: See [current-story.md](current-story.md)
- **Naming**: See [project-naming-standards.md](project-naming-standards.md)
- **Architecture**: See `architecture/` folder
- **Features**: See `prds/` folder
- **Implementation Details**: See `learning-notes/` folder

---

**Last Updated**: October 14, 2025  
**Next Update**: After M3 Phase 6 completion  
**Status**: Active development - M3 Phase 6 in progress