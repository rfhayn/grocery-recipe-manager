# Forager - Requirements Document

**Last Updated**: December 10, 2024  
**Version**: 4.1 - M7.1.3 Semantic Uniqueness  
**Current Milestone**: M7.1 ACTIVE (M7.0 ✅, M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🚀)  
**Total Requirements**: 155 (151 baseline + 4 new M7.1.3 semantic uniqueness)

---

## 📋 **OVERVIEW**

This document defines all functional and non-functional requirements for the Forager iOS application. Requirements are organized by milestone with traceability to implementation status.

---

## 🎯 **PROJECT VISION**

**Mission**: Create a revolutionary iOS grocery and recipe management app that eliminates shopping inefficiency through intelligent store-layout optimization, integrated recipe management, and smart automation.

**Core Value Propositions**:
1. **Store-Layout Optimization**: Custom-ordered grocery lists matching your actual shopping flow
2. **Recipe Integration**: Seamlessly manage recipes and generate grocery lists with one tap
3. **Structured Quantity Intelligence**: Scale recipes, consolidate duplicates, and smart quantity management
4. **Recipe Ingredient Autocomplete**: Efficient ingredient entry with fuzzy matching
5. **Meal Planning**: Calendar-based planning with automated grocery list generation
6. **Family Collaboration**: CloudKit-powered sharing for household coordination
7. **Analytics & Insights**: Data-driven recommendations for better shopping and cooking

---

## ✅ **M1: PROFESSIONAL GROCERY MANAGEMENT - COMPLETE**

**Status**: ✅ Complete - August 2025 (32 hours)  
**Summary**: Professional grocery list management with store-layout optimization

### **Functional Requirements - Grocery Lists**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-GL-001** | **Create weekly grocery lists** | ✅ WeeklyList entity with name, creation date, completion status | M1 Phase 1 | 🎯 **Core workflow** |
| **FR-GL-002** | **Add/edit/delete grocery items** | ✅ GroceryListItem CRUD with Core Data persistence | M1 Phase 1 | 🎯 **Basic functionality** |
| **FR-GL-003** | **Mark items complete/incomplete** | ✅ Toggle with visual feedback and persistence | M1 Phase 2 | 🎯 **Shopping tracking** |
| **FR-GL-004** | **Display completion percentage** | ✅ Progress bar with animated updates | M1 Phase 2 | 🎯 **Progress visibility** |
| **FR-GL-005** | **Auto-complete list when all items done** | ✅ Automatic status update with Core Data validation | M1 Phase 2 | 🎯 **Workflow completion** |

### **Functional Requirements - Categories**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-CAT-001** | **Custom category creation** | ✅ User-defined categories with names and colors | M1 Phase 3 | 🎯 **Personalization** |
| **FR-CAT-002** | **Drag-and-drop category ordering** | ✅ Reorderable list with Core Data persistence | M1 Phase 3 | 🎯 **Store-layout optimization** |
| **FR-CAT-003** | **Category color coding** | ✅ Visual distinction with 12 color palette | M1 Phase 3 | 🎯 **Visual organization** |
| **FR-CAT-004** | **Category assignment to items** | ✅ Dropdown selection with smart defaults | M1 Phase 4 | 🎯 **Item organization** |
| **FR-CAT-005** | **Protect categories with items** | ✅ Warning before deletion, option to reassign | M1 Phase 3 | 🎯 **Data protection** |

### **Functional Requirements - Staples**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-ST-001** | **Mark items as staples** | ✅ Toggle flag with persistence | M1 Phase 5 | 🎯 **Recurring item management** |
| **FR-ST-002** | **Auto-populate staples to new lists** | ✅ Automatic addition with category preservation | M1 Phase 5 | 🎯 **Time-saving automation** |
| **FR-ST-003** | **Staple management view** | ✅ Dedicated view with category organization | M1 Phase 5 | 🎯 **Centralized management** |
| **FR-ST-004** | **Add/remove staple status** | ✅ Toggle with immediate list updates | M1 Phase 5 | 🎯 **Flexible management** |

### **Non-Functional Requirements - M1**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **NFR-M1-001** | **Response time < 0.1s for queries** | ✅ Core Data optimization with fetch indexes | M1 All | 🎯 **Performance** |
| **NFR-M1-002** | **Zero data loss** | ✅ Transaction management with rollback | M1 All | 🎯 **Data integrity** |
| **NFR-M1-003** | **Professional iOS UI** | ✅ Native SwiftUI patterns throughout | M1 All | 🎯 **User experience** |
| **NFR-M1-004** | **Accessibility support** | ✅ VoiceOver compatible, color contrast standards | M1 All | 🎯 **Inclusivity** |

**M1 Summary**: All 19 requirements successfully completed with professional quality and exceptional performance.

---

## ✅ **M2: RECIPE INTEGRATION - COMPLETE**

**Status**: ✅ Complete - September-October 2025 (16.5 hours)  
**Summary**: Complete recipe catalog with intelligent ingredient management and autocomplete

