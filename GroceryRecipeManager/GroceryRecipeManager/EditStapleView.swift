import SwiftUI
import CoreData

struct EditStapleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // The staple item being edited
    let staple: GroceryItem
    
    // Form state - initialized from existing staple
    @State private var name: String
    @State private var selectedCategory: String
    @State private var lastPurchased: Date?
    @State private var includeLastPurchased: Bool
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Check if form has changes
    private var hasChanges: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName != (staple.name ?? "") ||
               selectedCategory != (staple.category ?? "") ||
               lastPurchased != staple.lastPurchased ||
               includeLastPurchased != (staple.lastPurchased != nil)
    }
    
    // Predefined grocery categories (matches your updated categories)
    private let groceryCategories = [
        "Produce",
        "Deli & Meat",
        "Dairy & Fridge",
        "Bread & Frozen",
        "Boxed & Canned",
        "Snacks, Drinks, & Other"
    ]
    
    // Initialize form state from existing staple
    init(staple: GroceryItem) {
        self.staple = staple
        // Ensure we have valid data or provide defaults
        self._name = State(initialValue: staple.name ?? "")
        self._selectedCategory = State(initialValue: staple.category ?? "Produce")
        self._lastPurchased = State(initialValue: staple.lastPurchased)
        self._includeLastPurchased = State(initialValue: staple.lastPurchased != nil)
        
        // Debug logging to see what data we're getting
        print("📝 EditStapleView init - Name: \(staple.name ?? "nil"), Category: \(staple.category ?? "nil")")
    }
    
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
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid || !hasChanges)
                }
                
                if !hasChanges {
                    Section {
                        Text("No changes to save")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Edit Staple")
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
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicate names (exclude current staple)
        let request: NSFetchRequest<GroceryItem> = GroceryItem.fetchRequest()
        if let stapleID = staple.id {
            request.predicate = NSPredicate(format: "name ==[c] %@ AND id != %@", trimmedName, stapleID as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "name ==[c] %@", trimmedName)
        }
        
        do {
            let existingItems = try viewContext.fetch(request)
            if !existingItems.isEmpty {
                let existingItem = existingItems.first!
                errorMessage = "A staple with this name already exists in '\(existingItem.category ?? "Unknown")' category. IsStaple: \(existingItem.isStaple)"
                showingError = true
                return
            }
        } catch {
            errorMessage = "Failed to check for duplicates: \(error.localizedDescription)"
            showingError = true
            return
        }
        
        // Save using background context
        let stapleID = staple.objectID
        PersistenceController.shared.performWrite({ context in
            // Get the staple in the background context
            let stapleToUpdate = context.object(with: stapleID) as! GroceryItem
            
            // Update the staple properties
            stapleToUpdate.name = trimmedName
            stapleToUpdate.category = selectedCategory
            
            if includeLastPurchased {
                stapleToUpdate.lastPurchased = lastPurchased
            } else {
                stapleToUpdate.lastPurchased = nil
            }
            
            print("✅ Updated staple: \(trimmedName) in \(selectedCategory)")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to save changes: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        // Dismiss on successful save
        dismiss()
    }
}

#Preview {
    // Create a sample staple for preview
    let context = PersistenceController.preview.container.viewContext
    let sampleStaple = GroceryItem(context: context)
    sampleStaple.id = UUID()
    sampleStaple.name = "Sample Staple"
    sampleStaple.category = "Produce"
    sampleStaple.isStaple = true
    sampleStaple.dateCreated = Date()
    sampleStaple.lastPurchased = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days ago
    
    return EditStapleView(staple: sampleStaple)
        .environment(\.managedObjectContext, context)
}
