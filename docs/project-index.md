# Forager - Project Index

**Last Updated**: December 10, 2024  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M7 - CloudKit Sync & External TestFlight (M7.0 ✅, M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🚀 READY)  
**Next Priority**: M7.1.3 CloudKit Sync Integrity (11-15 hours) ⭐ **COMPREHENSIVE ARCHITECTURAL FIX**

---

## 🚨 **START HERE: MANDATORY SESSION STARTUP**

### **For EVERY Development Session:**

**⚠️ CRITICAL - Complete these in order:**

1. **[Session Startup Checklist](session-startup-checklist.md)** ← **START HERE FIRST**
   - Mandatory 8-point checklist for every session (UPDATED with git workflow!)
   - Ensures naming consistency and context loading
   - Prevents 7-16 hours of potential rework
   - **10-15 minutes that save hours**

2. **[Project Naming Standards](project-naming-standards.md)** ← **READ SECOND**
   - M#.#.# naming hierarchy (e.g., M7.1.3)
   - Status indicators (✅ 🔄 🚀 ⏳)
   - Quick reference card at top
   - **Zero tolerance for incorrect naming**

3. **[Current Story](current-story.md)** ← **READ THIRD**
   - Current milestone and active phases
   - What's 🚀 READY to start
   - Recently completed work ✅
   - Next steps with prompts
   - **⚠️ M7.1.3 SCOPE CHANGED - Read carefully!**

4. **[Next Prompt](next-prompt.md)** ← **READ FOURTH**
   - Ready-to-use implementation prompt
   - Current phase guidance
   - Technical requirements
   - Acceptance criteria
   - **Complete M7.1.3 implementation guide (11-15 hours)**

**Why this order matters:**
- Checklist → Ensures you follow the complete process
- Naming Standards → Establishes the language/convention
- Current Story → Provides specific project state (includes critical scope change info)
- Next Prompt → Gives implementation details

**Failure to follow this sequence breaks project continuity.**

---

## 🚨 **CRITICAL: M7.1.3 SCOPE CHANGED**

### **Original Plan vs New Reality**

**Original M7.1.3 (3-4 hours):** Basic two-device sync testing

**⚠️ DISCOVERED FUNDAMENTAL ISSUE:** Multi-device testing revealed CloudKit creates duplicate entities when devices create semantically identical objects (e.g., same Category name). This causes crashes: `"Duplicate values for key: 'Produce'"`.

**New M7.1.3 (11-15 hours):** Comprehensive architectural fix
- **Three-layer semantic uniqueness architecture**
- **Two-stage migration** for CloudKit safety
- **Repository pattern** implementation
- **Field standardization** (name → displayName)
- **11 ADRs** documenting all decisions
- **Production-ready CloudKit sync**

**This is the RIGHT fix - addressing root cause, not symptoms.**

**See:** `docs/prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md`

---

## 🚀 **QUICK START BY ACTIVITY TYPE**

### **Starting M7.1.3 CloudKit Sync Integrity (Current Work)** 🚀 READY
1. Complete [Session Startup Checklist](session-startup-checklist.md) (ALL 8 items)
2. **READ CRITICALLY**: [Current Story](current-story.md) - Understand scope change
3. **STUDY PRD**: `docs/prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md`
4. Read [Next Prompt](next-prompt.md) - Phase 1.1 Stage A Migration guide
5. Review last Git checkpoint - Know where you left off
6. Begin Phase 1.1: Create Model Version 2, add optional semantic keys

### **Continuing M7.1.3 (After Phase 1.1)**
1. Complete [Session Startup Checklist](session-startup-checklist.md)
2. Check [Current Story](current-story.md) - Verify phase status
3. Read [Next Prompt](next-prompt.md) - Current phase implementation guide
4. Continue with next phase (1.2, 2.1, 2.2, etc.)

### **Starting New M7 Phase (After M7.1.3)**
1. Complete [Session Startup Checklist](session-startup-checklist.md)
2. Read [M7 PRD](prds/milestone-7-cloudkit-sync-external-testflight.md) - Complete plan
3. Check [Current Story](current-story.md) - Next phase details
4. **Strategic decision point**: M7.2 Collaboration vs M6 Testing vs M8 Analytics

