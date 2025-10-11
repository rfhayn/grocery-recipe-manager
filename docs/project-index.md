# Project Documentation Index

**Project**: Grocery & Recipe Manager iOS App  
**Last Updated**: October 11, 2025  
**Current Milestone**: M3 Phase 5 (Quantity Merge Service)  

---

## 📋 **QUICK NAVIGATION**

### **Core Documentation**
- **[Current Story](docs/current-story.md)** - Active development status and immediate next steps
- **[Next Prompt](docs/next-prompt.md)** - Copy-paste implementation guide for next session
- **[Requirements](docs/requirements.md)** - Comprehensive functional requirements specification
- **[Roadmap](docs/roadmap.md)** - Milestone timeline and completion tracking
- **[Naming Standards](docs/project-naming-standards.md)** - File and entity naming conventions

### **Architecture & Decisions**
- **[Architecture Decision Records](docs/architecture/)** - Key technical decisions and rationale
- **[Learning Notes](docs/learning-notes/)** - Implementation details and problem-solving

### **Product Requirements**
- **[PRD Archive](docs/prds/)** - Detailed feature specifications and requirements

---

## 🎯 **CURRENT DEVELOPMENT STATE**

### **Active Milestone: M3 Structured Quantity Management (83% Complete)**
**Status**: ✅ Phase 1-4 COMPLETE | ⏳ Phase 5-6 REMAINING  
**Time Spent**: 7 hours of 8-12 hours (58-88%)  
**Next Action**: Implement Quantity Merge Service (Phase 5)

**Completed Phases:**
- ✅ **Phase 1-2**: Core Data Model & Enhanced Parsing (3 hours)
- ✅ **Phase 3**: Data Migration (1.5 hours)
- ✅ **Phase 4**: Recipe Scaling Service (2.5 hours)

**Remaining Work:**
- ⏳ **Phase 5**: Quantity Merge Service (2-3 hours)
- 📋 **Phase 6**: UI Polish & Documentation (1 hour)

---

## 📊 **MILESTONE COMPLETION STATUS**

### **✅ Completed Milestones**
- **M1**: Professional Grocery Management (32 hours, Aug 2025)
- **M2**: Enhanced Recipe Integration (16.5 hours, Sep-Oct 2025)

### **🔄 In Progress**
- **M3**: Structured Quantity Management (7/8-12 hours, Oct 2025) - 83% complete

### **📋 Planned Milestones**
- **M4**: Meal Planning & Settings Integration (7.5-10 hours) - *Updated to include M4.3 PRD*
- **M5**: CloudKit Family Sharing (10-12 hours)
- **M6**: Testing Foundation (8-10 hours)
- **M7**: Usage Analytics & Insights (6-8 hours)

---

## 🗂️ **DOCUMENTATION STRUCTURE**

### **Core Strategy Documents**

#### **docs/current-story.md**
**Purpose**: Real-time development status and tactical planning  
**Updates**: After each development session  
**Contains**:
- Current milestone progress percentage
- Phase-by-phase completion status
- Immediate next steps
- Strategic milestone sequence
- Technical foundation status

#### **docs/next-prompt.md**
**Purpose**: Copy-paste ready implementation guide  
**Updates**: When starting new phase/milestone  
**Contains**:
- Detailed implementation plan for next session
- Code examples and architecture patterns
- Success criteria and validation steps
- Time estimates per task

#### **docs/requirements.md**
**Purpose**: Comprehensive functional requirements specification  
**Updates**: When adding new milestones or major features  
**Contains**:
- All functional requirements with IDs
- Non-functional requirements
- Success criteria and metrics
- Strategic value propositions
- Dependency tracking

#### **docs/roadmap.md**
**Purpose**: High-level milestone timeline and skills tracking  
**Updates**: After milestone completion  
**Contains**:
- Milestone completion dates and actual hours
- Skills mastered per milestone
- Strategic vision and platform evolution
- Development velocity tracking

#### **docs/project-naming-standards.md**
**Purpose**: Consistent naming across files, entities, and code  
**Updates**: When establishing new patterns  
**Contains**:
- File naming conventions
- Core Data entity standards
- Swift naming patterns
- Documentation standards

---

### **Product Requirements Documents (PRDs)**

**Location**: `docs/prds/`  
**Purpose**: Detailed feature specifications for complex implementations  
**Create When**: Feature complexity >6 hours or requires architectural decisions

**Current PRDs:**
- `milestone-3-qty-mgmt-prd.md` - Structured quantity management specification
- `milestone-4.3-scaled-recipe-added-to-shopping-list.md` - Scaled recipe to list integration (NEW)

