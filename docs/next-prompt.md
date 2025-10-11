# M3 Phase 4: Recipe Scaling Service - Development Prompt

**Copy and paste this prompt when ready to continue M3 Phase 4:**

---

I'm ready to continue **M3 Phase 4: Recipe Scaling Service** for my Grocery & Recipe Manager iOS app.

## Current Status - M3 Phase 1-3 COMPLETE:

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

**Migration Results:**
```
✅ Successfully Parsed: 24 items with quantities
   "2 cups all-purpose flour" → 2.0 cup
   "1.5 lb ground beef" → 1.5 lb
   "3/4 teaspoon salt" → 0.75 tsp

📝 Text-Only (Correct): 8 staple items without quantities
   "Apples", "Milk 2%", "Bananas" (correctly preserved)
```

---

## M3 Phase 4: Recipe Scaling Service (2-3 hours)

### **Goal:**
Build mathematical recipe scaling service enabling users to scale recipes up or down for different serving sizes, with graceful handling of both parseable and unparseable quantities.

### **Current Foundation:**
- ✅ Structured quantity data model operational
- ✅ numericValue, standardUnit, isParseable fields populated
- ✅ IngredientParsingService with unit standardization ready
- ✅ All recipes and ingredients have structured quantities

### **Phase 4 Implementation Plan:**

#### **Step 1: RecipeScalingService (60-90 minutes)**

**Create New Service:**
```swift
// Services/RecipeScalingService.swift

import Foundation
import CoreData

class RecipeScalingService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Main scaling function
    func scale(recipe: Recipe, scaleFactor: Double) -> ScaledRecipe {
        var scaledIngredients: [ScaledIngredient] = []
        var autoScaledCount = 0
        var manualAdjustCount = 0
        
        for ingredient in recipe.ingredientsArray {
            if ingredient.isParseable, let value = ingredient.numericValue {
                // Scale parseable quantities mathematically
                let scaledValue = value * scaleFactor
                let displayText = formatScaled(
                    value: scaledValue,
                    unit: ingredient.standardUnit
                )
                
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient.name ?? "Unknown",
                    displayText: displayText,
                    wasScaled: true,
                    originalText: ingredient.displayText
                ))
                autoScaledCount += 1
            } else {
                // Keep unparseable with helpful note
                let adjustmentNote = "adjust to taste for \(formatServings(recipe.servings, scaleFactor)) servings"
                
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient.name ?? "Unknown",
                    displayText: "\(ingredient.displayText) (\(adjustmentNote))",
                    wasScaled: false,
                    originalText: ingredient.displayText
                ))
                manualAdjustCount += 1
            }
        }
        
        return ScaledRecipe(
            originalRecipe: recipe,
            scaleFactor: scaleFactor,
            scaledServings: Int(Double(recipe.servings) * scaleFactor),
            scaledIngredients: scaledIngredients,
            autoScaledCount: autoScaledCount,
            manualAdjustCount: manualAdjustCount
        )
    }
    
    // Format scaled values with kitchen-friendly fractions
    private func formatScaled(value: Double, unit: String?) -> String {
        let fractionString = formatToFraction(value)
        
        if let unit = unit, !unit.isEmpty {
            return "\(fractionString) \(unit)"
        } else {
            return fractionString
        }
    }
    
    // Convert decimal to fraction for kitchen-friendly display
    private func formatToFraction(_ value: Double) -> String {
        let whole = Int(value)
        let fractional = value - Double(whole)
        
        // Common fractions with tolerance
        let fractions: [(value: Double, display: String)] = [
            (0.125, "1/8"), (0.166, "1/6"), (0.25, "1/4"),
            (0.333, "1/3"), (0.375, "3/8"), (0.5, "1/2"),
            (0.625, "5/8"), (0.666, "2/3"), (0.75, "3/4"),
            (0.833, "5/6"), (0.875, "7/8")
        ]
        
        let tolerance = 0.05
        
        // Find matching fraction
        for (fValue, fDisplay) in fractions {
            if abs(fractional - fValue) < tolerance {
                if whole > 0 {
                    return "\(whole) \(fDisplay)"
                } else {
                    return fDisplay
                }
            }
        }
        
        // No close fraction match, use decimal
        if whole > 0 {
            return String(format: "%.1f", value)
        } else {
            return String(format: "%.2f", value)
        }
    }
    
    private func formatServings(_ servings: Int16, _ factor: Double) -> String {
        let scaled = Int(Double(servings) * factor)
        return "\(scaled)"
    }
}

// Data structures for scaled recipe
struct ScaledRecipe {
    let originalRecipe: Recipe
    let scaleFactor: Double
    let scaledServings: Int
    let scaledIngredients: [ScaledIngredient]
    let autoScaledCount: Int
    let manualAdjustCount: Int
    
    var summary: String {
        if manualAdjustCount == 0 {
            return "All \(autoScaledCount) ingredients auto-scaled"
        } else {
            return "\(autoScaledCount) ingredients auto-scaled, \(manualAdjustCount) require manual adjustment"
        }
    }
}

struct ScaledIngredient: Identifiable {
    let id = UUID()
    let name: String
    let displayText: String
    let wasScaled: Bool
    let originalText: String
}
```

#### **Step 2: Recipe Scaling UI (45-60 minutes)**

**Add to RecipeDetailView:**
```swift
// Add these state variables near other @State properties
@State private var showScalingSheet = false
@State private var scaleFactor: Double = 1.0
@State private var scaledRecipe: ScaledRecipe?

// Add scaling service
private let scalingService: RecipeScalingService

// Initialize service in init
init(recipe: Recipe) {
    self.recipe = recipe
    self.scalingService = RecipeScalingService(
        context: PersistenceController.shared.container.viewContext
    )
}

// Add "Scale Recipe" button to toolbar
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            // ... existing menu items ...
            
            Divider()
            
            Button {
                showScalingSheet = true
                scaleFactor = 1.0
            } label: {
                Label("Scale Recipe", systemImage: "slider.horizontal.3")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// Add scaling sheet
.sheet(isPresented: $showScalingSheet) {
    NavigationStack {
        RecipeScalingView(
            recipe: recipe,
            scalingService: scalingService
        )
    }
}
```

