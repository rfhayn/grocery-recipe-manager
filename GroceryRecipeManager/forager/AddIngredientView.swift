// AddIngredientView.swift
// Standalone component for adding new ingredients

import SwiftUI
import CoreData

struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var selectedCategory = "Uncategorized"
    @State private var isStaple = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingredient Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("Uncategorized").tag("Uncategorized")
                        ForEach(categories, id: \.objectID) { category in
                            Text(category.displayName).tag(category.displayName)
                        }
                    }
                    
                    Toggle("Is Staple", isOn: $isStaple)
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
                    Button("Save") {
                        saveIngredient()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveIngredient() {
        let ingredient = IngredientTemplate(context: viewContext)
        ingredient.id = UUID()
        ingredient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.category = selectedCategory == "Uncategorized" ? nil : selectedCategory
        ingredient.isStaple = isStaple
        ingredient.dateCreated = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving ingredient: \(error)")
        }
    }
}
