# Next Implementation Prompt

**Last Updated**: December 21, 2025  
**For Milestone**: M7.2 - Shared Household Zone  
**Status**: 🚀 READY TO START  
**Estimated Duration**: 8-10 hours (4 phases)

---

## 🎯 **CONTEXT: WHAT JUST HAPPENED**

### **Architecture Pivot Complete**

We just completed a major architecture validation and pivot for M7.2:

**Original Plan (Abandoned):**
- M7.2.1 CKShare implementation (individual item sharing)
- 3.5 hours invested in Phases 1-3
- Discovered this doesn't match actual user need

**New Validated Plan:**
- M7.2 Shared Household Zone (all data shared automatically)
- CloudKit shared zones for household database
- One-time setup, automatic sharing
- Perfect for couples/roommates

**Documentation Created:**
- ✅ Learning note explaining pivot decision
- ✅ M7 Shared Zone Architecture document (technical framework)
- ✅ Detailed M7.2 PRD (implementation guide)
- ✅ M7.3-M7.6 outlines for future work
- ✅ Product validation checkpoint added to session checklist

**Current Branch**: `docs/m7-architecture-pivot` (ready to commit)

---

## 🚀 **NEXT: M7.2.1 - Household Setup & Shared Zone**

**When you're ready to start M7.2.1:**

### **Session Startup (MANDATORY)**

```
I'm ready to start M7.2.1 - Household Setup & Shared Zone.

I've completed:
✅ session-startup-checklist.md (including new validation checkpoint)
✅ project-naming-standards.md
✅ current-story.md (architecture pivot understood)
✅ next-prompt.md (this file)

Architecture Validation:
✅ Read: docs/architecture/m7-shared-zone-architecture.md
✅ Read: docs/prds/m7.2-shared-household-zone.md
✅ Understand: Shared zones vs CKShare difference
✅ Understand: Why we pivoted

Let's start with M7.2.1 Task 1: Core Data Model (45 min).

Current state:
- M7.1 complete (CloudKit foundation working)
- Docs branch ready to merge
- Clean architecture validated
- Ready for household entity creation

First task: Add Household and HouseholdMember entities to Core Data model.
```

---

## 📋 **M7.2.1 PHASE BREAKDOWN**

### **Task 1: Core Data Model (45 min)**

**Goal**: Add Household and HouseholdMember entities to data model

**Steps:**

1. **Open Core Data Model**
   ```
   Open: forager.xcdatamodeld in Xcode
   ```

2. **Create Household Entity**
   - Click + at bottom left
   - Name: "Household"
   - Codegen: Class Definition
   - Add attributes:
     - `id`: UUID, Optional: NO
     - `name`: String, Optional: NO
     - `createdDate`: Date, Optional: NO
     - `ownerEmail`: String, Optional: NO
     - `shareRecord`: Binary Data, Optional: YES, Allows External Storage: YES
   - Add relationship:
     - `members`: To-Many, Destination: HouseholdMember, Delete Rule: Cascade

3. **Create HouseholdMember Entity**
   - Click + at bottom left
   - Name: "HouseholdMember"
   - Codegen: Class Definition
   - Add attributes:
     - `id`: UUID, Optional: NO
     - `email`: String, Optional: NO
     - `displayName`: String, Optional: YES
     - `joinedDate`: Date, Optional: YES
     - `role`: String, Optional: NO, Default: "member"
     - `status`: String, Optional: NO, Default: "pending"
   - Add relationship:
     - `household`: To-One, Destination: Household, Inverse: members, Delete Rule: Nullify

4. **Set Inverse Relationships**
   - Household.members ↔ HouseholdMember.household

5. **Add Fetch Indexes**
   - Household: ownerEmail
   - HouseholdMember: email, status

6. **Build Project** (⌘B)
   - Verify no errors
   - Check that classes auto-generate

**Validation:**
- ✅ Build succeeds
- ✅ No Core Data model errors
- ✅ Both entities visible in model editor

---

### **Task 2: Manual Entity Extensions (30 min)**

**Goal**: Add computed properties for easier data access

**Files to Create:**

1. **Create `Household+Extensions.swift`**
   ```swift
   import CoreData
   
   extension Household {
       public var isOwner: Bool {
           guard let ownerEmail = ownerEmail else { return false }
           // TODO: Get current user email from CloudKit
           return false  // Placeholder for M7.2.1
       }
       
       public var memberCount: Int {
           return members?.count ?? 0
       }
       
       public var memberArray: [HouseholdMember] {
           let set = members as? Set<HouseholdMember> ?? []
           return set.sorted { 
               ($0.joinedDate ?? Date.distantPast) < ($1.joinedDate ?? Date.distantPast) 
           }
       }
   }
   ```

2. **Create `HouseholdMember+Extensions.swift`**
   ```swift
   import CoreData
   
   extension HouseholdMember {
       public var isOwner: Bool {
           return role == "owner"
       }
       
       public var isPending: Bool {
           return status == "pending"
       }
       
       public var isActive: Bool {
           return status == "active"
       }
   }
   ```

3. **Build Project** (⌘B)
   - Verify extensions compile

**Validation:**
- ✅ Extension files created
- ✅ Build succeeds
- ✅ Computed properties accessible

---

### **Task 3: HouseholdService Implementation (90 min)**

**Goal**: Create service for household management