**Create RecipeScalingView:**
```swift
// Views/Recipe/RecipeScalingView.swift

import SwiftUI

struct RecipeScalingView: View {
    @Environment(\.dismiss) var dismiss
    let recipe: Recipe
    let scalingService: RecipeScalingService
    
    @State private var scaleFactor: Double = 1.0
    @State private var scaledRecipe: ScaledRecipe?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with current servings
            VStack(spacing: 12) {
                Text("Scale Recipe")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 16) {
                    VStack {
                        Text("Original")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(recipe.servings)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("servings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Text("Scaled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(scaledServings)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        Text("servings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Scale factor slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Scale Factor: \(scaleFactor, specifier: "%.2f")x")
                    .font(.headline)
                
                Slider(value: $scaleFactor, in: 0.25...4.0, step: 0.25)
                    .onChange(of: scaleFactor) { _, _ in
                        updateScaledRecipe()
                    }
                
                HStack {
                    Text("0.25x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("4x")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Quick scale buttons
            HStack(spacing: 12) {
                ForEach([0.5, 1.0, 1.5, 2.0], id: \.self) { factor in
                    Button {
                        scaleFactor = factor
                    } label: {
                        Text("\(factor, specifier: "%.1f")x")
                            .font(.subheadline)
                            .fontWeight(scaleFactor == factor ? .semibold : .regular)
                            .foregroundColor(scaleFactor == factor ? .white : .accentColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scaleFactor == factor ? Color.accentColor : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            // Scaled ingredients preview
            if let scaled = scaledRecipe {
                List {
                    Section {
                        Text(scaled.summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Section("Scaled Ingredients") {
                        ForEach(scaled.scaledIngredients) { ingredient in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: ingredient.wasScaled ? "checkmark.circle.fill" : "info.circle")
                                    .foregroundColor(ingredient.wasScaled ? .green : .orange)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ingredient.name)
                                        .font(.body)
                                    
                                    Text(ingredient.displayText)
                                        .font(.subheadline)
                                        .foregroundColor(ingredient.wasScaled ? .primary : .secondary)
                                    
                                    if !ingredient.wasScaled {
                                        Text("Original: \(ingredient.originalText)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // For Phase 4, just dismiss
                    // In future, could save scaled version
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            updateScaledRecipe()
        }
    }
    
    private var scaledServings: Int {
        Int(Double(recipe.servings) * scaleFactor)
    }
    
    private func updateScaledRecipe() {
        scaledRecipe = scalingService.scale(recipe: recipe, scaleFactor: scaleFactor)
    }
}
```

#### **Step 3: Testing & Validation (15-30 minutes)**

**Test Scenarios:**
1. **Scale Up (2x)**:
   - "2 cups flour" → "4 cups flour"
   - "1.5 lb beef" → "3 lbs beef"
   - "Salt to taste" → "Salt to taste (adjust for 8 servings)"

2. **Scale Down (0.5x)**:
   - "4 cups water" → "2 cups water"
   - "2 tablespoons oil" → "1 tablespoon oil"

3. **Fractional Scaling (1.5x)**:
   - "2 cups flour" → "3 cups flour"
   - "1 cup milk" → "1 1/2 cups milk"
   - "2/3 cup sugar" → "1 cup sugar"

4. **Edge Cases**:
   - Very small quantities (0.25x)
   - Large scaling (3x, 4x)
   - Mixed parseable/unparseable ingredients

**Performance Validation:**
- Scaling operation < 0.5s for 20+ ingredient recipes
- UI responsive during calculations
- Fraction formatting displays correctly

### **Success Criteria:**

**Functionality:**
- ✅ Scale button appears in recipe detail toolbar
- ✅ Scaling sheet opens with current servings display
- ✅ Slider and quick buttons adjust scale factor
- ✅ Live preview updates as slider moves
- ✅ Parseable quantities scale mathematically
- ✅ Unparseable quantities show adjustment note
- ✅ Summary shows auto-scaled vs manual count
- ✅ Kitchen-friendly fractions display correctly

**User Experience:**
- ✅ Intuitive scaling interface
- ✅ Clear visual indicators (checkmark = auto-scaled, info = manual)
- ✅ Helpful adjustment notes for unparseable quantities
- ✅ Original quantities visible for comparison
- ✅ Quick scale buttons for common factors (0.5x, 1x, 1.5x, 2x)

**Performance:**
- ✅ Scaling calculations < 0.5s
- ✅ UI remains responsive during preview updates
- ✅ Smooth slider interaction

### **What's Already Ready:**
- ✅ Structured quantity data model
- ✅ numericValue, standardUnit, isParseable fields populated
- ✅ All recipes migrated to structured format
- ✅ IngredientParsingService with unit standardization
- ✅ Recipe detail view architecture ready for enhancement

### **After Phase 4:**
- **Phase 5**: Quantity Merge Service for shopping list consolidation (2-3 hours)
- **Phase 6**: UI polish and final documentation (1 hour)
- **M3 Complete**: Recipe scaling, migration, foundation for analytics

**Current Progress**: M3 is 50% complete (3 of 6 phases). Phase 4 will bring us to 67% complete with recipe scaling operational.

**Please help me implement M3 Phase 4: Recipe Scaling Service with mathematical quantity scaling, kitchen-friendly fraction display, and professional scaling UI.**