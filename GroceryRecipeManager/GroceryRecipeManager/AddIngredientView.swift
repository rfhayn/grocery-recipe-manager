// AddIngredientView.swift
// STEP 4 PHASE 2: Unified ingredient creation replacing AddStapleView
// Creates IngredientTemplate entities with optional staple designation

import SwiftUI
import CoreData

struct AddIngredientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory = "Produce"
    @State private var isStaple = false
    @State private var notes = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingDuplicateAlert = false
    @State private var existingIngredient: IngredientTemplate?
    
    // MARK: - Categories
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    private var isValidForm: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Ingredient name", text: $name)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.displayColor))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Text(categoryEmoji(for: category.displayName))
                                            .font(.system(size: 12))
                                    )
                                
                                Text(category.displayName)
                            }
                            .tag(category.displayName)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Options")) {
                    Toggle("Mark as Staple", isOn: $isStaple)
                    
                    if isStaple {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("This ingredient will be available for quick addition to grocery lists")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextField("Additional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                if !name.isEmpty {
                    Section(header: Text("Preview")) {
                        IngredientPreviewRow(
                            name: name,
                            category: selectedCategory,
                            isStaple: isStaple,
                            categoryColor: findCategory(named: selectedCategory)?.displayColor ?? "#9E9E9E"
                        )
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button("Save") {
                            saveIngredient()
                        }
                        .disabled(!isValidForm)
                    }
                }
            }
            .alert("Duplicate Ingredient", isPresented: $showingDuplicateAlert) {
                Button("Cancel", role: .cancel) { }
                
                if let existing = existingIngredient {
                    if existing.isStaple {
                        Button("Edit Existing") {
                            editExistingIngredient(existing)
                        }
                    } else {
                        Button("Convert to Staple") {
                            convertToStaple(existing)
                        }
                    }
                }
                
                Button("Create Anyway") {
                    createNewIngredient(allowDuplicate: true)
                }
            } message: {
                if let existing = existingIngredient {
                    if existing.isStaple {
                        Text("An ingredient named '\(name)' already exists as a staple. Would you like to edit the existing ingredient instead?")
                    } else {
                        Text("An ingredient named '\(name)' already exists. Would you like to convert it to a staple?")
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
        .onAppear {
            // Set default category to first available
            if let firstCategory = categories.first {
                selectedCategory = firstCategory.displayName
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveIngredient() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter an ingredient name"
            showingError = true
            return
        }
        
        // Check for existing ingredient using Core Data directly
        if let existing = findExistingIngredientTemplate(named: trimmedName) {
            existingIngredient = existing
            showingDuplicateAlert = true
            return
        }
        
        createNewIngredient(allowDuplicate: false)
    }
    
    private func createNewIngredient(allowDuplicate: Bool) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        isLoading = true
        
        PersistenceController.shared.performWrite({ context in
            // Create new ingredient template
            let newTemplate = IngredientTemplate(context: context)
            newTemplate.id = UUID()
            newTemplate.name = trimmedName
            newTemplate.category = selectedCategory
            newTemplate.isStaple = isStaple
            newTemplate.usageCount = 0
            
            // Set initial usage count for staples
            if isStaple {
                newTemplate.usageCount = 1
            }
            
            print("✅ Created new ingredient template: \(trimmedName)")
            print("   Category: \(selectedCategory)")
            print("   Staple: \(isStaple)")
            
        }, onError: { error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to save ingredient: \(error.localizedDescription)"
                self.showingError = true
            }
        })
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.dismiss()
        }
    }
    
    private func convertToStaple(_ template: IngredientTemplate) {
        let templateID = template.objectID
        isLoading = true
        
        PersistenceController.shared.performWrite({ context in
            let templateInContext = context.object(with: templateID) as! IngredientTemplate
            templateInContext.isStaple = true
            templateInContext.category = selectedCategory // Update to selected category
            templateInContext.usageCount += 1 // Increment usage
            
            print("✅ Converted '\(templateInContext.name ?? "Unknown")' to staple in \(selectedCategory)")
            
        }, onError: { error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to convert to staple: \(error.localizedDescription)"
                self.showingError = true
            }
        })
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.dismiss()
        }
    }
    
    private func editExistingIngredient(_ template: IngredientTemplate) {
        // For now, dismiss and let user find it in IngredientsView
        // Future enhancement: could navigate directly to edit view
        dismiss()
        
        print("ℹ️ User should edit existing ingredient: \(template.name ?? "Unknown")")
    }
    
    // MARK: - Helper Methods
    
    private func findCategory(named name: String) -> Category? {
        return categories.first { $0.displayName == name }
    }
    
    private func findExistingIngredientTemplate(named name: String) -> IngredientTemplate? {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error searching for existing ingredient: \(error)")
            return nil
        }
    }
    
    private func categoryEmoji(for categoryName: String) -> String {
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

// MARK: - Preview Component

struct IngredientPreviewRow: View {
    let name: String
    let category: String
    let isStaple: Bool
    let categoryColor: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: categoryColor))
                .frame(width: 20, height: 20)
                .overlay(
                    Text(categoryEmoji(for: category))
                        .font(.system(size: 12))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if isStaple {
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
                
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func categoryEmoji(for categoryName: String) -> String {
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

// MARK: - Preview

#Preview {
    AddIngredientView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
