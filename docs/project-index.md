# Grocery & Recipe Manager - Project Index

**Last Updated**: November 26, 2025  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M4 COMPLETE ✅ (All phases)  
**Next Priority**: M5 (CloudKit & Production Infrastructure) or TestFlight Deployment

---

## 🚨 **START HERE: MANDATORY SESSION STARTUP**

### **For EVERY Development Session:**

**⚠️ CRITICAL - Complete these in order:**

1. **[Session Startup Checklist](session-startup-checklist.md)** ← **START HERE FIRST**
   - Mandatory 7-point checklist for every session
   - Ensures naming consistency and context loading
   - Prevents 6-14 hours of potential rework
   - **5-10 minutes that save hours**

2. **[Project Naming Standards](project-naming-standards.md)** ← **READ SECOND**
   - M#.#.# naming hierarchy (e.g., M4.1.2)
   - Status indicators (✅ 🔄 🚀 ⏳)
   - Quick reference card at top
   - **Zero tolerance for incorrect naming**

3. **[Current Story](current-story.md)** ← **READ THIRD**
   - Current milestone and active phases
   - What's 🔄 ACTIVE right now
   - Recently completed work ✅
   - Next steps 🚀

4. **[Next Prompt](next-prompt.md)** ← **READ FOURTH (if developing)**
   - Ready-to-use implementation prompt
   - Current phase guidance
   - Technical requirements
   - Acceptance criteria

**Why this order matters:**
- Checklist → Ensures you follow the complete process
- Naming Standards → Establishes the language/convention
- Current Story → Provides specific project state
- Next Prompt → Gives implementation details

**Failure to follow this sequence breaks project continuity.**

---

## 🚀 **QUICK START BY ACTIVITY TYPE**

### **Starting a Development Session**
1. Complete [Session Startup Checklist](session-startup-checklist.md) (ALL 7 items)
2. Follow [Next Prompt](next-prompt.md) implementation guidance
3. Reference [Development Guidelines](development-guidelines.md) for code standards
4. Review relevant [Learning Notes](learning-notes/) for patterns