### **Functional Requirements - Recipe Management**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-RM-001** | **Recipe catalog view** | ✅ **Scrollable list with search, favorites, recent, categories** | ✅ M2.2.1 | 🎯 **Recipe discovery** |
| **FR-RM-002** | **Recipe detail view** | ✅ **Comprehensive display: ingredients, instructions, timing, tags** | ✅ M2.2.2 | 🎯 **Recipe information** |
| **FR-RM-003** | **Recipe CRUD operations** | ✅ **Create, read, update, delete with data validation** | ✅ M2.3 | 🎯 **Recipe management** |
| **FR-RM-004** | **Favorite recipes** | ✅ **Toggle favorite with visual feedback and filtering** | ✅ M2.2.3 | 🎯 **Quick access** |
| **FR-RM-005** | **Recipe usage tracking** | ✅ **Mark as used, usage count, last used date** | ✅ M2.2.3 | 🎯 **Analytics foundation** |
| **FR-RM-006** | **Recipe tags** | ✅ **Multiple tags per recipe for flexible categorization** | ✅ M2.2.2 | 🎯 **Organization** |
| **FR-RM-007** | **Recipe timing** | ✅ **Prep time, cook time, total time tracking** | ✅ M2.2.2 | 🎯 **Planning** |
| **FR-RM-008** | **Servings tracking** | ✅ **Number of servings with recipe scaling support** | ✅ M2.2.2 | 🎯 **Portion management** |
| **FR-RM-009** | **Recipe notes** | ✅ **Freeform text field for user notes and modifications** | ✅ M2.2.2 | 🎯 **Customization** |
| **FR-RM-010** | **Add recipe ingredients to list** | ✅ **One-tap workflow with category preservation** | ✅ M2.2.4 | 🎯 **Recipe-to-grocery integration** |
| **FR-RM-011** | **Unified ingredient management** | ✅ **Single IngredientTemplate system with direct category assignment** | ✅ M2.2.5 | 🎯 **Consolidated ingredient architecture** |
| **FR-RM-012** | **Custom category integration** | ✅ **Store-layout optimization fully integrated throughout recipe system** | ✅ M2.2.6 | 🎯 **Seamless personalized experience** |
| **FR-RM-013** | **Enhanced recipe search** | ✅ **Multi-field search across names, ingredients, tags, instructions** | ✅ M2.2.7 | 🎯 **Comprehensive recipe discovery** |
| **FR-RM-031** | **Recipe creation form** | ✅ **Professional multi-step form with comprehensive validation** | ✅ M2.3 | 🎯 **Complete recipe input** |
| **FR-RM-032** | **Ingredient management** | ✅ **Add/edit/remove/reorder ingredients with template integration** | ✅ M2.3 | 🎯 **Flexible ingredient handling** |
| **FR-RM-033** | **Parse-then-autocomplete** | ✅ **Intelligent parsing with fuzzy matching autocomplete** | ✅ M2.3 | 🎯 **Efficient ingredient entry** |
| **FR-RM-034** | **Template alignment** | ✅ **Automatic ingredient normalization with template linking** | ✅ M2.3 | 🎯 **Data consistency** |
| **FR-RM-035** | **Category assignment** | ✅ **Batch category assignment modal for uncategorized ingredients** | ✅ M2.3 | 🎯 **Category management** |
| **FR-RM-036** | **Recipe editing** | ✅ **Seamless editing workflow maintaining data integrity** | ✅ M2.3 | 🎯 **Recipe updates** |
| **FR-RM-037** | **Unsaved changes detection** | ✅ **Alert users before discarding modifications** | ✅ M2.3 | 🎯 **Data protection** |

### **Non-Functional Requirements - M2**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **NFR-M2-001** | **Recipe list performance < 0.1s** | ✅ Optimized @FetchRequest with predicates | M2.2 | 🎯 **Fast navigation** |
| **NFR-M2-002** | **Search performance < 0.2s** | ✅ Core Data text search with fetch indexes | M2.2.7 | 🎯 **Instant results** |
| **NFR-M2-003** | **Autocomplete performance < 0.1s** | ✅ Debounced search with fuzzy matching | M2.3 | 🎯 **Responsive input** |
| **NFR-M2-004** | **Recipe save performance < 0.5s** | ✅ Optimized Core Data transactions | M2.3 | 🎯 **Quick operations** |
| **NFR-M2-005** | **Template alignment accuracy > 90%** | ✅ Intelligent matching with manual fallback | M2.3 | 🎯 **Data quality** |
| **NFR-M2-006** | **Zero data duplication** | ✅ Template normalization system | M2.2.5 | 🎯 **Data integrity** |

**M2 Summary**: All 37 recipe integration requirements successfully completed with professional quality and comprehensive functionality.

---

## ✅ **M3: STRUCTURED QUANTITY MANAGEMENT - COMPLETE**

**Status**: ✅ Complete - October 2025 (10.5 hours)  
**Summary**: Intelligent quantity management with scaling, consolidation, and unit conversion

### **Functional Requirements - Quantity Model**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-QM-001** | **Structured quantity data model** | ✅ **numericValue, standardUnit, displayText, isParseable, parseConfidence** | ✅ M3 Phase 1-2 | 🎯 **Foundation for intelligence** |
| **FR-QM-002** | **Enhanced quantity parsing** | ✅ **Numeric conversion, unit standardization, fraction support** | ✅ M3 Phase 1-2 | 🎯 **Accurate data capture** |
| **FR-QM-003** | **Backward compatible display** | ✅ **displayText preserves original formatting** | ✅ M3 Phase 1-2 | 🎯 **User experience continuity** |
| **FR-QM-004** | **Parse confidence tracking** | ✅ **0.0-1.0 confidence score for quality assurance** | ✅ M3 Phase 1-2 | 🎯 **Quality metrics** |
| **FR-QM-005** | **Fraction recognition** | ✅ **1/2, 1/4, 3/4, 1/3, 2/3 parsing** | ✅ M3 Phase 1-2 | 🎯 **Kitchen-standard support** |

