# M3 Phase 5: Quantity Merge Service - Development Prompt

**Copy and paste this prompt when ready to continue M3 Phase 5:**

---

I'm ready to continue **M3 Phase 5: Quantity Merge Service** for my Grocery & Recipe Manager iOS app.

## Current Status - M3 Phase 1-4 COMPLETE:

### **M1-M2: Foundation Complete** ✅
- **M1**: Professional Grocery Management (32 hours, Aug 2025) - Complete
- **M2**: Recipe Integration (16.5 hours, Sep-Oct 2025) - Complete

### **M3 Phase 1-2: Structured Quantity Foundation** ✅
**Completion Date**: October 10, 2025  
**Time**: 3 hours

**Achievements:**
- **Structured Data Model**: Replaced string fields with numericValue, standardUnit, displayText, isParseable, parseConfidence
- **Enhanced IngredientParsingService**: Numeric conversion, unit standardization, fraction handling operational
- **10 Files Updated**: Systematic update across Ingredient, GroceryListItem, all views and services
- **Zero Build Errors**: Clean replacement architecture with type safety
- **Performance**: Sub-0.1s response times maintained

### **M3 Phase 3: Data Migration** ✅
**Completion Date**: October 11, 2025  
**Time**: 1.5 hours

**Achievements:**
- **QuantityMigrationService**: Batch processing with async/await patterns
- **Professional Migration UI**: Preview → Migration → Results flow
- **Settings Infrastructure**: Settings tab created and operational
- **100% Success Rate**: 32 items processed - 24 parsed (75%), 8 text-only (25%)
- **Migration Complete**: All existing data successfully migrated to structured format

### **M3 Phase 4: Recipe Scaling Service** ✅
**Completion Date**: October 11, 2025  
**Time**: 2.5 hours

**Achievements:**
- **RecipeScalingService**: Mathematical quantity scaling operational
- **Kitchen-Friendly Fractions**: Decimal to fraction conversion (1.5 → "1 1/2")
- **Scaling UI**: Professional SwiftUI interface with slider and quick buttons
- **Graceful Degradation**: Unparseable ingredients handled with adjustment notes
- **Performance**: < 0.5s scaling operations for 20+ ingredient recipes

**Features Working:**
- Scale recipes from 0.25x to 4x with live preview
- Auto-scaled vs manual adjustment summary
- Visual indicators (✓ for scaled, ℹ️ for manual)
- Preview-only (non-destructive to original recipe)

---

## M3 Phase 5: Quantity Merge Service (2-3 hours)

### **Goal:**
Build intelligent shopping list consolidation service that combines duplicate ingredients with compatible quantities while handling mixed types gracefully.

### **Current Foundation:**
- ✅ Structured quantity data model operational
- ✅ numericValue, standardUnit, isParseable fields populated
- ✅ Recipe scaling service demonstrates quantity manipulation
- ✅ Shopping lists have structured quantities ready for merging

### **Phase 5 Implementation Plan:**

#### **Step 1: QuantityMergeService (90-120 minutes)**

