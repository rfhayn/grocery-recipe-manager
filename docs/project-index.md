# Forager - Project Index

**Last Updated**: December 4, 2025  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M7 - CloudKit Sync & External TestFlight (M7.0 ✅, M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🚀 READY)  
**Next Priority**: M7.1.3 Multi-Device Sync Testing (3-4 hours)

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
   - What's 🚀 READY to start
   - Recently completed work ✅
   - Next steps with prompts

4. **[Next Prompt](next-prompt.md)** ← **READ FOURTH**
   - Ready-to-use implementation prompt
   - Current phase guidance
   - Technical requirements
   - Acceptance criteria
   - **Complete M7.1 implementation guide (8-10 hours) included**

**Why this order matters:**
- Checklist → Ensures you follow the complete process
- Naming Standards → Establishes the language/convention
- Current Story → Provides specific project state
- Next Prompt → Gives implementation details

**Failure to follow this sequence breaks project continuity.**

---

## 🚀 **QUICK START BY ACTIVITY TYPE**

### **Continuing M7.1 CloudKit Sync (Current Work)** 🔄 ACTIVE
1. Complete [Session Startup Checklist](session-startup-checklist.md) (ALL 7 items)
2. Read [Current Story](current-story.md) - M7.1 status and progress
3. Read [Next Prompt](next-prompt.md) - Complete M7.1 implementation guide
4. Review last Git checkpoint - Know where you left off
5. Continue with current M7.1 sub-phase (M7.1.3 Multi-Device Sync Testing)

### **Starting New M7 Phase (After M7.1)**
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

### **Completing Work**
1. Update [Current Story](current-story.md) - Mark ✅ COMPLETE with actual hours
2. Update [Project Index](project-index.md) - Add to Recent Activity
3. Create/update [Learning Notes](learning-notes/) - Document journey
4. If milestone complete, update [Roadmap](roadmap.md)

---

## 📋 **CORE DOCUMENTATION**

### **🎯 Critical Workflow Documents**

#### **[session-startup-checklist.md](session-startup-checklist.md)**
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
- Current milestone progress (M7.1 ACTIVE)
- Phase-by-phase breakdown with estimates
- Next actions and start prompts
- Recent completions summary (M1-M7.1.2)
- **Updated after every development session**

#### **[next-prompt.md](next-prompt.md)**
**Purpose**: Copy-paste ready implementation guidance  
**Contents**:
- Current phase implementation guide
- Technical requirements
- Integration points
- Acceptance criteria
- Validation checkpoints
- **Complete M7.1 CloudKit Sync implementation (8-10 hours)**
- Detailed breakdown of all three M7.1 phases:
  - M7.1.1: CloudKit Schema Validation (2-3h) ✅
  - M7.1.2: CloudKitSyncMonitor Service (2-3h) ✅
  - M7.1.3: Multi-Device Sync Testing (3-4h) 🚀
  - Code examples, error handling, testing scenarios

#### **[development-guidelines.md](development-guidelines.md)**
**Purpose**: How Claude should work - code standards and patterns  
**Contents**:
- Session startup requirements
- Pre-development analysis checklist
- Proven patterns from M1-M4
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
- Success criteria per feature
- M1-M4 complete (108 requirements ✅)

#### **[roadmap.md](roadmap.md)**
**Purpose**: Milestone sequence and high-level timeline  
**Contents**:
- M1-M7.0 complete with actual hours
- M7.1 in progress (2 of 3 phases complete)
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
  - M7.1 active 🔄 (2 of 3 phases complete, 3.5h so far)
  - 27-37 hours estimated total

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
- 25-m7.1.2-cloudkit-sync-monitor.md (after M7.1.2 learning note)
- 26-m7.1-cloudkit-sync-foundation.md (after M7.1.3 complete)

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
| Correct M#.#.# naming | [project-naming-standards.md](project-naming-standards.md) |
| What's active now | [current-story.md](current-story.md) |
| How to implement M7.1.3 | [next-prompt.md](next-prompt.md) |
| Complete M7 plan | [prds/milestone-7-cloudkit-sync-external-testflight.md](prds/milestone-7-cloudkit-sync-external-testflight.md) |
| Code standards | [development-guidelines.md](development-guidelines.md) |
| What features are needed | [requirements.md](requirements.md) |
| Milestone timeline | [roadmap.md](roadmap.md) |
| Architecture decisions | [architecture/](architecture/) |
| Feature details | [prds/](prds/) |
| How something was built | [learning-notes/](learning-notes/) |

