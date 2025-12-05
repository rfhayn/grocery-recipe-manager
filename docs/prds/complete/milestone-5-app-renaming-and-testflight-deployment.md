# PRD: M5.0 - Complete App Renaming & TestFlight Deployment

**Document Version**: 1.0  
**Created**: November 28, 2025  
**Priority**: HIGH - Foundation for production deployment  
**Estimated Duration**: 4-6 hours total across 5 phases  
**Dependencies**: M4 Complete ✅, Apple Developer Account enrollment required

---

## Executive Summary

Systematically rename the entire project from "forager" to a new app name, updating all technical identifiers, file structures, documentation, and GitHub repository while maintaining zero code breakage. Follow with TestFlight deployment to enable real-device testing. This milestone establishes production-ready branding and infrastructure before CloudKit implementation.

**Critical Success Factors**:
- Zero build breaks at any checkpoint
- Complete renaming (visible AND behind-the-scenes)
- Validation after each phase prevents cascading failures
- Git history preserved throughout
- TestFlight deployment successful

---

## Problem Statement

### Current State Issues
1. **Generic naming**: "forager" lacks brand identity and market appeal
2. **Inconsistent references**: Project name appears in 50+ locations across code, docs, GitHub
3. **Bundle ID locked**: Once App Store Connect record created, bundle ID is permanent
4. **No validation path**: Can't test on real devices before CloudKit investment
5. **Behind-the-scenes clutter**: File names, folder structures, Xcode configurations all use old name

### Business Impact
- **Marketing**: Generic name lacks memorability and App Store appeal
- **Technical debt**: Inconsistent naming creates confusion and maintenance burden
- **Risk management**: No real-device validation before 20-25 hour CloudKit investment
- **Professional quality**: File structure doesn't reflect production standards

---

## Solution Overview

### Five-Phase Systematic Approach

**M5.0.1: Name Selection & Planning** (30 minutes)  
- Choose display name, bundle ID, marketing name
- Document naming strategy
- Create rename checklist

**M5.0.2: Xcode Project Renaming** (1-1.5 hours)  
- Update bundle identifiers (3 targets)
- Rename Xcode project and scheme
- Update all Xcode configuration files
- **VALIDATION CHECKPOINT 1**: Build succeeds

**M5.0.3: File & Folder Structure Renaming** (1-1.5 hours)  
- Rename source code folders
- Update file references
- Rename Core Data model container
- Update entitlements file
- **VALIDATION CHECKPOINT 2**: Build succeeds, app runs

**M5.0.4: Documentation & GitHub Renaming** (45-60 minutes)  
- Update all documentation files
- Rename GitHub repository
- Update README and repo metadata
- Update Claude project knowledge references
- **VALIDATION CHECKPOINT 3**: All docs consistent

**M5.0.5: TestFlight Deployment** (45-90 minutes + wait time)  
- Apple Developer Account enrollment
- App Store Connect setup
- Build archive and upload
- TestFlight configuration
- **VALIDATION CHECKPOINT 4**: App installs on real device

---

## M5.0.1: Name Selection & Planning

### Estimated Time: 30 minutes

### Objectives
1. Choose final app name and all technical identifiers
2. Document naming strategy for consistency
3. Create comprehensive rename checklist
4. Identify all files/locations requiring updates

### Deliverables

#### Name Selection Decision Matrix

**Display Name** (Home screen, 10-12 char visible):
- Requirements: Short, memorable, descriptive
- Examples: "ShopList", "RecipeCart", "MealPrep", "Grocery+"
- Chosen: `[TO BE DECIDED]`

**Bundle Identifier** (Permanent technical ID):
- Format: `com.[yourdomain].[appname]`
- Requirements: Lowercase, no spaces, must be unique
- Chosen: `[TO BE DECIDED]`

**Marketing Name** (App Store, 30 char max):
- Can be longer than display name
- SEO-optimized with keywords
- Example: "ShopList - Grocery & Recipes"
- Chosen: `[TO BE DECIDED]`

**Xcode Project Name** (Developer-facing):
- Recommendation: Match app name for consistency
- Current: "forager"
- New: `[TO BE DECIDED]`

**GitHub Repository Name**:
- Current: "grocery-recipe-manager"
- Recommendation: Match bundle ID style (lowercase-with-dashes)
- New: `[TO BE DECIDED]`

#### Complete Rename Checklist

**Xcode Configuration** (15 items):
- [ ] Main target bundle identifier
- [ ] Main target display name
- [ ] Test target bundle identifier
- [ ] UI test target bundle identifier
- [ ] Scheme name
- [ ] Project name
- [ ] Product name
- [ ] Info.plist references
- [ ] Entitlements file name
- [ ] Entitlements container ID
- [ ] Core Data model file name
- [ ] Core Data model container name
- [ ] Asset catalog references
- [ ] Build settings PRODUCT_NAME
- [ ] Build settings PRODUCT_BUNDLE_IDENTIFIER

**File Structure** (12 items):
- [ ] Root folder name
- [ ] Xcode project folder name
- [ ] Source code folder name
- [ ] Tests folder name
- [ ] UI tests folder name
- [ ] Entitlements file name
- [ ] Core Data model file
- [ ] Preview Content folder
- [ ] Assets.xcassets references
- [ ] App.swift file references
- [ ] Main view references
- [ ] Service file headers

**Documentation** (10 items):
- [ ] docs/project-index.md
- [ ] docs/current-story.md
- [ ] docs/roadmap.md
- [ ] docs/requirements.md
- [ ] docs/next-prompt.md
- [ ] docs/development-guidelines.md
- [ ] All learning notes references
- [ ] All PRD references
- [ ] All ADR references
- [ ] README.md