### **Functional Requirements - Data Migration**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-QM-006** | **One-time migration service** | ✅ **QuantityMigrationService with batch processing** | ✅ M3 Phase 3 | 🎯 **Data transition** |
| **FR-QM-007** | **Migration preview** | ✅ **Preview before commit with statistics** | ✅ M3 Phase 3 | 🎯 **User control** |
| **FR-QM-008** | **Migration results** | ✅ **Comprehensive results display with metrics** | ✅ M3 Phase 3 | 🎯 **Transparency** |
| **FR-QM-009** | **Settings infrastructure** | ✅ **Professional Settings tab for future features** | ✅ M3 Phase 3 | 🎯 **Expandability** |
| **FR-QM-010** | **Zero data loss migration** | ✅ **Transaction safety with automatic rollback** | ✅ M3 Phase 3 | 🎯 **Data integrity** |

### **Functional Requirements - Recipe Scaling**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-QM-021** | **Recipe scaling service** | ✅ **Mathematical quantity scaling 0.25x-4x** | ✅ M3 Phase 4 | 🎯 **Flexible serving sizes** |
| **FR-QM-022** | **Kitchen-friendly fractions** | ✅ **Decimal to fraction conversion (1.5 → "1 1/2")** | ✅ M3 Phase 4 | 🎯 **Practical display** |
| **FR-QM-023** | **Scaling UI** | ✅ **Professional slider with quick buttons and live preview** | ✅ M3 Phase 4 | 🎯 **User-friendly scaling** |
| **FR-QM-024** | **Unparseable handling** | ✅ **Graceful degradation with adjustment notes** | ✅ M3 Phase 4 | 🎯 **Complete coverage** |
| **FR-QM-025** | **Non-destructive preview** | ✅ **Preview only, original recipe preserved** | ✅ M3 Phase 4 | 🎯 **Safe exploration** |
| **FR-QM-026** | **Scaling performance** | ✅ **< 0.5s for 20+ ingredient recipes** | ✅ M3 Phase 4 | 🎯 **Responsive UI** |

### **Functional Requirements - Quantity Consolidation**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-QM-011** | **Parseable quantity merging** | ✅ **Combine compatible quantities ("1 cup" + "2 cups" = "3 cups")** | ✅ M3 Phase 5 | 🎯 **List simplification** |
| **FR-QM-012** | **Mixed type handling** | ✅ **Keep incompatible quantities separate** | ✅ M3 Phase 5 | 🎯 **Intelligent separation** |
| **FR-QM-013** | **Consolidation preview** | ✅ **Preview with user approval before applying** | ✅ M3 Phase 5 | 🎯 **User control** |
| **FR-QM-014** | **Source tracking** | ✅ **Show contributing recipes for merged items** | ✅ M3 Phase 5 | 🎯 **Provenance transparency** |
| **FR-QM-015** | **QuantityMergeService** | ✅ **Intelligent consolidation with compatibility analysis** | ✅ M3 Phase 5 | 🎯 **Core service** |
| **FR-QM-027** | **Unit conversion support** | ✅ **Volume (cups ↔ tbsp ↔ tsp), Weight (lb ↔ oz)** | ✅ M3 Phase 5 | 🎯 **Advanced merging** |
| **FR-QM-028** | **Conversion accuracy** | ✅ **100% accurate unit conversions** | ✅ M3 Phase 5 | 🎯 **Data quality** |
| **FR-QM-029** | **Transaction safety** | ✅ **Atomic merge operations with rollback** | ✅ M3 Phase 5 | 🎯 **Data integrity** |
| **FR-QM-030** | **Consolidation performance** | ✅ **< 0.3s analysis for 50+ items, < 0.8s merge** | ✅ M3 Phase 5 | 🎯 **Responsive operations** |

### **Functional Requirements - UI Polish**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-QM-016** | **Visual indicators for quantity types** | ✅ **Color coding and icons for parseable/unparseable** | ✅ M3 Phase 6 | 🎯 **Visual clarity** |
| **FR-QM-017** | **Help documentation** | ✅ **Comprehensive user guide for quantity features (HelpView.swift)** | ✅ M3 Phase 6 | 🎯 **User education** |
| **FR-QM-018** | **Completion documentation** | ✅ **Learning notes and roadmap updates** | ✅ M3 Phase 6 | 🎯 **Project tracking** |
| **FR-QM-019** | **Autocomplete validation** | ✅ **Verified autocomplete works with M3 features** | ✅ M3 Phase 6 | 🎯 **Integration quality** |
| **FR-QM-020** | **Performance validation** | ✅ **All targets met or exceeded** | ✅ M3 Phase 6 | 🎯 **Quality assurance** |

