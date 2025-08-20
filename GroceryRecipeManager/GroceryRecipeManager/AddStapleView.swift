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
    
    // Smart duplicate handling
    @State private var showingConvertAlert = false
    @State private var showingEditAlert = false
    @State private var existingItem: GroceryItem?
    
    // Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Predefined grocery categories
    private let groceryCategories = [
        "Produce",
        "Deli & Meat",
        "Dairy & Fridge",
        "Bread & Frozen",
        "Boxed & Canned",
        "Snacks, Drinks, & Other"
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
            .alert("Convert to Staple?", isPresented: $showingConvertAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Convert") {
                    if let item = existingItem {
                        convertToStaple(item)
                    }
                }
            } message: {
                if let item = existingItem {
                    Text("'\(item.name ?? "Unknown")' already exists but isn't a staple. Convert it to a staple in '\(selectedCategory)' category?")
                }
            }
            .alert("Already a Staple", isPresented: $showingEditAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Edit Existing") {
                    if let item = existingItem {
                        editExistingStaple(item)
                    }
                }
            } message: {
                if let item = existingItem {
                    Text("'\(item.name ?? "Unknown")' is already a staple in '\(item.category ?? "Unknown")' category. Would you like to edit it instead?")
                }
            }
        }
    }
    
    private func saveStaple() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for existing items (any item with this name)
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", trimmedName)
        
        do {
            let existingItems = try viewContext.fetch(request)
            
            if let existingItem = existingItems.first {
                self.existingItem = existingItem
                
                if existingItem.isStaple {
                    // Already a staple - offer to edit
                    showingEditAlert = true
                } else {
                    // Not a staple - offer to convert
                    showingConvertAlert = true
                }
            } else {
                // No existing item - create new staple
                createNewStaple(trimmedName)
            }
        } catch {
            errorMessage = "Failed to check for existing items: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func createNewStaple(_ name: String) {
        PersistenceController.shared.performWrite({ context in
            let newStaple = GroceryItem(context: context)
            newStaple.id = UUID()
            newStaple.name = name
            newStaple.category = selectedCategory
            newStaple.isStaple = true
            newStaple.dateCreated = Date()
            
            if includeLastPurchased {
                newStaple.lastPurchased = lastPurchased
            }
            
            print("✅ Created new staple: \(name) in \(selectedCategory)")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to save staple: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        dismiss()
    }
    
    private func convertToStaple(_ item: GroceryItem) {
        let itemID = item.objectID
        PersistenceController.shared.performWrite({ context in
            let itemToUpdate = context.object(with: itemID) as! GroceryItem
            itemToUpdate.isStaple = true
            itemToUpdate.category = selectedCategory // Update to selected category
            
            if includeLastPurchased {
                itemToUpdate.lastPurchased = lastPurchased
            }
            
            print("✅ Converted '\(itemToUpdate.name ?? "Unknown")' to staple in \(selectedCategory)")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to convert item to staple: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        dismiss()
    }
    
    private func editExistingStaple(_ item: GroceryItem) {
        // For now, just dismiss and let user find it in StaplesView
        // Later you could navigate directly to EditStapleView
        dismiss()
        
        // TODO: Could implement navigation to edit the existing staple
        print("ℹ️ User should edit existing staple: \(item.name ?? "Unknown")")
    }
}

#Preview {
    AddStapleView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