**Create New Service:**
```swift
// Services/QuantityMergeService.swift

import Foundation
import CoreData

class QuantityMergeService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Main Merge Function
    
    /// Analyze grocery list items for consolidation opportunities
    func analyzeMergeOpportunities(for list: WeeklyList) -> MergeAnalysis {
        guard let itemsSet = list.items else {
            return MergeAnalysis(list: list, groups: [], totalSavings: 0)
        }
        
        let items = Array(itemsSet) as! [GroceryListItem]
        let incompleteItems = items.filter { !$0.isCompleted }
        
        // Group by ingredient template (normalized name)
        let grouped = Dictionary(grouping: incompleteItems) { item -> String in
            return item.ingredientTemplate?.name?.lowercased() ?? item.name?.lowercased() ?? ""
        }
        
        var mergeGroups: [MergeGroup] = []
        var potentialSavings = 0
        
        for (ingredientName, groupItems) in grouped where groupItems.count > 1 {
            // Further subdivide by unit compatibility
            let compatible = groupCompatibleQuantities(groupItems)
            
            if let mergedGroup = createMergeGroup(
                ingredientName: ingredientName,
                items: groupItems,
                compatibleSets: compatible
            ) {
                mergeGroups.append(mergedGroup)
                potentialSavings += (groupItems.count - mergedGroup.resultCount)
            }
        }
        
        return MergeAnalysis(
            list: list,
            groups: mergeGroups,
            totalSavings: potentialSavings
        )
    }
    
    // MARK: - Compatibility Analysis
    
    private func groupCompatibleQuantities(_ items: [GroceryListItem]) -> [[GroceryListItem]] {
        var compatibleSets: [[GroceryListItem]] = []
        
        // Separate parseable from unparseable
        let parseable = items.filter { $0.isParseable && $0.standardUnit != nil }
        let unparseable = items.filter { !$0.isParseable || $0.standardUnit == nil }
        
        // Group parseable by standardUnit
        let byUnit = Dictionary(grouping: parseable) { $0.standardUnit ?? "" }
        
        for (_, unitItems) in byUnit where unitItems.count > 1 {
            compatibleSets.append(unitItems)
        }
        
        // Each unparseable is its own group
        for item in unparseable {
            compatibleSets.append([item])
        }
        
        return compatibleSets
    }
    
    private func createMergeGroup(
        ingredientName: String,
        items: [GroceryListItem],
        compatibleSets: [[GroceryListItem]]
    ) -> MergeGroup? {
        
        var mergedItems: [MergedItem] = []
        
        for itemSet in compatibleSets {
            if itemSet.count > 1 && canMerge(itemSet) {
                // Mergeable set - combine quantities
                let totalValue = itemSet.compactMap { $0.numericValue }.reduce(0, +)
                let unit = itemSet.first?.standardUnit
                let sources = itemSet.compactMap { $0.source }
                
                mergedItems.append(MergedItem(
                    displayText: formatMergedQuantity(value: totalValue, unit: unit),
                    sourceCount: itemSet.count,
                    sources: sources,
                    originalItems: itemSet,
                    isMerged: true
                ))
            } else {
                // Keep separate
                for item in itemSet {
                    mergedItems.append(MergedItem(
                        displayText: item.displayText ?? item.name ?? "",
                        sourceCount: 1,
                        sources: [item.source ?? ""],
                        originalItems: [item],
                        isMerged: false
                    ))
                }
            }
        }
        
        guard mergedItems.count < items.count else { return nil }
        
        return MergeGroup(
            ingredientName: ingredientName,
            originalCount: items.count,
            mergedItems: mergedItems,
            savingsCount: items.count - mergedItems.count
        )
    }
    
    private func canMerge(_ items: [GroceryListItem]) -> Bool {
        // All must be parseable with same unit
        guard items.allSatisfy({ $0.isParseable && $0.standardUnit != nil }) else {
            return false
        }
        
        let firstUnit = items.first?.standardUnit
        return items.allSatisfy { $0.standardUnit == firstUnit }
    }
    
    // MARK: - Merge Execution
    
    func executeMerge(analysis: MergeAnalysis) throws {
        guard let list = analysis.list else { return }
        
        for group in analysis.groups {
            for mergedItem in group.mergedItems where mergedItem.isMerged {
                // Create single consolidated item
                let consolidated = GroceryListItem(context: context)
                consolidated.id = UUID()
                consolidated.name = group.ingredientName
                consolidated.displayText = mergedItem.displayText
                consolidated.numericValue = mergedItem.originalItems.compactMap { $0.numericValue }.reduce(0, +)
                consolidated.standardUnit = mergedItem.originalItems.first?.standardUnit
                consolidated.isParseable = true
                consolidated.source = "merged(\(mergedItem.sourceCount))"
                consolidated.dateCreated = Date()
                consolidated.isCompleted = false
                consolidated.weeklyList = list
                consolidated.ingredientTemplate = mergedItem.originalItems.first?.ingredientTemplate
                
                // Delete original items
                mergedItem.originalItems.forEach { context.delete($0) }
            }
        }
        
        try context.save()
    }
    
    // MARK: - Formatting
    
    private func formatMergedQuantity(value: Double, unit: String?) -> String {
        let fractionString = formatToFraction(value)
        if let unit = unit, !unit.isEmpty {
            return "\(fractionString) \(unit)"
        }
        return fractionString
    }
    
    private func formatToFraction(_ value: Double) -> String {
        let whole = Int(value)
        let fractional = value - Double(whole)
        
        let fractions: [(value: Double, display: String)] = [
            (0.125, "1/8"), (0.166, "1/6"), (0.25, "1/4"),
            (0.333, "1/3"), (0.375, "3/8"), (0.5, "1/2"),
            (0.625, "5/8"), (0.666, "2/3"), (0.75, "3/4"),
            (0.833, "5/6"), (0.875, "7/8")
        ]
        
        let tolerance = 0.05
        
        for (fValue, fDisplay) in fractions {
            if abs(fractional - fValue) < tolerance {
                return whole > 0 ? "\(whole) \(fDisplay)" : fDisplay
            }
        }
        
        if whole > 0 {
            return fractional < 0.01 ? "\(whole)" : String(format: "%.1f", value)
        }
        return String(format: "%.2f", value)
    }
}

// MARK: - Data Structures

struct MergeAnalysis {
    let list: WeeklyList?
    let groups: [MergeGroup]
    let totalSavings: Int
    
    var hasMergeOpportunities: Bool {
        return totalSavings > 0
    }
    
    var summary: String {
        if totalSavings == 0 {
            return "No merge opportunities found"
        } else if totalSavings == 1 {
            return "Can consolidate 1 duplicate item"
        } else {
            return "Can consolidate \(totalSavings) duplicate items"
        }
    }
}

struct MergeGroup {
    let ingredientName: String
    let originalCount: Int
    let mergedItems: [MergedItem]
    let savingsCount: Int
    
    var resultCount: Int {
        return mergedItems.count
    }
}

struct MergedItem: Identifiable {
    let id = UUID()
    let displayText: String
    let sourceCount: Int
    let sources: [String]
    let originalItems: [GroceryListItem]
    let isMerged: Bool
}
```

