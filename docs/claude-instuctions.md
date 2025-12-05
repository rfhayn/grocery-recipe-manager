# CLAUDE PROJECT INSTRUCTIONS - FORAGER

> **🚀 ACTIVE WORK: M7.1 - CloudKit Sync Foundation**
> 
> **Current Phase**: M7.1.3 Multi-Device Sync Testing - 🚀 READY
> **Status**: M7.1.1 Complete ✅, M7.1.2 Complete ✅, M7.1.3 Ready to Start
> 
> **Key M7.1 Documentation**:
> - [M7 PRD](docs/prds/milestone-7-cloudkit-sync-external-testflight.md) - Complete plan
> - [M7.1 Next-Prompt](docs/next-prompt.md) - Complete implementation guide
> - [Current Story](docs/current-story.md) - Current progress
> 
> **📊 Progress**: M7.0 Complete (3h), M7.1.1 Complete (1.5h), M7.1.2 Complete (2h)

**Project**: forager (Smart Meal Planner)  
**Version**: 4.0 - Git Workflow Integration  
**Last Updated**: December 5, 2025

---

## 🚨 MANDATORY: START EVERY SESSION HERE

### **Session Startup Sequence (Non-Negotiable)**

**Claude MUST complete these actions at the start of EVERY session:**

1. **Search project knowledge**: `session-startup-checklist.md`
   - Read complete 8-point checklist (updated with git workflow!)
   - Follow Phase 1 (context loading) for ALL sessions
   - Follow Phase 2 (implementation prep) for development sessions
   - **NEW: Item #8** - Create feature branch before any code

2. **Search project knowledge**: `project-naming-standards.md`
   - Verify current M#.#.# format (e.g., M7.1.3)
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

**Why this matters**: These 4 searches take 10-15 minutes but prevent 7-16 hours of rework from duplicate services, naming inconsistencies, architecture conflicts, or messy git history.

---

## 📋 PROJECT OVERVIEW

### **What We're Building**
iOS mobile app for grocery and recipe management with:
- Staple grocery items with auto-population to weekly lists
- Recipe catalog with ingredient tracking and usage analytics
- Structured quantity management with intelligent consolidation
- Recipe-to-grocery integration with smart automation
- Store-layout optimized grocery lists
- **CloudKit multi-device sync** (M7 in progress)

### **Current Status**
- **Completed**: M1-M5.0, M7.0 (~95.5 hours total)
- **Active**: M7.1 CloudKit Sync Foundation
- **Planning Accuracy**: 89% (consistently within estimates)
- **Build Success**: 100% (zero breaking changes)

### **Technology Stack**
- Swift + SwiftUI for UI
- Core Data for persistence with NSPersistentCloudKitContainer
- CloudKit for multi-device sync
- iOS 18.5+ target
- Xcode project structure
- Proven service architecture patterns
- **Feature branch git workflow** (M7+)

---

## 🎯 CRITICAL RULES (Zero Tolerance)

### **1. Naming Convention (MANDATORY)**

**Always use M#.#.# format:**
```
✅ CORRECT: "M7.1.3" or "M7.1.3: Multi-Device Sync Testing"
❌ WRONG: "Phase 3", "Step 3", "Story 7.1.3"
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
- **Complete PR workflow** (squash merge to main)

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

**Why this matters**: M1-M7 have established proven patterns - always leverage them instead of reinventing.

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
CloudKitSyncMonitor           - Sync monitoring (M7.1.2)
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
CloudKit sync                 - NSPersistentCloudKitContainer (M7.1.1)
```

---

## 🔧 DEVELOPMENT APPROACH

### **Phase-Based Planning (Your Proven Method)**
1. Document the plan - Break into 45-90 minute phases
2. **Create feature branch** - Isolate phase work
3. Implement one phase - Complete and test
4. **Commit frequently** - Every 15-30 minutes
5. Validate before proceeding - Ensure it works
6. **Complete PR workflow** - Squash merge to main
7. Move to next phase - Build incrementally

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
- ❌ **Working on main branch instead of feature branch**
- ❌ **Committing code without M#.#.# format in message**

### **Success Indicators (Continue if...)**
- ✅ Build succeeds first try or with minor fixes
- ✅ All existing tests/features continue working
- ✅ New feature meets performance targets
- ✅ Code follows established patterns
- ✅ Documentation updated per checklist
- ✅ **On feature branch with frequent commits**
- ✅ **All commits use M#.#.# naming**

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
// MARK: - M7.1: CloudKit Sync Functions
```

### **State Management Comments (Required)**
```swift
// M7.1.2: CloudKit sync monitor
// Observes NSPersistentStoreRemoteChange notifications
// Tracks sync state, event count, last sync date
@StateObject private var syncMonitor: CloudKitSyncMonitor