### **Non-Functional Requirements - M3**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **NFR-M3-001** | **Parsing performance < 0.05s** | ✅ Optimized parsing service (< 0.03s achieved) | M3 Phase 1-2 | 🎯 **Instant feedback** |
| **NFR-M3-002** | **Migration performance < 2s** | ✅ Batch processing with async/await | M3 Phase 3 | 🎯 **Quick transition** |
| **NFR-M3-003** | **Scaling performance < 0.5s** | ✅ Efficient mathematical operations (< 0.4s achieved) | M3 Phase 4 | 🎯 **Responsive scaling** |
| **NFR-M3-004** | **Analysis performance < 0.5s** | ✅ Optimized grouping algorithms (< 0.3s achieved) | M3 Phase 5 | 🎯 **Fast analysis** |
| **NFR-M3-005** | **Merge performance < 1s** | ✅ Transaction optimization (< 0.8s achieved) | M3 Phase 5 | 🎯 **Quick operations** |
| **NFR-M3-006** | **Parse accuracy > 95%** | ✅ Comprehensive parsing patterns | M3 Phase 1-2 | 🎯 **Data quality** |
| **NFR-M3-007** | **Conversion accuracy 100%** | ✅ Validated conversion logic | M3 Phase 5 | 🎯 **Precision** |
| **NFR-M3-008** | **UI responsiveness 60fps** | ✅ Maintained throughout | M3 All | 🎯 **Smooth experience** |

**M3 Summary**: All 33 requirements successfully completed. Structured quantity system operational with recipe scaling, intelligent consolidation, unit conversion, visual enhancements, and comprehensive help documentation. All performance targets met or exceeded. Production-ready quality achieved.

**M3.5 Validation**: Comprehensive validation completed with automated test suite. 75+ computed properties added, 100% test pass rate achieved, test automation pattern established for future milestones.

---

## ✅ **M4: MEAL PLANNING & SETTINGS - COMPLETE**

**Status**: ✅ Complete - November 2025 (~18.5 hours)  
**Summary**: Calendar-based meal planning with enhanced grocery automation

### **Functional Requirements - Settings Infrastructure**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-MP-001** | **Meal planning preferences** | ✅ Duration (3-14 days), start day, auto-naming | M4.1 | 🎯 **Personalization** |
| **FR-MP-002** | **Recipe source display preferences** | ✅ Show/hide recipe sources in lists | M4.1 | 🎯 **User control** |
| **FR-MP-003** | **UserPreferences entity** | ✅ Core Data entity for settings persistence | M4.1 | 🎯 **Data persistence** |
| **FR-MP-004** | **Real-time validation** | ✅ Validate settings as user changes them | M4.1 | 🎯 **Error prevention** |

### **Functional Requirements - Meal Planning Core**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-MP-005** | **MealPlan entity** | ✅ Core Data entity with date range | M4.2 | 🎯 **Data structure** |
| **FR-MP-006** | **PlannedMeal entity** | ✅ Date-recipe relationship tracking | M4.2 | 🎯 **Meal assignments** |
| **FR-MP-007** | **Calendar view** | ✅ Calendar grid with tap-to-add | M4.2 | 🎯 **Visual planning** |
| **FR-MP-008** | **Add to meal plan** | ✅ RecipePickerSheet with search/servings | M4.2 | 🎯 **Easy assignment** |
| **FR-MP-009** | **Configurable periods** | ✅ User-defined date ranges | M4.2 | 🎯 **Flexibility** |
| **FR-MP-010** | **Meal plan management** | ✅ Create meal plans with date pickers | M4.2 | 🎯 **Plan control** |
| **FR-MP-017** | **Recipe usage tracking** | ✅ usageCount and lastUsed on assignment | M4.2 | 🎯 **Analytics data** |

### **Functional Requirements - Enhanced Grocery Integration**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-MP-011** | **Generate list from meal plan** | ✅ Bulk add with progress overlay | M4.3.3 | 🎯 **Automation** |
| **FR-MP-012** | **Recipe source tags** | ✅ Recipe badges in grocery lists | M4.3.1 | 🎯 **Transparency** |
| **FR-MP-013** | **Smart consolidation** | ✅ Perfect integration with M3 Phase 5 | M4.3.3 | 🎯 **List optimization** |
| **FR-MP-014** | **Meal completion tracking** | ✅ Mark meals as completed | M4.3.4 | 🎯 **Progress tracking** |
| **FR-MP-015** | **Scaled recipe to list** | ✅ Servings adjustment UI with scale indicators | M4.3.2 | 🎯 **Party planning** |
| **FR-MP-016** | **Scaling metadata** | ✅ Servings adjustment in SelectListSheet | M4.3.3 | 🎯 **Context preservation** |

### **Non-Functional Requirements - M4**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **NFR-M4-001** | **List generation performance < 1s** | ✅ Sub-1s for 7-day plan | M4.3.3 | 🎯 **Fast automation** |
| **NFR-M4-002** | **Calendar rendering < 0.5s** | ✅ Responsive calendar | M4.2 | 🎯 **Responsive UI** |
| **NFR-M4-003** | **Settings persistence immediate** | ✅ Instant save | M4.1 | 🎯 **Reliability** |

**M4 Summary**: All 19 requirements complete. Calendar-based meal planning operational with automated grocery integration, smart consolidation, and comprehensive tracking.

---

## ✅ **M5.0: APP RENAMING & TESTFLIGHT DEPLOYMENT - COMPLETE**

**Status**: ✅ Complete - December 2025 (6 hours)  
**Summary**: Complete app renaming to "Forager" and TestFlight deployment for real-device validation

### **Functional Requirements - App Identity**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-TF-001** | **Professional app name** | ✅ Renamed to "Forager: Smart Meal Planner" | M5.0.1 | 🎯 **Brand identity** |
| **FR-TF-002** | **Bundle identifier update** | ✅ com.richhayn.forager across all targets | M5.0.2 | 🎯 **App Store presence** |
| **FR-TF-003** | **App icon design** | ✅ Professional 1024x1024 icon (green sprout) | M5.0.5B | 🎯 **Visual identity** |
| **FR-TF-004** | **File structure consistency** | ✅ All folders, files renamed systematically | M5.0.3 | 🎯 **Project organization** |

