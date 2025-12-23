# M7 Architecture: CloudKit Shared Zone for Household Collaboration

**Document Type**: Architecture Decision & Technical Framework  
**Created**: December 21, 2025  
**Status**: Approved for M7.2+ Implementation  
**Related Learning Note**: [25-m7-architecture-pivot-ckshare-vs-shared-zone.md](../learning-notes/25-m7-architecture-pivot-ckshare-vs-shared-zone.md)

---

## 🎯 **Executive Summary**

**Decision**: Implement CloudKit **Shared Zone** architecture for household collaboration, not CKShare individual item sharing.

**Rationale**: Users want a shared household database where all data (recipes, lists, meal plans, ingredients, categories) automatically syncs between household members. This is fundamentally different from selectively sharing individual items.

**Impact**: 
- Simpler UX (one-time household setup vs per-item sharing)
- Better for target use case (couples/roommates managing household)
- All data automatically shared (no share buttons needed)
- Cleaner architecture for household collaboration

---

## 📋 **Table of Contents**

1. [Architecture Overview](#architecture-overview)
2. [Use Case & User Journey](#use-case--user-journey)
3. [Technical Architecture](#technical-architecture)
4. [Data Model](#data-model)
5. [Implementation Phases](#implementation-phases)
6. [Security & Privacy](#security--privacy)
7. [Edge Cases & Conflict Resolution](#edge-cases--conflict-resolution)
8. [Testing Strategy](#testing-strategy)
9. [Migration Path](#migration-path)
10. [Alternatives Considered](#alternatives-considered)

---

## 🏗️ **Architecture Overview**

### **High-Level Concept**

```
┌─────────────────────────────────────────────┐
│     CloudKit Shared Record Zone             │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Household Database                 │   │
│  │  - All Recipes                      │   │
│  │  - All Grocery Lists                │   │
│  │  - All Meal Plans                   │   │
│  │  - All Categories                   │   │
│  │  - All Ingredient Templates         │   │
│  │  - All Planned Meals               │   │
│  │  - Shared UserPreferences          │   │
│  └─────────────────────────────────────┘   │
│                                             │
│          ↓           ↓           ↓          │
│      Owner    Participant  Participant      │
│     (Person A)  (Person B)  (Person C)      │
│                                             │
│   All see same data, all changes sync      │
└─────────────────────────────────────────────┘
```

### **Key Characteristics**

**Shared Zone:**
- ONE database for the entire household
- ALL records automatically shared
- ALL members see ALL data
- Changes sync in real-time across all devices
- No manual sharing per item required

**vs CKShare (Individual Item Sharing):**
- Multiple private databases
- SELECTIVE sharing per item
- Manual share button clicks
- Complex permission management
- Better for sharing with friends/extended family

---

## 👥 **Use Case & User Journey**

### **Primary Use Case**

**Personas**:
- Sarah: Lives with her partner Mike
- Both manage groceries and meal planning together
- Use iPhones to coordinate shopping and cooking

**Current State (Without Shared Zone)**:
- Sarah adds "milk" to her list → Mike doesn't see it
- Mike creates "Taco Tuesday" meal plan → Sarah can't see it
- Constant text messages: "Did you add eggs?" "What's for dinner?"
- Frustrating lack of coordination

**Desired State (With Shared Zone)**:
- Sarah adds "milk" → Mike sees it instantly
- Mike creates meal plan → Sarah sees it on her phone
- Both can edit, add, delete - always in sync
- Seamless household coordination

---

### **User Journey**

#### **Setup Phase (One-Time)**

**Step 1: Owner Initiates Household**
```
Sarah opens Forager → Settings → Household
[Create Household] button
→ "Would you like to share your Forager data with household members?"
→ [Yes, Create Household]
→ CloudKit shared zone created
→ All Sarah's existing data migrated to shared zone
```

**Step 2: Owner Invites Member**
```
Sarah → Settings → Household → [Invite Member]
→ Enter Mike's iCloud email: mike@icloud.com
→ [Send Invitation]
→ Mike receives iCloud notification
```

**Step 3: Member Accepts**
```
Mike receives notification → [Accept]
→ Mike's Forager app opens
→ "Join Sarah's Household?"
→ [Join Household]
→ Mike sees all of Sarah's recipes, lists, meal plans
→ Mike's devices now sync with shared database
```

#### **Daily Usage (Ongoing)**

**Scenario 1: Adding to Grocery List**
```
Sarah (on iPhone): Opens "This Week" list → Adds "milk"
↓ (CloudKit sync: ~2 seconds)
Mike (on iPhone): Opens "This Week" list → Sees "milk"
```

**Scenario 2: Creating Meal Plan**
```
Mike (on iPad): Creates "Week of Dec 23-29" meal plan
Mike: Adds "Tacos" to Tuesday, "Pasta" to Thursday
↓ (CloudKit sync: ~2 seconds)
Sarah (on iPhone): Opens Meal Plans → Sees Mike's plan
Sarah: Edits Tuesday → Changes to "Burritos"
↓ (CloudKit sync: ~2 seconds)
Mike (on iPad): Sees update → "Burritos" now shown
```

**Scenario 3: Managing Recipes**
```
Sarah: Creates "Chocolate Chip Cookies" recipe
↓ (CloudKit sync: ~2 seconds)
Mike: Sees recipe in his recipe list
Mike: Marks recipe as favorite ⭐
↓ (CloudKit sync: ~2 seconds)
Sarah: Sees favorite star on her device
```

---

### **Offline Behavior**

**Scenario: Mike Offline, Sarah Online**
```
Mike (offline): Adds "eggs" to grocery list
→ Saved locally to Core Data
→ Queued for CloudKit upload
Mike (goes online): 
→ CloudKit queue processes
→ "eggs" syncs to shared zone
Sarah (already online):
→ Receives notification of change
→ "eggs" appears in her list
```

---

## 🔧 **Technical Architecture**

### **CloudKit Zone Structure**

**NSPersistentCloudKitContainer Configuration:**

```swift
// Persistence.swift

let container: NSPersistentCloudKitContainer

init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "forager")
    
    if let description = container.persistentStoreDescriptions.first {
        // Configure for shared zone (M7.2+)
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.richhayn.forager"
        )
        
        // M7.2: Enable shared database scope
        cloudKitOptions.databaseScope = .shared
        
        description.cloudKitContainerOptions = cloudKitOptions
        
        // Enable history tracking (required)
        description.setOption(true as NSNumber, 
                            forKey: NSPersistentHistoryTrackingKey)
        
        // Enable remote change notifications (required)
        description.setOption(true as NSNumber, 
                            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    }
    
    container.loadPersistentStores { storeDescription, error in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    // Configure view context for shared zone
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
}
```

---

### **Zone Scopes**

CloudKit supports three database scopes:

1. **Private** (Default - M7.1)
   - User's personal data
   - Only accessible by that user across their devices
   - M7.1 currently uses this

2. **Shared** (M7.2+ - Household)
   - Data shared with specific users
   - All participants can read/write
   - **THIS IS WHAT WE'RE IMPLEMENTING**

3. **Public** (Not Used)
   - Data accessible to anyone
   - Not applicable for household use case

---

### **Household Management**

**New Entities (M7.2.1):**

```swift
// Household.swift (NEW)
@objc(Household)
public class Household: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?  // "Sarah & Mike's Household"
    @NSManaged public var createdDate: Date?
    @NSManaged public var ownerEmail: String?  // iCloud email of creator
    @NSManaged public var shareRecord: CKShare?  // CloudKit share for zone
    
    // Computed
    public var isOwner: Bool {
        // Check if current user is owner
        // Compare ownerEmail with CKContainer.default().fetchUserRecordID()
    }
}

// HouseholdMember.swift (NEW)
@objc(HouseholdMember)
public class HouseholdMember: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var email: String?  // iCloud email
    @NSManaged public var displayName: String?  // "Mike"
    @NSManaged public var joinedDate: Date?
    @NSManaged public var role: String?  // "owner" or "member"
    @NSManaged public var household: Household?
}
```

---

### **Share Creation Flow**

**M7.2.2: Creating Shared Zone**

```swift
// HouseholdService.swift (NEW)

class HouseholdService {
    private let container: NSPersistentCloudKitContainer
    
    /// Creates a new household and shared zone
    func createHousehold(name: String) async throws -> Household {
        // 1. Create Household entity
        let household = Household(context: container.viewContext)
        household.id = UUID()
        household.name = name
        household.createdDate = Date()
        
        // 2. Get current user's email
        let userRecordID = try await CKContainer.default().userRecordID()
        let userRecord = try await CKContainer.default().publicCloudDatabase.record(for: userRecordID)
        household.ownerEmail = userRecord.value(forKey: "emailAddress") as? String
        
        // 3. Create shared zone
        let share = try await container.share(
            [household],
            to: nil  // Creates new share
        )
        
        // 4. Configure share
        share[CKShare.SystemFieldKey.title] = name
        share.publicPermission = .none  // Private sharing only
        
        // 5. Save share record
        household.shareRecord = share
        try container.viewContext.save()
        
        print("✅ Household created with shared zone")
        return household
    }
    
    /// Invites a member to the household
    func inviteMember(email: String, to household: Household) async throws {
        guard let share = household.shareRecord else {
            throw HouseholdError.noShareRecord
        }
        
        // Present UICloudSharingController to send invitation
        let controller = UICloudSharingController(
            share: share,
            container: CKContainer(identifier: "iCloud.com.richhayn.forager")
        )
        
        // Set email as pre-filled recipient
        // iOS handles invitation sending
    }
}
```

---

## 📊 **Data Model**

### **CRITICAL ARCHITECTURE DECISION: All Entities Household-Scoped**

**Decision Date**: December 23, 2025  
**Status**: ✅ APPROVED  

**Decision**: ALL user-created entities will have explicit `household` relationship, including IngredientTemplate.

**Rationale**:
1. **Security & Privacy**: Explicit data ownership prevents potential leakage
2. **Architectural Consistency**: Zero special cases - all entities follow same pattern
3. **Clear Mental Model**: Everything the user touches is household-scoped
4. **Future-Proof**: Clean migration path when adding external ingredient databases
5. **YAGNI Principle**: Don't build for hypothetical global template use case today

**Entities Requiring Household Relationship (8 total)**:
- ✅ GroceryItem - Top-level user content
- ✅ Recipe - Top-level user content  
- ✅ WeeklyList - Top-level user content
- ✅ MealPlan - Top-level user content
- ✅ Tag - Top-level user content
- ✅ Ingredient - Child entity, explicit ownership for security
- ✅ GroceryListItem - Child entity, explicit ownership for security
- ✅ **IngredientTemplate - HOUSEHOLD-SCOPED** (architectural pivot)

**Why IngredientTemplate Gets Household Relationship**:
- User concern: "If I had ingredients showing up that I didn't put there, I'd be concerned about security"
- Templates are created automatically during ingredient parsing - user should only see THEIR templates
- Future external integration (Spoonacular, Open Food Facts) will use SEPARATE entity: `PublicIngredientTemplate`
- Clean separation: household templates vs public templates (when needed)
- No migration required when adding external databases - just add new entity

**Implementation Pattern** (ALL entities):
```swift
// Every user entity
entity.household = currentHousehold // Explicit ownership

// CloudKit query
let predicate = NSPredicate(format: "household == %@", currentHousehold)
// ✅ Can filter at database level
// ✅ No possibility of seeing other household's data
```

**Future External Integration** (M10+):
```swift
// When adding external databases
+ PublicIngredientTemplate (new entity, external sources)
+ PublicRecipe (new entity, external sources)

// Lookup strategy
func findTemplate(name: String, household: Household) -> Template {
    // 1. Check household templates first (user's custom entries)
    if let custom = household.templates.find(name) { return custom }
    
    // 2. Fall back to public database (external source)
    if let public = PublicIngredientTemplate.find(name) { return public }
    
    // 3. Create new household template if not found
    return household.createTemplate(name)
}
```

**Alternatives Considered & Rejected**:
- ❌ Global IngredientTemplate (no household): Violates security principle, user confusion
- ❌ Mixed approach (5 with household, 3 without): Inconsistent architecture, special cases
- ❌ Dual storage (household + global): Premature optimization, YAGNI violation

**Benefits of This Decision**:
- ✅ **Zero special cases** - all entities follow identical pattern
- ✅ **Security first** - explicit ownership prevents data leakage  
- ✅ **Clear to users** - everything is "mine" or "my household's"
- ✅ **Simple to implement** - one pattern for all entities
- ✅ **Easy to extend** - add external databases when actually needed

---

### **Modified Entities**

**All Existing Entities Modified to Add Household Relationship**:

- GroceryItem → Add `household` relationship (optional, to-one, nullify)
- Recipe → Add `household` relationship (optional, to-one, nullify)  
- WeeklyList → Add `household` relationship (optional, to-one, nullify)
- MealPlan → Add `household` relationship (optional, to-one, nullify)
- Tag → Add `household` relationship (optional, to-one, nullify)
- Ingredient → Add `household` relationship (optional, to-one, nullify)
- GroceryListItem → Add `household` relationship (optional, to-one, nullify)
- **IngredientTemplate → Add `household` relationship (optional, to-one, nullify)**

**Why Optional Relationships**:
- Existing data remains valid (no household = individual mode)
- Backward compatible during migration
- CloudKit sync works with or without household
- Users can use app solo or in household mode

---

### **New Entities (M7.2.1)**

```
Household
├── id: UUID (primary key)
├── name: String ("Sarah & Mike's Household")
├── createdDate: Date
├── ownerEmail: String (iCloud email of creator)
├── shareRecord: CKShare (CloudKit share object)
└── members: [HouseholdMember] (relationship)

HouseholdMember
├── id: UUID (primary key)
├── email: String (iCloud email)
├── displayName: String ("Mike")
├── joinedDate: Date
├── role: String ("owner" | "member")
└── household: Household (relationship inverse)
```

---

### **Relationships**

```
Household (1) ←→ (many) HouseholdMember
```

All other entities remain unchanged and automatically become part of shared zone when created after household setup.

---

## 🚀 **Implementation Phases**

### **M7.2.1: Household Setup (3-4 hours)**

**Deliverables:**
- `Household` and `HouseholdMember` Core Data entities
- `HouseholdService` for creating/managing household
- Settings → Household section UI
- "Create Household" flow
- Shared zone creation

**Acceptance Criteria:**
- ✅ User can create household
- ✅ Shared zone created in CloudKit
- ✅ Existing data migrated to shared zone
- ✅ Owner can see household in Settings

---

### **M7.2.2: Member Invitation (2-3 hours)**

**Deliverables:**
- Invitation sending via UICloudSharingController
- Member acceptance flow
- HouseholdMember creation on acceptance
- Welcome screen for new members

**Acceptance Criteria:**
- ✅ Owner can invite member via email
- ✅ Member receives iCloud notification
- ✅ Member can accept invitation
- ✅ Member sees all household data after joining

---

### **M7.2.3: Sync Validation (1-2 hours)**

**Deliverables:**
- Multi-device testing (Owner's iPhone + Participant's iPhone)
- Concurrent edit testing
- Offline → online queue testing
- Performance validation

**Acceptance Criteria:**
- ✅ Changes sync within 5 seconds
- ✅ Both users see same data
- ✅ Concurrent edits handled gracefully
- ✅ Offline changes sync when back online

---

### **M7.2.4: Household Management (1-2 hours)**

**Deliverables:**
- View household members list
- Remove member functionality (owner only)
- Leave household functionality (member only)
- Dissolve household functionality (owner only)

**Acceptance Criteria:**
- ✅ Owner can remove members
- ✅ Members can leave household
- ✅ Owner can dissolve household (migrates data back to private)
- ✅ UI shows member list with roles

---

## 🔒 **Security & Privacy**

### **Access Control**

**Owner Permissions:**
- ✅ Create household
- ✅ Invite members
- ✅ Remove members
- ✅ Dissolve household
- ✅ Full read/write to all data

**Member Permissions:**
- ✅ Accept invitation
- ✅ Full read/write to all data
- ✅ Leave household (not remove others)
- ❌ Cannot remove other members
- ❌ Cannot dissolve household

**Implementation:**
```swift
// Check if user is owner
func isOwner(household: Household) async -> Bool {
    let currentUserEmail = try? await getCurrentUserEmail()
    return currentUserEmail == household.ownerEmail
}

// Role-based UI
if isOwner {
    // Show "Remove Member" button
    // Show "Dissolve Household" button
} else {
    // Show "Leave Household" button only
}
```

---

### **Data Privacy**

**What's Shared:**
- ALL recipes, grocery lists, meal plans
- ALL categories, ingredient templates
- ALL user preferences (or separate per-user - TBD in M7.2.1)

**What's NOT Shared:**
- iCloud authentication credentials (handled by Apple)
- Personal Apple ID information
- Device-specific data (local Core Data only)

**Privacy Policy Implications:**
- Update privacy policy (already done in M7.0.1)
- Note that household members see all data
- User consent required before joining household

---

## ⚡ **Edge Cases & Conflict Resolution**

### **Concurrent Edits**

**Scenario**: Sarah and Mike both edit same grocery list item simultaneously

**CloudKit Behavior**:
- Last-write-wins (NSMergeByPropertyObjectTrumpMergePolicy)
- Conflicts automatically resolved by CloudKit
- Occasional data loss possible (rare)

**Mitigation**:
- Use optimistic locking (Core Data's default)
- Sync frequently (M7.1.2 CloudKitSyncMonitor)
- Inform users of conflict (M7.3)

---

### **Member Removal**

**Scenario**: Owner removes Mike from household

**Expected Behavior**:
1. Mike loses access to shared zone
2. Mike's app switches to private database
3. Mike's local data preserved (Core Data)
4. Mike cannot make new changes to shared data

**Implementation**:
```swift
func removeMember(_ member: HouseholdMember) async throws {
    guard let household = member.household,
          let share = household.shareRecord else {
        throw HouseholdError.noShareRecord
    }
    
    // Remove participant from CloudKit share
    let participants = share.participants
    if let participant = participants.first(where: { $0.userIdentity.userRecordID.recordName == member.email }) {
        share.removeParticipant(participant)
        
        // Save updated share
        try await CKContainer.default().privateCloudDatabase.save(share)
        
        // Delete HouseholdMember entity
        container.viewContext.delete(member)
        try container.viewContext.save()
    }
}
```

---

### **Household Dissolution**

**Scenario**: Owner (Sarah) dissolves household

**Expected Behavior**:
1. All members lose access to shared zone
2. Owner's data migrated back to private zone
3. Members' local copies preserved but read-only
4. Members can export data before dissolution (optional feature)

**Data Migration**:
```swift
func dissolveHousehold(_ household: Household) async throws {
    // 1. Delete CloudKit share
    if let share = household.shareRecord {
        try await CKContainer.default().privateCloudDatabase.delete(withRecordID: share.recordID)
    }
    
    // 2. Migrate all records from shared → private zone
    // CloudKit handles this automatically when share is deleted
    
    // 3. Delete Household and HouseholdMember entities
    if let members = household.members as? Set<HouseholdMember> {
        for member in members {
            container.viewContext.delete(member)
        }
    }
    container.viewContext.delete(household)
    
    // 4. Save changes
    try container.viewContext.save()
}
```

---

## 🧪 **Testing Strategy**

### **Unit Tests**

**HouseholdService Tests:**
- Create household
- Invite member
- Remove member
- Dissolve household
- Error handling (no network, invalid email, etc.)

---

### **Integration Tests**

**Multi-Device Sync:**
- Device A creates household
- Device B joins household
- Device A adds recipe → Device B sees it
- Device B edits recipe → Device A sees update
- Concurrent edits handled correctly

**Offline/Online:**
- Device A offline, adds item
- Device A goes online → item syncs
- Device B receives update

---

### **Manual Testing**

**Happy Path:**
1. Sarah creates household
2. Sarah invites Mike
3. Mike accepts
4. Both add/edit data
5. Both see changes sync

**Edge Cases:**
1. Sarah removes Mike
2. Mike loses access
3. Sarah dissolves household
4. Data migrated correctly

---

## 🔄 **Migration Path**

### **From M7.1 (Private Zone) → M7.2 (Shared Zone)**

**User Impact:**
- Users who DON'T create household: No change (stay on private zone)
- Users who CREATE household: One-time data migration

**Migration Flow:**
```
User: [Create Household]
↓
App: "This will move all your data to a shared database. Continue?"
↓
User: [Yes]
↓
App: Creates shared zone in CloudKit
App: Migrates all existing Core Data records to shared zone
App: Deletes records from private zone
↓
Done: User now in shared zone
```

**Technical Implementation:**
```swift
func migrateToSharedZone() async throws {
    // 1. Fetch all entities from private zone
    let recipes = try container.viewContext.fetch(Recipe.fetchRequest())
    let lists = try container.viewContext.fetch(WeeklyList.fetchRequest())
    // ... etc for all entities
    
    // 2. Create household (triggers shared zone creation)
    let household = try await createHousehold(name: "My Household")
    
    // 3. CloudKit automatically migrates records when share is created
    // No manual copying needed - CloudKit handles it!
    
    // 4. Verify migration complete
    print("✅ Migrated \(recipes.count) recipes, \(lists.count) lists")
}
```

---

### **Rollback Plan**

**If user wants to leave shared zone:**
```swift
func leavehousehold() async throws {
    // Member leaves household
    // Data stays in shared zone
    // Member's app switches back to private zone
    // Member starts fresh with empty database
    
    // Optional: Export data before leaving
}
```

---

## 🤔 **Alternatives Considered**

### **Option 1: CKShare (Individual Item Sharing) - REJECTED**

**What We Built in M7.2.1 (3.5 hours wasted)**

**Approach:**
- Each Recipe, WeeklyList, MealPlan has `ckShareRecord` attribute
- Share buttons in every detail view
- Manual sharing per item

**Why Rejected:**
- ❌ Tedious for household use case (share every single list/recipe)
- ❌ Confusing UX (which items are shared? with whom?)
- ❌ Not what users want (they want household database)
- ❌ Complex permission management

**When to Use:**
- Sharing recipes with friends (non-household)
- Selective collaboration on specific lists
- Public sharing (share link functionality)

---

### **Option 2: Shared Zone (Household Database) - SELECTED ✅**

**Approach:**
- ONE shared database for entire household
- All data automatically shared
- One-time household setup

**Why Selected:**
- ✅ Perfect for household use case
- ✅ Simple UX (invite once, share everything)
- ✅ Matches user mental model
- ✅ Cleaner architecture

**Implementation:** M7.2 (this document)

---

### **Option 3: Third-Party Backend (Firebase/Supabase) - REJECTED**

**Approach:**
- Use Firebase Realtime Database or Supabase
- Custom sync logic

**Why Rejected:**
- ❌ Additional infrastructure cost
- ❌ More complex to implement
- ❌ Doesn't leverage iCloud (users already have)
- ❌ Privacy concerns (data on third-party servers)

**When to Consider:**
- If CloudKit proves insufficient
- If need Android support (future)
- If need more complex queries

---

## 📚 **References**

### **Apple Documentation**

- [Setting Up Core Data with CloudKit (Shared Zone)](https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/creating_a_core_data_model_for_cloudkit)
- [NSPersistentCloudKitContainer](https://developer.apple.com/documentation/coredata/nspersistentcloudkitcontainer)
- [CKShare](https://developer.apple.com/documentation/cloudkit/ckshare)
- [CloudKit Database Scopes](https://developer.apple.com/documentation/cloudkit/ckdatabase/scope)

---

### **WWDC Videos**

- [WWDC 2021: Sync a Core Data app with CloudKit](https://developer.apple.com/videos/play/wwdc2021/10015/)
- [WWDC 2019: Introducing CloudKit Support in Core Data](https://developer.apple.com/videos/play/wwdc2019/202/)

---

### **Related Project Documentation**

- [25-m7-architecture-pivot-ckshare-vs-shared-zone.md](../learning-notes/25-m7-architecture-pivot-ckshare-vs-shared-zone.md) - Why we pivoted
- [24-m7.1.1-cloudkit-schema-validation.md](../learning-notes/24-m7.1.1-cloudkit-schema-validation.md) - M7.1 foundation
- [milestone-7-cloudkit-sync-external-testflight.md](../prds/milestone-7-cloudkit-sync-external-testflight.md) - High-level M7 plan

---

## ✅ **Validation & Approval**

**Architecture Validated**: December 21, 2025  
**Approved By**: Rich (Product Owner)  
**Implementation Start**: After M7.2 PRD complete  

**Validation Questions Answered:**
- ✅ CKShare vs Shared Zone decision clear
- ✅ Use case well-defined (household collaboration)
- ✅ Technical approach documented
- ✅ Migration path understood
- ✅ Security/privacy addressed

**Ready for Implementation**: YES ✅

---

**Version**: 1.0  
**Author**: Claude (with Rich's requirements)  
**Date**: December 21, 2025  
**Status**: Approved for M7.2+ Implementation