---

## 🔥 **RECENT ACTIVITY**

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
- **Next**: M7.1.3 Multi-Device Sync Testing (3-4h) - requires 2+ physical devices
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
- **Next**: M7.1.2 CloudKitSyncMonitor Service (2-3h)
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
- **Next**: Strategic decision point - M7.1 CloudKit vs M6 Testing vs M8 Analytics
- **Total Progress**: 95.5 hours (M1-M5.0: 92.5h + M7.0: 3h)
- **Planning Accuracy**: 89% overall, M7.0: 100%!

### **December 3, 2025** - M7 Documentation Complete + M5.0 Closed ✅
- **Completed**: M7 PRD - CloudKit Sync & External TestFlight (complete 80-page plan)
- **Updated**: requirements.md - Added M7.0 App Store Prerequisites (4 new requirements, 151 total)
- **Updated**: roadmap.md - M7 details with all 6 phases documented
- **Status**: Ready to execute M7.0.1 - Privacy Policy Creation & Hosting
- **Critical**: M7.0 prerequisites MANDATORY before external TestFlight
- **Closed**: M5.0 milestone (6 hours, 86% accuracy) ✅

### **November 28-December 2, 2025** - M5.0 COMPLETE ✅
- **Completed**: M5.0 - App Renaming & TestFlight Deployment (6 hours)
- **Achievement**: Complete rename from "GroceryRecipeManager" to "Forager"
- **Deliverables**:
  - Professional app icon (green sprout, grocery-themed)
  - Bundle identifier migration (com.richhayn.forager)
  - Systematic file and folder renaming
  - Apple Developer Program enrollment ($99/year)
  - App Store Connect configuration
  - CloudKit production entitlements
  - Internal TestFlight deployment
  - Multi-tester beta program (3+ testers)
  - Real device validation on physical iPhones
  - Zero data loss through migration
- **Status**: Forager brand established, ready for M7 CloudKit sync

### **November 28, 2025** - M5.0 Documentation Complete
- **Created**: M5.0 PRD - Complete app renaming & TestFlight plan
- **Created**: M5.0 Next-Prompt - Implementation guide with validation checkpoints
- **Updated**: current-story.md for M5.0 start
- **Updated**: project-index.md (this file)
- **Updated**: claude-instructions.md with transition note
- **Status**: Ready to execute M5.0.1 - Name Selection & Planning
- **Decision**: Chose TestFlight validation before CloudKit investment

### **November 26, 2025** - M4 COMPLETE ✅
- **Completed**: M4 Milestone (19.25 hours vs 14.5-17.5h estimate)
- **Achievement**: 90% planning accuracy maintained
- **Components**: All 7 sub-components complete
  - M4.1: Settings Infrastructure (1.5h)
  - M4.2: Calendar Meal Planning (4h)
  - M4.3.1: Recipe Source Tracking (3.5h)
  - M4.3.2: Scaled Recipe to List (1.25h)
  - M4.3.3: Bulk Add from Meal Plan (2.5h)
  - M4.3.4: Meal Completion Tracking (1h)
  - M4.3.5: Ingredient Normalization - All 4 phases (5.5h)
- Revolutionary meal planning to grocery automation complete
- 30% reduction in ingredient template fragmentation achieved

### **November 25, 2025** - M4.3.5 Phases 2-4 Complete ✅
- **Completed**: M4.3.5 Ingredient Normalization system (5.5h total)
- **Phase 2**: Singular/plural with 13-item preserve-plural list
- **Phase 3**: Abbreviation expansion safety net
- **Phase 4**: Variation handling (descriptive qualifiers removal)
- **Bonus**: StandardEmptyStateView component for UI consistency
- 30% template consolidation achieved (50+ → 35 templates)

### **November 24, 2025** - M4.3.4 & M4.3.3 Complete ✅
- **M4.3.4**: Meal Completion Tracking (1.0 hour) - On-target estimate
- **M4.3.3**: Bulk Add from Meal Plan (2.5 hours) with servings UI enhancement
- Clean state management patterns established
- Progress overlay implementation successful

### **November 22, 2025** - M4.3.2 & M4.3.1 Complete ✅
- **M4.3.2**: Scaled Recipe to List Integration (1.25 hours) - 17% under estimate
- **M4.3.1**: Recipe Source Tracking (3.5 hours) - Within estimate
- RecipeScalingService integration completed
- Recipe usage analytics operational