### **Planning Future Features (After M7)**
1. Review [Requirements](requirements.md) - Check existing requirements (155 total with M7.1.3)
2. Check [Roadmap](roadmap.md) - Verify strategic fit
3. Review [Architecture](architecture/) - Check for relevant ADRs (11 new ADRs in M7.1.3!)
4. Create PRD in `prds/` if complex (6+ hours)
5. Update [Current Story](current-story.md) with new work (using M#.#.# naming)

### **Understanding Project Status**
1. Check [Current Story](current-story.md) - Detailed current state (includes M7.1.3 scope change!)
2. Review [Roadmap](roadmap.md) - Milestone sequence and completion
3. See "Current State" section below - Quick overview
4. Review recent [Learning Notes](learning-notes/) - Implementation details

### **Completing Work**
1. Update [Current Story](current-story.md) - Mark ✅ COMPLETE with actual hours
2. Update [Project Index](project-index.md) - Add to Recent Activity
3. Create/update [Learning Notes](learning-notes/) - Document journey
4. **Create ADRs** (if M7.1.3 Phase 6) - Document architectural decisions
5. If milestone complete, update [Roadmap](roadmap.md)
6. **Complete git workflow** - PR, squash merge, update main

---

## 📋 **CORE DOCUMENTATION**

### **🎯 Critical Workflow Documents**

#### **[session-startup-checklist.md](session-startup-checklist.md)**
**Purpose**: Mandatory startup procedure for EVERY session  
**Contents**:
- 8-point checklist (4 for context, 4 for development) ⭐ **UPDATED WITH GIT WORKFLOW**
- Prevents duplicate work, naming issues, architecture conflicts
- Time saved: 7-16 hours of rework per session
- **Read first, every time, no exceptions**
- **Item #8**: Create feature branch before any code

#### **[project-naming-standards.md](project-naming-standards.md)**
**Purpose**: M#.#.# naming hierarchy and conventions  
**Contents**:
- Quick reference card (M7.1.3 format)
- Status indicators (✅ 🔄 🚀 ⏳)
- Enforcement guidelines
- Current project mapping
- **Zero tolerance for non-compliance**

#### **[current-story.md](current-story.md)**
**Purpose**: Active milestone status and progress tracking  
**Contents**:
- Current milestone progress (M7.1 ACTIVE with M7.1.3 scope change!)
- Phase-by-phase breakdown with estimates
- Next actions and start prompts
- Recent completions summary (M1-M7.1.2)
- **⚠️ CRITICAL M7.1.3 scope change explanation**
- **Updated after every development session**

#### **[next-prompt.md](next-prompt.md)**
**Purpose**: Copy-paste ready implementation guidance  
**Contents**:
- Current phase implementation guide (M7.1.3 Phase 1.1 Stage A Migration)
- Technical requirements and code examples
- Integration points
- Acceptance criteria
- Validation checkpoints
- **Complete M7.1.3 CloudKit Sync Integrity guide (11-15 hours)**
- Detailed 6-phase breakdown with code templates

#### **[development-guidelines.md](development-guidelines.md)**
**Purpose**: How Claude should work - code standards and patterns  
**Contents**:
- Session startup requirements
- Pre-development analysis checklist
- Proven patterns from M1-M7
- Code documentation standards
- Quality gates and success criteria
- **Git workflow requirements** (feature branches, PR workflow)
- **Reference during development work**

---

### **📊 Strategic Documents**

#### **[requirements.md](requirements.md)**
**Purpose**: All functional and non-functional requirements  
**Contents**:
- Requirements organized by milestone
- Traceability to implementation
- Success criteria per feature
- M1-M4 complete (108 requirements ✅)
- **M7.1.3 adds semantic uniqueness requirements (4 new)**

#### **[roadmap.md](roadmap.md)**
**Purpose**: Milestone sequence and high-level timeline  
**Contents**:
- M1-M7.0 complete with actual hours
- M7.1 in progress (2 of 3 phases complete)
- **M7.1.3 scope expanded** (architectural fix + testing)
- Future milestones (M7.2-M11) outlined
- Strategic decisions documented

---

### **📁 Implementation Documentation**

#### **PRDs (Product Requirements Documents)**

**Active PRDs**:
- **[M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md](prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md)** ⭐ **NEW**
  - Complete semantic uniqueness architecture
  - Two-stage migration strategy
  - Repository pattern implementation
  - 11 architectural decisions documented
  - 6 implementation phases with code examples
  - 11-15 hours estimated
  
- **[milestone-7-cloudkit-sync-external-testflight.md](prds/milestone-7-cloudkit-sync-external-testflight.md)** ← Overall M7 plan
  - Complete CloudKit sync + external TestFlight
  - 6 phases (M7.0-M7.6) with detailed breakdowns
  - M7.0 complete ✅ (3h)
  - M7.1 active 🔄 (2 of 3 phases complete, 3.5h so far, 11-15h remaining)
  - 27-37 hours estimated total (now 38-48h with M7.1.3 expansion)

**Completed PRDs** (in docs/prds/complete/):
- M1: Professional Grocery Management
- M2: Recipe Integration
- M3: Structured Quantity Management
- M4: Meal Planning & Enhanced Grocery Integration
- M5.0: App Renaming & TestFlight Deployment

#### **Learning Notes** (Implementation Journey)

**Recent Notes**:
- [24-m7.1.1-cloudkit-schema-validation.md](learning-notes/24-m7.1.1-cloudkit-schema-validation.md)
- [23-m4.3.5-ingredient-normalization.md](learning-notes/23-m4.3.5-ingredient-normalization.md)
- [22-m4.3.1-recipe-source-tracking.md](learning-notes/22-m4.3.1-recipe-source-tracking.md)
- [19-m4.2-calendar-meal-planning.md](learning-notes/19-m4.2-calendar-meal-planning.md)
- [18-m4.1-settings-infrastructure.md](learning-notes/18-m4.1-settings-infrastructure.md)

**To Create**:
- 25-m7.1.2-cloudkit-sync-monitor.md (after M7.1.2 complete)
- 26-m7.1.3-cloudkit-sync-integrity.md ⭐ **MAJOR - Comprehensive with ADRs** (after M7.1.3 complete)
- This will be one of the most comprehensive learning notes yet!

#### **Architecture Decision Records (ADRs)**

**Existing ADRs** (in docs/architecture/):
- ADR-001: Selective Technical Improvements
- ADR-006: Consolidate Staples and Ingredients
- ADR-007: Core Data Change Process

**To Create in M7.1.3 Phase 6** (11 new ADRs!):
- ADR-009: Two-Stage Migration Strategy
- ADR-010: PlannedMeal Slot Uniqueness
- ADR-011: WeeklyList No Uniqueness
- ADR-012: DisplayName Standardization
- ADR-013: Timezone Handling for Slot Keys
- ADR-014: Skip Deduplication Service
- ADR-015: Repository Pattern for Semantic Uniqueness
- ADR-016: Recipe Duplicate Detection
- ADR-017: GroceryListItem Duplicates By Design
- ADR-018: Canonical Normalization Helpers
- ADR-019: Merge Policy for Conflict Resolution

**This doubles our ADR count and establishes forager's architectural knowledge base!**

---

## 📅 **RECENT ACTIVITY**

### **December 10, 2024** - M7.1.3 PRD v4.1 Created ⭐
- **Created**: M7.1.3 CloudKit Sync Integrity PRD v4.1 (comprehensive architectural fix)
- **Discovered**: Fundamental CloudKit semantic uniqueness issue (duplicate entities)
- **Scope Change**: From 3-4h testing → 11-15h architectural fix + testing
- **Architecture**: Three-layer semantic uniqueness system designed
- **Documentation**: 11 architectural decisions captured in PRD
- **Decision**: Fix root cause (not patch symptoms) - production-ready approach
- **Status**: M7.1.3 ready to start with Phase 1.1 (Stage A Migration)
- **Updated**: current-story.md, next-prompt.md, project-index.md (this file)
- **Next**: Begin M7.1.3 Phase 1.1 - Create Model Version 2, add optional semantic keys

### **December 4, 2025** - M7.1.2 Complete ✅
- **Completed**: M7.1.2 - CloudKitSyncMonitor Service (2 hours - 100% accuracy!)
- **Achievement**: Real-time sync monitoring operational
- **Technical**: 226-line service + 273-line test view
- **Validation**: 46 sync events observed, < 1 second latency
- **Integration**: Settings → Developer Tools → CloudKit Sync Status
- **Next**: M7.1.3 Multi-Device Sync Testing (originally 3-4 hours, now 11-15 hours)

### **December 4, 2025** - M7.1.1 Complete ✅
- **Completed**: M7.1.1 - CloudKit Schema Validation (1.5 hours - 100% accuracy!)
- **Achievement**: NSPersistentCloudKitContainer integration successful
- **Technical**: 8+ record types auto-generated in CloudKit Dashboard
- **Validation**: 28 sync events observed, schema confirmed
- **Strategy**: #if !DEBUG wrapper for fast development (Debug = local, Release = CloudKit)
- **Next**: M7.1.2 CloudKitSyncMonitor Service

### **December 3, 2025** - M7.0 Complete ✅ + M7 Planning Complete
- **Completed**: M7.0 - App Store Prerequisites (3 hours - 100% accuracy!)
- **Achievement**: All Apple App Store requirements met
- **Deliverables**: Privacy policy published, in-app privacy link, questionnaire complete
- **Created**: M7 PRD - CloudKit Sync & External TestFlight (complete 80-page plan)
- **Updated**: requirements.md - Added M7.0 (4 new requirements, 151 total)
- **Updated**: roadmap.md - M7 details with all 6 phases
- **Status**: Ready to execute M7.1.1 - CloudKit Schema Validation
- **Next**: M7.1 CloudKit Sync Foundation (3 phases, 8-10 hours)

### **December 2, 2025** - M5.0 Complete ✅
- **Completed**: M5.0 - App Renaming & TestFlight Deployment (6 hours)
- **Achievement**: Complete rename to "forager: smart meal planner"
- **Deliverables**: Professional app icon, internal TestFlight, multi-tester beta
- **Status**: Forager brand established, ready for M7 CloudKit sync
- **Planning Accuracy**: 86% (6h actual vs 7h estimated)

---

## 📊 **CURRENT STATE**

### **Project Metrics**
- **Total Development Time**: ~99 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h + M7.1.2: 2h)
- **Planning Accuracy**: 89% overall (consistently within estimates)
- **Build Success**: 100% (zero breaking changes)
- **Performance**: 100% (all operations <0.5s target maintained)
- **Data Integrity**: 100% (zero data loss across all migrations)
- **Technical Debt**: NONE ✅
- **Architectural Decisions**: 7 ADRs complete, 11 to be created in M7.1.3