### **Functional Requirements - TestFlight Deployment**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-TF-005** | **Apple Developer enrollment** | ✅ Program enrolled ($99/year) | M5.0.5A | 🎯 **Distribution capability** |
| **FR-TF-006** | **App Store Connect setup** | ✅ App created, configured | M5.0.5C | 🎯 **Deployment infrastructure** |
| **FR-TF-007** | **CloudKit entitlements** | ✅ Production entitlements configured | M5.0.5D | 🎯 **Sync readiness** |
| **FR-TF-008** | **Internal TestFlight** | ✅ Internal testing group operational | M5.0.5E | 🎯 **Beta testing** |
| **FR-TF-009** | **Real device validation** | ✅ App running on physical iPhones | M5.0.5F | 🎯 **Production validation** |
| **FR-TF-010** | **Multi-tester distribution** | ✅ Multiple testers invited and active | M5.0.5E | 🎯 **Feedback collection** |

### **Non-Functional Requirements - M5.0**

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **NFR-TF-001** | **Zero data loss during rename** | ✅ All existing data preserved | M5.0.3B | 🎯 **Data integrity** |
| **NFR-TF-002** | **Build success after rename** | ✅ Clean builds throughout | M5.0 All | 🎯 **Technical stability** |
| **NFR-TF-003** | **Performance maintained** | ✅ All M1-M4 targets still met | M5.0.5F | 🎯 **Quality preserved** |
| **NFR-TF-004** | **Archive/upload success** | ✅ TestFlight upload successful | M5.0.5D | 🎯 **Deployment capability** |

**M5.0 Summary**: All 14 requirements complete. Forager successfully renamed, deployed to TestFlight, and validated on real devices. Internal beta testing operational with multiple testers.

---

## 🔄 **M7: CLOUDKIT SYNC & EXTERNAL TESTFLIGHT - ACTIVE**

**Status**: 🔄 ACTIVE (M7.0 ✅, M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🚀)  
**Original Estimate**: 27-37 hours base, 32-42 hours with buffer  
**Revised Estimate**: 38-48 hours base, 43-53 hours with buffer (M7.1.3 expansion: +11h)  
**Summary**: Full CloudKit synchronization with semantic uniqueness, multi-user collaboration, and external public beta

**⚠️ CRITICAL SCOPE CHANGE**: M7.1.3 expanded from 3-4h basic testing to 11-15h comprehensive architectural fix for CloudKit semantic uniqueness issue

### **✅ Functional Requirements - App Store Prerequisites (M7.0 - COMPLETE)** ✅

| ID | Requirement | Implementation | Milestone | Status |
|----|-------------|----------------|-----------|--------|
| **FR-AS-001** | **Privacy policy published** | ✅ Hosted at https://rfhayn.github.io/forager/privacy.html | M7.0.1 | ✅ COMPLETE |
| **FR-AS-002** | **In-app privacy link** | ✅ Settings → Privacy Policy (SafariServices) | M7.0.2 | ✅ COMPLETE |
| **FR-AS-003** | **App Privacy questionnaire** | ✅ Completed in App Store Connect | M7.0.3 | ✅ COMPLETE |
| **FR-AS-004** | **Display name disambiguation** | ✅ "forager: smart meal planner" (display) + "Forager" (icon) | M7.0.4 | ✅ COMPLETE |

**M7.0 Summary**: All 4 App Store prerequisites complete (3 hours, 100% accuracy). Cleared for external TestFlight.

**Why M7.0 was MANDATORY:**
- Apple's November 2025 policies require privacy policy URL for ALL apps
- External TestFlight requires completed App Privacy questionnaire
- Name disambiguation avoids rejection under Guideline 4.1 (Copycats)
- Attempting external TestFlight without M7.0 = automatic rejection

### **🔄 Functional Requirements - CloudKit Sync Foundation (M7.1 - ACTIVE)**

| ID | Requirement | Implementation | Milestone | Status |
|----|-------------|----------------|-----------|--------|
| **FR-CK-001** | **CloudKit schema generation** | ✅ All 8 entities sync to CloudKit | M7.1.1 | ✅ COMPLETE |
| **FR-CK-002** | **Automatic background sync** | ✅ CloudKit syncs without user action | M7.1.1 | ✅ COMPLETE |
| **FR-CK-003** | **Sync status monitoring** | ✅ Real-time CloudKit sync state tracking | M7.1.2 | ✅ COMPLETE |
| **FR-CK-004** | **Multi-device sync** | 🚀 Changes sync across devices <5s | M7.1.3 | 🔄 ACTIVE |
| **FR-CK-005** | **Offline sync queue** | 🚀 Changes queue offline, sync when online | M7.1.3 | 🔄 ACTIVE |

---

### **🚀 NEW: Functional Requirements - Semantic Uniqueness (M7.1.3)**

**Context**: Discovered CloudKit creates duplicate entities when multiple devices create semantically identical objects (e.g., same Category name with different UUIDs). This causes crashes and data integrity issues. M7.1.3 implements production-ready semantic uniqueness architecture.