### **November 21, 2025** - M4.2 Complete ✅
- **Completed**: M4.2 - Calendar-Based Meal Planning (4 hours vs 3-4h estimate)
- Visual calendar interface with meal types
- Recipe selection and meal plan creation
- Comprehensive view for meal plan management
- Professional UI polish with SF Symbols

### **November 20, 2025** - M4.1 Complete ✅
- **Completed**: M4.1 - Settings Infrastructure (1.5 hours)
- UserPreferencesService with Core Data persistence
- Professional Settings view with SwiftUI sections
- Planning configuration (meal planning duration, default servings)
- Foundation for future settings expansion

---

## 📊 **CURRENT STATE**

### **Project Metrics**
- **Total Development Time**: 99 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1: 3.5h)
- **Planning Accuracy**: 89% overall (consistently within estimates)
- **Build Success**: 100% (zero breaking changes)
- **Performance**: 100% (all operations <0.5s target maintained)
- **Data Integrity**: 100% (zero data loss across all migrations)
- **Technical Debt**: NONE ✅

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
- **M7.1.3**: Multi-Device Sync Testing (3-4 hours) 🚀 READY
  - Requires 2+ physical devices on same iCloud account
  - 6 testing scenarios planned
  - Performance validation (<5s latency target)

### **Technology Stack**
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI (iOS 18.5+)
- **Persistence**: Core Data → CloudKit (M7.1)
- **Cloud Backend**: CloudKit (NSPersistentCloudKitContainer)
- **Testing**: XCTest framework + TestFlight
- **Version Control**: Git + GitHub

### **App Features** (Fully Operational)
- ✅ Professional grocery list management with store-layout optimization
- ✅ Recipe catalog with ingredient tracking and scaling
- ✅ Structured quantity management with intelligent consolidation
- ✅ Calendar-based meal planning with recipe integration
- ✅ Automated meal plan to grocery list conversion
- ✅ Settings infrastructure with user preferences
- ✅ Internal TestFlight deployment
- ✅ CloudKit infrastructure (schema validated, sync monitoring operational)

### **Key Achievements**
- 8+ CloudKit record types auto-generated and validated
- 46 sync events observed with < 1 second latency
- Professional iOS app with App Store readiness
- Zero technical debt maintained throughout
- 89% planning accuracy across all milestones
- Sub-millisecond performance for all operations
- Comprehensive documentation and learning notes

---

## 🎯 **WHAT'S NEXT**

### **Immediate Priority** (M7.1.3 - 3-4 hours)
Multi-device sync testing across 2+ physical devices:
1. Create → Sync → Read scenarios
2. Edit → Sync → Update validation
3. Delete → Sync → Remove testing
4. Offline → Online sync verification
5. Simultaneous operations handling
6. Complex data relationships (recipes, meal plans)
7. Performance measurement (<5s target)

### **Strategic Options After M7.1.3**
1. **Continue M7.2**: Multi-User Collaboration (8-10h) - CKShare for family meal planning
2. **Pause M7, Start M6**: Testing Foundation (12-18h) - build comprehensive test suite
3. **Pause M7, Start M8**: Analytics Dashboard (8-12h) - usage insights and patterns

---

## 🚨 **CRITICAL REMINDERS**

1. **Session Startup**: Complete [session-startup-checklist.md](session-startup-checklist.md) EVERY session
2. **Naming Standards**: Always use M#.#.# format (enforced in [project-naming-standards.md](project-naming-standards.md))
3. **Documentation Updates**: Update [current-story.md](current-story.md) after EVERY session
4. **Learning Notes**: Create comprehensive notes after milestone completion
5. **Git Checkpoints**: Commit after each phase/sub-phase completion
6. **Zero Technical Debt**: Maintain quality standards throughout
7. **Performance Targets**: <0.5s for operations, <5s for CloudKit sync

---

## 📚 **LEARNING RESOURCES**

### **Internal Knowledge**
- [learning-notes/](learning-notes/) - 24+ implementation journey notes
- [architecture/](architecture/) - 7+ architecture decision records
- [prds/](prds/) - 6+ product requirement documents

### **External Resources**
- [NSPersistentCloudKitContainer Documentation](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com)

---

**Version**: 7.1  
**Last Updated**: December 4, 2025  
**Maintained By**: Rich Hayn  
**Project**: forager - Smart Meal Planning  
**Repository**: https://github.com/rfhayn/grocery-recipe-manager.git