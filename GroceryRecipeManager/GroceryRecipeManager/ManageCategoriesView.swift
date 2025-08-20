import SwiftUI
import CoreData

struct ManageCategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // Category data
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // State for drag and drop
    @State private var draggedCategory: Category?
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Loading state
    @State private var isReordering = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                categoriesListSection
            }
            .navigationTitle("Organize Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Drag categories to match your store layout")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Categories appear in this order throughout the app")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    private var categoriesListSection: some View {
        List {
            ForEach(categories, id: \.self) { category in
                categoryRow(category: category)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .onDrag {
                        self.draggedCategory = category
                        return NSItemProvider(object: category.displayName as NSString)
                    }
                    .onDrop(of: [.text], delegate: CategoryDropDelegate(
                        destinationCategory: category,
                        categories: Array(categories),
                        draggedCategory: $draggedCategory,
                        onReorder: updateCategoryOrder
                    ))
            }
            .onMove(perform: moveCategories)
        }
        .listStyle(InsetGroupedListStyle())
        .overlay(
            isReordering ? reorderingOverlay : nil
        )
    }
    
    private var reorderingOverlay: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Updating order...")
                    .font(.headline)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: resetToDefaultOrder) {
                    Label("Reset to Default Order", systemImage: "arrow.clockwise")
                }
                
                Button(action: { }) {
                    Label("Add Custom Category", systemImage: "plus.circle")
                }
                .disabled(true) // Future feature
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    // MARK: - Category Row
    
    @ViewBuilder
    private func categoryRow(category: Category) -> some View {
        HStack(spacing: 16) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.title2)
                .frame(width: 20)
            
            // Category icon and color
            Circle()
                .fill(Color(hex: category.displayColor))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(categoryEmoji(for: category.displayName))
                        .font(.system(size: 18))
                )
            
            // Category info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    if category.isDefault {
                        Text("Default")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
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
            
            // Sort order indicator
            Text("\(category.sortOrder + 1)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color(hex: category.displayColor))
                .clipShape(Circle())
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Actions
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var categoriesArray = Array(categories)
        categoriesArray.move(fromOffsets: source, toOffset: destination)
        updateCategoryOrder(categoriesArray)
    }
    
    private func updateCategoryOrder(_ reorderedCategories: [Category]) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isReordering = true
        }
        
        PersistenceController.shared.performWrite({ context in
            for (index, category) in reorderedCategories.enumerated() {
                // Get the category in the background context
                let categoryInContext = context.object(with: category.objectID) as! Category
                categoryInContext.sortOrder = Int16(index)
            }
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to update category order: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isReordering = false
            }
        }
    }
    
    private func resetToDefaultOrder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isReordering = true
        }
        
        PersistenceController.shared.performWrite({ context in
            Category.resetToDefaultOrder(in: context)
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to reset category order: \(error.localizedDescription)"
                showingError = true
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isReordering = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
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

// MARK: - Drop Delegate

struct CategoryDropDelegate: DropDelegate {
    let destinationCategory: Category
    let categories: [Category]
    @Binding var draggedCategory: Category?
    let onReorder: ([Category]) -> Void
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedCategory = draggedCategory else { return false }
        
        if draggedCategory != destinationCategory {
            var reorderedCategories = categories
            
            // Find current positions
            guard let fromIndex = reorderedCategories.firstIndex(of: draggedCategory),
                  let toIndex = reorderedCategories.firstIndex(of: destinationCategory) else {
                return false
            }
            
            // Perform the move
            reorderedCategories.move(fromOffsets: IndexSet([fromIndex]), toOffset: toIndex)
            
            // Update the order
            onReorder(reorderedCategories)
        }
        
        self.draggedCategory = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedCategory = draggedCategory else { return }
        
        if draggedCategory != destinationCategory {
            // Visual feedback could be added here
        }
    }
}

// Color extension moved to Color+Extensions.swift

#Preview {
    ManageCategoriesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