**PRD Template Structure:**
1. Executive Summary
2. Problem Statement & User Scenarios
3. Solution Overview & Design Principles
4. Detailed Functional Requirements
5. Technical Implementation Architecture
6. UI Specifications & User Flows
7. Success Criteria & Acceptance Tests
8. Risk Analysis & Mitigation

---

### **Learning Notes**

**Location**: `docs/learning-notes/`  
**Purpose**: Capture implementation details, problems solved, and decisions made  
**Create When**: After each development session or phase completion

**Naming Convention**: `XX-milestone-phase-feature.md`
- Use sequential numbers (01, 02, 03...)
- Include milestone and phase identifiers
- Brief feature description

**Current Learning Notes:**
- `01-m1-core-data-foundation.md`
- `02-m1-performance-architecture.md`
- `03-m1-staples-management.md`
- `04-m1-custom-categories.md`
- `05-m1-auto-grocery-lists.md`
- `06-m2-architecture-services.md`
- `07-m2-recipe-catalog.md`
- `08-m2-ingredient-templates.md`
- `09-m2-unified-ingredients.md`
- `10-m2-custom-category-integration.md`
- `11-m2-recipe-creation-editing.md`
- `12-m3-structured-quantities.md`
- `13-m3-data-migration.md`
- `14-m3-recipe-scaling.md` (NEW)

**Learning Note Template Structure:**
1. Phase/Feature Overview
2. Implementation Approach
3. Problems Encountered & Solutions
4. Key Technical Decisions
5. Performance Metrics Achieved
6. What Worked Well
7. What to Improve Next Time

---

### **Architecture Decision Records (ADRs)**

**Location**: `docs/architecture/`  
**Purpose**: Document significant architectural decisions and their rationale  
**Create When**: Making decisions with long-term impact or choosing between competing approaches

**Naming Convention**: `XXX-decision-title.md`
- Use sequential numbers (001, 002, 003...)
- Brief, descriptive title

**Current ADRs:**
- `001-selective-technical-improvements.md` - When to adopt vs defer optimizations
- `002-ingredient-template-normalization.md` - Single source of truth for ingredients
- `003-custom-category-architecture.md` - Dynamic user-customizable categories
- `004-recipe-architecture-services.md` - Performance-optimized recipe data layer
- `005-unified-ingredient-management.md` - Consolidation of staples and ingredients
- `006-structured-quantity-architecture.md` - Hybrid quantity data model (NEW)

**ADR Template Structure:**
1. Status (Proposed/Accepted/Superseded)
2. Context (Problem and constraints)
3. Decision (What we decided and why)
4. Consequences (Benefits and trade-offs)
5. Alternatives Considered

---

## 🔑 **KEY PROJECT PATTERNS**

### **Proven Service Architecture**
- **OptimizedRecipeDataService**: N+1 query prevention, sub-millisecond response times
- **IngredientParsingService**: Regex-based parsing, sub-0.05s performance
- **IngredientTemplateService**: Template normalization, autocomplete
- **QuantityMigrationService**: Batch processing with async/await patterns
- **RecipeScalingService**: Mathematical scaling with kitchen-friendly fractions (NEW)

### **Proven UI Patterns**
- **@FetchRequest** with predicate-based filtering for Core Data
- **SwiftUI navigation** with sheets/NavigationStack
- **Category-aware organization** throughout all interfaces
- **Real-time search** with native iOS patterns
- **Professional polish** with sub-0.1s response time targets

### **Proven Data Patterns**
- **Template normalization** (IngredientTemplate prevents duplication)
- **READ-ONLY template relationships** for data integrity
- **Single-save transactions** with rollback capability
- **Structured quantity model** with hybrid parseable/unparseable approach (NEW)
- **Migration safety** with preview, validation, and comprehensive error handling

---

## 📈 **DEVELOPMENT VELOCITY METRICS**

### **Actual Time vs Estimates**
- **M1**: 32 hours (target: 32 hours) - 100% accuracy ✅
- **M2**: 16.5 hours (target: 15-18.5 hours) - 100% within range ✅
- **M3 Phase 1-4**: 7 hours (target: 7-9 hours) - 100% within range ✅

### **Quality Indicators**
- **Build Success Rate**: 100% - All phases build successfully first try or with minor fixes
- **Performance Targets**: 100% - All operations meeting sub-0.5s targets
- **Feature Completion**: 100% - All committed features fully operational
- **Documentation Quality**: Comprehensive learning notes for all phases

### **Planning Accuracy**
- **Phase-based estimates**: Consistently accurate within ±15 minutes
- **Milestone estimates**: On target for M1, M2, and M3 phases 1-4
- **Risk mitigation**: Proactive problem identification preventing scope creep

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

