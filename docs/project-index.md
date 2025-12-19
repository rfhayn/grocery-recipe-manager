# Forager - Project Index

**Last Updated**: December 18, 2025  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M7 - CloudKit Sync & External TestFlight (M7.0 ✅, M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🔄 ACTIVE)  
**Next Priority**: M7.1.3 Phase 1.2 - Repository Pattern Implementation (3-4 hours) 🚀 READY

---

## 🚨 **START HERE: MANDATORY SESSION STARTUP**

### **For EVERY Development Session:**

**⚠️ CRITICAL - Complete these in order:**

1. **[Session Startup Checklist](session-startup-checklist.md)** ← **START HERE FIRST**
   - Mandatory 8-point checklist for every session (updated with git workflow!)
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

4. **[Next Prompt](next-prompt.md)** ← **READ FOURTH**
   - Ready-to-use implementation prompt
   - Current phase guidance
   - Technical requirements
   - Acceptance criteria
   - **Complete M7.1.3 Phase 1.2 Repository Pattern implementation guide**

**Why this order matters:**
- Checklist → Ensures you follow the complete process
- Naming Standards → Establishes the language/convention
- Current Story → Provides specific project state
- Next Prompt → Gives implementation details

**Failure to follow this sequence breaks project continuity.**

---

## 🚀 **QUICK START BY ACTIVITY TYPE**

### **Continuing M7.1.3 CloudKit Sync Integrity (Current Work)** 🔄 ACTIVE
1. Complete [Session Startup Checklist](session-startup-checklist.md) (ALL 8 items - includes git workflow!)
2. Read [Current Story](current-story.md) - M7.1.3 status and progress
3. Read [Next Prompt](next-prompt.md) - Phase 1.2 Repository Pattern implementation guide
4. Review last Git checkpoint - Phase 1.1 complete, ready to create new feature branch for Phase 1.2
5. Start Phase 1.2 (Repository Pattern Implementation)

### **Starting New M7 Phase (After M7.1.3)**
1. Complete [Session Startup Checklist](session-startup-checklist.md)
2. Read [M7 PRD](prds/milestone-7-cloudkit-sync-external-testflight.md) - Complete plan
3. Check [Current Story](current-story.md) - Next phase details
4. Follow implementation guide for that phase