### **Milestones Complete** ✅
- **M1**: Professional Grocery Management (32 hours)
- **M2**: Recipe Integration (16.5 hours)
- **M3**: Structured Quantity Management (10.5 hours)
- **M3.5**: Foundation Validation (8.5 hours)
- **M4**: Meal Planning & Enhanced Grocery (19.25 hours)
- **M5.0**: App Renaming & TestFlight (6 hours)
- **M7.0**: App Store Prerequisites (3 hours)
- **M7.1.1**: CloudKit Schema Validation (1.5 hours)
- **M7.1.2**: CloudKitSyncMonitor Service (2 hours)

### **Current Work** 🔄
- **M7.1.3**: CloudKit Sync Integrity (11-15 hours) 🚀 READY ⭐ **COMPREHENSIVE SCOPE**
  - **NOT just testing** - architectural fix for semantic uniqueness
  - Three-layer architecture: Core Data model + Repositories + Application layer
  - Two-stage migration for CloudKit safety
  - 11 ADRs documenting all decisions
  - Production-ready CloudKit sync foundation

### **Technology Stack**
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 18.5+)
- **Persistence**: Core Data + NSPersistentCloudKitContainer
- **Cloud Backend**: CloudKit (Development environment)
- **Testing**: XCTest framework + TestFlight
- **Version Control**: Git + GitHub (feature branch workflow)