**Phase 4: Recipe Scaling Service (2.5 hours)** ✅ NEW
- RecipeScalingService with mathematical quantity scaling
- Kitchen-friendly fraction conversion (1.5 → "1 1/2")
- Professional scaling UI with slider and quick buttons
- Graceful degradation for unparseable ingredients
- Performance: < 0.5s for 20+ ingredient recipes

**Key Achievements:**
- Scale recipes from 0.25x to 4x with live preview
- Auto-scaled vs manual adjustment summary
- Visual indicators (✓ for scaled, ℹ️ for manual)
- Non-destructive preview-only scaling

### **⏳ Remaining Phases**

**Phase 5: Quantity Merge Service (2-3 hours) - NEXT**
- Intelligent shopping list consolidation
- Combine compatible quantities ("1 cup" + "2 cups" = "3 cups")
- Handle mixed types gracefully
- Source tracking for recipe ingredients
- Consolidation preview with user approval

**Phase 6: UI Polish & Documentation (1 hour)**
- Visual indicators for parseable vs unparseable quantities
- Help documentation for quantity features
- Completion documentation and learning notes
- Performance validation

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
1. **M3 Phase 5**: Quantity Merge Service (2-3 hours) ← NEXT
2. **M3 Phase 6**: UI Polish & Documentation (1 hour)
3. **M3 Completion**: Mark milestone complete with learning notes
4. **M4 Implementation**: Meal Planning & Settings (7.5-10 hours)
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
   
2. **Create/Update docs/learning-notes/**:
   - Problems encountered and solutions
   - Performance metrics achieved
   - Deviations from plan and why

### **After Phase/Milestone Completion**
1. **Update docs/roadmap.md**:
   - Mark phase/milestone complete with actual hours
   - Add completion date
   - Link to learning notes
   
2. **Update docs/project-index.md** (this file):
   - Update current milestone status
   - Add new learning notes to list
   - Update completion percentages

### **When Making Architectural Decisions**
1. **Create docs/architecture/XXX-decision.md**:
   - Document context and decision
   - Explain alternatives considered
   - List consequences and trade-offs
   
2. **Reference ADR in relevant docs**:
   - Link from requirements.md if affects requirements
   - Link from current-story.md if affects current work

---

## 🎓 **SKILLS & PATTERNS MASTERED**

### **Core Data Excellence**
- Complex entity relationships with cascade rules
- Performance optimization with compound indexes
- Migration strategies with zero data loss
- Template-based normalization patterns
- Structured quantity hybrid architecture

### **Service Layer Architecture**
- Protocol-based dependency injection
- Performance tracking with @Published properties
- Transaction management with rollback
- Background context usage for imports/migrations
- Mathematical operations on structured data

### **SwiftUI Mastery**
- @FetchRequest with dynamic predicates
- Professional form design with validation
- Sheet navigation and dismissal patterns
- Real-time search implementation
- Category-aware organization throughout

### **Professional Development Practices**
- Phase-based planning with accurate estimates
- Comprehensive learning documentation
- Architecture decision records
- Performance-first development
- Clean replacement vs dual storage

---

## 🔗 **RELATED RESOURCES**

### **External Documentation**
- **Apple Core Data**: https://developer.apple.com/documentation/coredata
- **SwiftUI Navigation**: https://developer.apple.com/documentation/swiftui/navigation
- **CloudKit Framework**: https://developer.apple.com/documentation/cloudkit

### **Project-Specific Patterns**
- All service patterns documented in learning notes
- ADRs explain key architectural decisions
- PRDs provide detailed feature specifications
- Requirements.md tracks all functional requirements

---

## 📊 **PROJECT STATISTICS**

### **Code Quality Metrics**
- **Total Development Hours**: 55.5 hours (M1: 32h, M2: 16.5h, M3: 7h)
- **Build Success Rate**: 100% - Clean builds throughout
- **Performance Targets Met**: 100% - All operations < 0.5s
- **Documentation Coverage**: 100% - All phases documented

### **Feature Completion**
- **M1**: 100% - 6/6 phases complete
- **M2**: 100% - All 3 components complete (M2.1, M2.2, M2.3)
- **M3**: 67% - 4/6 phases complete (Phase 5-6 remaining)

### **Development Velocity**
- **Average Phase Duration**: 1.5 hours
- **Planning Accuracy**: ±15 minutes per phase
- **Quality Consistency**: Professional standards maintained throughout

---

**Last Updated**: October 11, 2025  
**Next Update**: After M3 Phase 5 completion  
**Maintainer**: Development team following docs/project-naming-standards.md