#### **Step 2: Consolidation UI (45-60 minutes)**

**Add to GroceryListDetailView:**
```swift
// Add state for consolidation
@State private var showingConsolidationSheet = false
@State private var mergeAnalysis: MergeAnalysis?
@StateObject private var mergeService: QuantityMergeService

// Initialize service
init(weeklyList: WeeklyList) {
    self.weeklyList = weeklyList
    _mergeService = StateObject(wrappedValue: QuantityMergeService(
        context: PersistenceController.shared.container.viewContext
    ))
}

// Add "Consolidate" button in toolbar
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            analyzeConsolidation()
        } label: {
            Label("Consolidate", systemImage: "arrow.triangle.merge")
        }
        .disabled(incompletedItems.count < 2)
    }
}

private func analyzeConsolidation() {
    mergeAnalysis = mergeService.analyzeMergeOpportunities(for: weeklyList)
    if mergeAnalysis?.hasMergeOpportunities == true {
        showingConsolidationSheet = true
    } else {
        // Show "no opportunities" message
    }
}

.sheet(isPresented: $showingConsolidationSheet) {
    if let analysis = mergeAnalysis {
        ConsolidationPreviewView(
            analysis: analysis,
            mergeService: mergeService,
            onComplete: {
                showingConsolidationSheet = false
                mergeAnalysis = nil
            }
        )
    }
}
```