| ID | Requirement | Implementation | Milestone | Value |
|----|-------------|----------------|-----------|-------|
| **FR-SU-001** | **Category semantic uniqueness** | Repository pattern with normalizedName field and uniqueness constraint | M7.1.3 | 🎯 **Prevent duplicate categories** |
| **FR-SU-002** | **IngredientTemplate semantic uniqueness** | Repository pattern with canonicalName field and uniqueness constraint | M7.1.3 | 🎯 **Prevent duplicate templates** |
| **FR-SU-003** | **PlannedMeal slot protection** | Repository pattern with slotKey (date + mealType) and uniqueness constraint | M7.1.3 | 🎯 **One meal per slot** |
| **FR-SU-004** | **Recipe duplicate detection** | User-assisted detection with dialog (View Existing \| Save as New \| Cancel) | M7.1.3 | 🎯 **Intentional duplicates allowed** |

**Implementation Architecture**:

1. **Two-Stage Migration**: 
   - Stage A: Add optional semantic key fields
   - Stage B: Make required, add uniqueness constraints
   - Prevents CloudKit crashes during migration

2. **Repository Pattern**: 
   - CategoryRepository - Get-or-create for categories
   - PlannedMealRepository - Slot protection for meal planning
   - Enhanced IngredientTemplateService - Canonical ingredient names
   - RecipeDuplicateDetector - User-assisted duplicate detection

3. **Field Standardization**: 
   - All entities rename `name`/`title` → `displayName` for consistency

4. **11 Architectural Decision Records**: 
   - ADR-009 through ADR-019 document all decisions

**Entities With Semantic Uniqueness**:
- Category: `normalizedName` (lowercase, trimmed)
- IngredientTemplate: `canonicalName` (via IngredientTemplateService)
- PlannedMeal: `slotKey` (format: "2024-12-10-breakfast")

**User-Assisted Detection**:
- Recipe: `titleKey` → Detect similar, show dialog with existing recipe details

**Intentional Duplicates Allowed**:
- GroceryListItem: Source tracking requires duplicates (Recipe A + Recipe B + Manual)
- WeeklyList: Simple list container, no date range constraint
- MealPlan: Week container, no uniqueness needed

**Why This Matters**:
- Prevents CloudKit crashes from duplicate entity creation
- Production-ready multi-device sync
- Clean architectural foundation
- Doubles forager's ADR count (7 → 18 total)

**PRD**: docs/prds/active/M7.1.3-CloudKit-Sync-Integrity-PRD-v4.1-FINAL.md

---

### **Functional Requirements - Multi-User Collaboration**

| ID | Requirement | Target Implementation | Milestone | Value |
|----|-------------|----------------------|-----------|-------|
| **FR-CK-006** | **CKShare implementation** | Share grocery lists, recipes, meal plans | M7.2.1 | 🎯 **Family collaboration** |
| **FR-CK-007** | **Share invitation flow** | Send/accept share invitations | M7.2.1 | 🎯 **Easy sharing** |
| **FR-CK-008** | **Permission management** | Owner/participant roles, read/write control | M7.2.3 | 🎯 **Access control** |
| **FR-CK-009** | **Share management UI** | View/revoke shares, manage participants | M7.2.2 | 🎯 **Share control** |
| **FR-CK-010** | **Concurrent edit support** | Multiple users edit simultaneously | M7.2.4 | 🎯 **Real-time collaboration** |

### **Functional Requirements - Conflict Resolution**

| ID | Requirement | Target Implementation | Milestone | Value |
|----|-------------|----------------------|-----------|-------|
| **FR-CK-011** | **Last-write-wins policy** | Most recent edit wins for simple fields | M7.3.1 | 🎯 **Automatic resolution** |
| **FR-CK-012** | **Array merge policy** | Intelligently merge ingredient/item arrays | M7.3.1 | 🎯 **Data preservation** |
| **FR-CK-013** | **Deleted record handling** | Graceful handling of delete conflicts | M7.3.2 | 🎯 **Data consistency** |
| **FR-CK-014** | **Network error recovery** | Retry logic for transient failures | M7.3.2 | 🎯 **Reliability** |
| **FR-CK-015** | **CloudKit quota management** | Monitor and optimize storage usage | M7.3.2 | 🎯 **Scalability** |

### **Functional Requirements - Sync UI & Polish**

| ID | Requirement | Target Implementation | Milestone | Value |
|----|-------------|----------------------|-----------|-------|
| **FR-CK-016** | **Sync status indicators** | Visual sync status (synced/syncing/error) | M7.4.1 | 🎯 **User awareness** |
| **FR-CK-017** | **Manual sync trigger** | Pull-to-refresh force sync | M7.4.1 | 🎯 **User control** |
| **FR-CK-018** | **Last synced timestamp** | Show when last sync occurred | M7.4.1 | 🎯 **Transparency** |
| **FR-CK-019** | **CloudKit account status** | Display iCloud sign-in status | M7.4.2 | 🎯 **User awareness** |
| **FR-CK-020** | **Sync diagnostics** | Debug view for troubleshooting | M7.4.2 | 🎯 **Supportability** |

### **Functional Requirements - External TestFlight**

| ID | Requirement | Target Implementation | Milestone | Value |
|----|-------------|----------------------|-----------|-------|
| **FR-TF-011** | **External testing group** | Create public external testing group | M7.5.1 | 🎯 **Public beta** |
| **FR-TF-012** | **App Review submission** | Pass Apple's external testing review | M7.5.2 | 🎯 **Public distribution** |
| **FR-TF-013** | **Public TestFlight link** | Generate shareable public link | M7.5.4 | 🎯 **Easy distribution** |
| **FR-TF-014** | **Beta landing page** | Professional web page for beta | M7.6.1 | 🎯 **Professional showcase** |
| **FR-TF-015** | **LinkedIn showcase** | Public post with beta link | M7.6.2 | 🎯 **Professional visibility** |