### **App Features** (Fully Operational)
- ✅ Professional grocery list management with store-layout optimization
- ✅ Recipe catalog with ingredient tracking and scaling
- ✅ Structured quantity management with intelligent consolidation
- ✅ Calendar-based meal planning with recipe integration
- ✅ Automated meal plan to grocery list conversion
- ✅ Settings infrastructure with user preferences
- ✅ Internal TestFlight deployment
- ✅ CloudKit infrastructure (schema validated, sync monitoring operational)
- 🚀 **Semantic uniqueness architecture** (M7.1.3 in progress)

### **Key Achievements**
- 8+ CloudKit record types auto-generated and validated
- 46 sync events observed with < 1 second latency
- Professional iOS app with App Store readiness
- Zero technical debt maintained throughout
- 89% planning accuracy across all milestones
- Sub-millisecond performance for all operations
- Comprehensive documentation and learning notes
- **Discovered and designing fix for CloudKit semantic uniqueness issue**

---

## 🎯 **WHAT'S NEXT**

### **Immediate Priority** (M7.1.3 - 11-15 hours)
CloudKit Sync Integrity - Comprehensive architectural fix:

**Phase 1: Core Data Model (2-3h)**
- Stage A: Add optional semantic key fields
- Stage B: Make required, add constraints
- Two-stage migration for CloudKit safety

