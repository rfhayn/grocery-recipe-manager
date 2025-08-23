import SwiftUI
import CoreData

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = "#4CAF50"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private let availableColors = [
        "#4CAF50", // Green
        "#F44336", // Red
        "#2196F3", // Blue
        "#FF9800", // Orange
        "#795548", // Brown
        "#9C27B0", // Purple
        "#E91E63", // Pink
        "#00BCD4", // Cyan
        "#FFC107", // Amber
        "#607D8B"  // Blue Grey
    ]
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("Add Category") {
                        saveCategory()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("New Category")
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
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", trimmedName)
        
        do {
            let existingCategories = try viewContext.fetch(request)
            if !existingCategories.isEmpty {
                errorMessage = "A category with this name already exists."
                showingError = true
                return
            }
        } catch {
            errorMessage = "Failed to check for existing categories: \(error.localizedDescription)"
            showingError = true
            return
        }
        
        // Create new category
        PersistenceController.shared.performWrite({ context in
            let newCategory = Category(context: context)
            newCategory.id = UUID()
            newCategory.name = trimmedName
            newCategory.color = selectedColor
            newCategory.isDefault = false
            newCategory.dateCreated = Date()
            
            // Get next sort order (add to end)
            let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
            let maxSortOrder = (try? context.fetch(categoryRequest).map(\.sortOrder).max()) ?? 5
            newCategory.sortOrder = maxSortOrder + 1
            
            print("✅ Created new category: \(trimmedName)")
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to save category: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
