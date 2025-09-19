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
    
    // Enhanced state for ingredient template protection
    @State private var showingReassignmentDialog = false
    @State private var assignedIngredientCount = 0
    @State private var reassignmentCategories: [Category] = []
    @State private var selectedReassignmentCategory: Category? = nil
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
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
                Text(enhancedDeleteAlertMessage(for: category))
            }
        }
        .sheet(isPresented: $showingReassignmentDialog) {
            NavigationView {
                reassignmentDialog
                    .navigationTitle("Reassign Ingredients")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingReassignmentDialog = false
                                categoryToDelete = nil
                            }
                        }
                    }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(successMessage)
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
                    onDelete: {
                        prepareForCategoryDeletion(category)
                    }
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
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isReordering ? "Done" : "Reorder") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isReordering.toggle()
                }
            }
        }
    }
    
    // MARK: - Enhanced Category Deletion Protection
    private func checkIngredientTemplateAssignments(for category: Category) -> Int {
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category.displayName)
        
        do {
            let assignedTemplates = try viewContext.fetch(request)
            print("📊 Category '\(category.displayName)' has \(assignedTemplates.count) assigned ingredient templates")
            return assignedTemplates.count
        } catch {
            print("❌ Error checking ingredient template assignments: \(error)")
            return 0
        }
    }
    
    private func prepareForCategoryDeletion(_ category: Category) {
        categoryToDelete = category
        
        // BLOCK DELETION: Check if this is the Uncategorized category
        if category.displayName.lowercased() == "uncategorized" {
            errorMessage = "The 'Uncategorized' category cannot be deleted as it's needed for unassigned ingredients."
            showingError = true
            categoryToDelete = nil
            return
        }
        
        // Check both grocery items and ingredient template assignments
        let groceryItemCount = category.groceryItemsArray.count
        let ingredientTemplateCount = checkIngredientTemplateAssignments(for: category)
        
        print("🔍 Category '\(category.displayName)' deletion check:")
        print("   - Grocery items: \(groceryItemCount)")
        print("   - Ingredient templates: \(ingredientTemplateCount)")
        
        if ingredientTemplateCount > 0 {
            // Category has ingredient template assignments - show enhanced dialog
            assignedIngredientCount = ingredientTemplateCount
            prepareReassignmentOptions(excluding: category)
            showingReassignmentDialog = true
        } else {
            // No ingredient template assignments - use standard deletion flow
            showingDeleteAlert = true
        }
    }
    
    private func prepareReassignmentOptions(excluding categoryToExclude: Category) {
        reassignmentCategories = categories.filter { $0 != categoryToExclude }
        selectedReassignmentCategory = reassignmentCategories.first
        print("📋 Prepared \(reassignmentCategories.count) reassignment options")
    }
    
    private func enhancedDeleteAlertMessage(for category: Category) -> String {
        let groceryItemCount = category.groceryItemsArray.count
        let hasGroceryItems = groceryItemCount > 0
        
        if hasGroceryItems {
            return "Delete '\(category.displayName)'?\n\n\(groceryItemCount) item\(groceryItemCount == 1 ? "" : "s") in this category will keep their category name for existing lists, but new items will need a different category."
        } else {
            return "Delete '\(category.displayName)'?\n\nThis category will no longer be available for new items."
        }
    }
    
    // MARK: - Reassignment Dialog
    private var reassignmentDialog: some View {
        VStack(spacing: 24) {
            // Header with better spacing
            VStack(spacing: 12) {
                Text("Category Has Assigned Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if let category = categoryToDelete {
                    VStack(spacing: 8) {
                        Text("\(assignedIngredientCount) ingredient\(assignedIngredientCount == 1 ? "" : "s") \(assignedIngredientCount == 1 ? "is" : "are") assigned to '\(category.displayName)'.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Choose how to handle these assignments:")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // Reassignment options with better styling
            VStack(spacing: 16) {
                // Option 1: Reassign to different category
                if !reassignmentCategories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.blue)
                            Text("Reassign to Different Category")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        // Replace picker with NavigationLink to selection view
                        NavigationLink(destination: CategorySelectionView(
                            categories: reassignmentCategories,
                            selectedCategory: $selectedReassignmentCategory
                        )) {
                            HStack {
                                if let selected = selectedReassignmentCategory {
                                    Circle()
                                        .fill(Color(hex: selected.displayColor))
                                        .frame(width: 16, height: 16)
                                        .overlay(
                                            Text(categoryEmoji(for: selected.displayName))
                                                .font(.system(size: 10))
                                        )
                                    Text(selected.displayName)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Select Category")
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Option 2: Move to Uncategorized
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.gray)
                        Text("Move to \"Uncategorized\" Category")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    Text("Ingredients will be moved to the Uncategorized category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Action buttons with better layout
            VStack(spacing: 12) {
                if !reassignmentCategories.isEmpty {
                    Button("Reassign to Selected Category") {
                        if let category = categoryToDelete,
                           let newCategory = selectedReassignmentCategory {
                            reassignIngredientTemplates(from: category, to: newCategory)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(selectedReassignmentCategory == nil ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(selectedReassignmentCategory == nil ? Color(.systemGray4) : Color.blue)
                    .cornerRadius(10)
                    .disabled(selectedReassignmentCategory == nil)
                }
                
                Button("Move to Uncategorized") {
                    if let category = categoryToDelete {
                        moveIngredientTemplatesToUncategorized(from: category)
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.gray)
                .cornerRadius(10)
                
                Button("Cancel") {
                    showingReassignmentDialog = false
                    categoryToDelete = nil
                    selectedReassignmentCategory = nil
                }
                .font(.body)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .padding(20)
    }
    
    // Helper function for category emojis
    private func categoryEmoji(for categoryName: String) -> String {
        switch categoryName {
        case "Produce": return "🥬"
        case "Deli & Meat": return "🥩"
        case "Dairy & Fridge": return "🥛"
        case "Bread & Frozen": return "🍞"
        case "Boxed & Canned": return "📦"
        case "Snacks, Drinks, & Other": return "🥤"
        case "Uncategorized": return "📋"
        default: return "📂"
        }
    }
    
    // MARK: - Reassignment Implementation
    private func reassignIngredientTemplates(from sourceCategory: Category, to targetCategory: Category) {
        let sourceCategoryID = sourceCategory.objectID
        let targetCategoryID = targetCategory.objectID
        let sourceCategoryName = sourceCategory.displayName
        let targetCategoryName = targetCategory.displayName
        
        PersistenceController.shared.performWrite({ context in
            // Get references to categories in write context
            let sourceCategoryInContext = context.object(with: sourceCategoryID) as! Category
            let targetCategoryInContext = context.object(with: targetCategoryID) as! Category
            
            let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", sourceCategoryName)
            
            do {
                let templates = try context.fetch(request)
                for template in templates {
                    template.category = targetCategoryName  // Assign String, not Category object
                    let templateName = template.name ?? "Unknown"
                    print("🔄 Reassigned '\(templateName)' from '\(sourceCategoryName)' to '\(targetCategoryName)'")
                }
                
                // Now delete the source category
                context.delete(sourceCategoryInContext)
                print("✅ Successfully reassigned \(templates.count) ingredient templates and deleted category '\(sourceCategoryName)'")
            } catch {
                print("❌ Error during reassignment: \(error)")
            }
            
        }, onError: { error in
            DispatchQueue.main.async {
                self.errorMessage = "Failed to reassign ingredients: \(error.localizedDescription)"
                self.showingError = true
            }
        })
        
        // Clean up state
        showingReassignmentDialog = false
        categoryToDelete = nil
        selectedReassignmentCategory = nil
    }
    
    private func moveIngredientTemplatesToUncategorized(from sourceCategory: Category) {
        let sourceCategoryID = sourceCategory.objectID
        let sourceCategoryName = sourceCategory.displayName
        
        PersistenceController.shared.performWrite({ context in
            // Get reference to category in write context
            let sourceCategoryInContext = context.object(with: sourceCategoryID) as! Category
            
            // Find or create the Uncategorized category
            let uncategorizedRequest: NSFetchRequest<Category> = Category.fetchRequest()
            uncategorizedRequest.predicate = NSPredicate(format: "name ==[c] %@", "Uncategorized")
            
            do {
                let uncategorizedCategories = try context.fetch(uncategorizedRequest)
                let uncategorizedCategory: Category
                
                if let existing = uncategorizedCategories.first {
                    uncategorizedCategory = existing
                } else {
                    // Create Uncategorized category if it doesn't exist
                    uncategorizedCategory = Category(context: context)
                    uncategorizedCategory.id = UUID()
                    uncategorizedCategory.name = "Uncategorized"
                    uncategorizedCategory.color = "#9E9E9E" // Gray color
                    uncategorizedCategory.isDefault = false
                    uncategorizedCategory.dateCreated = Date()
                    uncategorizedCategory.sortOrder = Int16.max
                    print("✅ Created Uncategorized category during reassignment")
                }
                
                // Move ingredient templates to Uncategorized
                let templateRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
                templateRequest.predicate = NSPredicate(format: "category == %@", sourceCategoryName)
                
                let templates = try context.fetch(templateRequest)
                for template in templates {
                    template.category = uncategorizedCategory.displayName  // Assign to Uncategorized, not nil
                    let templateName = template.name ?? "Unknown"
                    print("🔄 Moved '\(templateName)' to Uncategorized category")
                }
                
                // Now delete the source category
                context.delete(sourceCategoryInContext)
                print("✅ Successfully moved \(templates.count) ingredient templates to Uncategorized and deleted category '\(sourceCategoryName)'")
                
            } catch {
                print("❌ Error moving templates to Uncategorized: \(error)")
            }
            
        }, onError: { error in
            DispatchQueue.main.async {
                self.errorMessage = "Failed to move ingredients to Uncategorized: \(error.localizedDescription)"
                self.showingError = true
            }
        })
        
        // Clean up state
        showingReassignmentDialog = false
        categoryToDelete = nil
    }
    
    // MARK: - Actions
    private func moveCategories(from source: IndexSet, to destination: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        // Extract category IDs before entering performWrite
        var categoryArray = Array(categories)
        categoryArray.move(fromOffsets: source, toOffset: destination)
        let categoryOrderUpdates = categoryArray.enumerated().map { (index, category) in
            (objectID: category.objectID, sortOrder: Int16(index))
        }
        
        PersistenceController.shared.performWrite({ context in
            // Update sort orders using object IDs
            for update in categoryOrderUpdates {
                let categoryToUpdate = context.object(with: update.objectID) as! Category
                categoryToUpdate.sortOrder = update.sortOrder
            }
            
            print("✅ Reordered categories successfully")
        }, onError: { error in
            DispatchQueue.main.async {
                self.errorMessage = "Failed to reorder categories: \(error.localizedDescription)"
                self.showingError = true
            }
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
            prepareForCategoryDeletion(category)
            break // Handle one at a time for better UX
        }
    }
    
    private func deleteCategory(_ category: Category) {
        let categoryID = category.objectID
        let itemCount = category.groceryItemsArray.count
        let categoryName = category.displayName
        
        PersistenceController.shared.performWrite({ context in
            let categoryToDelete = context.object(with: categoryID) as! Category
            
            // Update grocery items to remove the relationship but keep the category name
            // This ensures existing list items maintain their category display
            if let items = categoryToDelete.groceryItems {
                for case let item as GroceryItem in items {
                    // Remove the relationship but preserve the category string
                    item.categoryEntity = nil
                    // Keep the original category name so existing lists still show it
                    item.category = categoryName
                }
                
                if itemCount > 0 {
                    print("📝 Updated \(itemCount) item\(itemCount == 1 ? "" : "s") - removed category relationship but preserved category name '\(categoryName)'")
                }
            }
            
            context.delete(categoryToDelete)
            print("✅ Deleted category: \(categoryName)")
        }, onError: { error in
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete category: \(error.localizedDescription)"
                self.showingError = true
            }
        })
        
        // Clear the categoryToDelete after successful deletion
        categoryToDelete = nil
    }
    
    private func resetToDefaultOrder() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        PersistenceController.shared.performWrite({ context in
            Category.resetToDefaultOrder(in: context)
            print("✅ Reset categories to default order")
        }, onError: { error in
            DispatchQueue.main.async {
                self.errorMessage = "Failed to reset order: \(error.localizedDescription)"
                self.showingError = true
            }
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
            }
            
            Spacer()
            
            // Delete button - HIDE for Uncategorized category
            if category.displayName.lowercased() != "uncategorized" {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(BorderlessButtonStyle())
            } else {
                // Add spacing equivalent to the delete button to maintain alignment
                Spacer()
                    .frame(width: 24) // Approximate width of trash icon
            }
            
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
        case "Uncategorized": return "📋"
        default: return "📂"
        }
    }
}

#Preview {
    NavigationView {
        ManageCategoriesView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// MARK: - Category Selection View
struct CategorySelectionView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                CategorySelectionRow(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    selectedCategory = category
                    dismiss()
                }
            }
        }
        .navigationTitle("Select Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Category Selection Row
struct CategorySelectionRow: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Category color and icon
                Circle()
                    .fill(Color(hex: category.displayColor))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(categoryEmoji(for: category.displayName))
                            .font(.system(size: 16))
                    )
                
                // Category name
                Text(category.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func categoryEmoji(for categoryName: String) -> String {
        switch categoryName {
        case "Produce": return "🥬"
        case "Deli & Meat": return "🥩"
        case "Dairy & Fridge": return "🥛"
        case "Bread & Frozen": return "🍞"
        case "Boxed & Canned": return "📦"
        case "Snacks, Drinks, & Other": return "🥤"
        case "Uncategorized": return "📋"
        default: return "📂"
        }
    }
}