**Create ConsolidationPreviewView:**
```swift
// Views/ConsolidationPreviewView.swift

struct ConsolidationPreviewView: View {
    @Environment(\.dismiss) var dismiss
    let analysis: MergeAnalysis
    let mergeService: QuantityMergeService
    let onComplete: () -> Void
    
    @State private var isExecuting = false
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(analysis.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ForEach(analysis.groups) { group in
                    Section(header: groupHeader(group)) {
                        ForEach(group.mergedItems) { item in
                            mergedItemRow(item)
                        }
                    }
                }
            }
            .navigationTitle("Consolidate Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        executeConsolidation()
                    }
                    .disabled(isExecuting)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func groupHeader(_ group: MergeGroup) -> some View {
        HStack {
            Text(group.ingredientName.capitalized)
            Spacer()
            Text("\(group.originalCount) → \(group.resultCount) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func mergedItemRow(_ item: MergedItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.isMerged ? "arrow.triangle.merge" : "minus")
                .foregroundColor(item.isMerged ? .green : .secondary)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayText)
                    .font(.body)
                    .fontWeight(item.isMerged ? .medium : .regular)
                
                if item.isMerged && item.sourceCount > 1 {
                    Text("Merged from \(item.sourceCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !item.sources.isEmpty {
                    Text("Sources: \(item.sources.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func executeConsolidation() {
        isExecuting = true
        
        do {
            try mergeService.executeMerge(analysis: analysis)
            dismiss()
            onComplete()
        } catch {
            self.error = error
            isExecuting = false
        }
    }
}
```

#### **Step 3: Testing & Validation (15-30 minutes)**

**Test Scenarios:**
1. **Simple Merge**:
   - Add "1 cup flour" from Recipe A
   - Add "2 cups flour" from Recipe B
   - Consolidate → "3 cups flour" with source tracking

2. **Mixed Units**:
   - "2 cups milk" + "1 tablespoon milk"
   - Keep separate (incompatible units)

3. **Unparseable**:
   - "Flour to taste" + "2 cups flour"
   - Keep separate (incompatible types)

4. **Multiple Recipes**:
   - Same ingredient from 3+ recipes
   - Proper source tracking

**Performance Validation:**
- Analysis < 0.5s for 50+ item lists
- Merge execution < 1s
- UI responsive during operations

### **Success Criteria:**

**Functionality:**
- ✅ Analyze button appears in grocery list toolbar
- ✅ Consolidation sheet shows merge preview
- ✅ Compatible quantities merge correctly
- ✅ Incompatible quantities stay separate
- ✅ Source tracking shows origin recipes
- ✅ Apply button executes merge
- ✅ Original items deleted, consolidated item created

**User Experience:**
- ✅ Clear preview of what will be consolidated
- ✅ Easy to understand merge summary
- ✅ Cancel preserves original items
- ✅ Apply executes merge and updates list
- ✅ Visual indicators for merged vs separate items

**Performance:**
- ✅ Analysis < 0.5s for lists with 50+ items
- ✅ Merge execution < 1s
- ✅ UI remains responsive during consolidation

### **What's Already Ready:**
- ✅ Structured quantity data in all grocery list items
- ✅ numericValue and standardUnit fields populated
- ✅ Recipe scaling service shows quantity manipulation patterns
- ✅ GroceryListDetailView ready for toolbar enhancement

### **After Phase 5:**
- **Phase 6**: UI polish and final M3 documentation (1 hour)
- **M3 Complete**: All 6 phases operational
- **M4 Ready**: Meal planning with enhanced grocery integration

**Current Progress**: M3 is 67% complete (4 of 6 phases). Phase 5 will bring us to 83% complete with intelligent shopping list consolidation operational.

**Please help me implement M3 Phase 5: Quantity Merge Service with intelligent consolidation, source tracking, and professional preview UI.**