**GitHub** (5 items):
- [ ] Repository name
- [ ] Repository description
- [ ] README.md title
- [ ] README.md badges/links
- [ ] About section

**Total**: 42 items to update

### Validation Checkpoint 1A
- [ ] All names chosen and documented
- [ ] Rename checklist created with 42 items
- [ ] Strategy documented in this PRD
- [ ] No conflicting names chosen

### Success Criteria
- Clear, consistent naming strategy documented
- Complete checklist ready for systematic execution
- All stakeholders aligned on chosen names

---

## M5.0.2: Xcode Project Renaming

### Estimated Time: 1-1.5 hours

### Objectives
1. Update all bundle identifiers (3 targets)
2. Rename Xcode project file and scheme
3. Update all Xcode internal configurations
4. Maintain working build throughout

### Phase Breakdown

#### Phase 2A: Bundle Identifier Updates (20 minutes)

**Order of operations**:

1. **Main Target Bundle ID**:
   ```
   Steps:
   1. Open Xcode
   2. Select project in navigator
   3. Select "forager" target
   4. General tab → Bundle Identifier
   5. Change from: com.richhayn.groceryrecipemanager
   6. Change to: [NEW_BUNDLE_ID]
   7. Note: This appears in 2 build configurations (Debug + Release)
   ```

2. **Test Target Bundle ID**:
   ```
   Steps:
   1. Select "foragerTests" target
   2. General tab → Bundle Identifier
   3. Change to: [NEW_BUNDLE_ID]Tests
   4. Must match main target + "Tests" suffix
   ```

3. **UI Test Target Bundle ID**:
   ```
   Steps:
   1. Select "foragerUITests" target
   2. General tab → Bundle Identifier
   3. Change to: [NEW_BUNDLE_ID]UITests
   4. Must match main target + "UITests" suffix
   ```

**Validation Checkpoint 2A**:
```bash
# Test 1: Check bundle IDs are consistent
# In Xcode: Product → Scheme → Edit Scheme
# Verify all 3 targets show new bundle IDs

# Test 2: Clean build
# Product → Clean Build Folder (Cmd+Shift+K)
# Product → Build (Cmd+B)
# Expected: BUILD SUCCEEDED

# Test 3: Check for hardcoded references
# Xcode → Find in Project (Cmd+Shift+F)
# Search: "com.richhayn.groceryrecipemanager"
# Expected: Only appears in git history/comments
```

**If validation fails**: 
- Revert bundle IDs
- Check for typos
- Ensure all 3 targets updated

---

#### Phase 2B: Display Name Update (10 minutes)

**Steps**:
1. Select main target → General tab
2. Find "Display Name" field (may be empty, defaulting to target name)
3. Set to: `[NEW_DISPLAY_NAME]`
4. This is what appears under home screen icon

**Validation Checkpoint 2B**:
```bash
# Test 1: Build and run on simulator
# Product → Run (Cmd+R)
# Expected: App launches successfully

# Test 2: Check home screen
# Look at simulator home screen after app installs
# Expected: Icon shows new display name

# Test 3: Check Info.plist
# Open Info.plist
# Verify CFBundleDisplayName (if present) matches new name
```

---

#### Phase 2C: Scheme Rename (15 minutes)

**Steps**:
1. Product → Scheme → Manage Schemes
2. Double-click "forager" scheme
3. Rename to: `[NEW_APP_NAME]`
4. Click "Close"
5. Xcode may prompt to save - click "Save"

**Validation Checkpoint 2C**:
```bash
# Test 1: Scheme appears in dropdown
# Check top-left Xcode toolbar
# Expected: New scheme name visible

# Test 2: Build with new scheme
# Product → Clean Build Folder
# Product → Build
# Expected: BUILD SUCCEEDED

# Test 3: Run tests
# Product → Test (Cmd+U)
# Expected: All tests pass (should be 0 tests currently)
```

---

#### Phase 2D: Project File Rename (20 minutes)

**⚠️ CRITICAL**: This is the most risk-prone step. Follow exactly.

**Preparation**:
```bash
# In Terminal:
cd /path/to/project
git add .
git commit -m "M5.0.2: Before project file rename checkpoint"
```

**Steps**:
1. **Close Xcode completely** (Cmd+Q)
2. **In Finder**:
   - Navigate to project folder
   - Right-click "forager.xcodeproj"
   - Rename to: `[NEW_APP_NAME].xcodeproj`
3. **Rename containing folder** (optional but recommended):
   - Rename "forager" folder to `[NEW_APP_NAME]`
4. **Open renamed project file**:
   - Double-click `[NEW_APP_NAME].xcodeproj`
   - Xcode should open (may take a moment)
5. **Check for red/missing files** in navigator:
   - If files appear red: Right-click → Delete → Remove Reference
   - Then: File → Add Files → Re-add the missing files
   - This fixes broken path references

**Validation Checkpoint 2D**:
```bash
# Test 1: Project opens without errors
# Expected: No warnings about missing files

# Test 2: All files visible in navigator
# Expected: No red files, all sources visible

# Test 3: Clean build
# Product → Clean Build Folder
# Product → Build
# Expected: BUILD SUCCEEDED

# Test 4: Run on simulator
# Product → Run
# Expected: App launches, works normally

# Test 5: Check derived data
# Window → Organizer → Projects
# Verify no duplicate projects listed
# Delete old derived data if present
```

**If validation fails**:
```bash
# Recovery steps:
1. Close Xcode
2. Git revert to checkpoint:
   git reset --hard HEAD
3. Restart from Phase 2D preparation
4. Consider leaving project file name unchanged (optional)
```

---

#### Phase 2E: Target Names & Product Names (15 minutes)

