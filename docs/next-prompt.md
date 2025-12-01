# NEXT PROMPT: M5.0 - App Renaming & TestFlight Deployment

**Last Updated**: November 28, 2025  
**Status**: 🚀 READY TO START  
**Estimated Time**: 4-6 hours across 5 phases  
**PRD**: M5.0-APP-RENAMING-TESTFLIGHT-PRD.md

---

## 🚨 BEFORE YOU START - MANDATORY SESSION STARTUP

**Complete these 4 steps FIRST**:
1. ✅ Read [session-startup-checklist.md](session-startup-checklist.md)
2. ✅ Read [project-naming-standards.md](project-naming-standards.md)
3. ✅ Read [current-story.md](current-story.md)
4. ✅ Read this file (next-prompt.md)

**This 5-10 minute investment prevents 6-14 hours of rework.**

---

## 📋 SESSION STARTUP CHECKLIST FOR M5.0

### Phase 1: Context Loading (Required)
- [x] Read session-startup-checklist.md
- [x] Read project-naming-standards.md
- [x] Read current-story.md
- [x] Read M5.0 PRD (M5.0-APP-RENAMING-TESTFLIGHT-PRD.md)

### Phase 2: Pre-Development Preparation
- [ ] Review proven patterns from M1-M4 documentation approach
- [ ] Understand validation checkpoint strategy
- [ ] Have Git ready for frequent commits
- [ ] Xcode closed (will open/close multiple times)

---

## 🎯 QUICK START GUIDE

### If Starting Fresh (First Session)

**Say this to Claude**:
```
I'm ready to start M5.0 - App Renaming & TestFlight Deployment.

I've completed:
✅ session-startup-checklist.md
✅ project-naming-standards.md
✅ current-story.md
✅ M5.0 PRD review

Let's start with M5.0.1: Name Selection & Planning.

I'm considering these names:
- Display Name: [YOUR IDEA HERE]
- Bundle ID: [YOUR IDEA HERE]
- Marketing Name: [YOUR IDEA HERE]

Help me finalize the choices and create the 42-item checklist.
```

### If Continuing (Subsequent Sessions)

**Say this to Claude**:
```
Continuing M5.0 - App Renaming & TestFlight.

Completed so far:
✅ M5.0.1: Name selection
✅ M5.0.2: Xcode renaming (if done)
[etc.]

Current checkpoint: [M5.0.X Phase Y]

Ready to proceed with next phase.
```

---

## 📊 MILESTONE OVERVIEW

**M5.0 Structure**:
```
M5.0: App Renaming & TestFlight Deployment
├── M5.0.1: Name Selection & Planning (30 min)
├── M5.0.2: Xcode Project Renaming (1-1.5 hours)
│   ├── Phase 2A: Bundle IDs
│   ├── Phase 2B: Display Name
│   ├── Phase 2C: Scheme Rename
│   ├── Phase 2D: Project File Rename
│   └── Phase 2E: Target/Product Names
├── M5.0.3: File Structure Renaming (1-1.5 hours)
│   ├── Phase 3A: Source Folders
│   ├── Phase 3B: Core Data Model
│   ├── Phase 3C: Entitlements
│   ├── Phase 3D: App File
│   └── Phase 3E: File Headers
├── M5.0.4: Documentation & GitHub (45-60 min)
│   ├── Phase 4A: Core Docs
│   ├── Phase 4B: Learning Notes
│   ├── Phase 4C: GitHub Repo
│   └── Phase 4D: README
└── M5.0.5: TestFlight Deployment (45-90 min + wait)
    ├── Phase 5A: Apple Developer Enrollment
    ├── Phase 5B: App Icon
    ├── Phase 5C: App Store Connect
    ├── Phase 5D: Build Upload
    ├── Phase 5E: TestFlight Config
    └── Phase 5F: Device Testing
```

---

## 🚀 M5.0.1: NAME SELECTION & PLANNING

### Session Start Prompt

