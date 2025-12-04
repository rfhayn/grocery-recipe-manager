# Forager - Project Index

**Last Updated**: December 4, 2025  
**Purpose**: Central navigation hub for all project documentation  
**Current Milestone**: M7 - CloudKit Sync & External TestFlight (M7.0 ✅, M7.1.1 ✅, M7.1.2 🚀 READY)  
**Next Priority**: M7.1.2 CloudKitSyncMonitor Service (2-3 hours)

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
5. Continue with current M7.1 sub-phase (M7.1.1, M7.1.2, or M7.1.3)

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
- Current milestone progress (M5.0 READY)
- Phase-by-phase breakdown with estimates
- Next actions and start prompts
- Recent completions summary (M1-M4)
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
  - M7.1.1: CloudKit Schema Validation (2-3h)
  - M7.1.2: Basic Sync Implementation (2-3h)
  - M7.1.3: Multi-Device Sync Testing (3-4h)
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
- M1-M4 complete with actual hours
- M5.0 planned and documented
- Future milestones (M5.1-M11) outlined
- Strategic decisions documented

---

### **📁 Implementation Documentation**

#### **PRDs (Product Requirements Documents)**

**Active PRD**:
- **[M5.0-APP-RENAMING-TESTFLIGHT-PRD.md](M5.0-APP-RENAMING-TESTFLIGHT-PRD.md)** ← Current milestone
  - Complete renaming + TestFlight deployment
  - 42-item checklist
  - 5 phases with validation checkpoints
  - 4-6 hours estimated

**Completed PRDs** (in docs/prds/complete/):
- M1: Professional Grocery Management
- M2: Recipe Integration
- M3: Structured Quantity Management
- M4: Meal Planning & Enhanced Grocery Integration

#### **Learning Notes** (Implementation Journey)

**Recent Notes**:
- [18-m4.1-settings-infrastructure.md](learning-notes/18-m4.1-settings-infrastructure.md)
- [19-m4.2-calendar-meal-planning.md](learning-notes/19-m4.2-calendar-meal-planning.md)
- [22-m4.3.1-recipe-source-tracking.md](learning-notes/22-m4.3.1-recipe-source-tracking.md)
- [23-m4.3.5-ingredient-normalization.md](learning-notes/23-m4.3.5-ingredient-normalization.md)

**To Create**:
- 24-m5.0-app-renaming-testflight.md (after M5.0 complete)

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
| How to implement M7.0 | [next-prompt.md](next-prompt.md) |
| Complete M7 plan | [prds/milestone-7-cloudkit-sync-external-testflight.md](prds/milestone-7-cloudkit-sync-external-testflight.md) |
| Code standards | [development-guidelines.md](development-guidelines.md) |
| What features are needed | [requirements.md](requirements.md) |
| Milestone timeline | [roadmap.md](roadmap.md) |
| Architecture decisions | [architecture/](architecture/) |
| Feature details | [prds/](prds/) |
| How something was built | [learning-notes/](learning-notes/) |

---

## 🔥 **RECENT ACTIVITY**

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
- **M4.3.1**: Recipe Source Tracking Foundation (3.5 hours)
- Many-to-many relationships with professional UI
- Servings picker with real-time scaling
- Recipe source badges with user control

### **November 3, 2025** - M4.2 Complete ✅
- **Completed**: M4.2 Calendar-Based Meal Planning (~4 hours)
- Multi-week calendar view with meal assignments
- Professional iOS calendar patterns
- Recipe picker with search and filtering

### **October 26, 2025** - M3.5 Complete ✅
- **Completed**: M3.5 - Foundation Validation (8.5 hours)
- Validated entire M1-M3 architecture
- Fixed 3 deletion cascade bugs
- Comprehensive testing infrastructure
- System health confirmed for M4

### **October 14, 2025** - M3 Complete ✅
- **Status**: M3 MILESTONE COMPLETE (10.5 hours total)
- Intelligent quantity consolidation (30-50% list reduction)
- Recipe scaling with kitchen-friendly fractions
- Unit conversion system operational

---

## 🚦 **QUICK REFERENCE: PROJECT STATUS**

### **Current State**
- **Current Milestone**: M7 - CloudKit Sync & External TestFlight (M7.0 ✅ COMPLETE)
- **Next Decision**: M7.1 CloudKit (8-10h) OR M6 Testing (12-18h) OR M8 Analytics (8-12h)
- **Completed Milestones**: M1-M5.0 (92.5 hours) + M7.0 (3 hours) = 95.5 hours total
- **Planning Accuracy**: 89% overall, M7.0: 100%!
- **Status**: Strategic decision point - choose next milestone