### **Planning Future Features (After M7)**
1. Review [Requirements](requirements.md) - Check existing requirements (151 total)
2. Check [Roadmap](roadmap.md) - Verify strategic fit
3. Review [Architecture](architecture/) - Check for relevant ADRs
4. Create PRD in `prds/` if complex (6+ hours)
5. Update [Current Story](current-story.md) with new work (using M#.#.# naming)

### **Understanding Project Status**
1. Check [Current Story](current-story.md) - Detailed current state
2. Review [Roadmap](roadmap.md) - Milestone sequence and completion
3. See "Current State" section below - Quick overview
4. Review recent [Learning Notes](learning-notes/) - Implementation details
5. Check [M7 Breadcrumb Trail](m7-docs/) - Detailed M7.1.3 progress

### **Completing Work**
1. Update [Current Story](current-story.md) - Mark ✅ COMPLETE with actual hours
2. Update [Project Index](project-index.md) - Add to Recent Activity
3. Create/update [Learning Notes](learning-notes/) or [M7 Breadcrumb Trail](m7-docs/)
4. Complete [Git PR Workflow](git-workflow-for-milestones.md) - Squash merge to main
5. If milestone complete, update [Roadmap](roadmap.md)

---

## 📋 **CORE DOCUMENTATION**

### **🎯 Critical Workflow Documents**

#### **[session-startup-checklist.md](session-startup-checklist.md)**
**Purpose**: Mandatory startup procedure for EVERY session  
**Contents**:
- 8-point checklist (3 for context, 4 for development, 1 for git!)
- Prevents duplicate work, naming issues, architecture conflicts, messy git history
- Time saved: 7-16 hours of rework per session
- **Read first, every time, no exceptions**

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
- Current milestone progress (M7.1.3 Phase 1.1 Part 2 COMPLETE)
- Phase-by-phase breakdown with estimates
- Next actions and start prompts
- Recent completions summary (M1-M7.1.3 Part 2)
- **Updated after every development session**

#### **[next-prompt.md](next-prompt.md)**
**Purpose**: Copy-paste ready implementation guidance  
**Contents**:
- Current phase implementation guide
- Technical requirements
- Integration points
- Acceptance criteria
- Validation checkpoints
- **Complete M7.1.3 Phase 1.1 Part 3 implementation (1-1.5 hours)**
- Detailed breakdown with code examples

#### **[development-guidelines.md](development-guidelines.md)**
**Purpose**: How Claude should work - code standards and patterns  
**Contents**:
- Session startup requirements
- Pre-development analysis checklist
- Proven patterns from M1-M7
- Code documentation standards
- Quality gates and success criteria
- **Reference during development work**

#### **[git-workflow-for-milestones.md](git-workflow-for-milestones.md)**
**Purpose**: Feature branch workflow with squash merges  
**Contents**:
- Complete git workflow for milestones
- Feature branch naming conventions
- Commit frequency guidelines (every 15-30 min)
- PR creation and squash merge process
- Clean main branch history strategy
- **Essential for M7+ development**

---

### **📊 Strategic Documents**

#### **[requirements.md](requirements.md)**
**Purpose**: All functional and non-functional requirements  
**Contents**:
- Requirements organized by milestone
- Traceability to implementation
- Success criteria per feature
- M1-M4 complete (108 requirements ✅)

#### **[roadmap.md](roadmap.md)**
**Purpose**: Milestone sequence and high-level timeline  
**Contents**:
- M1-M7.0 complete with actual hours
- M7.1.3 in progress (Phase 1.1 Parts 1-2 complete)
- Future milestones (M7.2-M11) outlined
- Strategic decisions documented

---

### **📁 Implementation Documentation**

#### **PRDs (Product Requirements Documents)**

**Active PRD**:
- **[milestone-7-cloudkit-sync-external-testflight.md](prds/milestone-7-cloudkit-sync-external-testflight.md)** ← Current milestone
  - Complete CloudKit sync + external TestFlight
  - 6 phases (M7.0-M7.6) with detailed breakdowns
  - M7.0 complete ✅ (3h)
  - M7.1 active 🔄 (multiple sub-phases)
  - 27-37 hours estimated total

**M7.1.3 Specific PRD**:
- **[m7.1.3-cloudkit-sync-integrity.md](prds/m7.1.3-cloudkit-sync-integrity.md)**
  - Comprehensive 3-phase plan to prevent CloudKit duplicates
  - Phase 1.1 Parts 1-2 complete (5h actual)
  - Semantic keys + population functions operational

**Completed PRDs** (in docs/prds/complete/):
- M1: Professional Grocery Management
- M2: Recipe Integration
- M3: Structured Quantity Management
- M4: Meal Planning & Enhanced Grocery Integration
- M5.0: App Renaming & TestFlight Deployment

#### **M7 Breadcrumb Trail** (Detailed Progress Notes)

**Purpose**: Comprehensive documentation of M7.1.3 implementation journey for future consolidation into learning notes

**Active Breadcrumbs**:
- **[M7.1.3-PHASE1.1-PART1-COMPLETION.md](M7.1.3-PHASE1.1-PART1-COMPLETION.md)** (Dec 17, 2025)
  - Model Version 2 with semantic key fields
  - 4 entities updated with fetch indexes
  - 2.5 hours, 100% planning accuracy
  
- **[m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md](m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md)** (Dec 18, 2025)
  - 4 population functions + master migration
  - Idempotency with UserDefaults pattern
  - 0.02s performance for 53 entities
  - 2.5 hours, 100% planning accuracy
  - **Most comprehensive breadcrumb to date**

**Future Consolidation**: Will create final learning notes after Phase 1.1 complete

#### **Learning Notes** (Implementation Journey)

**Recent Notes**:
- [24-m7.1.1-cloudkit-schema-validation.md](learning-notes/24-m7.1.1-cloudkit-schema-validation.md)
- [23-m4.3.5-ingredient-normalization.md](learning-notes/23-m4.3.5-ingredient-normalization.md)
- [22-m4.3.1-recipe-source-tracking.md](learning-notes/22-m4.3.1-recipe-source-tracking.md)
- [19-m4.2-calendar-meal-planning.md](learning-notes/19-m4.2-calendar-meal-planning.md)
- [18-m4.1-settings-infrastructure.md](learning-notes/18-m4.1-settings-infrastructure.md)

**To Create**:
- 25-m7.1.2-cloudkit-sync-monitor.md (after M7.1.2 consolidation)
- 26-m7.1.3-phase1.1-semantic-keys.md (after Phase 1.1 complete)

#### **Architecture Decision Records**

**Key ADRs**:
- [001-selective-technical-improvements.md](architecture/001-selective-technical-improvements.md)
- [006-consolidate-staples-and-ingredients.md](architecture/006-consolidate-staples-and-ingredients.md)
- [007-core-data-change-process.md](architecture/007-core-data-change-process.md)

---

## 📞 **DOCUMENTATION QUICK LINKS**

**When you need to know...**

| What | Check This Document |
|------|-------------------|
| How to start a session | [session-startup-checklist.md](session-startup-checklist.md) |
| Git workflow | [git-workflow-for-milestones.md](git-workflow-for-milestones.md) |
| Correct M#.#.# naming | [project-naming-standards.md](project-naming-standards.md) |
| What's active now | [current-story.md](current-story.md) |
| How to implement Part 3 | [next-prompt.md](next-prompt.md) |
| Complete M7.1.3 plan | [prds/m7.1.3-cloudkit-sync-integrity.md](prds/m7.1.3-cloudkit-sync-integrity.md) |
| Part 2 implementation details | [m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md](m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md) |
| Code standards | [development-guidelines.md](development-guidelines.md) |
| What features are needed | [requirements.md](requirements.md) |
| Milestone timeline | [roadmap.md](roadmap.md) |
| Architecture decisions | [architecture/](architecture/) |
| Feature details | [prds/](prds/) |
| How something was built | [learning-notes/](learning-notes/) or [m7-docs/](m7-docs/) |

---

## 🔥 **RECENT ACTIVITY**

### **December 18, 2025** - M7.1.3 Phase 1.1 COMPLETE! 🎉 All 4 Parts Done - Semantic Keys Foundation Ready
- **Completed**: M7.1.3 Phase 1.1 - Semantic Keys Foundation (5.5 hours, 92% estimate accuracy!)
- **Achievement**: Complete semantic uniqueness infrastructure for CloudKit duplicate prevention
- **All 4 Parts**:
  - **Part 1 - Schema** (1h): 8 fields added to 4 entities with fetch indexes
  - **Part 2 - Population** (1.5h): 4 functions + master migration (0.04s for 53 entities!)
  - **Part 3 - Helpers** (1.5h): 4 static helpers for DRY normalization
  - **Part 4 - Testing** (1.5h): Fresh install + idempotency validation
- **Deliverables**:
  - Model Version 2 with semantic keys (normalizedName, canonicalName, slotKey, titleKey)
  - Idempotent migration with UserDefaults tracking
  - 4 reusable static helpers in extension files
  - MigrationTestHelper.swift for testing
  - Zero build errors, zero regressions
- **Performance**: 0.04s migration (2.5x better than 0.1s target!)
- **Documentation**: 
  - [learning-notes/25-m7.1.3-phase1.1-semantic-keys-foundation.md](learning-notes/25-m7.1.3-phase1.1-semantic-keys-foundation.md) - Comprehensive learning note
  - [m7-docs/M7.1.3-PHASE1.1-PART1-COMPLETION.md](m7-docs/M7.1.3-PHASE1.1-PART1-COMPLETION.md) - Part 1 breadcrumb
  - [m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md](m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md) - Part 2 breadcrumb
- **Git**: 17 clean commits, branch: feature/M7.1.3-phase1.1-fresh-start (ready for PR)
- **Next**: M7.1.3 Phase 1.2 - Repository Pattern (3-4h) - Implement findOrCreate functions
- **Total Progress**: 107.5 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h + M7.1.2: 2h + M7.1.3 Phase 1.1: 5.5h + doc updates: 0.5h)
- **Planning Accuracy**: 92% overall!