### **Non-Functional Requirements - M7**

| ID | Requirement | Target | Milestone | Value |
|----|-------------|--------|-----------|-------|
| **NFR-CK-001** | **Sync latency < 5s** | Multi-device sync within 5 seconds | M7.1.3 | 🎯 **Real-time feel** |
| **NFR-CK-002** | **Sync success rate > 99%** | Reliable synchronization | M7 All | 🎯 **Dependability** |
| **NFR-CK-003** | **Conflict resolution 100%** | All conflicts handled gracefully | M7.3.1 | 🎯 **Data integrity** |
| **NFR-CK-004** | **UI responsiveness maintained** | Sync doesn't block UI | M7 All | 🎯 **Performance** |
| **NFR-CK-005** | **Battery impact < 5%** | Minimal battery drain from sync | M7 All | 🎯 **Efficiency** |
| **NFR-CK-006** | **Network data < 1MB/sync** | Efficient data transfer | M7 All | 🎯 **Data economy** |
| **NFR-CK-007** | **App Review pass** | Approval for external testing | M7.5.3 | 🎯 **Public readiness** |
| **NFR-CK-008** | **Zero duplicate entities** | Semantic uniqueness enforced | M7.1.3 | 🔄 **ACTIVE** |

**M7 Summary**: 33 requirements total (up from 29 with M7.1.3 expansion):
- App Store prerequisites: 4 requirements ✅ COMPLETE
- CloudKit sync foundation: 5 requirements (3 complete, 2 active)
- **Semantic uniqueness: 4 requirements** ⭐ NEW (M7.1.3)
- Multi-user collaboration: 5 requirements (planned)
- Conflict resolution: 5 requirements (planned)
- Sync UI polish: 5 requirements (planned)
- External TestFlight: 5 requirements (planned)
- Non-functional: 8 requirements (7 original + 1 new)

Transforms Forager into App Store-compliant collaborative family platform with production-ready CloudKit sync and public beta program.

---

## 🔮 **FUTURE MILESTONES (M6, M8-M11)**

### **M6: Testing Foundation & AI Augmentation**
- Comprehensive test suite (50%+ coverage)
- AI-powered test review
- Automated testing infrastructure
- CI/CD pipeline
- **Estimated**: 12-18 hours

### **M8: Analytics & Insights**
- Usage analytics dashboard
- Recipe recommendations
- Shopping insights
- Data export
- **Estimated**: 6-8 hours

### **M9-M11: Advanced Intelligence**
- **M9**: Nutrition tracking (6-8 hours)
- **M10**: Budget intelligence (6-8 hours)
- **M11**: AI recipe assistant & lifestyle optimization (8-12 hours)

---

## 📊 **REQUIREMENTS SUMMARY**

### **By Status**

| Status | M1 | M2 | M3 | M4 | M5.0 | M7 | Total |
|--------|----|----|----|----|------|----|----|
| ✅ Complete | 19 | 37 | 33 | 19 | 14 | 0 | **122** |
| ⏳ Planned | 0 | 0 | 0 | 0 | 0 | 29 | **29** |
| **Total** | **19** | **37** | **33** | **19** | **14** | **29** | **151** |

### **By Category**

| Category | Requirements | Status |
|----------|--------------|--------|
| Grocery Lists | 5 | ✅ Complete |
| Categories | 5 | ✅ Complete |
| Staples | 4 | ✅ Complete |
| Recipes | 19 | ✅ Complete |
| Quantities | 33 | ✅ Complete |
| Meal Planning | 19 | ✅ Complete |
| TestFlight & Identity | 14 | ✅ Complete |
| App Store Compliance | 4 | ⏳ Planned (M7.0) |
| CloudKit Sync | 25 | ⏳ Planned (M7.1-M7.6) |
| **Complete** | **122** | **81% (122/151)** |
| **Planned** | **29** | **19% (29/151)** |

### **Performance Requirements Status**

| Requirement | Target | Actual | Status |
|-------------|--------|--------|--------|
| Query performance | < 0.1s | < 0.1s | ✅ Met |
| Search performance | < 0.2s | < 0.15s | ✅ Exceeded |
| Autocomplete | < 0.1s | < 0.08s | ✅ Exceeded |
| Parsing | < 0.05s | < 0.03s | ✅ Exceeded |
| Scaling | < 0.5s | < 0.4s | ✅ Exceeded |
| Consolidation analysis | < 0.5s | < 0.3s | ✅ Exceeded |
| Merge execution | < 1s | < 0.8s | ✅ Exceeded |
| UI responsiveness | 60fps | 60fps | ✅ Met |

**All performance targets met or exceeded** ✅

---

## 🎯 **CURRENT REQUIREMENTS FOCUS**

### **Completed: M5.0 App Renaming & TestFlight** ✅
**Total Time**: 6 hours  
**Status**: All requirements complete

**Achievements:**
- Complete app rename to "Forager" ✅
- Professional app icon (green sprout) ✅
- Apple Developer enrollment ✅
- App Store Connect configuration ✅
- CloudKit production entitlements ✅
- Internal TestFlight operational ✅
- Multi-tester beta program launched ✅
- Real device validation successful ✅

### **Next Priority: M7 CloudKit Sync & External TestFlight** 🚀
**Timeline**: 27-37 hours base, 32-42 hours with buffer (3-4 weeks with Apple review)  
**Status**: PRD complete, ready to start

