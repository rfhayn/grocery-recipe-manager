# Next Implementation Prompt - M7.0 App Store Prerequisites

**Last Updated**: December 3, 2025  
**Current Phase**: M7.0.1 - Privacy Policy Creation & Hosting 🚀 READY  
**Status**: Ready to begin  
**Estimated Time**: 2-3 hours total for M7.0 (all 4 sub-phases)

---

## 🎯 **WHAT YOU'RE BUILDING**

**M7.0: App Store Prerequisites** - MANDATORY compliance steps before external TestFlight submission (M7.5)

This phase prepares Forager for external public beta testing by completing Apple's mandatory App Store requirements:
1. Privacy policy published and accessible
2. In-app privacy link implemented
3. App Privacy questionnaire completed
4. Display name disambiguated

**⚠️ CRITICAL**: Cannot submit for external TestFlight (M7.5) without completing ALL of M7.0.

---

## 🚀 **M7.0.1: PRIVACY POLICY CREATION & HOSTING** - READY TO START

**Estimated Time**: 1 hour  
**Status**: Not started  
**Purpose**: Create and host privacy policy at public URL for App Store Connect

### **What You'll Create:**

A simple, professional privacy policy hosted on GitHub Pages that:
- States data is stored locally on device only
- Confirms no tracking, analytics, or third-party sharing
- Explains data deletion (uninstall app)
- Notes policy will be updated when CloudKit sync added (M7.1-7.4)

**Target URL**: `https://rfhayn.github.io/forager/privacy.html`

### **Step-by-Step Implementation:**

#### **Step 1: Create Privacy Policy HTML** (30 min)

Create file: `docs/privacy.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forager Privacy Policy</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
            color: #333;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #27ae60;
            padding-bottom: 10px;
        }
        h2 {
            color: #27ae60;
            margin-top: 30px;
        }
        .last-updated {
            color: #7f8c8d;
            font-style: italic;
        }
        .important {
            background-color: #ecf0f1;
            padding: 15px;
            border-left: 4px solid #27ae60;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <h1>Forager Privacy Policy</h1>
    <p class="last-updated">Last updated: December 2025</p>

    <div class="important">
        <strong>Summary:</strong> Forager stores all data locally on your device. We do not collect, transmit, or share any personal information.
    </div>

    <h2>Data Collection</h2>
    <p>Forager does not collect any personal data. All information you enter (grocery lists, recipes, meal plans, and preferences) is stored locally on your device.</p>

    <h2>Data Storage</h2>
    <p>Your data is stored in the app's local database on your device. This includes:</p>
    <ul>
        <li>Grocery lists and shopping items</li>
        <li>Recipes and ingredients</li>
        <li>Meal plans and schedules</li>
        <li>Personal preferences and settings</li>
    </ul>
    <p>None of this information is transmitted to external servers or third parties.</p>

    <h2>Third-Party Services</h2>
    <p>Forager does not use any third-party analytics, tracking, or advertising services. We do not share your data with anyone.</p>

    <h2>Future Updates</h2>
    <p>When we add iCloud sync capabilities in a future update, this policy will be updated to reflect how Apple's iCloud service handles your data. You will be notified of any policy changes before they take effect.</p>

    <h2>Data Deletion</h2>
    <p>To delete all your data, simply uninstall the Forager app from your device. This will permanently remove all locally stored information.</p>

    <h2>Children's Privacy</h2>
    <p>Forager does not knowingly collect information from children under 13. The app does not require any personal information to function.</p>

    <h2>Contact</h2>
    <p>If you have questions about this privacy policy, please contact us through the App Store.</p>

    <h2>Changes to This Policy</h2>
    <p>We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last updated" date.</p>

    <p class="last-updated">This privacy policy is effective as of December 2025.</p>
</body>
</html>
```