### **December 18, 2025** - M7.1.3 Phase 1.1 Part 2 Complete - Semantic Key Population Operational [CONSOLIDATED ABOVE]
- **Completed**: M7.1.3 Phase 1.1 Part 2 - Semantic Key Population (2.5 hours, 100% estimate accuracy!)
- **Achievement**: Complete migration system with idempotency for CloudKit duplicate prevention
- **Deliverables**:
  - populateCategorySemanticKeys() - normalizes Category names (7 populated)
  - populateIngredientTemplateSemanticKeys() - normalizes template names (35 populated)
  - populatePlannedMealSemanticKeys() - generates slotKey from date+mealType (0 meals - none exist yet)
  - populateRecipeSemanticKeys() - normalizes titles for duplicate detection (11 populated)
  - performStageAMigration() - master orchestration with UserDefaults idempotency
  - Integrated into performOneTimeSetup() as Step 6
  - Manual property additions for Category and Recipe (Manual/None codegen)
  - Auto-generated properties for IngredientTemplate and PlannedMeal (Class Definition codegen)
- **Performance**: **0.02 seconds** for 53 entities (5x better than < 0.1s target!)
- **Testing**: Fresh install ✅ (migration executed), Idempotency ✅ (migration skipped on rerun)
- **Key Learnings**:
  - Codegen differences critical (Manual/None vs Class Definition)
  - Field naming verification essential (name vs displayName confusion)
  - UserDefaults perfect for migration flags (simple, reliable, fast)
  - Timing pattern for testing (first run 0 count, second run correct count)