### **M7.0 Component Status (App Store Prerequisites)** ✅ ALL COMPLETE
- ✅ **M7.0.1**: Privacy Policy Creation & Hosting (1h actual) - COMPLETE
- ✅ **M7.0.2**: Privacy Policy Integration (1h actual) - COMPLETE
- ✅ **M7.0.3**: App Privacy Questionnaire (30 min actual) - COMPLETE
- ✅ **M7.0.4**: Display Name Disambiguation (30 min actual) - COMPLETE

**Achievement**: All Apple App Store prerequisites met! Cleared for external TestFlight after M7.1-7.4.

### **M7 Full Roadmap (After M7.0)**
- ⏳ **M7.1**: CloudKit Sync Foundation (8-10h) - After M7.0 complete
- ⏳ **M7.2**: Multi-User Collaboration (8-10h) - After M7.1
- ⏳ **M7.3**: Conflict Resolution (4-6h) - After M7.2
- ⏳ **M7.4**: Sync UI & Polish (5-7h) - After M7.3
- ⏳ **M7.5**: External TestFlight (3-5h) - After M7.4 (requires M7.0 complete)
- ⏳ **M7.6**: Public Beta Program (2-4h) - After M7.5

### **Next Milestones After M7**
### **Next Milestone Options (Choose One)**
- **Option A - M7.1**: CloudKit Sync Foundation (8-10h) - Multi-device sync, HIGH complexity
- **Option B - M6**: Testing Foundation & AI Augmentation (12-18h) - Quality assurance, MEDIUM complexity
- **Option C - M8**: Analytics & Insights (8-12h) - Usage data, LOW-MEDIUM complexity
- **Strategic Pause**: Take break, evaluate priorities based on TestFlight feedback
- **Decision Framework**: See next-prompt.md for detailed comparison

### **Foundation Achievements (M1-M4)**
- ✅ Store-layout optimized shopping
- ✅ Complete recipe management with autocomplete
- ✅ Intelligent quantity handling & consolidation
- ✅ Meal planning with calendar interface
- ✅ Recipe source tracking & scaled integration
- ✅ Ingredient normalization (30% template reduction)

---

## 📅 **RECENT ACTIVITY**

### **December 4, 2025**

**M7.1.1 CloudKit Schema Validation COMPLETE** ✅
- **Actual Time**: 1.5 hours (estimated 2-3 hours - 100% planning accuracy!)
- **Achievement**: CloudKit-enabled Core Data stack with zero regressions
- **Deliverables**:
  - Replaced NSPersistentContainer with NSPersistentCloudKitContainer
  - Configured CloudKit container (iCloud.com.richhayn.forager)
  - Enabled history tracking and remote change notifications
  - Implemented #if !DEBUG wrapper for fast local development
  - Verified 8+ record types in CloudKit Dashboard (CD_Category, CD_GroceryListItem, CD_Ingredient, CD_IngredientTemplate, CD_MealPlan, CD_PlannedMeal, CD_Recipe, CD_WeeklyList, CD_UserPreferences)
  - Confirmed sync activity (28 events, RecordSave operations logged)
  - First build succeeded with zero errors/warnings
- **Key Learning**: #if !DEBUG strategy enables fast Debug builds (local-only) while keeping CloudKit for Release builds
- **Documentation**:
  - Learning Note: [24-m7.1.1-cloudkit-schema-validation.md](learning-notes/24-m7.1.1-cloudkit-schema-validation.md)
  - Impact Analysis: [M7.1.1-CORE-DATA-IMPACT-ANALYSIS.md](M7.1.1-CORE-DATA-IMPACT-ANALYSIS.md)
- **Status**: M7.1.2 CloudKitSyncMonitor Service ready next (2-3 hours)
- **Total Progress**: 97 hours (M1-M5.0: 92.5h + M7.0: 3h + M7.1.1: 1.5h)
- **Planning Accuracy**: 89% overall maintained

### **December 3, 2025**

**M7.0 App Store Prerequisites COMPLETE** ✅
- **Actual Time**: 3 hours (estimated 2-3 hours - 100% accuracy!)
- **Completed**: Privacy policy, App Privacy questionnaire, display name disambiguation
- **Impact**: forager cleared for external TestFlight after M7.1-7.4
- **Learning Note**: To be created after M7 fully complete

