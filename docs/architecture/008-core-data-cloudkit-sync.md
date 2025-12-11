# ADR 008: Core Data + CloudKit Sync Integrity & Semantic Uniqueness

**Status:** Approved  
**Date:** December 2025  
**Related Milestones:**  
- M7 – CloudKit Sync, Family Sharing & TestFlight  
- M7.1.1 – Core Data Impact Analysis  
- M7.1.2 – CloudKit Sync Monitor  
- M7.1.3 – Sync Integrity & Multi-Device Testing  

---

# 1. Context

Forager uses **Core Data + NSPersistentCloudKitContainer** to provide:

- Offline-first persistence  
- Multi-device sync across iPhone + iPad (and future Mac)  
- Foundation for optional CloudKit Sharing for multi-user scenarios  

During M7.1.3 multi-device testing, a critical issue surfaced:

> CloudKit sync does **not** prevent semantic duplicates, because Core Data identity is based strictly on UUID.  
> The app created duplicate Categories, IngredientTemplates, WeeklyLists, and more.

Examples:

- Two devices seed default Categories → 14 categories instead of 7  
- Ingredient parsing creates multiple “eggs” templates with different UUIDs  
- WeeklyList created independently for the same week → duplicates  
- UI crashes because dictionaries expect unique keys  

This occurs because:

- CloudKit sync mirrors Core Data exactly  
- Core Data does not enforce uniqueness on semantic fields  
- No domain rules previously existed to prevent duplicate creation  
- UI assumed uniqueness that the model does not guarantee  

This harms reliability, UX, and sync stability.

---

# 2. Problem

The system lacks **semantic identity** for all domain entities.

| Entity | Intended Identity | Current Identity | Result |
|--------|-------------------|------------------|--------|
| Category | Unique by name (“Produce”) | UUID only | Duplicate rows crash UI |
| IngredientTemplate | Unique by canonical ingredient | UUID | Multiple “eggs” templates |
| WeeklyList | One list per ISO week | UUID | Several lists for same week |
| MealPlan | One per date+slot | UUID | Duplicate meal entries |

Consequences:

- Fatal crashes  
- Divergent data across devices  
- Conflicting versions of the same logical object  
- Ingredient usage tracking becomes split-brain  
- Growing sync instability if not addressed  

This must be corrected **before** releasing a TestFlight build.

---

# 3. Decision

### We will introduce a **Semantic Identity + Repository Architecture** to guarantee sync safety and prevent duplicates.

This includes:

## 3.1 Semantic Keys
Add fields that represent the true identity:

- `Category.normalizedName`
- `IngredientTemplate.canonicalName`
- `WeeklyList.weekIdentifier` (ISO week format)
- `MealPlan.slotKey` (date + mealType)
- `Recipe.canonicalTitle` (non-unique; used for grouping, not identity)

## 3.2 Unique Constraints

Core Data model must enforce:

- Category: `normalizedName`
- IngredientTemplate: `canonicalName`
- MealPlan: `slotKey` (optional for this milestone)

## 3.3 Repository Pattern

All creation of key domain entities must go through dedicated repositories:

- `CategoryRepository`
- `IngredientTemplateService`
- `WeeklyListRepository`
- `MealPlanRepository`

Repositories must:

- Compute semantic keys  
- Query before creating  
- Return existing entity if found  
- NEVER call `init(context:)` in UI or view models  

## 3.4 Deduplication Migration

A one-time migration must:

- Identify duplicates  
- Choose a deterministic keeper  
- Reassign relationships  
- Delete duplicates  
- Save changes → CloudKit propagates merged records  

## 3.5 UI Safety

UI must:

- Never assume uniqueness  
- Avoid dictionary initializers that require unique keys  
- Use grouping operations instead  

## 3.6 Prepare for CloudKit Sharing

Add metadata:

- `ownerUserRecordID`
- `sharingScope`

Behavior does not change yet.

---

# 4. Rationale

This approach:

- Makes Core Data safe for multi-device sync  
- Makes CloudKit mirroring predictable  
- Eliminates crashes from duplicate keys  
- Prevents corruption of IngredientTemplate usage tracking  
- Enables smooth migration to CloudKit Sharing later  
- Supports long-term scalability without introducing a backend prematurely  

Rejected alternatives:

- **Fixed UUIDs only** — works only for default categories  
- **CloudKit validator functions** — not supported in Private DB  
- **Moving to server backend now** — too heavy for current milestone and not aligned with Apple-only scope  

---

# 5. Detailed Design

## 5.1 Semantic Key Definitions

**Category**

normalizedName = displayName.trim().lowercased()

**IngredientTemplate**

canonicalName = ingredientName.trim().lowercased()

**WeeklyList**

weekIdentifier = ISOWeekFormatter.string(from: date)

**MealPlan**

slotKey = “(YYYY-MM-DD)-(mealType.rawValue)”

## 5.2 Merge Policies

All contexts use:

container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
container.viewContext.automaticallyMergesChangesFromParent = true

## 5.3 Repository Creation Rules

- UI and view models **never** instantiate NSManagedObject subclasses directly  
- Repositories guarantee semantic uniqueness  
- Creation is always get-or-create  

## 5.4 Dedup Algorithm

For each entity:

1. Group by semantic key  
2. If group.count > 1  
3. Choose keeper = record with most relationships, else oldest creation date  
4. Migrate all references  
5. Delete others  
6. Save  

Idempotent.

---

# 6. Consequences

### Positive:
- Stable CloudKit sync  
- Prevents app crashes  
- Unified ingredient usage tracking  
- Clean domain model  
- Foundation for CloudKit Sharing  

### Negative:
- Additional code required  
- Developers must follow repository patterns  
- One migration step needed  

---

# 7. Implementation Plan

1. Add semantic key fields  
2. Add Core Data constraints  
3. Build repositories  
4. Replace direct entity creation  
5. Add dedup step  
6. Harden UI  
7. Run multi-device tests  
8. Release to TestFlight  

---

# 8. Status

**Accepted and in execution.**  