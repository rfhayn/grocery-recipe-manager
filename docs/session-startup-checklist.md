# Session Startup Checklist

**Purpose**: Mandatory startup procedure for every Claude development session  
**Last Updated**: October 23, 2025  
**Required Reading**: **EVERY SESSION** - No exceptions

---

## 🚀 CRITICAL: START HERE EVERY SESSION

This checklist ensures:
- ✅ Consistent naming conventions (M#.#.# format)
- ✅ Current project context loaded
- ✅ No duplicate work or services
- ✅ Documentation continuity
- ✅ Efficient development workflow

**Estimated Time**: 5-10 minutes  
**Impact**: Prevents hours of rework and confusion

---

## 📋 THE CHECKLIST

### **PHASE 1: CONTEXT LOADING** (Required for ALL sessions)

#### **1. Read Session Startup Checklist** ✅
**Location**: `docs/session-startup-checklist.md` (this file)  
**Purpose**: Ensure you follow the complete startup procedure  
**Action**: You're doing it right now!

#### **2. Read Project Naming Standards** ✅
**Location**: `docs/project-naming-standards.md`  
**Purpose**: Understand M#.#.# naming hierarchy and status indicators  
**What to verify:**
- [ ] Current active milestone (e.g., M4)
- [ ] Current active component (e.g., M4.1)
- [ ] Status indicator meanings (✅ 🔄 🚀 ⏳)
- [ ] Quick reference card at top of document

**Key Takeaway**: 
```
Always use full identifiers: "M4.1.2" not "Phase 2" or "Step 2"
```

#### **3. Read Current Story** ✅
**Location**: `docs/current-story.md`  
**Purpose**: Understand current milestone progress and what's active  
**What to capture:**
- [ ] Current milestone number and name
- [ ] Active phases/components with 🔄 ACTIVE status
- [ ] Recently completed work with ✅ COMPLETE status
- [ ] Next planned work with 🚀 READY status
- [ ] Any blockers or open questions

**Key Takeaway**: What work is active RIGHT NOW?

---

### **PHASE 2: IMPLEMENTATION PREPARATION** (Required if doing development work)

#### **4. Read Next Prompt** ✅
**Location**: `docs/next-prompt.md`  
**Purpose**: Get specific implementation guidance for current active work  
**What to review:**
- [ ] Phase breakdown and time estimates
- [ ] Technical requirements
- [ ] Integration points
- [ ] Acceptance criteria
- [ ] Files that will be modified

**Key Takeaway**: Copy-paste ready implementation plan for current session

#### **5. Search Project Knowledge for Core Data Schema** ✅
**When**: If working with data model (entities, relationships, migrations)  
**Search queries to use:**
```
"Core Data entity [EntityName] properties relationships"
"[EntityName] codegen fetch indexes"
"Core Data schema current"
```

**What to document:**
- [ ] Existing properties and exact types
- [ ] All relationships and inverses
- [ ] Codegen settings (Manual/None vs Class Definition)
- [ ] Fetch indexes present
- [ ] Recent migration history

**Key Takeaway**: Never assume schema - always verify current state

#### **6. Review Relevant ADRs** ✅
**Location**: `docs/architecture/`  
**When**: Working on features with architectural implications  
**What to search:**
```
"architecture decision [feature area]"
"ADR [technology or pattern]"
```

**Key ADRs to know:**
- ADR 001: Selective Technical Improvements
- ADR 006: Consolidate Staples and Ingredients
- ADR 007: Core Data Change Process

**Key Takeaway**: Don't reinvent patterns - follow established decisions

#### **7. Search for Existing Services** ✅
**When**: Before creating ANY new service or infrastructure  
**Search queries to use:**
```
"Service [functionality] implementation"
"Parse [data type]"
"[Feature] pattern existing"
```

**What to check:**
- [ ] Similar services already exist?
- [ ] Can existing service be extended?
- [ ] Established patterns in similar features?
- [ ] Relevant implementations in learning notes?

**Proven services to leverage:**
- OptimizedRecipeDataService (Core Data operations)
- IngredientParsingService (text parsing)
- IngredientTemplateService (normalization)
- QuantityMergeService (consolidation)
- UnitConversionService (measurements)
- RecipeScalingService (recipe scaling)

**Key Takeaway**: Search before creating - avoid duplicate infrastructure

---

## ✅ CHECKLIST COMPLETION

**Before writing ANY code, verify you've completed:**

**Phase 1: Context Loading** (ALL sessions)
- [x] Read session-startup-checklist.md (this file)
- [ ] Read project-naming-standards.md
- [ ] Read current-story.md

**Phase 2: Implementation Preparation** (Development sessions only)
- [ ] Read next-prompt.md
- [ ] Search for Core Data schema (if needed)
- [ ] Review relevant ADRs (if needed)
- [ ] Search for existing services (if creating new infrastructure)

**Red Flag Check:**
- [ ] No duplicate services being created
- [ ] Using correct M#.#.# naming convention
- [ ] Current work documented in current-story.md
- [ ] Architecture patterns match existing decisions

---

## 🎯 QUICK WINS FROM THIS CHECKLIST

### **Prevents These Common Issues:**

❌ **Without Checklist:**
- Creating duplicate services that already exist
- Using inconsistent naming (Phase 1 vs M4.1)
- Breaking existing Core Data relationships
- Contradicting established architecture decisions
- Starting work that's not documented
- Missing critical context from previous sessions

✅ **With Checklist:**
- Consistent naming across all documentation
- Leveraging existing proven services
- Following established patterns
- Building on current work correctly
- Maintaining documentation continuity
- Efficient, focused development

### **Time Saved:**

| Issue | Time Without Checklist | Time With Checklist |
|-------|----------------------|-------------------|
| Duplicate service creation | 2-4 hours | 0 (prevented) |
| Naming corrections | 30-60 min | 0 (prevented) |
| Core Data conflicts | 1-3 hours | 0 (prevented) |
| Architecture rework | 2-6 hours | 0 (prevented) |
| Documentation cleanup | 30-90 min | 0 (prevented) |

**Total Time Saved Per Session**: 6-14 hours of potential rework

---

## 📊 CHECKLIST PERFORMANCE TRACKING

### **Session Success Metrics**

**After completing this checklist, your session should achieve:**
- ✅ Zero naming inconsistencies
- ✅ Zero duplicate infrastructure
- ✅ Zero Core Data conflicts
- ✅ Zero architecture contradictions
- ✅ 100% documentation continuity
- ✅ Clear, focused development path

### **Historical Results**

**Sessions Using Checklist (M1-M3.5):**
- 67.5 hours total development
- < 10% variance from estimates
- Zero major rework required
- 100% documentation consistency
- Zero breaking changes to working features

**Impact**: This checklist is a proven success factor for the project's 88% planning accuracy

---

## 🔗 RELATED DOCUMENTS

**After completing this checklist, refer to:**

**For Development:**
- [development-guidelines.md](development-guidelines.md) - Code standards and patterns
- [next-prompt.md](next-prompt.md) - Current implementation guidance

**For Context:**
- [requirements.md](requirements.md) - Feature requirements
- [roadmap.md](roadmap.md) - Milestone sequence
- [project-index.md](project-index.md) - Central navigation

**For Architecture:**
- [architecture/](architecture/) - Architecture Decision Records
- [learning-notes/](learning-notes/) - Implementation patterns

---

## 💡 PRO TIPS

### **First Session of the Day**
Complete ALL 7 checklist items - full context load is critical

### **Continuing Previous Session's Work**
Can skip items 5-7 if:
- Working on same feature
- No Core Data changes planned
- No new services being created

BUT always complete items 1-4 - these ensure naming consistency and current context

### **Starting New Milestone/Component**
Complete ALL 7 items + additionally review:
- Relevant PRDs in `docs/prds/`
- Similar milestone learning notes
- Related ADRs for the feature area

### **Quick Context Refreshes**
If interrupted or switching contexts mid-session:
1. Re-read current-story.md (item 3)
2. Re-read next-prompt.md (item 4)
3. Verify M#.#.# naming still correct

---

## 🚨 ENFORCEMENT

### **This Checklist is MANDATORY**

**Non-compliance indicators:**
- Using "Phase" or "Step" without M#.#.# identifier
- Creating services that duplicate existing ones
- Core Data changes without schema verification
- Documentation updates without checking current-story.md
- Code that contradicts established patterns

**If you catch non-compliance:**
1. Stop current work
2. Re-read this checklist
3. Complete missing items
4. Correct any inconsistencies
5. Resume work with proper context

### **Success Validation**

**Before committing ANY code or documentation:**
- [ ] All files use M#.#.# naming consistently
- [ ] current-story.md updated with progress
- [ ] No duplicate services or infrastructure
- [ ] Architecture follows established ADRs
- [ ] Documentation uses correct status indicators (✅ 🔄 🚀 ⏳)

---

## 📈 CONTINUOUS IMPROVEMENT

**This checklist evolves based on project needs.**

**Suggest additions when:**
- Common issues arise despite checklist
- New critical documents are created
- Process improvements are identified
- Project complexity increases

**Update frequency**: Review after each milestone completion

---

**Remember**: 10 minutes of checklist time saves hours of rework.

**Start every session here. No exceptions.**

---

**Version**: 1.0  
**Created**: October 23, 2025  
**Next Review**: After M4 completion