// Sync status for UI display
// Updates in real-time as CloudKit operations occur
@State private var isSyncing: Bool = false
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

**CloudKit Sync (M7.1+):**
- ✅ Use NSPersistentCloudKitContainer for sync
- ✅ Wrap in #if !DEBUG for development speed
- ✅ Enable history tracking and remote notifications
- ✅ Monitor sync with CloudKitSyncMonitor service

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
- **Explicit references to existing patterns from M1-M7**
- **Mentioning relevant learning notes when suggesting approaches**

### **What to Flag**
- When existing infrastructure can be leveraged vs creating new
- When technical debt would be created
- When proposals contradict proven patterns from M1-M7
- When Core Data changes need impact analysis
- **When code should be on feature branch but isn't**
- **When PR workflow should be completed**

### **Principal Engineer Perspective**
- Challenge proposals that contradict proven patterns
- Flag dual-storage or unnecessary backward compatibility
- Suggest simple solutions before complex architecture
- Reference successful patterns from completed milestones
- **Enforce feature branch workflow discipline**

---

## 📚 DOCUMENTATION STRUCTURE

### **Critical Startup Documents (Read Every Session)**
```
docs/
├── session-startup-checklist.md   ← START HERE EVERY SESSION (now with git!)
├── project-naming-standards.md    ← M#.#.# naming conventions  
├── current-story.md               ← Current milestone status
├── next-prompt.md                 ← Implementation guidance
├── development-guidelines.md      ← Code standards & patterns
└── git-workflow-for-milestones.md ← Complete git workflow (NEW!)
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
│   ├── 17-m3.5-foundation-validation.md
│   ├── 24-m7.1.1-cloudkit-schema-validation.md
│   └── [future M7+ notes]
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
5. **Leverage proven patterns**: M1-M7 established excellent patterns
6. **Performance matters**: Maintain <0.5s targets for all operations
7. **Zero regressions**: Never break existing working features
8. **Incremental validation**: Build and test each phase before proceeding
9. **Feature branch workflow**: One phase = one branch = one PR = one commit to main
10. **Clean git history**: Squash merge for readable main branch

---

## 📊 SUCCESS METRICS

### **Planning Accuracy**
- M1: 32h (est 30-35h) - ✅ 91% accuracy
- M2: 16.5h (est 15-18h) - ✅ 92% accuracy  
- M3: 10.5h (est 8-12h) - ✅ 88% accuracy
- M3.5: 8.5h (est 7h) - ✅ 82% accuracy
- M7.0: 3h (est 2-3h) - ✅ 100% accuracy
- M7.1.1: 1.5h (est 1.5h) - ✅ 100% accuracy
- M7.1.2: 2h (est 2h) - ✅ 100% accuracy
- **Overall: 89% accuracy (<11% variance)**

### **Quality Metrics**
- Build success: 100% (zero breaking changes)
- Performance: 100% (<0.5s for all operations, <5s CloudKit sync)
- Data integrity: 100% (zero data loss)
- Documentation consistency: 100% (M#.#.# naming throughout)
- **Git history: Clean (feature branches with squash merges)**

### **Success Factors**
- Strict adherence to session-startup-checklist.md
- Consistent use of project-naming-standards.md
- Phase-based development with validation gates
- Comprehensive learning notes for knowledge preservation
- Proven architecture patterns reused across milestones
- **Feature branch workflow with frequent commits**
- **Clean main branch history via squash merges**

---

## 🚨 REALITY CHECKS & RED FLAGS

### **Your Actual Constraints**
- ✅ Pre-production app - breaking changes acceptable
- ✅ Single developer - optimize for long-term maintainability
- ✅ Learning-focused - balance learning with pragmatism
- ✅ Quality over speed - but excellent velocity (95.5h for M1-M7.1.2)

### **Red Flags to Challenge**
- ❌ Proposals contradicting proven M1-M7 patterns
- ❌ Dual-storage or backward compatibility for pre-production
- ❌ Complex architecture before simple solution proven
- ❌ Suggestions that create technical debt
- ❌ Creating new infrastructure when existing can be extended
- ❌ Ignoring project-naming-standards.md
- ❌ **Working on main branch instead of feature branch**
- ❌ **Skipping PR workflow and squash merge**

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
8. "git-workflow-for-milestones" (for git workflow reference)
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

### **Code Quality**
- [ ] Code includes function header comments
- [ ] Code includes inline comments explaining "why"
- [ ] Code uses MARK comments for organization
- [ ] All files use correct M#.#.# naming
- [ ] No build errors or warnings
- [ ] No regressions to existing features
- [ ] Performance targets maintained (<0.5s, <5s for CloudKit sync)

### **Documentation**
- [ ] current-story.md updated with progress
- [ ] Learning notes created/updated (if insights gained)
- [ ] project-index.md Recent Activity updated (if phase complete)
- [ ] All documentation uses consistent M#.#.# naming

### **Git Workflow**
- [ ] All changes committed to feature branch
- [ ] All commits pushed to GitHub
- [ ] Commit messages use M#.#.# format
- [ ] No uncommitted changes (git status clean on branch)

**If phase complete:**
- [ ] Mark ✅ COMPLETE in current-story.md with actual hours
- [ ] Update next-prompt.md for next phase
- [ ] Create/update comprehensive learning note
- [ ] **Complete PR workflow** (see below)

**If milestone complete:**
- [ ] Update roadmap.md with completion summary
- [ ] Update project-index.md with milestone links
- [ ] Verify all documentation uses consistent M#.#.# naming
- [ ] All feature branches merged and deleted

---

## 🔀 PHASE COMPLETION: PR WORKFLOW

**When a phase (M#.#.#) is complete:**

### **1. Final Documentation Commit**
```bash
# Ensure all documentation is committed
git add docs/current-story.md docs/learning-notes/24-*.md docs/next-prompt.md
git commit -m "M7.1.3 COMPLETE: Update documentation

