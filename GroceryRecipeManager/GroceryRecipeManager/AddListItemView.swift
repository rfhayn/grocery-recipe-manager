import SwiftUI
import CoreData

struct AddListItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let weeklyList: WeeklyList
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    @State private var ingredientText = ""
    @State private var selectedCategory = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var isFormValid: Bool {
        !ingredientText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $ingredientText)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    Text("Enter with quantity (e.g., \"2 cups flour\") or just the item name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Category")) {
                    if !categories.isEmpty {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.displayName) { category in
                                // FIXED: Show both emoji and text
                                Text("\(categoryEmoji(for: category.displayName)) \(category.displayName)")
                                    .tag(category.displayName)
                            }
                        }
                        .pickerStyle(.menu)
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
                
                Section {
                    Text("Items added manually will be marked as 'Added' items.")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if selectedCategory.isEmpty, let firstCategory = categories.first {
                    selectedCategory = firstCategory.displayName
                }
            }
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
        let trimmedText = ingredientText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let templateService = IngredientTemplateService(context: viewContext)
        let parsingService = IngredientParsingService(
            context: viewContext,
            templateService: templateService
        )
        
        let parsed = parsingService.parseIngredient(text: trimmedText)
        let structured = parsingService.parseToStructured(text: trimmedText)
        
        let listItem = GroceryListItem(context: viewContext)
        listItem.id = UUID()
        listItem.name = parsed.displayName
        listItem.displayText = structured.displayText
        listItem.numericValue = structured.numericValue ?? 0.0
        listItem.standardUnit = structured.standardUnit
        listItem.isParseable = structured.isParseable
        listItem.parseConfidence = structured.parseConfidence
        listItem.categoryName = selectedCategory
        listItem.source = "manual"
        listItem.isCompleted = false
        listItem.weeklyList = weeklyList
        listItem.sortOrder = Int16(weeklyList.items?.count ?? 0)
        
        do {
            try viewContext.save()
            print("✅ Added item: \(parsed.displayName)")
            dismiss()
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleList = WeeklyList(context: context)
    sampleList.id = UUID()
    sampleList.name = "Sample List"
    sampleList.dateCreated = Date()
    sampleList.isCompleted = false
    
    return AddListItemView(weeklyList: sampleList)
        .environment(\.managedObjectContext, context)
}