**Phase 2: Repositories (2-3h)**
- CategoryRepository - Get-or-create pattern
- PlannedMealRepository - Slot protection
- Enhanced IngredientTemplateService
- RecipeDuplicateDetector

**Phase 3: Code Integration (2-3h)**
- Wire up all repositories
- Update entity creation code
- Add user dialogs (Recipe duplicates, slot conflicts)

**Phase 4: Two-Device Testing (2-3h)**
- Environment setup (2 iPhones, same iCloud)
- Repository pattern validation
- Simultaneous offline creation (critical)
- CloudKit Dashboard verification

**Phase 5: Basic Documentation (1h)**
- Learning notes
- Update project docs

**Phase 6: ADRs & Learning Documents (1.5-2h)** ⭐ **NEW**
- Create all 11 ADR documents
- Comprehensive learning notes with code examples
- Cross-reference all documentation
- Establish architectural knowledge base

**Total: 11-15 hours (conservative: 12 hours)**

### **Strategic Options After M7.1.3**
1. **Continue M7.2**: Multi-User Collaboration (8-10h) - CKShare for family meal planning
2. **Pause M7, Start M6**: Testing Foundation (12-18h) - build comprehensive test suite
3. **Pause M7, Start M8**: Analytics Dashboard (8-12h) - usage insights and patterns

**The right choice:** Probably M7.2 to complete CloudKit foundation while context is fresh.

---

## 🚨 **CRITICAL REMINDERS**

1. **Session Startup**: Complete [session-startup-checklist.md](session-startup-checklist.md) EVERY session (now 8 items!)
2. **Naming Standards**: Always use M#.#.# format (enforced in [project-naming-standards.md](project-naming-standards.md))
3. **Documentation Updates**: Update [current-story.md](current-story.md) after EVERY session
4. **Learning Notes**: Create comprehensive notes after milestone completion
5. **ADRs**: Document all major architectural decisions (M7.1.3 creates 11!)
6. **Git Workflow**: Feature branches → PR → squash merge → main
7. **Zero Technical Debt**: Maintain quality standards throughout
8. **Performance Targets**: <0.5s for operations, <5s for CloudKit sync
9. **M7.1.3 Scope**: Remember this is architectural fix, not just testing!

---

## 📚 **LEARNING RESOURCES**

### **Internal Knowledge**
- [learning-notes/](learning-notes/) - 24+ implementation journey notes (+1 major note coming!)
- [architecture/](architecture/) - 7+ architecture decision records (+11 coming in M7.1.3!)
- [prds/](prds/) - 7+ product requirement documents

### **External Resources**
- [NSPersistentCloudKitContainer Documentation](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
- [Core Data Model Versioning](https://developer.apple.com/documentation/coredata/core_data_model_versioning_and_data_migration)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com)

---

**Version**: 8.0 - M7.1.3 Scope Expansion  
**Last Updated**: December 10, 2024  
**Maintained By**: Rich Hayn  
**Project**: forager - Smart Meal Planning  
**Repository**: https://github.com/rfhayn/forager.git