**Priority Areas:**
- **M7.0: App Store Prerequisites (MANDATORY)** - Privacy policy, questionnaire, name disambiguation
- CloudKit schema validation and sync foundation
- Multi-user collaboration with CKShare
- Multi-device synchronization (<5s latency)
- Conflict resolution strategies
- Sync status UI indicators
- External TestFlight with App Review
- Public beta landing page
- LinkedIn professional showcase

**Strategic Value:**
- Achieves App Store compliance for public distribution
- Transforms single-device app into collaborative platform
- Enables family sharing and multi-user workflows
- Public beta expands feedback opportunities
- Professional portfolio showcase piece
- Foundation for future App Store launch

---

## 📈 **REQUIREMENTS TRACEABILITY**

### **Core Data Model Requirements**

| Entity | Requirements Met | Status |
|--------|------------------|--------|
| GroceryList | FR-GL-001 through FR-GL-005 | ✅ Complete |
| GroceryListItem | FR-GL-002, FR-CAT-004, FR-QM-001-005 | ✅ Complete |
| Category | FR-CAT-001 through FR-CAT-005 | ✅ Complete |
| Recipe | FR-RM-001 through FR-RM-013 | ✅ Complete |
| Ingredient | FR-RM-032, FR-RM-034, FR-QM-001-005 | ✅ Complete |
| IngredientTemplate | FR-RM-011, FR-RM-033-035 | ✅ Complete |
| MealPlanRecipe | FR-MP-005, FR-MP-006 | ✅ Complete |
| MealPlan | FR-MP-007 through FR-MP-010 | ✅ Complete |
| UserPreferences | FR-MP-001 through FR-MP-004 | ✅ Complete |

---

## 🔍 **VALIDATION FRAMEWORK**

### **Acceptance Criteria Tracking**

**M1 Validation**: ✅ Complete
- All functional requirements implemented
- Performance targets met
- User testing successful
- Zero critical bugs

**M2 Validation**: ✅ Complete
- Recipe CRUD operational
- Autocomplete functional
- Template system working
- Performance targets met

**M3 Validation**: ✅ Complete
- All 6 phases validated ✅
- All 33 requirements complete ✅
- Performance targets exceeded ✅
- Production-ready quality ✅

**M4 Validation**: ✅ Complete
- All requirements validated ✅
- Calendar planning operational ✅
- Grocery integration complete ✅
- Performance targets met ✅

**M5.0 Validation**: ✅ Complete
- App rename successful ✅
- TestFlight deployment operational ✅
- Real device validation passed ✅
- Multi-tester beta active ✅

**M7 Validation**: ⏳ Planned
- CloudKit sync operational
- Multi-user collaboration tested
- External TestFlight approved
- Public beta launched

---

## 🚀 **STRATEGIC REQUIREMENTS ROADMAP**

### **Phase 1: Core Platform (M1-M4)** - ✅ Complete
**Goal**: Complete essential grocery and recipe workflows  
**Timeline**: 77 hours actual  
**Status**: ✅ Complete

**Value Delivered**:
- Store-layout optimized shopping ✅
- Complete recipe management ✅
- Intelligent quantity handling ✅
- Meal planning automation ✅

### **Phase 2: Production & Collaboration (M5.0-M7)** - 🔄 In Progress
**Goal**: Production deployment and collaborative features  
**Timeline**: 38-48 hours (M5.0: 6h, M7.0: 3h, M7.1-7.6: 35-45h with buffer)  
**Status**: M5.0 complete ✅, M7.0 complete ✅, M7.1 active 🔄 (M7.1.1 ✅, M7.1.2 ✅, M7.1.3 🚀)

**Value Delivered**:
- ✅ Apple Developer Program enrollment
- ✅ TestFlight deployment & real device validation
- ✅ Internal beta testing program
- ✅ App Store compliance (privacy policy, questionnaire, name disambiguation)
- ✅ CloudKit infrastructure operational
- ✅ Real-time sync monitoring
- 🔄 CloudKit semantic uniqueness architecture (M7.1.3 in progress)
- ⏳ Multi-device sync validation
- ⏳ Family collaboration features
- ⏳ External public beta program
- ⏳ Professional portfolio showcase

### **Phase 3: Quality & Intelligence (M6, M8-M11)** - ⏳ Future
**Goal**: Testing foundation and advanced features  
**Timeline**: ~38-56 hours  
**Status**: Strategic planning

**Value Delivered**:
- Comprehensive test coverage (M6)
- Analytics and insights (M8)
- Nutrition tracking (M9)
- Budget intelligence (M10)
- AI assistance & lifestyle optimization (M11)

---

**Strategic Validation**: Core platform (M1-M4) complete with professional quality (87h, 108 requirements ✅). Production infrastructure (M5.0) delivered TestFlight deployment (6h, 14 requirements ✅). App Store compliance (M7.0) complete (3h, 4 requirements ✅). CloudKit foundation (M7.1) in progress with production-ready semantic uniqueness architecture (6.5h so far, 6 requirements active, 11-15h remaining for M7.1.3). Combined M1-M7 represents complete collaborative meal planning platform ready for App Store launch.

**Last Updated**: December 10, 2024  
**Version**: 4.1 - M7.1.3 Semantic Uniqueness  
**Next Update**: After M7.1.3 completion  
**Current Focus**: M7.1.3 - CloudKit Sync Integrity (comprehensive architectural fix)