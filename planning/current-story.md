# Current Story: Story 1.2.5 - Core Data Performance & Architecture (NEW)

**Story ID**: 1.2.5 (NEW - Inserted before Story 1.3 completion)
**Goal**: Implement selective technical improvements for better performance and maintainability
**Status**: Ready to Start
**Estimated Duration**: 3-4 hours
**Development Machine**: MacBook Air (fully configured and tested)
**Context**: Architecture review identified high-value, low-risk improvements to implement before completing Story 1.3

## 🎯 Story 1.2.5 Overview: Technical Foundation Enhancement

### Why This Story Was Added
After comprehensive architecture review, we identified several improvements that will:
1. **Improve Performance**: Predicate-based queries vs computed properties
2. **Prevent UI Blocking**: Background write operations for Core Data
3. **Enable Future Growth**: Model versioning and professional error handling
4. **Maintain Focus**: High-value improvements without over-engineering

### Architecture Decision Context
- **ADOPTED**: High-value, low-risk Core Data improvements
- **DEFERRED**: Repository pattern, ViewModels, complex sync coordination
- **FOCUS**: Maintain learning momentum while building professional foundation
- **DOCUMENTATION**: Complete ADR created at `docs/architecture/decisions/001-selective-technical-improvements.md`

---

## ✅ Previous Stories Status

### Story 1.1: Environment Setup - COMPLETED 8/16/25 ✅
- [x] GitHub repository created and organized
- [x] VS Code configured with Swift extensions
- [x] Xcode 16.4 installed and configured
- [x] iOS project created with Core Data + CloudKit
- [x] Project builds and runs successfully in simulator
- [x] Core Data template verified working

### Story 1.2: Core Data Foundation - COMPLETED 8/18/25 ✅
**Major Achievement: Complete Project Recreation on MacBook Air**

#### MacBook Air Recreation (8/18/25):
- [x] **Complete environment setup** (Homebrew, Git, Xcode CLI, VS Code)
- [x] **Repository cloned** and GitHub authentication configured
- [x] **New Xcode project created** with Core Data + CloudKit integration
- [x] **6 entities recreated** exactly matching documented specifications
- [x] **All Core Data classes generated** manually to avoid conflicts
- [x] **Comprehensive sample data** with realistic scenarios:
  - 12 grocery items (8 staples) across 5 categories
  - 4 sample recipes with usage tracking and source URLs
  - 6 recipe tags with color coding
  - Sample weekly shopping list with mixed sources
- [x] **Professional iOS UI** with staple indicators and category display
- [x] **Git repository issues resolved** (submodule conflicts fixed)
- [x] **All files properly tracked** in version control
- [x] **Working iOS app** builds and runs with sample data
- [x] **CloudKit integration** configured (ready when developer account available)

### Story 1.3: Staples Management Foundation - COMPLETED 8/18/25 ✅
- [x] **StaplesView created** with dedicated staples-only interface
- [x] **Filtering implemented** - Only displays `isStaple == true` items
- [x] **Professional UI design** with staple indicators and category display
- [x] **Add functionality working** - Can create new staples with unique names
- [x] **Delete functionality working** - Swipe-to-delete with Core Data persistence
- [x] **List scrolling functional** - Fixed NavigationView conflicts
- [x] **Core Data integration** - Proper @FetchRequest with filtering
- [x] **Data persistence verified** - Changes save and load correctly
- [x] **Professional iOS patterns** - Native toolbar, edit mode, animations

---

## 🚧 Story 1.2.5 Tasks (3-4 hours)

### Phase 1: Core Data Performance Improvements (2-3 hours)

#### Task 1.1: Add Core Data Indexes (30 minutes)
- [ ] **Open GroceryRecipeManager.xcdatamodeld** in Xcode Data Model Inspector
- [ ] **Add indexes for GroceryItem entity**:
  - isStaple (Boolean) - Most frequently queried attribute
  - category (String) - Used for grouping and filtering
  - dateCreated (Date) - Used for sorting and recent items
- [ ] **Add indexes for Recipe entity**:
  - usageCount (Int32) - For "most used" queries
  - lastUsed (Date) - For "recently used" queries  
  - isFavorite (Boolean) - For favorites filtering
- [ ] **Test**: Verify model validates and builds successfully
- [ ] **Document**: Note performance improvement expectations

**Expected Outcome**: Faster queries on frequently filtered attributes, especially isStaple filtering

#### Task 1.2: Update PersistenceController with Background Writes (45 minutes)
- [ ] **Add performWrite method** to PersistenceController.swift:
```swift
func performWrite(_ block: @escaping (NSManagedObjectContext) -> Void) {
    container.performBackgroundTask { ctx in
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        block(ctx)
        if ctx.hasChanges { 
            try? ctx.save() 
        }
    }
}
```
- [ ] **Set merge policy** to NSMergeByPropertyObjectTrumpMergePolicy for main context
- [ ] **Test background write functionality** with sample data operations
- [ ] **Verify**: Background operations don't block UI thread
- [ ] **Add error handling** for background context failures

**Expected Outcome**: Non-blocking UI during Core Data save operations

#### Task 1.3: Convert StaplesView to Predicate-Based FetchRequest (30 minutes)
- [ ] **Replace computed property filtering** with NSPredicate in @FetchRequest: