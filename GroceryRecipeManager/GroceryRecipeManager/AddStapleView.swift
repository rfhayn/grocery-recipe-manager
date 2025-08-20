import SwiftUI
import CoreData

struct AddStapleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Form state
    @State private var name = ""
    @State private var selectedCategory = "Produce"
    @State private var lastPurchased: Date? = nil
    @State private var includeLastPurchased = false
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Predefined grocery categories
    private let groceryCategories = [
        "Produce", "Dairy", "Bakery", "Meat", "Pantry",
        "Beverages", "Snacks", "Frozen", "Personal Care", "Household"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Staple Information")) {
                    TextField("Staple Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(groceryCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Purchase History")) {
                    Toggle("Include Last Purchased Date", isOn: $includeLastPurchased)
                    
                    if includeLastPurchased {
                        DatePicker("Last Purchased",
                                 selection: Binding(
                                    get: { lastPurchased ?? Date() },
                                    set: { lastPurchased = $0 }
                                 ),
                                 displayedComponents: .date)
                    }
                }
                
                Section {
                    Button("Save Staple") {
                        saveStaple()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Staple")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveStaple() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicate names
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", trimmedName)
        
        do {
            let existingItems = try viewContext.fetch(request)
            if !existingItems.isEmpty {
                errorMessage = "A staple with this name already exists"
                showingError = true
                return
            }
        } catch {
            errorMessage = "Failed to check for duplicates: \(error.localizedDescription)"
            showingError = true
            return
        }
        
        // Save using background context
        PersistenceController.shared.performWrite({ context in
            let newStaple = GroceryItem(context: context)
            newStaple.id = UUID()
            newStaple.name = trimmedName
            newStaple.category = selectedCategory
            newStaple.isStaple = true
            newStaple.dateCreated = Date()
            
            if includeLastPurchased {
                newStaple.lastPurchased = lastPurchased
            }
            
            print("✅ Created new staple: \(trimmedName) in \(selectedCategory)")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to save staple: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        // Dismiss on successful save
        dismiss()
    }
}

#Preview {
    AddStapleView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}//
//  AddStapleView.swift
//  GroceryRecipeManager
//
//  Created by Richard Hayn on 8/20/25.
//