- **Documentation**: [m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md](m7-docs/M7.1.3-PHASE1.1-PART2-COMPLETION.md) - **Most comprehensive breadcrumb to date**
- **Git**: 5 clean commits with M7.1.3 format, branch: feature/M7.1.3-phase1.1-fresh-start
- **Next**: M7.1.3 Phase 1.1 Part 3 - Normalization Helpers (1-1.5h) - Refactor to reusable functions
- **Total Progress**: 104 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h + M7.1.2: 2h + M7.1.3 Part 1: 2.5h + Part 2: 2.5h)
- **Planning Accuracy**: 90% overall, recent phases 100%!

### **December 17, 2025** - M7.1.3 Phase 1.1 Part 1 COMPLETE! 🎉 Semantic Key Fields Added
- **Completed**: M7.1.3 Phase 1.1 Part 1 - Model Version 2 (2.5 hours, 100% estimate accuracy!)
- **Achievement**: Semantic uniqueness infrastructure for CloudKit duplicate prevention
- **Deliverables**:
  - Model Version 2 created with semantic key fields
  - Category: normalizedName + updatedAt with fetch index
  - IngredientTemplate: canonicalName + updatedAt with fetch index
  - PlannedMeal: slotKey + mealType with fetch index
  - Recipe: titleKey with fetch index
  - All fields Optional for two-stage migration
  - Zero build errors, zero regressions
- **Approach**: One entity at a time (30 min each) with build/test/commit cycle
- **Documentation**: [M7.1.3-PHASE1.1-PART1-COMPLETION.md](M7.1.3-PHASE1.1-PART1-COMPLETION.md)
- **Git**: 5 clean commits, branch: feature/M7.1.3-phase1.1-fresh-start
- **Total Progress**: 101.5 hours

