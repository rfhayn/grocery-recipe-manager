import SwiftUI
import CoreData

struct ManageCategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Fetch categories sorted by current order
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // State management
    @State private var isReordering = false
    @State private var showingAddCategory = false
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    @State private var isLoading = false
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                categoriesListSection
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Delete '\(category.displayName)'? Items in this category will be moved to 'Uncategorized'.")
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Drag to Reorder Categories")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Arrange categories to match your store layout")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Reset to Default") {
                    resetToDefaultOrder()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    private var categoriesListSection: some View {
        List {
            ForEach(Array(categories.enumerated()), id: \.element) { index, category in
                CategoryRowView(
                    category: category,
                    position: index + 1,
                    onDelete: { deleteCategory(category) }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onMove(perform: moveCategories)
            .onDelete(perform: deleteCategories)
            
            // Add new category row
            Button(action: { showingAddCategory = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Add Custom Category")
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.vertical, 12)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.editMode, .constant(isReordering ? .active : .inactive))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isReordering ? "Done" : "Reorder") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isReordering.toggle()
                }
            }
        }
    }
    
    // MARK: - Actions
    private func moveCategories(from source: IndexSet, to destination: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        PersistenceController.shared.performWrite({ context in
            // Create array of categories to reorder
            var categoryArray = Array(categories)
            categoryArray.move(fromOffsets: source, toOffset: destination)
            
            // Update sort orders
            for (index, category) in categoryArray.enumerated() {
                let categoryToUpdate = context.object(with: category.objectID) as! Category
                categoryToUpdate.sortOrder = Int16(index)
            }
            
            print("✅ Reordered categories successfully")
        }, onError: { error in
            errorMessage = "Failed to reorder categories: \(error.localizedDescription)"
            showingError = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            categoryToDelete = category
            showingDeleteAlert = true
            break // Handle one at a time for better UX
        }
    }
    
    private func deleteCategory(_ category: Category) {
        guard !category.isDefault else {
            errorMessage = "Cannot delete default categories"
            showingError = true
            return
        }
        
        let categoryID = category.objectID
        PersistenceController.shared.performWrite({ context in
            let categoryToDelete = context.object(with: categoryID) as! Category
            
            // Move items to uncategorized
            if let items = categoryToDelete.groceryItems {
                for case let item as GroceryItem in items {
                    item.categoryEntity = nil
                    item.category = "Uncategorized"
                }
            }
            
            context.delete(categoryToDelete)
            print("✅ Deleted category: \(categoryToDelete.displayName)")
        }, onError: { error in
            errorMessage = "Failed to delete category: \(error.localizedDescription)"
            showingError = true
        })
    }
    
    private func resetToDefaultOrder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        PersistenceController.shared.performWrite({ context in
            Category.resetToDefaultOrder(in: context)
            print("✅ Reset categories to default order")
        }, onError: { error in
            errorMessage = "Failed to reset order: \(error.localizedDescription)"
            showingError = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
}

// MARK: - Category Row View
struct CategoryRowView: View {
    let category: Category
    let position: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Position indicator
            Text("\(position)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            // Category color and icon
            Circle()
                .fill(Color(hex: category.displayColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(categoryEmoji(for: category.displayName))
                        .font(.system(size: 16))
                )
            
            // Category info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    if category.isDefault {
                        Text("Default")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Text("\(category.groceryItemsArray.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.title2)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
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
}

#Preview {
    ManageCategoriesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
