// CategoryChangeModal.swift
// SIMPLIFIED: Copy the exact working pattern from CategoryAssignmentModal

import SwiftUI
import CoreData

struct CategoryChangeModal: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Data
    let ingredientTemplates: [IngredientTemplate]
    let onAssignmentsComplete: () -> Void
    
    // State - EXACT SAME as CategoryAssignmentModal
    @State private var categoryAssignments: [UUID: String?] = [:]
    @State private var showingAddCategory = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Fetch existing categories
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    // Filter out "Uncategorized" from assignment options
    private var realCategories: [Category] {
        categories.filter { $0.displayName.lowercased() != "uncategorized" }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Ingredient Assignment List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(ingredientTemplates, id: \.objectID) { template in
                            IngredientCategoryChangeRow(
                                template: template,
                                categories: realCategories,
                                selectedCategoryName: categoryAssignments[template.id ?? UUID()] ?? nil,
                                onCategorySelected: { categoryName in
                                    categoryAssignments[template.id ?? UUID()] = categoryName
                                }
                            )
                        }
                        
                        // Add New Category Option
                        addNewCategoryButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
                
                // Action Buttons
                actionButtons
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
                .environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            // SIMPLIFIED: Use the exact same initialization as CategoryAssignmentModal
            initializeAssignments()
        }
        .alert("Change Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // EXACT COPY from CategoryAssignmentModal - but initialize with current category instead of nil
    private func initializeAssignments() {
        for template in ingredientTemplates {
            let templateId = template.id ?? UUID()
            // Initialize with current category instead of nil
            categoryAssignments[templateId] = template.category ?? "Uncategorized"
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Change Category")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            
            Text("Reassign ingredient category.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private var addNewCategoryButton: some View {
        Button(action: {
            showingAddCategory = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Category")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    Text("Create a custom category for these ingredients")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, 8)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Change Categories Button
            Button(action: changeCategories) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text(isLoading ? "Changing..." : "Change Categories")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading)
            
            // Cancel Button
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "xmark")
                    Text("Cancel")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            .disabled(isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    // COPY the exact logic from CategoryAssignmentModal
    private func changeCategories() {
        isLoading = true
        errorMessage = nil
        
        // Update categories for templates
        for template in ingredientTemplates {
            guard let templateID = template.id else { continue }
            
            // Apply selected category
            if let selectedCategoryName = categoryAssignments[templateID] {
                if let categoryName = selectedCategoryName,
                   !categoryName.isEmpty {
                    template.category = categoryName
                } else {
                    template.category = "Uncategorized"
                }
            }
        }
        
        // Save changes
        do {
            try viewContext.save()
            DispatchQueue.main.async {
                self.isLoading = false
                self.onAssignmentsComplete()
                self.dismiss()
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to change categories: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Ingredient Category Change Row - SIMPLIFIED
struct IngredientCategoryChangeRow: View {
    let template: IngredientTemplate
    let categories: [Category]
    let selectedCategoryName: String?
    let onCategorySelected: (String?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ingredient Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name ?? "Unknown ingredient")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Current Category Display - Show what's currently selected
                if let currentCategory = selectedCategoryName,
                   !currentCategory.isEmpty,
                   currentCategory.lowercased() != "uncategorized" {
                    HStack(spacing: 8) {
                        let category = categories.first { $0.name == currentCategory }
                        Circle()
                            .fill(colorFromHex(category?.color ?? "#4CAF50"))
                            .frame(width: 16, height: 16)
                        Text(currentCategory)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                } else {
                    Text("Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Category Selection Button - EXACT SAME logic as CategoryAssignmentModal
            NavigationLink(destination: CategorySelectionViewForChange(
                categories: categories,
                selectedCategoryName: selectedCategoryName,
                onCategorySelected: onCategorySelected
            )) {
                HStack {
                    if let categoryName = selectedCategoryName,
                       !categoryName.isEmpty,
                       categoryName.lowercased() != "uncategorized" {
                        HStack(spacing: 8) {
                            let category = categories.first { $0.name == categoryName }
                            Circle()
                                .fill(colorFromHex(category?.color ?? "#4CAF50"))
                                .frame(width: 16, height: 16)
                            Text(categoryName)
                                .foregroundColor(.primary)
                        }
                    } else {
                        Text("Choose Category")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // Helper function for color conversion
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Category Selection View for Change (unchanged)
struct CategorySelectionViewForChange: View {
    let categories: [Category]
    let selectedCategoryName: String?
    let onCategorySelected: (String?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(categories, id: \.objectID) { category in
                CategorySelectionRowForChange(
                    category: category,
                    isSelected: selectedCategoryName == category.name,
                    onTap: {
                        onCategorySelected(category.name)
                        dismiss()
                    }
                )
            }
            
            // Option to move to uncategorized
            Button("Move to Uncategorized") {
                onCategorySelected("Uncategorized")
                dismiss()
            }
            .foregroundColor(.secondary)
        }
        .navigationTitle("Select Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Category Selection Row for Change (unchanged)
struct CategorySelectionRowForChange: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category color and name
                Circle()
                    .fill(colorFromHex(category.color ?? "#4CAF50"))
                    .frame(width: 24, height: 24)
                
                Text(category.name ?? "Unknown")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper function for color conversion
    private func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