**Reference**: See detailed implementation in `docs/prds/m7.2-shared-household-zone.md`

**Key Methods to Implement:**
- `createHousehold(name:)` - Creates household and shared zone
- `inviteMember(email:to:)` - Sends invitation
- `acceptInvitation(household:)` - Accepts invitation
- `removeMember(_:)` - Removes member (owner only)
- `leaveHousehold()` - Member leaves
- `dissolveHousehold(_:)` - Owner dissolves

**File**: `Services/HouseholdService.swift`

**Validation:**
- ✅ Service compiles
- ✅ All methods documented
- ✅ Error handling complete

---

### **Task 4: Settings UI - Household Section (60 min)**

**Goal**: Add household management to Settings

**Files to Update/Create:**
1. `SettingsView.swift` - Add Household section
2. `HouseholdCreateView.swift` - Create household sheet
3. `HouseholdDetailView.swift` - Household management view

**Reference**: See UI mockups in M7.2 PRD

**Validation:**
- ✅ Settings shows Household section
- ✅ Tapping "Create Household" shows sheet
- ✅ Can enter household name and create

---

### **M7.2.1 Acceptance Criteria**

**Before moving to M7.2.2, verify:**

- ✅ Household entity exists in Core Data model
- ✅ HouseholdMember entity exists
- ✅ HouseholdService implemented with all methods
- ✅ Settings → Household section functional
- ✅ User can tap "Create Household"
- ✅ User can enter household name
- ✅ Household created in Core Data
- ✅ Owner added as first member
- ✅ CloudKit shared zone created (verify in CloudKit Dashboard)
- ✅ Build succeeds with zero errors
- ✅ No regressions to existing features

---

## 📚 **REFERENCE DOCUMENTS**

**Read BEFORE starting M7.2.1:**

1. **Architecture Decision**
   - `docs/learning-notes/25-m7-architecture-pivot-ckshare-vs-shared-zone.md`
   - Why we chose shared zones over CKShare

2. **Technical Framework**
   - `docs/architecture/m7-shared-zone-architecture.md`
   - Complete technical architecture
   - Entity design, service patterns, edge cases

3. **Implementation Guide**
   - `docs/prds/m7.2-shared-household-zone.md`
   - Detailed task breakdown
   - Code examples
   - Testing strategy

4. **Session Checklist**
   - `docs/session-startup-checklist.md` (updated)
   - Now includes product validation checkpoint (#8)

---

## 🔀 **GIT WORKFLOW FOR M7.2.1**

**Before Starting Development:**

1. **Complete Documentation PR First**
   ```bash
   # On docs/m7-architecture-pivot branch
   git add docs/
   git commit -m "M7.2 Architecture Pivot: Documentation complete
   
   - Learning note: CKShare vs Shared Zone decision
   - Architecture doc: Shared Zone technical framework
   - Updated M7 PRD with household sharing approach
   - Detailed M7.2 PRD (implementation guide)
   - M7.3-M7.6 outlines for future work
   - Session checklist: Added product validation checkpoint
   
   This pivot ensures we build the right solution for household
   collaboration. 3.5h invested in CKShare approach was valuable
   learning that led to this better architecture."
   
   git push origin docs/m7-architecture-pivot
   
   gh pr create --title "M7.2 Architecture Pivot: Shared Zone Documentation" \
     --body "Complete documentation for M7.2 architecture pivot from CKShare to Shared Zones."
   
   gh pr merge --squash --delete-branch
   ```

2. **Update Local Main**
   ```bash
   git checkout main
   git pull origin main
   ```

3. **Delete Abandoned Branch**
   ```bash
   git branch -D feature/M7.2.1-ckshare-implementation
   git push origin --delete feature/M7.2.1-ckshare-implementation
   ```

4. **Create New Feature Branch for M7.2.1**
   ```bash
   git checkout -b feature/M7.2.1-household-setup
   ```

5. **Start Development**
   - Begin with Task 1: Core Data Model
   - Commit frequently (every 15-30 min)
   - Push after each commit

---

## ⚠️ **CRITICAL REMINDERS**

**Before ANY Code:**
1. ✅ Complete docs PR and merge
2. ✅ Delete abandoned M7.2.1 branch
3. ✅ Start fresh on `feature/M7.2.1-household-setup`
4. ✅ Read architecture doc thoroughly

**During Development:**
1. ✅ Commit every 15-30 minutes
2. ✅ Use M7.2.1 naming in all commits
3. ✅ Build and test after each task
4. ✅ Stop if more than 3 build errors

**After M7.2.1 Complete:**
1. ✅ Mark complete in current-story.md
2. ✅ Update next-prompt.md for M7.2.2
3. ✅ Create PR with squash merge
4. ✅ Update main branch

---

## 💡 **SUCCESS INDICATORS**

**You'll know M7.2.1 is done when:**
- ✅ You can create a household in Settings
- ✅ Household appears with your email as owner
- ✅ CloudKit Dashboard shows shared zone created
- ✅ Member count shows 1 (you)
- ✅ Zero crashes, zero errors
- ✅ All existing features still work

---

**Ready to Start**: Complete docs PR first, then begin M7.2.1  
**Estimated Time**: 3-4 hours for M7.2.1  
**Next After M7.2.1**: M7.2.2 - Member Invitation & Acceptance