✅ Acceptance Criteria:
- All 6 test scenarios passed
- Average sync latency: 3.2 seconds (< 5s target)
- Zero data loss across all scenarios
- Multi-device sync validated on 2 iPhones

📊 Metrics:
- Estimated: 3-4 hours
- Actual: 3.5 hours (88% accuracy)
- Performance: 3.2s avg sync (target: < 5s)

📝 Documentation:
- current-story.md marked M7.1.3 complete
- Learning notes updated with CloudKit insights
- next-prompt.md ready for M7.2 (or strategic decision)"

git push
```

### **2. Create Pull Request**
```bash
# Auto-fill from commits
gh pr create --fill

# OR specify manually for better PR description
gh pr create \
  --title "M7.1.3: Multi-Device Sync Testing" \
  --body "## Summary
Validated CloudKit sync across two physical devices with comprehensive testing scenarios.

## Changes
- Tested 6 scenarios: Create/Edit/Delete/Offline/Concurrent/Complex
- Measured sync performance: 3.2s average (< 5s target met)
- Validated zero data loss across all operations
- Updated documentation with test results

## Testing
- ✅ All 6 test scenarios passed
- ✅ Average sync latency: 3.2 seconds
- ✅ Zero data loss or duplication
- ✅ Offline queue works correctly
- ✅ Complex relationships preserved

## Time
- Estimated: 3-4 hours
- Actual: 3.5 hours (88% accuracy)

## Next
Strategic decision: M7.2 (Multi-User Collaboration) vs M6 (Testing) vs M8 (Analytics)" \
  --base main
```

### **3. Merge PR (Squash Merge)**
```bash
# Squash merge for clean history
gh pr merge --squash --delete-branch

# This will:
# - Squash all commits into one commit on main
# - Delete feature branch on GitHub
# - Keep main branch history clean (one commit per phase)
```

### **4. Update Local Repository**
```bash
# Switch back to main
git checkout main

# Pull the squashed commit
git pull origin main

# Clean up local feature branch
git branch -d feature/M7.1.3-multi-device-testing

# Verify clean state
git status  # Should show: "nothing to commit, working tree clean"
git branch   # Should show only: * main
```

### **5. Ready for Next Phase**
```bash
# Immediately create branch for next phase (if continuing)
git checkout -b feature/M7.2.1-ckshare-implementation

# Or return to main if taking a break
git checkout main
```

---

## 💾 GIT COMMIT BEST PRACTICES

### **Commit Message Format**
```
M#.#.#: Brief description (50 chars or less)