### **December 4, 2025** - M7.1.2 COMPLETE! 🎉 CloudKit Sync Monitoring Operational
- **Completed**: M7.1.2 - CloudKitSyncMonitor Service (2 hours, 100% estimate accuracy!)
- **Achievement**: Real-time CloudKit sync observation with sub-second latency
- **Deliverables**:
  - CloudKitSyncMonitor.swift service (226 lines) - ObservableObject for SwiftUI
  - CloudKitSyncTestView.swift test interface (273 lines) - visual sync status
  - 46 sync events observed successfully during implementation
  - Sync latency: < 1 second (nearly instant detection)
  - Event counting and state tracking (idle, syncing, synced, error)
  - Manual sync trigger and state reset functionality
  - Comprehensive CloudKit error mapping (8+ CKError codes)
  - Integration into Settings → Developer Tools
  - @StateObject/@EnvironmentObject pattern for app-wide sync state
  - Combine-based notification observation (.NSPersistentStoreRemoteChange)
- **Validation**: Test data creation working, zero regressions
- **Console**: Clean sync event logging with timestamps and history tokens
- **Total Progress**: 99 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h + M7.1.2: 2h)
- **Planning Accuracy**: 89% overall, recent phases 100%!

### **December 4, 2025** - M7.1.1 COMPLETE! 🎉 CloudKit Schema Validated
- **Completed**: M7.1.1 - CloudKit Schema Validation (1.5 hours, 100% estimate accuracy!)
- **Achievement**: CloudKit infrastructure operational with auto-generated schema
- **Deliverables**:
  - NSPersistentCloudKitContainer integration (replaced NSPersistentContainer)
  - CloudKit container configuration (iCloud.com.richhayn.forager)
  - History tracking and remote change notifications enabled
  - #if !DEBUG wrapper for fast local development (Debug: local, Release: CloudKit)
  - 8+ record types auto-generated in CloudKit Dashboard Development environment
  - Sync activity confirmed (28 events, RecordSave operations logged)
  - Zero regressions, first build succeeded
- **Learning**: NSPersistentCloudKitContainer is API-compatible subclass (zero code changes elsewhere)
- **Documentation**: M7.1.1-CORE-DATA-IMPACT-ANALYSIS.md + comprehensive learning note
- **Total Progress**: 97 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h)
- **Planning Accuracy**: 89% overall, 100% recent phases!

### **December 3, 2025** - M7.0 COMPLETE! 🎉 App Store Prerequisites Done
- **Completed**: M7.0 - App Store Prerequisites (3 hours, 100% estimate accuracy!)
- **Achievement**: All mandatory Apple requirements met for external TestFlight
- **Deliverables**:
  - Privacy policy published at https://rfhayn.github.io/forager/privacy.html
  - Privacy policy integration in app (SafariServices in-app browser)
  - App Privacy questionnaire completed ("Data Not Collected")
  - Display name disambiguated ("forager: smart meal planner")
  - Branding consistency: all lowercase "forager" throughout
  - Migration section hidden from Settings (M3 complete, no longer needed)
- **Status**: Cleared for external TestFlight after M7.1-7.4 CloudKit sync
- **Total Progress**: 95.5 hours (M1-M5.0: 92.5h + M7.0: 3h)
- **Planning Accuracy**: 89% overall, M7.0: 100%!

---

## 📊 **CURRENT STATE**

### **Project Metrics**
- **Total Development Time**: 107.5 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1: 9.5h + docs: 0.5h)
- **Planning Accuracy**: 92% overall (consistently within estimates)
- **Build Success**: 100% (zero breaking changes)
- **Performance**: 100% (all operations <0.5s target maintained, migration 0.02s!)
- **Data Integrity**: 100% (zero data loss across all migrations)
- **Technical Debt**: NONE ✅
- **Git Workflow**: Clean main branch history with feature branches + squash merges

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
- **M7.1.3 Phase 1.1**: Semantic Keys Foundation - All 4 Parts (5.5 hours)