**Steps**:

1. **Update target names** (cosmetic, optional):
   - Select project → Select target
   - Single-click target name in sidebar
   - Rename from "forager" to `[NEW_APP_NAME]`
   - Repeat for test targets

2. **Update product name** (build settings):
   - Select target → Build Settings tab
   - Search for: "Product Name"
   - Change from: $(TARGET_NAME) or "forager"
   - Change to: `[NEW_APP_NAME]`
   - Do this for all 3 targets

**Validation Checkpoint 2E**:
```bash
# Test 1: Final clean build
# Product → Clean Build Folder
# Product → Build
# Expected: BUILD SUCCEEDED

# Test 2: Run all validation tests
# Product → Test
# Expected: Tests pass (or no tests yet)

# Test 3: Archive build (TestFlight preparation)
# Product → Archive
# Expected: Archive succeeds
# Note: Archive doesn't need to be uploaded yet

# Test 4: Check .app file name
# After archive, in Organizer, check app name
# Expected: Shows [NEW_APP_NAME].app
```

---

### M5.0.2 Complete Validation

**Before proceeding to M5.0.3**:

```bash
# Validation Test Suite:

# 1. Clean build succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# 2. App runs on simulator
Product → Run
✓ Expected: App launches, all features work

# 3. No red files in navigator
✓ Expected: All files green/visible

# 4. Scheme renamed
✓ Expected: New name in scheme dropdown

# 5. Bundle IDs updated
Project → Select each target → General
✓ Main target: [NEW_BUNDLE_ID]
✓ Tests target: [NEW_BUNDLE_ID]Tests
✓ UI Tests target: [NEW_BUNDLE_ID]UITests

# 6. Display name updated
✓ Simulator home screen shows new name

# 7. Git checkpoint
git status
git add .
git commit -m "M5.0.2 COMPLETE: Xcode project renamed, all builds pass"
```

**If ALL validations pass**: ✅ Proceed to M5.0.3  
**If ANY validation fails**: 🛑 STOP, debug, re-validate

---

## M5.0.3: File & Folder Structure Renaming

### Estimated Time: 1-1.5 hours

### Objectives
1. Rename all source code folders
2. Update Core Data model file and container
3. Rename entitlements file
4. Update all file header comments
5. Maintain working build throughout

### Phase Breakdown

#### Phase 3A: Source Folder Renaming (25 minutes)

**Current structure**:
```
forager/
├── forager/          # Main source folder
│   ├── Models/
│   ├── Views/
│   ├── Services/
│   ├── foragerApp.swift
│   ├── forager.xcdatamodeld/
│   ├── Assets.xcassets
│   └── forager.entitlements
├── foragerTests/
└── foragerUITests/
```

**Steps**:

1. **In Xcode** (not Finder):
   - Select "forager" folder (blue folder in navigator)
   - File → Show in Finder
   - Note the location

2. **Close Xcode completely**

3. **In Finder**:
   - Rename "forager" folder to `[NEW_APP_NAME]`
   - Rename "foragerTests" to `[NEW_APP_NAME]Tests`
   - Rename "foragerUITests" to `[NEW_APP_NAME]UITests`

4. **Open Xcode project**:
   - Double-click `[NEW_APP_NAME].xcodeproj`
   - **Fix broken references**:
     - Files may appear red in navigator
     - Select red folder → File Inspector (⌘⌥1)
     - Click folder icon → Choose new folder location
     - Repeat for all 3 folders

**Validation Checkpoint 3A**:
```bash
# Test 1: No red files
✓ All folders visible and green in navigator

# Test 2: Build succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# Test 3: Check folder references
Right-click any file → Show in Finder
✓ Expected: Opens correct renamed folder
```

---

#### Phase 3B: Core Data Model Renaming (20 minutes)

**Current**: `forager.xcdatamodeld`  
**New**: `[NEW_APP_NAME].xcdatamodeld`

**Steps**:

1. **In Xcode**:
   - Select `forager.xcdatamodeld` in navigator
   - File → Show in Finder
   - Note exact location

2. **Close Xcode**

3. **In Finder**:
   - Rename `forager.xcdatamodeld` to `[NEW_APP_NAME].xcdatamodeld`
   - This is a package - make sure to rename the whole thing

4. **Open Xcode**

5. **Update Persistence.swift** (or wherever NSPersistentContainer is initialized):
   ```swift
   // OLD:
   let container = NSPersistentCloudKitContainer(name: "forager")
   
   // NEW:
   let container = NSPersistentCloudKitContainer(name: "[NEW_APP_NAME]")
   ```

6. **Search for model references**:
   - Xcode → Find in Project (Cmd+Shift+F)
   - Search: "forager.xcdatamodeld"
   - Replace with: "[NEW_APP_NAME].xcdatamodeld"

**Validation Checkpoint 3B**:
```bash
# Test 1: Build succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# Test 2: Core Data loads
Product → Run
✓ App launches without Core Data errors
✓ Existing data loads (categories, recipes, etc.)

# Test 3: Core Data writes
✓ Create a new grocery list item
✓ Data persists across app restarts

# Test 4: Check container name
# In code, verify NSPersistentCloudKitContainer name matches new file
✓ Container name: [NEW_APP_NAME]
```

**⚠️ CRITICAL**: If Core Data fails to load:
1. Check container name exactly matches .xcdatamodeld file name
2. Check case sensitivity
3. Verify no typos in file rename

---

#### Phase 3C: Entitlements File Renaming (15 minutes)

**Current**: `forager.entitlements`  
**New**: `[NEW_APP_NAME].entitlements`

**Steps**:

1. **In Xcode navigator**:
   - Locate `forager.entitlements`
   - Right-click → Rename
   - Rename to: `[NEW_APP_NAME].entitlements`

2. **Update target settings**:
   - Select project → Select target
   - Build Settings tab
   - Search: "Code Signing Entitlements"
   - Update path from: `forager/forager.entitlements`
   - Update path to: `[NEW_APP_NAME]/[NEW_APP_NAME].entitlements`

3. **Update CloudKit container identifier**:
   - Open entitlements file
   - Find: `com.apple.developer.icloud-container-identifiers`
   - Update from: `iCloud.com.richhayn.groceryrecipemanager`
   - Update to: `iCloud.[NEW_BUNDLE_ID]`

**Validation Checkpoint 3C**:
```bash
# Test 1: Build succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# Test 2: Entitlements correct
Project → Target → Signing & Capabilities
✓ No entitlements errors
✓ CloudKit container shown

# Test 3: Check entitlements file
Open entitlements file in editor
✓ All identifiers use new bundle ID
✓ No references to old app name
```

---

#### Phase 3D: Main App File Renaming (10 minutes)

**Current**: `foragerApp.swift`  
**New**: `[NEW_APP_NAME]App.swift`

**Steps**:

1. **In Xcode navigator**:
   - Locate `foragerApp.swift`
   - Right-click → Rename
   - Rename to: `[NEW_APP_NAME]App.swift`

2. **Update struct name inside file**:
   ```swift
   // OLD:
   @main
   struct foragerApp: App {
   
   // NEW:
   @main
   struct [NEW_APP_NAME]App: App {
   ```

3. **Search for app struct references**:
   - Cmd+Shift+F → Search: "foragerApp"
   - Replace with: "[NEW_APP_NAME]App"
   - Check each occurrence (may be in previews)

**Validation Checkpoint 3D**:
```bash
# Test 1: Build succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# Test 2: App runs
Product → Run
✓ Expected: App launches normally
```

---

#### Phase 3E: File Header Comments Update (20 minutes)

**Objective**: Update copyright headers and project name in all source files

**Script approach** (faster):
```bash
# In Terminal at project root:

# 1. Update project name in all Swift files
find . -name "*.swift" -type f -exec sed -i '' \
  's/forager/[NEW_APP_NAME]/g' {} +

# 2. Verify changes
git diff | grep "forager"
# Should show old name being replaced

# 3. Check for unwanted replacements
git diff
# Review each change - revert any that shouldn't change
# (e.g., comments explaining old structure)
```

**Manual approach** (safer):
```bash
# For each file with header comment:
//
//  [FileName].swift
//  forager    ← Update this line
//
//  Created by Rich Hayn on [date]
//

# Change to:
//
//  [FileName].swift
//  [NEW_APP_NAME]          ← New name
//
//  Created by Rich Hayn on [date]
//
```

**Validation Checkpoint 3E**:
```bash
# Test 1: Search for old name
Cmd+Shift+F → Search: "forager"
✓ Should only appear in:
  - Git commit messages
  - Learning notes documenting rename
  - Comments explaining "was previously named X"

# Test 2: Build still succeeds
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# Test 3: All features work
Product → Run
✓ Test each tab
✓ Create/edit items
✓ Verify data persists
```

---

### M5.0.3 Complete Validation

**Full validation before M5.0.4**:

```bash
# Comprehensive Test Suite:

# 1. Project structure
✓ All folders renamed
✓ No references to old folder names
✓ File system matches Xcode navigator

# 2. Core Data operational
✓ App loads existing data
✓ Can create new data
✓ Data persists across launches
✓ Model file named correctly

# 3. Entitlements correct
✓ File renamed
✓ CloudKit container updated
✓ No signing errors

# 4. Build configuration
✓ Clean build succeeds
✓ Archive build succeeds
✓ All targets build

# 5. App functionality
✓ All 4 tabs load
✓ Categories work
✓ Recipes work
✓ Grocery lists work
✓ Meal planning works

# 6. Git checkpoint
git status
git add .
git commit -m "M5.0.3 COMPLETE: File structure renamed, all tests pass"
git push origin main
```

**If ALL validations pass**: ✅ Proceed to M5.0.4  
**If ANY validation fails**: 🛑 STOP, debug, re-validate

---

## M5.0.4: Documentation & GitHub Renaming

### Estimated Time: 45-60 minutes

### Objectives
1. Update all project documentation
2. Rename GitHub repository
3. Update README and repository metadata
4. Update Claude project knowledge references
5. Maintain documentation consistency

### Phase Breakdown

#### Phase 4A: Core Documentation Updates (20 minutes)

**Files to update** (in order):

1. **docs/project-index.md**:
   ```markdown
   # [NEW_APP_NAME] - Project Index
   
   **Project**: [NEW_MARKETING_NAME]
   **Repository**: [NEW_GITHUB_URL]
   **Bundle ID**: [NEW_BUNDLE_ID]
   ```

2. **docs/current-story.md**:
   ```markdown
   # Current Development Story
   
   **Project**: [NEW_APP_NAME]
   **Status**: M5.0 Complete - App Renamed & TestFlight Ready
   ```

3. **docs/roadmap.md**:
   - Update project name in header
   - Add M5.0 completion entry

4. **docs/requirements.md**:
   - Update project name in header
   - Update any app name references in requirements

5. **docs/next-prompt.md**:
   - Update for M5.1 or next milestone
   - Reference new app name

6. **docs/development-guidelines.md**:
   - Update project name
   - Update GitHub URL

7. **docs/session-startup-checklist.md**:
   - Update project name references

8. **docs/project-naming-standards.md**:
   - Add M5.0 completion
   - Update examples if they reference old name

9. **claude-instructions.md**:
   ```markdown
   # CLAUDE PROJECT INSTRUCTIONS - [NEW_APP_NAME]
   
   [Remove transition note banner]
   **Project**: [NEW_APP_NAME] iOS App
   **GitHub**: https://github.com/rfhayn/[new-repo-name]
   **Bundle ID**: com.richhayn.[new-bundle-id]
   
   [Update all "forager" references]
   [Update current status to M5.0 COMPLETE]
   ```

**Search-and-replace strategy**:
```bash
# In Terminal at docs/ directory:
grep -r "forager" . | grep -v ".git"
# Review all occurrences
# Manually update each file (safer than bulk replace)
```

**Validation Checkpoint 4A**:
```bash
# Test 1: Grep for old name
cd docs/
grep -r "forager" . | grep -v ".git"
✓ Expected: Only in learning notes documenting history

# Test 2: Check key files
✓ project-index.md has new name
✓ current-story.md has new name
✓ roadmap.md has new name
✓ requirements.md has new name

# Test 3: Links still work
✓ All internal doc links functional
✓ No broken references
```

---

#### Phase 4B: Learning Notes & Historical Docs (15 minutes)

**Strategy**: Learning notes document the journey, so they should mention BOTH names

**Approach**:
1. **Keep old references in historical notes** - they document what was true at the time
2. **Add context note at top of recent notes**:
   ```markdown
   > **Note**: This project was renamed from "forager" 
   > to "[NEW_APP_NAME]" in M5.0 (November 2025). Historical 
   > references to the old name are preserved for accuracy.
   ```

3. **Update future-facing content**:
   - PRDs in docs/prds/ that aren't completed yet
   - Any "next steps" sections
   - Future milestone references

**Files to review**:
- All files in `docs/learning-notes/`
- All files in `docs/prds/`
- All files in `docs/architecture/`

**Validation Checkpoint 4B**:
```bash
# Test 1: Historical accuracy preserved
✓ Old learning notes keep "forager"
✓ Context notes added to recent documents

# Test 2: Future content updated
✓ Planned PRDs use new name
✓ Architecture docs use new name where appropriate
```

---

#### Phase 4C: GitHub Repository Rename (15 minutes)

**Steps**:

1. **Commit all local changes first**:
   ```bash
   git status
   git add .
   git commit -m "M5.0.4: Documentation updated for rename"
   git push origin main
   ```

2. **On GitHub.com**:
   - Go to: https://github.com/rfhayn/grocery-recipe-manager
   - Click "Settings" tab
   - Scroll to "Repository name"
   - Change from: `grocery-recipe-manager`
   - Change to: `[new-repo-name]` (lowercase-with-dashes)
   - Click "Rename"
   - GitHub will redirect all old URLs automatically

3. **Update local Git remote**:
   ```bash
   # Git automatically updates, but verify:
   git remote -v
   # Should show new URL
   
   # If needed, update manually:
   git remote set-url origin https://github.com/rfhayn/[new-repo-name].git
   ```

4. **Test push/pull**:
   ```bash
   git pull origin main
   git push origin main
   # Both should work without errors
   ```

**Validation Checkpoint 4C**:
```bash
# Test 1: GitHub URL updated
✓ New URL works: github.com/rfhayn/[new-repo-name]
✓ Old URL redirects to new

# Test 2: Local Git working
git remote -v
✓ Shows new URL

# Test 3: Push/pull work
git pull
git push
✓ Both succeed
```

---

#### Phase 4D: README & Repository Metadata (10 minutes)

**1. Update README.md**:
```markdown
# [NEW_MARKETING_NAME]

iOS app for intelligent grocery shopping and meal planning.

## Features
- Smart grocery list management
- Recipe organization with meal planning
- Store-layout optimization
- Scaled recipe-to-shopping-list integration

## Tech Stack
- Swift + SwiftUI
- Core Data + CloudKit
- iOS 18.5+

## Development Status
- ✅ M1: Grocery Management (32h)
- ✅ M2: Recipe Integration (16.5h)
- ✅ M3: Quantity Management (10.5h)
- ✅ M4: Meal Planning (19.25h)
- ✅ M5.0: Renaming & TestFlight (Xh)
- 🔄 M5.1: CloudKit Sync (planned)

## Author
Rich Hayn

## License
Private - All Rights Reserved
```

**2. Update GitHub About section**:
- Click "⚙️" next to About
- Update description: "iOS grocery & recipe management app with meal planning"
- Add topics: `ios`, `swift`, `swiftui`, `recipes`, `grocery-shopping`

**Validation Checkpoint 4D**:
```bash
# Test 1: README renders correctly
✓ Visit GitHub repo page
✓ README displays properly
✓ All sections formatted correctly

# Test 2: Metadata correct
✓ Description shown
✓ Topics listed
✓ Looks professional
```

---

### M5.0.4 Complete Validation

**Final documentation check**:

```bash
# Comprehensive Documentation Audit:

# 1. Core docs updated
✓ project-index.md
✓ current-story.md
✓ roadmap.md
✓ requirements.md
✓ next-prompt.md

# 2. Historical accuracy maintained
✓ Learning notes preserve context
✓ Old references explained with context notes

# 3. GitHub operational
✓ Repository renamed
✓ README updated
✓ Metadata current
✓ Git push/pull working

# 4. Consistency check
grep -r "forager" docs/ | grep -v ".git"
✓ Only appears with historical context

# 5. Git checkpoint
git add .
git commit -m "M5.0.4 COMPLETE: Documentation and GitHub renamed"
git push origin main
```

**If ALL validations pass**: ✅ Proceed to M5.0.5  
**If ANY validation fails**: 🛑 STOP, fix issues, re-validate

---

## M5.0.5: TestFlight Deployment

### Estimated Time: 45-90 minutes + wait time

### Objectives
1. Enroll in Apple Developer Program ($99/year)
2. Set up App Store Connect
3. Create app record with new bundle ID
4. Prepare and upload build
5. Configure TestFlight
6. Install on real device

### Phase Breakdown

#### Phase 5A: Apple Developer Enrollment (15 min + 24-48h wait)

**Steps**:

1. **Go to**: https://developer.apple.com/programs/enroll/
2. **Sign in with Apple ID**
3. **Choose entity type**:
   - Individual (if just you)
   - Organization (if company - requires D-U-N-S number)
4. **Complete enrollment form**:
   - Legal name
   - Contact information
   - Agree to terms
5. **Pay $99/year fee**
6. **Wait for approval**: Typically 24-48 hours

**During wait time**:
- Continue with Phase 5B preparations
- Create app icon if not done
- Write app description
- Prepare screenshots (can be added later)

**Validation Checkpoint 5A**:
```bash
# After approval email:
✓ Log into developer.apple.com
✓ See "Membership" status: Active
✓ Can access Certificates, Identifiers & Profiles
```

---

#### Phase 5B: App Icon Creation (30 minutes if needed)

**Requirements**:
- 1024x1024px PNG
- No transparency
- No rounded corners (iOS adds automatically)

**Quick options**:

1. **SF Symbols approach** (free, quick):
   - Use SF Symbols app (free from Apple)
   - Pick an icon (cart.fill, book.fill, list.bullet, etc.)
   - Export at 1024x1024
   - Add colored background in Preview or Canva

2. **Canva** (free):
   - Go to canva.com
   - Search "App Icon"
   - Use template
   - Export as PNG 1024x1024

3. **Commission** ($5-25):
   - Fiverr.com
   - Search "iOS app icon"
   - Quick turnaround (24-48 hours)

**Adding to Xcode**:
1. Open Assets.xcassets
2. Select AppIcon
3. Drag 1024x1024 PNG to "App Store" slot
4. Xcode generates all other sizes

**Validation Checkpoint 5B**:
```bash
# Test icon in Xcode:
Product → Run
✓ Icon appears on simulator home screen
✓ Looks good at small size
✓ Recognizable and distinct
```

---

#### Phase 5C: App Store Connect Setup (20 minutes)

**After Apple Developer approval**:

1. **Go to**: https://appstoreconnect.apple.com
2. **Sign in** with same Apple ID
3. **Click "My Apps"**
4. **Click "+" → New App**

5. **Fill out form**:
   - **Platforms**: iOS
   - **Name**: [NEW_MARKETING_NAME] (30 char max)
   - **Primary Language**: English
   - **Bundle ID**: Select [NEW_BUNDLE_ID] from dropdown
     - If not in dropdown: Need to create in developer.apple.com first
   - **SKU**: Your choice (e.g., [new-app-name]-001)
   - **User Access**: Full Access

6. **Click "Create"**

7. **Fill in required metadata** (can update later):
   - **Privacy Policy URL**: "https://example.com/privacy" (placeholder for now)
   - **Category**: Productivity or Food & Drink
   - **App Subtitle**: Short description (30 chars)
   - **Description**: Full description (4000 chars)

**Validation Checkpoint 5C**:
```bash
# In App Store Connect:
✓ App appears in "My Apps"
✓ Status shows "Prepare for Submission"
✓ Can navigate to TestFlight tab
```

---

#### Phase 5D: Build Archive & Upload (30 minutes)

**Prepare Xcode**:

1. **Update version info**:
   - Select project → Target → General
   - **Version**: 1.0
   - **Build**: 1

2. **Select device**: "Any iOS Device (arm64)"

3. **Archive**:
   - Product → Archive
   - Wait for build (2-5 minutes)
   - Organizer window opens when complete

4. **Validate Archive**:
   - Click "Validate App"
   - Select distribution certificate
   - Click "Validate"
   - Wait for validation (1-2 minutes)
   - Should say "Success"

5. **Distribute**:
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Choose "Upload"
   - Select options:
     - ✓ Include bitcode (if needed for iOS < 14)
     - ✓ Upload symbols for crash reporting
   - Click "Upload"
   - Wait for upload (5-10 minutes depending on size)

**Validation Checkpoint 5D**:
```bash
# In Xcode Organizer:
✓ Archive succeeded
✓ Validation succeeded
✓ Upload succeeded
✓ No errors in Organizer

# In App Store Connect (wait 5-10 min for processing):
✓ Build appears in "Activity" tab
✓ Shows "Processing"
✓ Eventually changes to "Ready to Submit"
```

---

#### Phase 5E: TestFlight Configuration (15 minutes)

**After build processing completes**:

1. **In App Store Connect**:
   - Go to your app
   - Click "TestFlight" tab

2. **Add build to TestFlight**:
   - Under "iOS Builds", click build number
   - Review export compliance questions (typically "No" for internal testing)
   - Click "Submit"