- Detailed bullet point 1
- Detailed bullet point 2
- Test results or validation notes
```

### **When to Commit**
**Commit frequently (every 15-30 minutes) when:**
- ✅ Logical unit of work complete
- ✅ Code builds successfully
- ✅ Tests pass (if applicable)
- ✅ Before switching tasks
- ✅ Before taking a break
- ✅ Before switching computers

**Don't commit:**
- ❌ Code that doesn't compile
- ❌ Broken tests
- ❌ Debug statements or commented-out code
- ❌ Secrets, API keys, or credentials

### **Good Commit Examples**
```bash
✅ git commit -m "M7.1.3: Test Create → Sync → Read scenario

- Created test list on Device A
- Verified sync to Device B in 2.8 seconds
- All 3 items present with correct details
- CloudKitSyncMonitor event count incremented on both devices"

✅ git commit -m "M7.1.2: Implement CloudKitSyncMonitor service

- ObservableObject with @Published properties
- Observe NSPersistentStoreRemoteChange notifications
- Map CKError types to user-friendly messages
- Real-time sync status updates"

✅ git commit -m "M7.1.1: Configure CloudKit container with #if !DEBUG

- Enables fast local development (Debug builds)
- CloudKit active in Release builds only
- Confirmed schema generation in CloudKit Dashboard"
```

### **Bad Commit Examples**
```bash
❌ git commit -m "Fixed stuff"
❌ git commit -m "WIP"
❌ git commit -m "Update files"
❌ git commit -m "Trying to make it work"
```

---

## 🚨 GIT EMERGENCY SCENARIOS

### **Need to Switch Computers Mid-Phase**
```bash
# On Computer A - save work
git add .
git commit -m "M7.1.3 WIP: Completed scenarios 1-3, pausing at scenario 4"
git push

# On Computer B - resume work
git fetch origin
git checkout feature/M7.1.3-multi-device-testing
git pull origin feature/M7.1.3-multi-device-testing
# Continue working...
```

### **Made a Mistake in Last Commit (Not Yet Pushed)**
```bash
# Amend the last commit
git add <fixed-files>
git commit --amend
# Edit commit message if needed, then save
```

### **Made a Mistake in Last Commit (Already Pushed)**
```bash
# Just make another commit fixing it
git add <fixed-files>
git commit -m "M7.1.3: Fix typo in CloudKit container configuration"
git push
```

### **Need to Abandon Branch and Start Over**
```bash
git checkout main
git branch -D feature/M7.1.3-multi-device-testing  # Force delete
git checkout -b feature/M7.1.3-multi-device-testing-v2
```

### **Accidentally Committed to Main**
```bash
# Create branch from current main
git branch feature/M7.1.3-multi-device-testing

# Reset main to origin
git checkout main
git reset --hard origin/main

# Continue work on feature branch
git checkout feature/M7.1.3-multi-device-testing
```

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
4. Reference proven patterns from M1-M7
5. Review git-workflow-for-milestones.md for workflow questions
6. Ask for clarification with specific context

**When making decisions:**
1. Search for relevant ADRs first
2. Consider long-term maintainability
3. Prefer simple over complex
4. Document decision in ADR if significant
5. Reference decision in implementation

---

## 🏁 FINAL REMINDER

**Every session starts with the same 4 searches:**
1. `session-startup-checklist.md` - Complete procedure (now 8 items with git!)
2. `project-naming-standards.md` - M#.#.# naming  
3. `current-story.md` - Current status
4. `next-prompt.md` - Implementation guide (if developing)

**This 10-15 minute investment prevents 7-16 hours of rework.**

**Follow the checklist. Use M#.#.# naming. Document everything. Build incrementally. Use feature branches.**

---

## 📚 GIT WORKFLOW REFERENCE

**See Complete Workflow**: [git-workflow-for-milestones.md](docs/git-workflow-for-milestones.md)

**Quick Reference:**
1. **Phase Start**: `git checkout -b feature/M#.#.#-description`
2. **Development**: Commit frequently (15-30 min), push after each commit
3. **Phase Complete**: `gh pr create --fill`, then `gh pr merge --squash --delete-branch`
4. **Main Updated**: `git checkout main`, `git pull origin main`
5. **Next Phase**: Create new feature branch, repeat

**Benefits:**
- ✅ Clean main branch (one commit per phase)
- ✅ Safe experimentation (can abandon branch)
- ✅ Easy rollback (revert one commit)
- ✅ Cross-computer development (push/pull freely)
- ✅ Clear progress tracking (PRs show phase work)

---

**Version**: 4.0 - Git Workflow Integration  
**Last Updated**: December 5, 2025  
**GitHub**: https://github.com/rfhayn/forager.git