```
Let's complete M5.0.1 - Name Selection & Planning.

Here are my name ideas:
- Display Name (home screen): [YOUR CHOICE]
- Bundle ID: com.richhayn.[YOUR CHOICE]
- Marketing Name (App Store): [YOUR CHOICE]
- GitHub Repo: [your-choice-lowercase-dashes]

Please:
1. Review these choices for any issues
2. Help me finalize if needed
3. Create the complete 42-item rename checklist from the PRD
4. Document the naming strategy
5. Identify all files requiring updates

Expected outcome: Complete checklist, documented strategy, ready for M5.0.2
```

### What Claude Will Do

1. Review your name choices for:
   - Length (display name should be <12 chars)
   - Bundle ID format (lowercase, no spaces)
   - Marketing name SEO
   - Consistency across choices

2. Create the 42-item checklist customized with your names

3. Document naming strategy in a file

4. Prepare you for M5.0.2

### Validation Before Proceeding

- [ ] All names chosen and finalized
- [ ] 42-item checklist created
- [ ] Naming strategy documented
- [ ] No conflicting names
- [ ] Ready to start Xcode changes

### Checkpoint Commit

```bash
git add .
git commit -m "M5.0.1 COMPLETE: Name selection finalized, checklist created"
```

---

## 🔧 M5.0.2: XCODE PROJECT RENAMING

### Session Start Prompt

```
Starting M5.0.2 - Xcode Project Renaming.

Chosen names:
- Display Name: [YOUR NAME]
- Bundle ID: [YOUR BUNDLE ID]

I've committed M5.0.1 changes. Xcode is closed.

Let's start with Phase 2A: Bundle Identifier Updates.
Walk me through each step with validation checkpoints.
```

### Phase-by-Phase Breakdown

**Phase 2A: Bundle IDs** (20 min)
- Update 3 targets: Main, Tests, UITests
- Validation: Clean build succeeds

**Phase 2B: Display Name** (10 min)
- Set display name in target settings
- Validation: Simulator shows new name

**Phase 2C: Scheme Rename** (15 min)
- Rename scheme in scheme manager
- Validation: Build with new scheme succeeds

**Phase 2D: Project File Rename** (20 min) ⚠️ HIGH RISK
- Close Xcode, rename .xcodeproj in Finder
- Reopen, fix broken references
- Validation: All files green, build succeeds

**Phase 2E: Target/Product Names** (15 min)
- Rename targets and product names
- Validation: Archive build succeeds

### Critical Validation After M5.0.2

**Before proceeding to M5.0.3**:

```bash
# Full validation test suite:

# 1. Clean build
Product → Clean Build Folder
Product → Build
✓ Expected: BUILD SUCCEEDED

# 2. Run on simulator
Product → Run
✓ Expected: App launches, all tabs work

# 3. No red files
✓ All files green in navigator

# 4. Archive succeeds
Product → Archive
✓ Expected: Archive successful

# If ALL pass:
git add .
git commit -m "M5.0.2 COMPLETE: Xcode project renamed, all builds pass"
git push origin main

# If ANY fail:
STOP - Debug - Re-validate - Do not proceed
```

---

## 📁 M5.0.3: FILE & FOLDER STRUCTURE RENAMING

### Session Start Prompt

```
Starting M5.0.3 - File & Folder Structure Renaming.

M5.0.2 validation passed ✅:
- Clean build succeeds
- App runs on simulator
- Archive succeeds
- Git committed and pushed

Let's start with Phase 3A: Source Folder Renaming.
```

### Phase-by-Phase Breakdown

**Phase 3A: Source Folders** (25 min)
- Close Xcode, rename 3 folders in Finder
- Reopen, fix broken references
- Validation: Build succeeds

**Phase 3B: Core Data Model** (20 min) ⚠️ HIGH RISK
- Rename .xcdatamodeld file
- Update NSPersistentCloudKitContainer name
- Validation: Data loads correctly

**Phase 3C: Entitlements** (15 min)
- Rename .entitlements file
- Update CloudKit container ID
- Validation: No signing errors

**Phase 3D: App File** (10 min)
- Rename [OldName]App.swift
- Update struct name
- Validation: Build succeeds

**Phase 3E: File Headers** (20 min)
- Update all file header comments
- Can use script or manual
- Validation: No unwanted changes

### Critical Validation After M5.0.3

**Before proceeding to M5.0.4**:

```bash
# Comprehensive test suite:

# 1. Build & run
Product → Clean Build Folder
Product → Build
Product → Run
✓ All tabs load
✓ Existing data displays

# 2. Data integrity
✓ Create new grocery item → Persists
✓ Create new recipe → Persists
✓ Create meal plan → Persists

# 3. All features functional
✓ Categories work
✓ Recipes work
✓ Grocery lists work
✓ Meal planning works

# 4. Archive succeeds
Product → Archive
✓ Archive successful

# If ALL pass:
git add .
git commit -m "M5.0.3 COMPLETE: File structure renamed, all tests pass"
git push origin main

# If ANY fail:
STOP - Debug - May need to revert Core Data changes
```

---

## 📚 M5.0.4: DOCUMENTATION & GITHUB RENAMING

### Session Start Prompt

```
Starting M5.0.4 - Documentation & GitHub Renaming.

M5.0.3 validation passed ✅:
- All folders renamed
- Core Data working
- All features functional
- Git committed and pushed

Let's start with Phase 4A: Core Documentation Updates.
```

### Phase-by-Phase Breakdown

**Phase 4A: Core Docs** (20 min)
- Update project-index.md, current-story.md, roadmap.md, etc.
- Search-and-replace strategy
- Validation: All key docs consistent

**Phase 4B: Learning Notes** (15 min)
- Preserve historical references
- Add context notes
- Update future-facing content
- Validation: Historical accuracy maintained

**Phase 4C: GitHub Repo** (15 min)
- Rename repository on GitHub
- Update local Git remote
- Validation: Push/pull works

**Phase 4D: README** (10 min)
- Update README.md
- Update repo metadata
- Validation: Professional appearance

### Critical Validation After M5.0.4

**Before proceeding to M5.0.5**:

```bash
# Documentation audit:

# 1. Core docs updated
✓ project-index.md has new name
✓ current-story.md has new name
✓ roadmap.md has new name
✓ requirements.md updated
✓ claude-instructions.md updated (transition note removed)

# 2. GitHub operational
✓ Repository renamed
✓ git push works
✓ git pull works
✓ README displays correctly

# 3. Consistency check
grep -r "forager" docs/ | grep -v ".git"
✓ Only historical references with context

# If ALL pass:
git add .
git commit -m "M5.0.4 COMPLETE: Documentation and GitHub renamed"
git push origin main

# If ANY fail:
STOP - Fix inconsistencies before TestFlight
```

---

## 📱 M5.0.5: TESTFLIGHT DEPLOYMENT

### Session Start Prompt

```
Starting M5.0.5 - TestFlight Deployment.

M5.0.4 validation passed ✅:
- All docs updated
- GitHub renamed
- Git operational

Let's start with Phase 5A: Apple Developer Enrollment.

Status:
- [ ] Already enrolled in Apple Developer Program
- [ ] Need to enroll ($99/year)

[Indicate your status]
```

### Phase-by-Phase Breakdown

**Phase 5A: Apple Developer** (15 min + 24-48h wait)
- Enroll at developer.apple.com
- Pay $99/year
- Wait for approval

**Phase 5B: App Icon** (30 min if needed)
- Create 1024x1024 PNG
- Add to Assets.xcassets
- Validation: Icon shows on simulator

**Phase 5C: App Store Connect** (20 min)
- Create app record
- Fill metadata
- Validation: App appears in My Apps

**Phase 5D: Build Upload** (30 min)
- Archive in Xcode
- Validate
- Upload
- Validation: Build shows in Activity

**Phase 5E: TestFlight Config** (15 min)
- Add build to TestFlight
- Create testing group
- Invite testers
- Validation: Invitations sent

**Phase 5F: Device Testing** (15 min)
- Install TestFlight app
- Accept invitation
- Install app on device
- Test all features
- Validation: App works on real device

### Critical Validation After M5.0.5

**Final M5.0 Validation**:

```bash
# Complete deployment verification:

# Apple Services
✓ Developer account active
✓ App Store Connect configured
✓ Build uploaded and processed

# TestFlight
✓ Build available
✓ Testers invited
✓ App installable

# Device Testing
✓ App runs on real iPhone
✓ All tabs load
✓ All features work
✓ Data persists
✓ No crashes

# If ALL pass:
git add .
git commit -m "M5.0.5 COMPLETE: TestFlight deployment successful"
git push origin main

# Update current-story.md:
Mark M5.0 ✅ COMPLETE with actual hours

# Create learning note:
Document rename process and TestFlight experience

🎉 M5.0 COMPLETE!
```

---

## 🎓 LEARNING NOTE CREATION

**After M5.0 Complete**:

Create: `docs/learning-notes/24-m5.0-app-renaming-testflight.md`

**Include**:
1. **Name Selection Process**: How you chose the name
2. **Xcode Rename Journey**: What worked, what didn't
3. **Core Data Gotchas**: Container name matching
4. **TestFlight Experience**: Approval time, any issues
5. **Validation Checkpoints**: How they saved time
6. **Time Accuracy**: Estimated vs actual for each phase
7. **Recommendations**: What you'd do differently

**Template**:
```markdown
# Learning Notes: M5.0 - App Renaming & TestFlight

**Date**: November 28, 2025  
**Duration**: X hours (estimated 4-6h)  
**Components**: M5.0.1-5 complete

## Key Concepts Learned

### Systematic Renaming
[Document the step-by-step process]

### Validation Strategy
[How checkpoints prevented issues]

### TestFlight Deployment
[Developer enrollment through device testing]

## Technical Discoveries

### Xcode Configuration
[What worked for project/scheme renaming]

### Core Data Considerations
[Container name must match file name exactly]

### Git Strategy
[Frequent commits were essential]

## Challenges & Solutions

### Challenge 1: [Description]
**Solution**: [How you solved it]

### Challenge 2: [Description]
**Solution**: [How you solved it]

## Time Tracking

- M5.0.1: X min (estimated 30 min)
- M5.0.2: X hours (estimated 1-1.5h)
- M5.0.3: X hours (estimated 1-1.5h)
- M5.0.4: X min (estimated 45-60 min)
- M5.0.5: X min + wait (estimated 45-90 min)
**Total**: X hours

**Planning Accuracy**: X%

## Recommendations

### Do Again:
- Validation checkpoints after each phase
- Git commits before risky operations
- Systematic checklist approach

### Do Differently:
- [Any improvements for next time]

## Next Steps

After M5.0:
- Gather TestFlight feedback
- Choose M5.1 (CloudKit) vs M6 (Testing)
- Create PRD for next milestone
```

---

## 📋 PROGRESS TRACKING

**Copy this to track your progress**:

```
M5.0 PROGRESS TRACKER

[ ] M5.0.1: Name Selection (30 min)
    [ ] Names chosen
    [ ] Checklist created
    [ ] Strategy documented
    [ ] Git checkpoint

[ ] M5.0.2: Xcode Renaming (1-1.5h)
    [ ] Phase 2A: Bundle IDs
    [ ] Phase 2B: Display Name
    [ ] Phase 2C: Scheme
    [ ] Phase 2D: Project File
    [ ] Phase 2E: Targets
    [ ] All validation tests pass
    [ ] Git checkpoint

[ ] M5.0.3: File Structure (1-1.5h)
    [ ] Phase 3A: Folders
    [ ] Phase 3B: Core Data
    [ ] Phase 3C: Entitlements
    [ ] Phase 3D: App File
    [ ] Phase 3E: Headers
    [ ] All validation tests pass
    [ ] Git checkpoint

[ ] M5.0.4: Documentation (45-60 min)
    [ ] Phase 4A: Core Docs
    [ ] Phase 4B: Learning Notes
    [ ] Phase 4C: GitHub
    [ ] Phase 4D: README
    [ ] All validation tests pass
    [ ] Git checkpoint

[ ] M5.0.5: TestFlight (45-90 min + wait)
    [ ] Phase 5A: Developer Account
    [ ] Phase 5B: App Icon
    [ ] Phase 5C: App Store Connect
    [ ] Phase 5D: Build Upload
    [ ] Phase 5E: TestFlight Config
    [ ] Phase 5F: Device Testing
    [ ] All validation tests pass
    [ ] Git checkpoint

[ ] M5.0 Complete
    [ ] Learning note created
    [ ] current-story.md updated
    [ ] roadmap.md updated
    [ ] project-index.md updated
    [ ] All docs use M5.0 naming

Total Time: _____ hours
Planning Accuracy: _____%
```

---

## 🆘 TROUBLESHOOTING GUIDE

### Problem: Build fails after rename

**Check**:
1. All 3 bundle IDs updated consistently?
2. Any typos in bundle IDs?
3. Product name updated in build settings?
4. Clean build folder?

**Solution**:
```bash
# In Xcode:
Product → Clean Build Folder
# Delete derived data:
Window → Organizer → Projects → Delete
# Rebuild
```

---

### Problem: Core Data doesn't load after rename

**Check**:
1. Container name EXACTLY matches file name?
2. Case-sensitive - "ShopList" ≠ "shoplist"?
3. File extension removed in code: "ShopList" not "ShopList.xcdatamodeld"?

**Solution**:
```swift
// Verify exact match:
let container = NSPersistentCloudKitContainer(name: "[EXACT_FILE_NAME]")
// File: ShopList.xcdatamodeld
// Code: name: "ShopList"  ← No extension!
```

---

### Problem: Files show red in Xcode after rename

**Solution**:
```
1. Select red file/folder
2. File Inspector (⌘⌥1)
3. Click folder icon
4. Navigate to actual file location
5. Select → reconnects reference
```

---

### Problem: Git push fails after GitHub rename

**Solution**:
```bash
# Update remote URL
git remote set-url origin https://github.com/rfhayn/[new-name].git

# Verify
git remote -v

# Try again
git push origin main
```

---

### Problem: TestFlight build stuck "Processing"

**Solution**:
- Wait 30 minutes (can take time)
- Check Activity tab for errors
- If >2 hours, upload new build
- Verify export compliance answered

---

## 🎯 SUCCESS CRITERIA

**M5.0 is complete when**:

### Functional
- [ ] App launches with new name
- [ ] All M1-M4 features work
- [ ] Data loads and saves correctly
- [ ] App installs via TestFlight
- [ ] Runs on real device

### Technical
- [ ] Zero build errors
- [ ] Zero red files
- [ ] Archive succeeds
- [ ] Bundle IDs consistent
- [ ] Core Data operational

### Documentation
- [ ] All docs use new name consistently
- [ ] GitHub renamed
- [ ] README updated
- [ ] Learning note created

### Quality
- [ ] No regressions
- [ ] Performance maintained
- [ ] Zero data loss
- [ ] Professional appearance

---

## 📞 GETTING HELP

**If stuck**:

1. **Review validation checkpoint** - Did you pass all tests before proceeding?
2. **Check Git history** - Can you revert to last good checkpoint?
3. **Consult PRD** - Detailed solutions in Appendix A
4. **Search learning notes** - Similar issues in M1-M4?

**When asking Claude for help**:
```
I'm stuck on M5.0.[X] Phase [Y].

Error/Issue: [Describe specific problem]

What I've tried:
1. [Action 1]
2. [Action 2]

Validation results:
- [Test 1]: Pass/Fail
- [Test 2]: Pass/Fail

Last successful checkpoint: M5.0.[X] Phase [Y-1]

Git status: [committed / uncommitted]

Need help with: [Specific question]
```

---

## 🏁 AFTER M5.0 COMPLETION

### Immediate Actions
1. Update current-story.md → Mark M5.0 ✅ COMPLETE
2. Update roadmap.md → Add M5.0 completion
3. Create learning note → Document journey
4. Update project-index.md → Recent activity

### Next Session Planning
1. Gather TestFlight feedback from family/friends
2. Test on 2-3 different devices
3. Choose next milestone:
   - M5.1: CloudKit Sync (20-25h)
   - M6: Testing Foundation (12-18h)
   - M7: Analytics (6-8h)

### Documentation Cleanup
1. Move M5.0 PRD to docs/prds/complete/
2. Archive this next-prompt
3. Create next-prompt for chosen milestone

---

**Remember**: Follow the validation checkpoints religiously. They exist to prevent cascading failures and save you hours of debugging!

**Good luck! 🚀**

---

**Last Updated**: November 28, 2025  
**Status**: Ready for execution  
**Next Review**: After M5.0 completion