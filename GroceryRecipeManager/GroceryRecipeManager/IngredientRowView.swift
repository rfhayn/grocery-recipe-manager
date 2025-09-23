// IngredientRowView.swift
// Clean version without conflicts

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
        let categoryName = ingredient.category ?? "Uncategorized"
        switch categoryName.lowercased() {
        case "produce": return .green
        case "deli & meat": return .red
        case "dairy & fridge": return .blue
        case "bread & frozen": return .orange
        case "boxed & canned": return .brown
        case "snacks, drinks, & other": return .purple
        default: return .gray
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
            
            // Main content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ingredient.name ?? "Unknown Ingredient")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if ingredient.usageCount > 0 {
                        Text("\(ingredient.usageCount)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action buttons
            if !isEditMode {
                HStack(spacing: 12) {
                    Button(action: onCategoryAssign) {
                        Image(systemName: "folder")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onStapleToggle) {
                        Image(systemName: ingredient.isStaple ? "pin.fill" : "pin")
                            .font(.title3)
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
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        IngredientRowView(
            ingredient: {
                let template = IngredientTemplate(context: PersistenceController.preview.container.viewContext)
                template.name = "Test Ingredient"
                template.category = "Produce"
                template.isStaple = true
                template.usageCount = 5
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
