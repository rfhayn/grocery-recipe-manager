import SwiftUI
import CoreData

struct AddListItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let weeklyList: WeeklyList
    
    // Dynamic categories fetch (sorted by custom order)
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // Form state
    @State private var name = ""
    @State private var quantity = "1"
    @State private var selectedCategory = ""
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Quantity", text: $quantity)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Category")) {
                    if !categories.isEmpty {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.displayName) { category in
                                Text("\(categoryEmoji(for: category.displayName)) \(category.displayName)")
                                    .tag(category.displayName)
                            }
                        }
                    } else {
                        Text("Loading categories...")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Add to List") {
                        addItemToList()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
                
                Section(footer: Text("Items added manually will be marked as 'Added' items.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setDefaultCategory()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setDefaultCategory() {
        if selectedCategory.isEmpty && !categories.isEmpty {
            selectedCategory = categories.first?.displayName ?? "Produce"
        }
    }
    
    private func categoryEmoji(for categoryName: String) -> String {
        switch categoryName {
        case "Produce": return "🥬"
        case "Deli & Meat": return "🥩"
        case "Dairy & Fridge": return "🥛"
        case "Bread & Frozen": return "🍞"
        case "Boxed & Canned": return "📦"
        case "Snacks, Drinks, & Other": return "🥤"
        default: return "📋"
        }
    }
    
    private func addItemToList() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQuantity = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let listID = weeklyList.objectID
        PersistenceController.shared.performWrite({ context in
            // Get the weekly list in the background context
            let listInContext = context.object(with: listID) as! WeeklyList
            
            // Get current max sort order
            let existingItems = listInContext.items as? Set<GroceryListItem> ?? []
            let maxSortOrder = existingItems.map { $0.sortOrder }.max() ?? -1
            
            // Create new item
            let newItem = GroceryListItem(context: context)
            newItem.id = UUID()
            newItem.name = trimmedName
            
            // M3: Use structured quantity fields
            newItem.displayText = trimmedQuantity.isEmpty ? "1" : trimmedQuantity
            newItem.numericValue = 0.0  // Manual entry - will be properly parsed in Phase 3
            newItem.isParseable = false  // Not parsed yet
            newItem.parseConfidence = 0.0
            
            newItem.isCompleted = false
            newItem.source = "manual"
            newItem.sortOrder = maxSortOrder + 1
            newItem.categoryName = selectedCategory
            
            // Add to the weekly list
            listInContext.addToItems(newItem)
            
            print("✅ Added manual item: \(trimmedName) to list \(listInContext.name ?? "Unknown")")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to add item: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        dismiss()
    }
}

#Preview {
    // Create sample data for preview
    let context = PersistenceController.preview.container.viewContext
    
    let sampleList = WeeklyList(context: context)
    sampleList.id = UUID()
    sampleList.name = "Sample List"
    sampleList.dateCreated = Date()
    
    return AddListItemView(weeklyList: sampleList)
        .environment(\.managedObjectContext, context)
}