**Key Elements:**
- Mobile-responsive design (viewport meta tag + max-width styling)
- Clean typography using system fonts
- Green accent color (#27ae60) matching app branding
- Summary box for quick understanding
- All required sections covered
- Future-proofs for CloudKit addition

#### **Step 2: Test Privacy Policy Locally** (5 min)

```bash
# Open in browser to verify rendering
open docs/privacy.html

# Check:
# ✓ Readable on narrow window (mobile simulation)
# ✓ Green accent colors visible
# ✓ All sections present
# ✓ No broken formatting
```

#### **Step 3: Enable GitHub Pages** (10 min)

1. **Push privacy.html to GitHub:**
   ```bash
   git add docs/privacy.html
   git commit -m "M7.0.1: Add privacy policy for App Store compliance"
   git push origin main
   ```

2. **Enable GitHub Pages:**
   - Go to: https://github.com/rfhayn/forager/settings/pages
   - Source: "Deploy from a branch"
   - Branch: `main`
   - Folder: `/docs`
   - Click "Save"

3. **Wait for deployment** (1-2 minutes)
   - GitHub Actions will build site
   - Check: https://github.com/rfhayn/forager/actions

#### **Step 4: Verify Public URL** (5 min)

Test the published privacy policy:
```
https://rfhayn.github.io/forager/privacy.html
```

**Verification Checklist:**
- [ ] URL loads without 404 error
- [ ] Content renders correctly on desktop browser
- [ ] Content renders correctly on iPhone (Safari)
- [ ] All styling (green accents, formatting) displays properly
- [ ] No console errors (open browser dev tools)

#### **Step 5: Git Checkpoint** (5 min)

Mark M7.0.1 complete:
```bash
git add docs/privacy.html
git commit -m "M7.0.1 COMPLETE: Privacy policy published at https://rfhayn.github.io/forager/privacy.html"
git push origin main
```

### **Acceptance Criteria for M7.0.1:**

- [ ] privacy.html file created in docs/ directory
- [ ] GitHub Pages enabled for /docs folder
- [ ] Privacy policy accessible at public URL
- [ ] Mobile-responsive design verified
- [ ] All required sections present:
  - Data Collection
  - Data Storage
  - Third-Party Services
  - Future Updates (iCloud mention)
  - Data Deletion
  - Children's Privacy
  - Contact
  - Changes to Policy
- [ ] Git checkpoint created

### **Troubleshooting:**

**Issue**: GitHub Pages 404 error  
**Solution**: 
- Wait 2-3 minutes for initial deployment
- Check GitHub Actions completed successfully
- Verify file path is exactly `docs/privacy.html` (case-sensitive)

**Issue**: Styling doesn't display  
**Solution**: 
- Check for HTML syntax errors
- Verify `<style>` block is in `<head>`
- Test in incognito window (clear cache)

**Issue**: Mobile rendering problems  
**Solution**: 
- Verify viewport meta tag present
- Test `max-width: 800px` is working
- Check padding on mobile (20px sides)

---

## 📋 **REMAINING M7.0 PHASES** (Execute after M7.0.1 complete)

### **M7.0.2: Privacy Policy Integration** ⏳ NEXT (1 hour)
**After M7.0.1 complete**

Tasks:
1. Add privacy policy URL to App Store Connect metadata
2. Add "Privacy Policy" link in SettingsView
3. Implement SafariServices in-app browser
4. Test: Tap link → policy opens in-app

### **M7.0.3: App Privacy Questionnaire** ⏳ AFTER M7.0.2 (30 min)

Tasks:
1. Navigate to App Store Connect → App Privacy
2. Select "Data Not Collected" (accurate for current build)
3. Save and verify complete
4. Note: Will update after CloudKit (M7.1-7.4)

### **M7.0.4: Display Name Disambiguation** ⏳ AFTER M7.0.3 (30 min)

Tasks:
1. Update Xcode: Display Name = "Forager: Smart Meal Planner"
2. Keep Bundle Name = "Forager" (clean home screen icon)
3. Update App Store Connect display name
4. Build and test

---

## 🎯 **AFTER M7.0 COMPLETE**

### **Update Documentation:**
1. **current-story.md**: Mark M7.0 ✅ COMPLETE, update to M7.1 🚀 READY
2. **next-prompt.md**: Replace M7.0 content with M7.1 content
3. **Git commit**: "M7.0 COMPLETE: App Store prerequisites done, ready for CloudKit"

### **Next Phase:**
M7.1 - CloudKit Sync Foundation (8-10 hours)
- CloudKit schema validation
- NSPersistentCloudKitContainer integration
- Multi-device sync testing

---

## 💡 **RECOMMENDED APPROACH**

### **For M7.0.1 (Starting Now):**

Use this prompt to begin:
```
M7.0.1 ready to start.

Let's create the privacy policy HTML file for GitHub Pages.

Walk me through Step 1: Creating docs/privacy.html with the template provided.
After we create the file, I'll test it locally before enabling GitHub Pages.
```

### **After M7.0.1 Complete:**

Return to this document and follow M7.0.2, then M7.0.3, then M7.0.4 in sequence.

Each sub-phase includes:
- Clear acceptance criteria
- Step-by-step instructions
- Validation checkpoints
- Troubleshooting guidance

---

## 📊 **M7.0 PROGRESS TRACKER**

- [ ] **M7.0.1**: Privacy Policy Creation & Hosting (1h) 🚀 READY
- [ ] **M7.0.2**: Privacy Policy Integration (1h) ⏳ After M7.0.1
- [ ] **M7.0.3**: App Privacy Questionnaire (30min) ⏳ After M7.0.2
- [ ] **M7.0.4**: Display Name Disambiguation (30min) ⏳ After M7.0.3

**Total M7.0 Time**: 2-3 hours  
**Status**: MANDATORY before external TestFlight (M7.5)  
**Next After M7.0**: M7.1 CloudKit Sync Foundation (8-10 hours)

---

**Last Updated**: December 3, 2025  
**Version**: 1.0 (M7.0 App Store Prerequisites)  
**PRD Reference**: docs/prds/milestone-7-cloudkit-sync-external-testflight.md  
**Current Story**: docs/current-story.md