3. **Create internal testing group**:
   - Click "Internal Testing" section
   - Click "+" to add testers
   - Add your email (and family members')
   - Testers get email invitations

4. **Configure test information** (optional):
   - What to Test: "Initial beta test - all M1-M4 features"
   - Feedback email: your email
   - Marketing URL: Leave blank for now

**Validation Checkpoint 5E**:
```bash
# In App Store Connect:
✓ Build shows "Ready to Test"
✓ Internal testing group created
✓ Testers added and invited

# In Email:
✓ Invitation email received
✓ Contains TestFlight link
```

---

#### Phase 5F: Device Installation & Testing (15 minutes)

**On your iPhone**:

1. **Install TestFlight app**:
   - Open App Store
   - Search "TestFlight"
   - Install (free, made by Apple)

2. **Accept invitation**:
   - Open email invitation on device
   - Tap "View in TestFlight"
   - TestFlight app opens
   - Tap "Accept"
   - Tap "Install"

3. **Launch app**:
   - Tap "Open" in TestFlight
   - App launches on real device

4. **Test core functionality**:
   - Navigate all 4 tabs
   - Create a grocery list item
   - Create a recipe
   - Create a meal plan
   - Verify data persists

**Validation Checkpoint 5F**:
```bash
# On Device:
✓ App installed from TestFlight
✓ App launches successfully
✓ All tabs load
✓ Can create data
✓ Data persists across app restarts
✓ Performance feels smooth
✓ No crashes

# Critical Tests:
✓ Categories display correctly
✓ Grocery lists work
✓ Recipes load and display
✓ Meal planning functional
✓ Core Data loads existing data
```

---

### M5.0.5 Complete Validation

**Full TestFlight deployment verification**:

```bash
# Apple Developer Account:
✓ Enrolled and active
✓ Can access developer.apple.com

# App Store Connect:
✓ App created
✓ Bundle ID registered
✓ Build uploaded and processed
✓ TestFlight configured

# TestFlight:
✓ Build available for testing
✓ Internal testers invited
✓ App installable via TestFlight

# Device Testing:
✓ App runs on physical iPhone
✓ All M1-M4 features work
✓ No crashes or major bugs
✓ Performance acceptable
✓ Data persists correctly

# Git checkpoint:
git add .
git commit -m "M5.0.5 COMPLETE: TestFlight deployment successful"
git push origin main
```

**If ALL validations pass**: 🎉 M5.0 COMPLETE!  
**If ANY validation fails**: 🛑 STOP, debug, re-validate

---

## Success Metrics

### Functional Metrics
- [ ] All 42 rename checklist items completed
- [ ] Zero build breaks throughout process
- [ ] All validation checkpoints passed
- [ ] App runs on simulator with new name
- [ ] App runs on real device via TestFlight
- [ ] All M1-M4 features work post-rename
- [ ] Core Data loads and saves correctly
- [ ] GitHub repository renamed and operational

### Quality Metrics
- [ ] No red files in Xcode navigator
- [ ] No compiler warnings related to rename
- [ ] Clean build from scratch succeeds
- [ ] Archive build succeeds
- [ ] All tests pass (if any exist)
- [ ] Documentation 100% consistent with new name

### Time Metrics
- [ ] M5.0.1: Name selection completed in 30 minutes
- [ ] M5.0.2: Xcode rename completed in 1-1.5 hours
- [ ] M5.0.3: File structure renamed in 1-1.5 hours
- [ ] M5.0.4: Documentation updated in 45-60 minutes
- [ ] M5.0.5: TestFlight deployed in 45-90 minutes + wait time
- [ ] **Total active work**: 4-6 hours (plus 24-48h approval wait)

### Strategic Metrics
- [ ] Professional app name established
- [ ] Bundle ID locked before CloudKit
- [ ] Real device validation complete
- [ ] Ready for M5.1 (CloudKit) or M6 (Testing)
- [ ] Foundation for App Store submission established

---

## Risk Mitigation

### High-Risk Operations

**1. Core Data Model Rename**:
- **Risk**: Data loss if container name doesn't match
- **Mitigation**: 
  - Backup app data before rename
  - Test data loading immediately after rename
  - Git checkpoint before this phase
- **Recovery**: Git revert + restore from backup

**2. Xcode Project File Rename**:
- **Risk**: Broken file references, Xcode won't open
- **Mitigation**:
  - Git commit before rename
  - Close Xcode completely
  - Follow exact steps
  - Check for red files immediately
- **Recovery**: Git revert to last checkpoint

**3. Bundle ID Change After App Store Connect**:
- **Risk**: Can't change bundle ID once app record created
- **Mitigation**:
  - Choose bundle ID BEFORE creating App Store Connect record
  - Double-check spelling
  - Think long-term
- **Recovery**: Delete app record and start over (if not yet deployed)

### Validation Strategy

**Progressive Checkpoints**:
- After each phase, full validation required
- Build must succeed at every checkpoint
- Features must work at every checkpoint
- No proceeding to next phase with failures

**Rollback Points**:
- Git commit after each phase completion
- Clear rollback instructions if validation fails
- Never more than 1 phase of lost work

### Testing Strategy

**After Each Phase**:
1. Clean build folder
2. Build from scratch
3. Run on simulator
4. Test core functionality
5. Check for errors/warnings

**Final Validation**:
1. Fresh install on device
2. Test complete user workflow
3. Performance check
4. Data persistence check

---

## Dependencies & Prerequisites

### Before Starting M5.0

**Required**:
- [ ] M4 completed and validated ✅
- [ ] All code committed to Git
- [ ] Xcode 16.4+ installed
- [ ] iOS 18.5+ simulator available
- [ ] Apple ID created
- [ ] Credit card for $99 Developer Program fee

**Recommended**:
- [ ] App icon designed (or plan for quick creation)
- [ ] App name ideas brainstormed
- [ ] Marketing name considered
- [ ] 4-6 hours available for focused work
- [ ] iPhone available for device testing

### External Dependencies

**Apple Services**:
- Apple Developer Program approval: 24-48 hours
- Build processing in App Store Connect: 5-15 minutes
- TestFlight invitation delivery: 5-10 minutes

**Tools**:
- Xcode 16.4+
- Git
- GitHub account
- Text editor (for bulk doc updates)
- Apple ID

---

## Post-M5.0 Next Steps

### Immediate (M5.0 Complete)
1. **Update current-story.md**: Mark M5.0 ✅ COMPLETE with actual hours
2. **Update roadmap.md**: Add M5.0 completion entry
3. **Create learning note**: Document rename process and TestFlight experience
4. **Update project-index.md**: Add M5.0 to Recent Activity

### Short-Term (Next Session)
1. **Gather TestFlight feedback**: 
   - Install on 2-3 devices
   - Have family test
   - Note any device-specific issues

2. **Choose next milestone**:
   - **Option A**: M5.1 - CloudKit Sync (20-25 hours)
   - **Option B**: M6 - Testing Foundation (12-18 hours)
   - **Option C**: M7 - Analytics Dashboard (6-8 hours)

3. **Create PRD for chosen milestone**

### Long-Term (After M5)
1. **App Store submission preparation**:
   - App Store screenshots
   - App description optimization
   - App Store preview video (optional)
   - Marketing website (optional)

2. **Production deployment**:
   - Full App Store review
   - Public release
   - Marketing strategy

---

## Appendix A: Common Issues & Solutions

### Issue: Xcode won't open after project rename
**Solution**:
```bash
# 1. Close Xcode
# 2. Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/[OLD_NAME]-*
# 3. Open project again
# 4. Clean build folder
```

### Issue: Core Data fails to load after rename
**Solution**:
```swift
// Verify container name exactly matches .xcdatamodeld file name
let container = NSPersistentCloudKitContainer(name: "[EXACT_FILE_NAME_WITHOUT_EXTENSION]")

// Check capitalization - it's case-sensitive!
```

### Issue: TestFlight build stuck in "Processing"
**Solution**:
- Wait 15-30 minutes (sometimes takes longer)
- Check Activity tab in App Store Connect for errors
- Verify export compliance answered correctly
- If stuck >2 hours, upload new build

### Issue: Git push fails after repo rename
**Solution**:
```bash
# Update remote URL
git remote set-url origin https://github.com/rfhayn/[new-repo-name].git

# Verify
git remote -v

# Try again
git push origin main
```

### Issue: Bundle ID already in use
**Solution**:
- Choose different bundle ID
- Check if you have another Apple Developer account with same ID
- Ensure you're signed into correct Apple ID

---

## Appendix B: Quick Reference

### Bundle Identifier Format
```
com.[domain].[appname]
Example: com.richhayn.shoplist

Tests: [main-bundle-id]Tests
Example: com.richhayn.shoplistTests

UI Tests: [main-bundle-id]UITests
Example: com.richhayn.shoplistUITests
```

### CloudKit Container Format
```
iCloud.[bundle-identifier]
Example: iCloud.com.richhayn.shoplist
```

### Display Name Best Practices
- Keep under 12 characters for full visibility
- Avoid special characters
- Consider App Store searchability
- Think long-term brand identity

### Marketing Name Best Practices
- 30 characters max in App Store
- Include relevant keywords for search
- Can differ from display name
- Example: "ShopList - Grocery & Recipes"

---

## Appendix C: Validation Checklist

**Copy this to track progress:**

```
M5.0 VALIDATION CHECKLIST

M5.0.1: Name Selection ✅
- [ ] Display name chosen
- [ ] Bundle ID chosen
- [ ] Marketing name chosen
- [ ] GitHub repo name chosen
- [ ] 42-item checklist created

M5.0.2: Xcode Renaming ✅
- [ ] Main target bundle ID updated
- [ ] Test target bundle ID updated
- [ ] UI test target bundle ID updated
- [ ] Display name updated
- [ ] Scheme renamed
- [ ] Project file renamed (optional)
- [ ] Product names updated
- [ ] Clean build succeeds
- [ ] App runs on simulator
- [ ] Checkpoint 2 Git commit

M5.0.3: File Structure ✅
- [ ] Source folders renamed
- [ ] Core Data model renamed
- [ ] Core Data container name updated
- [ ] Entitlements file renamed
- [ ] CloudKit container ID updated
- [ ] Main app file renamed
- [ ] File headers updated
- [ ] Clean build succeeds
- [ ] App runs with existing data
- [ ] All features functional
- [ ] Checkpoint 3 Git commit

M5.0.4: Documentation ✅
- [ ] project-index.md updated
- [ ] current-story.md updated
- [ ] roadmap.md updated
- [ ] requirements.md updated
- [ ] next-prompt.md updated
- [ ] Learning notes context added
- [ ] GitHub repo renamed
- [ ] README updated
- [ ] Repository metadata updated
- [ ] Git push succeeds
- [ ] Checkpoint 4 Git commit

M5.0.5: TestFlight ✅
- [ ] Apple Developer enrolled
- [ ] App Store Connect configured
- [ ] App record created
- [ ] App icon added to project
- [ ] Build archived successfully
- [ ] Build validated
- [ ] Build uploaded
- [ ] TestFlight configured
- [ ] Build processing complete
- [ ] Testers invited
- [ ] App installed on device
- [ ] All features work on device
- [ ] Checkpoint 5 Git commit

FINAL VALIDATION ✅
- [ ] Zero build errors
- [ ] Zero red files in Xcode
- [ ] App works on simulator
- [ ] App works on real device
- [ ] All documentation consistent
- [ ] Git history clean
- [ ] GitHub operational
- [ ] TestFlight functional

M5.0 COMPLETE! 🎉
Total time: _____ hours
```

---

**End of M5.0 PRD**

**Document Status**: ✅ Complete  
**Next Session**: Execute M5.0 systematically with validation at each checkpoint  
**Success Pattern**: Follow proven M1-M4 approach - incremental, validated, documented