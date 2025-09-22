// IngredientRowView.swift
// STEP 4 PHASE 2: Professional ingredient row component with comprehensive functionality
// Displays ingredient info with staple status, category, usage, and interaction options

import SwiftUI
import CoreData

struct IngredientRowView: View {
    let ingredient: IngredientTemplate
    let isSelected: Bool
    let isEditMode: Bool
    let onSelectionChanged: (Bool) -> Void
    let onStapleToggle: () -> Void
    let onCategoryAssign: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var categoryColor: Color {
        // Get category color based on ingredient's category
        let categoryName = ingredient.category ?? "Uncategorized"
        switch categoryName.lowercased() {
        case "produce": return Color(hex: "#4CAF50") // Green
        case "deli & meat": return Color(hex: "#F44336") // Red
        case "dairy & fridge": return Color(hex: "#2196F3") // Blue
        case "bread & frozen": return Color(hex: "#FF9800") // Orange
        case "boxed & canned": return Color(hex: "#795548") // Brown
        case "snacks, drinks, & other": return Color(hex: "#9C27B0") // Purple
        default: return Color.gray
        }
    }
    
    private var usageFrequency: UsageFrequency {
        switch ingredient.usageCount {
        case 0: return .none
        case 1...3: return .low
        case 4...10: return .medium
        default: return .high
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator (edit mode)
            if isEditMode {
                Button(action: { onSelectionChanged(!isSelected) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Category indicator
            Circle()
                .fill(categoryColor)
                .frame(width: 20, height: 20)
                .overlay(
                    Text(categoryEmoji)
                        .font(.system(size: 12))
                )
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Ingredient name
                    Text(ingredient.name ?? "Unknown Ingredient")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Staple badge
                    if ingredient.isStaple {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Staple")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                
                // Category and usage info
                HStack {
                    Text(ingredient.category ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if ingredient.usageCount > 0 {
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption2)
                            Text("Used \(ingredient.usageCount) times")
                                .font(.caption2)
                            
                            // Usage frequency indicator
                            Circle()
                                .fill(usageFrequency.color)
                                .frame(width: 6, height: 6)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action buttons (non-edit mode)
            if !isEditMode {
                HStack(spacing: 8) {
                    // Category assignment button
                    Button(action: onCategoryAssign) {
                        Image(systemName: "folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Staple toggle button
                    Button(action: onStapleToggle) {
                        Image(systemName: ingredient.isStaple ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(ingredient.isStaple ? .blue : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
    
    private var categoryEmoji: String {
        let categoryName = ingredient.category ?? "Uncategorized"
        switch categoryName.lowercased() {
        case "produce": return "🥬"
        case "deli & meat": return "🥩"
        case "dairy & fridge": return "🥛"
        case "bread & frozen": return "🍞"
        case "boxed & canned": return "📦"
        case "snacks, drinks, & other": return "🥤"
        default: return "📦"
        }
    }
}

// MARK: - Usage Frequency

enum UsageFrequency {
    case none, low, medium, high
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .green
        }
    }
    
    var description: String {
        switch self {
        case .none: return "Unused"
        case .low: return "Low Usage"
        case .medium: return "Medium Usage"
        case .high: return "High Usage"
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        // Staple ingredient
        IngredientRowView(
            ingredient: {
                let template = IngredientTemplate(context: PersistenceController.preview.container.viewContext)
                template.name = "Milk"
                template.category = "Dairy & Fridge"
                template.isStaple = true
                template.usageCount = 15
                return template
            }(),
            isSelected: false,
            isEditMode: false,
            onSelectionChanged: { _ in },
            onStapleToggle: { },
            onCategoryAssign: { }
        )
        
        // Regular ingredient
        IngredientRowView(
            ingredient: {
                let template = IngredientTemplate(context: PersistenceController.preview.container.viewContext)
                template.name = "Basil"
                template.category = "Produce"
                template.isStaple = false
                template.usageCount = 3
                return template
            }(),
            isSelected: true,
            isEditMode: true,
            onSelectionChanged: { _ in },
            onStapleToggle: { },
            onCategoryAssign: { }
        )
        
        // Uncategorized ingredient
        IngredientRowView(
            ingredient: {
                let template = IngredientTemplate(context: PersistenceController.preview.container.viewContext)
                template.name = "Special Sauce"
                template.category = nil
                template.isStaple = false
                template.usageCount = 0
                return template
            }(),
            isSelected: false,
            isEditMode: false,
            onSelectionChanged: { _ in },
            onStapleToggle: { },
            onCategoryAssign: { }
        )
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