### **Planning a New Feature**
1. Review [Requirements](requirements.md) - Check existing requirements
2. Check [Roadmap](roadmap.md) - Verify strategic fit
3. Review [Architecture](architecture/) - Check for relevant ADRs
4. Create PRD in `prds/` if complex (6+ hours)
5. Update [Current Story](current-story.md) with new work (using M#.#.# naming)

### **Understanding Project Status**
1. Check [Current Story](current-story.md) - Detailed current state
2. Review [Roadmap](roadmap.md) - Milestone sequence and completion
3. See "Current State" section below - Quick overview
4. Review recent [Learning Notes](learning-notes/) - Implementation details

### **Completing Work**
1. Update [Current Story](current-story.md) - Mark ✅ COMPLETE with actual hours
2. Update [Project Index](project-index.md) - Add to Recent Activity
3. Create/update [Learning Notes](learning-notes/) - Document journey
4. If milestone complete, update [Roadmap](roadmap.md)

---

## 📋 **CORE DOCUMENTATION**

### **🎯 Critical Workflow Documents**

#### **[session-startup-checklist.md](session-startup-checklist.md)** 🆕
**Purpose**: Mandatory startup procedure for EVERY session  
**Contents**:
- 7-point checklist (3 for context, 4 for development)
- Prevents duplicate work, naming issues, architecture conflicts
- Time saved: 6-14 hours of rework per session
- **Read first, every time, no exceptions**

#### **[project-naming-standards.md](project-naming-standards.md)**
**Purpose**: M#.#.# naming hierarchy and conventions  
**Contents**:
- Quick reference card (M4.1.2 format)
- Status indicators (✅ 🔄 🚀 ⏳)
- Enforcement guidelines
- Current project mapping
- **Zero tolerance for non-compliance**

#### **[current-story.md](current-story.md)**
**Purpose**: Active milestone status and progress tracking  
**Contents**:
- Current milestone progress
- Phase-by-phase status
- Next actions and priorities
- Recent completions summary
- **Updated after every development session**

#### **[next-prompt.md](next-prompt.md)**
**Purpose**: Copy-paste ready implementation guidance  
**Contents**:
- Current phase implementation guide
- Technical requirements
- Integration points
- Acceptance criteria
- **Updated at end of each phase**

#### **[development-guidelines.md](development-guidelines.md)**
**Purpose**: How Claude should work - code standards and patterns  
**Contents**:
- Session startup requirements
- Pre-development analysis checklist
- Proven patterns from M1-M3.5
- Code documentation standards
- Quality gates and success criteria
- **Reference during development work**

---

### **📊 Strategic Documents**

#### **[requirements.md](requirements.md)**
**Purpose**: All functional and non-functional requirements  
**Contents**:
- Requirements organized by milestone
- Traceability to implementation
- Acceptance criteria for each requirement
- **Check before planning new features**

#### **[roadmap.md](roadmap.md)**
**Purpose**: Milestone sequence and completion tracking  
**Contents**:
- Milestone status and timelines
- Estimates vs actuals
- Success criteria by milestone
- Strategic integration points
- Risk management
- **Update after milestone completion**

---

## 📊 **CURRENT STATE - November 2025**

### **Project Velocity Summary**
- **Total Hours**: 85.75 hours across M1-M4.3.5 Phases 1-3 complete
- **Planning Accuracy**: 88% (< 12% average variance)
- **Build Success Rate**: 100% (zero breaking changes)
- **Performance**: All operations < 0.5s target maintained

### **Completed Work**

#### **M1: Professional Grocery Management** ✅ (32 hours - August 2025)
**Key Achievements:**
- Store-layout optimized grocery lists
- Custom category management with drag-and-drop ordering
- Staple item system with auto-population
- Professional iOS UI with accessibility compliance

**Components:**
- M1.1: Core Data Foundation ✅
- M1.2: Performance Architecture ✅
- M1.3: Staples Management ✅
- M1.4: Custom Category System ✅
- M1.5: Auto-Generated Lists ✅

#### **M2: Recipe Integration** ✅ (16.5 hours - Sept-Oct 2025)
**Key Achievements:**
- Complete recipe catalog with search
- Recipe CRUD operations with validation
- Recipe-to-grocery integration
- Ingredient autocomplete with parse-then-search
- Fuzzy matching and template alignment
- Enhanced search and navigation

**Components:**
- M2.1: Recipe Architecture Services ✅ (1 hour)
- M2.2: Recipe Catalog ✅ (10.5 hours)
- M2.3: Recipe Creation & Editing ✅ (5 hours)

#### **M3: Structured Quantity Management** ✅ (10.5 hours - October 2025)
**Key Achievements:**
- Structured quantity parsing (amount + unit)
- Recipe scaling with unit conversion
- Intelligent quantity consolidation (30-50% list reduction)
- Visual quantity indicators
- Comprehensive help documentation

**Phases:**
- M3 Phase 1-2: Core Data Model & Enhanced Parsing ✅ (3 hours)
- M3 Phase 3: Data Migration ✅ (1.5 hours)
- M3 Phase 4: Recipe Scaling Service ✅ (1 hour)
- M3 Phase 5: Quantity Consolidation ✅ (2.5 hours)
- M3 Phase 6: UI Polish & Help ✅ (2.5 hours)

#### **M3.5: Foundation Validation & System Health Check** ✅ (8.5 hours - October 2025)
**Key Achievements:**
- Validated Core Data relationships end-to-end
- Fixed 3 critical deletion cascade bugs
- Verified IngredientTemplate normalization
- Confirmed recipe-to-list workflow integrity
- Comprehensive testing infrastructure

#### **M4: Meal Planning & Enhanced Grocery Integration** 🔄 (18.25h complete, ~1h remaining)
**Key Achievements So Far:**
- Settings infrastructure with user preferences
- Calendar-based meal planning
- Recipe source tracking with many-to-many relationships
- Scaled recipe-to-list with servings adjustment
- Bulk add from meal plan with progress overlay
- Meal completion tracking
- Ingredient normalization system (Phases 1-3 complete)

**Components:**
- M4.1: Settings Infrastructure ✅ (1.5 hours)
- M4.2: Calendar Meal Planning ✅ (~4 hours)
- M4.3.1: Recipe Source Tracking ✅ (3.5 hours)
- M4.3.2: Scaled Recipe to List ✅ (1.25 hours)
- M4.3.3: Bulk Add from Meal Plan ✅ (2.5 hours)
- M4.3.4: Meal Completion Tracking ✅ (1.0 hour)
- M4.3.5: Ingredient Normalization 🔄 (4.5h Phases 1-3, ~1h Phase 4 remaining)

---

## 📅 **RECENT ACTIVITY**

### **November 26, 2025** - M4.3.5 & M4 COMPLETE ✅ 🎉
- **Completed**: M4.3.5 Phase 4 - Variation Handling (1 hour)
- **Completed**: M4 Milestone - Meal Planning & Enhanced Grocery Integration (19.25 hours total)
- **Achievement**: Complete 4-phase ingredient normalization pipeline operational
- Variation handling removes qualifiers (diced, fresh, organic, large, etc.)
- Handles both spaced ("large egg") and compound ("largeegg") forms
- 13-item preserve-plural list finalized (peas, beans, chocolate chips, etc.)
- Enhanced Phase 2 with qualifier stripping before preserve-plural check
- Fixed "frozen peas" → "peas" (not "pea") preservation
- 30% reduction in template fragmentation (50+ → 35 templates)
- StandardEmptyStateView component created for app-wide consistency
- **Planning Accuracy**: 90% for M4 (19.25h vs 14.5-17.5h estimate)
- **M4 Components**: M4.1 (1.5h), M4.2 (4h), M4.3.1 (3.5h), M4.3.2 (1.25h), M4.3.3 (2.5h), M4.3.4 (1h), M4.3.5 (5.5h)
- Revolutionary grocery-recipe workflow complete
- Ready for M5 (CloudKit) or TestFlight deployment

### **November 25, 2025** - M4.3.5 Phases 2-3 Complete ✅
- **Completed**: M4.3.5 Phases 2-3 - Ingredient Normalization (2 hours)
- **Phase 2**: Singular/plural consolidation with "preserve-plural" list (eggs→egg, but "chocolate chips" stays plural)
- **Phase 3**: Abbreviation expansion safety net (tbsp→tablespoon)
- **Bonus**: StandardEmptyStateView component for UI consistency across all 4 tabs
- 18 ingredient templates with intelligent normalization
- Template count down from initial duplicates
- Professional iOS design standards maintained

### **November 24, 2025** - M4.3.4 Complete ✅
- **Completed**: M4.3.4 - Meal Completion Tracking (1.0 hour)
- **Achievement**: On-target estimate (0% variance)
- Tappable completion checkbox with visual feedback
- Clean state management with refreshID pattern
- No date restrictions for plan flexibility

### **November 24, 2025** - M4.3.3 Complete ✅
- **Completed**: M4.3.3 - Bulk Add from Meal Plan (2.5 hours)
- **Achievement**: Added servings adjustment UI enhancement
- "Add All to Shopping List" with progress overlay
- Individual recipe servings adjusters
- Recipe source tracking integration (M4.3.1)
- Quantity scaling integration (M4.3.2)

### **November 22, 2025** - M4.3.2 Complete ✅
- **Completed**: M4.3.2 - Scaled Recipe to List Integration (1.25 hours)
- **Achievement**: Under estimate by 17%!
- Servings picker with real-time scaling
- Scaled quantities in blue, original in gray
- Fraction formatting for kitchen-friendly display

### **November 22, 2025** - M4.3.1 Complete ✅
- **Completed**: M4.3.1 - Recipe Source Tracking Foundation (3.5 hours)
- **Achievement**: Many-to-many relationships with professional UI
- GroceryListItem ↔ Recipe relationships
- Display Options in Settings
- Recipe source badges with user control
- Fixed 3 critical bugs

### **November 3, 2025** - M4.2.1-3 Complete ✅
- **Completed**: M4.2 Calendar-Based Meal Planning (~4 hours)
- **Components**: M4.2.1 (Calendar UI), M4.2.2 (Recipe Assignment), M4.2.3 (Meal Plan Management)
- Multi-week calendar view with meal assignments
- Professional iOS calendar patterns
- Recipe picker with search and filtering

### **October 26, 2025** - M3.5 Complete ✅
- **Completed**: M3.5 - Foundation Validation (8.5 hours)
- **Achievement**: Validated entire M1-M3 architecture
- Fixed 3 deletion cascade bugs
- Verified 75+ computed properties
- Comprehensive testing infrastructure
- System health confirmed for M4

### **October 14, 2025** - M3 Complete ✅
- **Status**: M3 MILESTONE COMPLETE (10.5 hours total)
- Validated recipe ingredient autocomplete with M3 features
- Added consolidation button with opportunity badge
- Implemented visual indicators for quantity types
- Created comprehensive user help documentation
- Finalized all M3 documentation

### **October 14, 2025** - M3 Phase 5 Complete ✅
- **Completed**: M3 Phase 5 - Quantity Consolidation (2.5 hours)
- **Achievement**: Intelligent consolidation reduces list redundancy by 30-50%
- Created QuantityMergeService and UnitConversionService
- Implemented preview-before-merge workflow

---

## 🚦 **QUICK REFERENCE: PROJECT STATUS**

### **Current State**
- **Completed Milestone**: M4 (Meal Planning & Enhanced Grocery Integration) ✅
- **All M4 Components Complete**: M4.1 (Settings), M4.2 (Calendar Planning), M4.3.1 (Recipe Source Tracking), M4.3.2 (Scaled Recipe to List), M4.3.3 (Bulk Add), M4.3.4 (Meal Completion), M4.3.5 (Ingredient Normalization - All 4 Phases) ✅
- **Next Priority**: M5 (CloudKit & Production Infrastructure) or TestFlight Deployment
- **Progress**: M1-M4 complete (86.5 hours total across 4 major milestones)
- **Status**: Revolutionary grocery-recipe workflow complete with 89% planning accuracy

### **M4.3 Work Breakdown**

**M4.3.1: Recipe Source Tracking Foundation** ✅ **COMPLETE** (3.5 hours)
- Many-to-many GroceryListItem ↔ Recipe relationships
- Display Options section in Settings
- Professional recipe source badges with user control
- Fixed 3 critical bugs (displayText, duplicate text, redundant tags)
- 6 comprehensive test recipes with strategic overlap
- Complete testing validation (11/11 tests passing)

**M4.3.2: Scaled Recipe to List Integration** ✅ **COMPLETE** (1.25 hours)
- Servings picker with +/- stepper
- Real-time quantity scaling with RecipeScalingService
- Scaled quantities in blue, original in gray
- Fraction formatting for kitchen-friendly display
- Updated addToShoppingList() for scaled saving
- Under estimate by 17%! Clean M3 pattern reuse

**M4.3.3: Bulk Add from Meal Plan** ✅ **COMPLETE** (2.5 hours)
- "Add All to Shopping List" button
- Process all meal plan recipes with progress overlay
- Servings adjustment UI with scale factor indicators
- Recipe source tracking integration (M4.3.1)
- Quantity scaling integration (M4.3.2)
- Smart consolidation with M3 Phase 5

**M4.3.4: Meal Completion Tracking** ✅ **COMPLETE** (1.0 hour)
- Checkbox toggle for meal completion (circle → checkmark)
- Visual feedback: green checkmark, strikethrough, 50% opacity
- No date restrictions (flexible for change of plans)
- Core Data persistence with isCompleted and completedDate
- SwiftUI reactivity fix with refreshID state trigger

**M4.3.5: Ingredient Normalization** ✅ **COMPLETE** (5.5 hours - all 4 phases)
- **Phase 1**: Case normalization (Butter → butter) ✅ COMPLETE (2.5h)
- **Phase 2**: Singular/plural with 13-item preserve-plural list (eggs → egg, "chocolate chips" stays plural) ✅ COMPLETE (1.5h)
- **Phase 3**: Abbreviation expansion safety net (tbsp → tablespoon) ✅ COMPLETE (0.5h)
- **Phase 4**: Variation handling (diced tomato → tomato, fresh basil → basil) ✅ COMPLETE (1h)
- 30% reduction in template fragmentation (50+ → 35 templates)
- Handles both spaced and compound qualifier forms
- Intelligent plural preservation for items bought in bulk
- StandardEmptyStateView component for UI consistency
- Complete 4-phase normalization pipeline operational

### **Performance Metrics**
- **All Operations**: < 0.5s target maintained ✅
- **Parse Accuracy**: 95%+ ✅
- **Unit Conversion**: 100% accurate ✅
- **Data Integrity**: Zero data loss across migrations ✅
- **Build Success**: 100% (zero breaking changes) ✅

### **Technical Debt**
- **Status**: NONE ✅
- Clean architecture maintained throughout M1-M4.3.5
- No shortcuts or workarounds
- Comprehensive documentation at all levels
- All code follows established patterns from development-guidelines.md

---

## 💡 **TIPS FOR USING THIS INDEX**

### **Every Session Start**
1. Complete [session-startup-checklist.md](session-startup-checklist.md) (mandatory)
2. Verify current M#.#.# identifier in [current-story.md](current-story.md)
3. Follow [next-prompt.md](next-prompt.md) for implementation

### **Planning New Features**
1. Check [requirements.md](requirements.md) for existing requirements
2. Review [roadmap.md](roadmap.md) for strategic fit and dependencies
3. Search [architecture/](architecture/) for relevant ADRs
4. Create PRD in `prds/` if complex feature (6+ hours)
5. Add to [current-story.md](current-story.md) using correct M#.#.# naming

### **Completing Work**
1. Update [current-story.md](current-story.md) - Mark ✅ COMPLETE with hours
2. Update this file ([project-index.md](project-index.md)) - Add to Recent Activity
3. Create/update [learning-notes/](learning-notes/) - Document implementation journey
4. If milestone complete, update [roadmap.md](roadmap.md) with completion summary

### **Finding Information**
- **Current work**: [current-story.md](current-story.md)
- **How to implement**: [next-prompt.md](next-prompt.md)
- **Naming rules**: [project-naming-standards.md](project-naming-standards.md)
- **Code patterns**: [development-guidelines.md](development-guidelines.md)
- **Architecture**: [architecture/](architecture/) ADRs
- **Implementation details**: [learning-notes/](learning-notes/)

---

## 📞 **DOCUMENTATION QUICK LINKS**

**When you need to know...**

| What | Check This Document |
|------|-------------------|
| How to start a session | [session-startup-checklist.md](session-startup-checklist.md) |
| Correct M#.#.# naming | [project-naming-standards.md](project-naming-standards.md) |
| What's active now | [current-story.md](current-story.md) |
| How to implement current work | [next-prompt.md](next-prompt.md) |
| Code standards | [development-guidelines.md](development-guidelines.md) |
| What features are needed | [requirements.md](requirements.md) |
| Milestone timeline | [roadmap.md](roadmap.md) |
| Architecture decisions | [architecture/](architecture/) |
| Feature details | [prds/](prds/) |
| How something was built | [learning-notes/](learning-notes/) |

---

## 🎯 **SUCCESS METRICS**

**This project maintains excellence through:**

1. **Consistent Naming**: M#.#.# format everywhere (zero variance)
2. **Session Discipline**: Startup checklist followed every session
3. **Documentation Currency**: All docs updated after every session
4. **Planning Accuracy**: 88% accuracy (< 12% variance)
5. **Code Quality**: Zero regressions, 100% build success
6. **Performance**: All operations < 0.5s target
7. **Knowledge Preservation**: Comprehensive learning notes for all work

**These metrics are maintained through disciplined adherence to the documentation structure and session startup procedures.**

---

**Last Updated**: November 26, 2025  
**Next Update**: After M5 planning or TestFlight preparation  
**Current Status**: M4 COMPLETE ✅ - All 4 milestones complete, ready for M5 or TestFlight  
**Documentation Version**: Updated with M4.3.5 Phase 4 and M4 milestone completion