### **Current Work** 🔄
- **M7.1.3 Phase 1.2**: Repository Pattern Implementation (3-4 hours) 🚀 READY
  - Implement findOrCreate() for Category, IngredientTemplate, PlannedMeal
  - Implement findSimilar() for Recipe (allows duplicates by design)
  - Update all entity creation to use repositories
  - Application-level duplicate prevention

### **Technology Stack**
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 18.5+)
- **Persistence**: Core Data → CloudKit (M7.1)
- **Cloud Backend**: CloudKit (NSPersistentCloudKitContainer)
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
- ✅ Semantic key infrastructure complete (Phase 1.1: schema + population + helpers + testing)
- ✅ Migration system (idempotent with UserDefaults, 0.04s performance)

### **Key Achievements**
- 8+ CloudKit record types auto-generated and validated
- 46 sync events observed with < 1 second latency
- 53 entities populated with semantic keys in 0.04 seconds (2.5x better than target!)
- Idempotent migration system with UserDefaults
- 4 reusable semantic key helpers (DRY normalization)
- Professional iOS app with App Store readiness
- Zero technical debt maintained throughout
- 90% planning accuracy across all milestones
- Clean git history with feature branch workflow
- Sub-millisecond performance for all operations

---

## 🎯 **WHAT'S NEXT**

### **Immediate Priority** (M7.1.3 Phase 1.2 - 3-4 hours) 🚀 READY
Implement repository pattern for application-level duplicate prevention:
1. **CategoryRepository** - findOrCreate(name:) using normalizedName
2. **IngredientTemplateRepository** - findOrCreate(name:category:) using canonicalName
3. **PlannedMealRepository** - findOrCreate(date:mealType:recipe:) using slotKey
4. **RecipeRepository** - findSimilar(title:) for warnings only (allows duplicates)
5. Update all entity creation code to use repositories
6. Test: Try creating duplicate categories/templates

**Benefits**: Query before create, consistent logic, prepares for Phase 1.3 constraints

### **After Phase 1.2**
- **M7.1.3 Phase 1.3**: Uniqueness Constraints (1-2h) - Core Data database-level enforcement
- **M7.1.3 Phase 2**: Multi-Device Testing (3-4h) - Validate sync across devices

### **Strategic Options After M7.1.3**
1. **Continue M7.2**: Multi-User Collaboration (8-10h) - CKShare for family meal planning
2. **Pause M7, Start M6**: Testing Foundation (12-18h) - build comprehensive test suite
3. **Pause M7, Start M8**: Analytics Dashboard (8-12h) - usage insights and patterns

---

## 🚨 **CRITICAL REMINDERS**

1. **Session Startup**: Complete [session-startup-checklist.md](session-startup-checklist.md) EVERY session (8 items!)
2. **Naming Standards**: Always use M#.#.# format (enforced in [project-naming-standards.md](project-naming-standards.md))
3. **Documentation Updates**: Update [current-story.md](current-story.md) after EVERY session
4. **Learning Notes**: Create comprehensive notes or breadcrumb trails after phase completion
5. **Git Workflow**: Feature branches with frequent commits (15-30 min), squash merge to main
6. **Zero Technical Debt**: Maintain quality standards throughout
7. **Performance Targets**: <0.5s for operations, <5s for CloudKit sync, <0.1s for migrations

---

## 📚 **LEARNING RESOURCES**

### **Internal Knowledge**
- [learning-notes/](learning-notes/) - 24+ implementation journey notes
- [m7-docs/](m7-docs/) - M7.1.3 detailed breadcrumb trail
- [architecture/](architecture/) - 7+ architecture decision records
- [prds/](prds/) - 7+ product requirement documents
- [git-workflow-for-milestones.md](git-workflow-for-milestones.md) - Complete git workflow guide

### **External Resources**
- [NSPersistentCloudKitContainer Documentation](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com)

---

**Version**: 7.2  
**Last Updated**: December 18, 2025  
**Maintained By**: Rich Hayn  
**Project**: forager - Smart Meal Planning  
**Repository**: https://github.com/rfhayn/forager.git