### **November 28, 2025**

**M5.0 App Renaming & TestFlight COMPLETE** ✅
- **Actual Time**: 6 hours (estimated 4-6 hours - 100% accuracy!)
- **Renamed**: GroceryRecipeManager → forager
- **Deployed**: Internal TestFlight with 3+ active testers
- **Impact**: Professional branding, production-ready infrastructure
- **Learning Note**: 21-m5.0-forager-renaming-testflight.md

---

## 🎯 **SUCCESS METRICS**

**This project maintains excellence through:**

1. **Consistent Naming**: M#.#.# format everywhere (zero variance)
2. **Session Discipline**: Startup checklist followed every session
3. **Documentation Currency**: All docs updated after every session
4. **Planning Accuracy**: 89% accuracy across M1-M4 (< 12% variance)
5. **Code Quality**: Zero regressions, 100% build success
6. **Performance**: All operations < 0.5s target maintained
7. **Knowledge Preservation**: Comprehensive learning notes for all work

**M1-M7.0 Track Record:**
- **M1**: 32h (estimated 30-35h) - 91% accuracy ✅
- **M2**: 16.5h (estimated 15-18h) - 92% accuracy ✅
- **M3**: 10.5h (estimated 8-12h) - 88% accuracy ✅
- **M4**: 19.25h (estimated 14.5-17.5h) - 90% accuracy ✅
- **M5.0**: 6h (estimated 4-6h) - 100% accuracy ✅
- **M7.0**: 3h (estimated 2-3h) - 100% accuracy ✅
- **Average**: 93% planning accuracy

**M7.0 Actual**: 3 hours (estimated 2-3 hours - 100% accuracy!)  
**M7.1 Estimate**: 8-10 hours  
**Confidence**: Medium-High (CloudKit has learning curve, but systematic approach)

---

## 💡 **TIPS FOR USING THIS INDEX**

### **Every Session Start**
1. Complete [session-startup-checklist.md](session-startup-checklist.md) (mandatory)
2. Verify current M#.#.# identifier in [current-story.md](current-story.md)
3. For M7.1: Follow [next-prompt.md](next-prompt.md) for implementation

### **Planning New Features (After M7)**
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
- **Current work**: [current-story.md](current-story.md) → M7.1 details
- **How to implement**: [next-prompt.md](next-prompt.md) → Complete M7.1 guide (8-10h)
- **Complete plan**: [milestone-7-cloudkit-sync-external-testflight.md](prds/milestone-7-cloudkit-sync-external-testflight.md) → Full M7 PRD
- **Naming rules**: [project-naming-standards.md](project-naming-standards.md)
- **Code patterns**: [development-guidelines.md](development-guidelines.md)
- **Architecture**: [architecture/](architecture/) ADRs
- **Implementation details**: [learning-notes/](learning-notes/)

---

## 🚀 **READY TO CONTINUE M7.1?**

### **Current Session Start Prompt**:
```
M7.0 complete ✅, ready to start M7.1.1 CloudKit Schema Validation.

First phase: Replace NSPersistentContainer with NSPersistentCloudKitContainer
and verify CloudKit schema generation.

Current setup:
- App renamed to "forager"
- CloudKit entitlements configured (from M5.0)
- 8 Core Data entities operational
- Privacy policy published

Let's start with:
1. Replace NSPersistentContainer with NSPersistentCloudKitContainer in PersistenceController.swift
2. Configure CloudKit container options (iCloud.com.richhayn.forager)
3. Enable history tracking and remote change notifications
4. Test schema generation on physical device
5. Verify CloudKit Dashboard shows 8 record types

Estimated time: 2-3 hours for M7.1.1

I've read the complete implementation guide at docs/next-prompt.md.

Ready to begin!
```

### **Continuing M7.1 Mid-Phase**:
```
Continuing M7.1 - CloudKit Sync Foundation.

Completed so far:
✅ M7.1.1: CloudKit Schema Validation (if done)
✅ M7.1.2: Basic Sync Implementation (if done)
[list completed phases]

Current checkpoint: M7.1.[X] 

Ready to proceed with next sub-phase.
```

---

**Last Updated**: December 4, 2025  
**Next Update**: When M7.1 complete or M7.2 starts  
**Current Status**: M7.1 ACTIVE - CloudKit Sync Foundation (M7.1.1 complete ✅, 6.5-8.5h remaining)  
**Documentation Version**: M7.0 complete (✅), M7.1.1 complete (✅), M7.1.2 ready (🚀)