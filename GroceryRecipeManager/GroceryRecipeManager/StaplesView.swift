// Fixed StaplesView.swift - No Duplicate Categories
import SwiftUI
import CoreData

struct StaplesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Search and filter state
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    
    // Form presentation states
    @State private var showingAddForm = false
    @State private var stapleToEdit: GroceryItem?
    @State private var showingManageCategories = false
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Loading states
    @State private var isLoading = false
    
    // Dynamic categories fetch (sorted by custom order)
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // Dynamic staples fetch
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroceryItem.category, ascending: true),
            NSSortDescriptor(keyPath: \GroceryItem.name, ascending: true)
        ],
        predicate: NSPredicate(format: "isStaple == YES"),
        animation: .default
    ) private var staples: FetchedResults<GroceryItem>
    
    var body: some View {
        contentView
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            categoryFilterSection
            mainContentArea
        }
        .searchable(text: $searchText, prompt: "Search staples...")
        .navigationTitle("Staples")
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddForm) {
            AddStapleView()
        }
        .sheet(item: $stapleToEdit) { staple in
            EditStapleView(staple: staple)
        }
        .sheet(isPresented: $showingManageCategories) {
            ManageCategoriesView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            cleanupDuplicateCategories()
        }
    }
    
    // MARK: - View Components
    private var categoryFilterSection: some View {
        HStack {
            Text("Category:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Menu {
                Button("All Categories") {
                    selectedCategory = nil
                }
                
                Divider()
                
                // Use ONLY the dynamic categories, not hardcoded ones
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: category.displayColor))
                                .frame(width: 12, height: 12)
                            Text(category.displayName)
                        }
                    }
                }
            } label: {
                HStack {
                    if let selectedCategory = selectedCategory {
                        Circle()
                            .fill(Color(hex: selectedCategory.displayColor))
                            .frame(width: 12, height: 12)
                    }
                    Text(selectedCategory?.displayName ?? "All Categories")
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private var mainContentArea: some View {
        ZStack {
            if filteredStaples.isEmpty {
                emptyStateView
            } else {
                staplesListView
            }
            
            if isLoading {
                loadingOverlay
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Staples Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some staples to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddForm = true }) {
                Label("Add Staple", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var staplesListView: some View {
        List {
            ForEach(groupedStaples, id: \.key) { category, items in
                Section(header: categoryHeader(category: category, count: items.count)) {
                    ForEach(items, id: \.self) { item in
                        stapleRow(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editStaple(item)
                            }
                            .contextMenu {
                                contextMenuButtons(for: item)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteStaple(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    editStaple(item)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    markAsPurchased(item)
                                } label: {
                                    Label("Purchased", systemImage: "cart.badge.plus")
                                }
                                .tint(.green)
                            }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Updating...")
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
            Button(action: {
                showingManageCategories = true
            }) {
                Label("Organize Categories", systemImage: "slider.horizontal.3")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            EditButton()
        }
        
        ToolbarItem {
            Button(action: {
                showingAddForm = true
            }) {
                Label("Add Staple", systemImage: "plus")
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredStaples: [GroceryItem] {
        var filtered = Array(staples)
        
        // Apply search filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = filtered.filter { staple in
                let name = staple.name ?? ""
                let category = staple.effectiveCategory
                return name.localizedCaseInsensitiveContains(searchText) ||
                       category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { staple in
                staple.categoryEntity == selectedCategory
            }
        }
        
        return filtered
    }
    
    private var groupedStaples: [(key: Category, value: [GroceryItem])] {
        ensureItemsHaveCategoryRelationships()
        
        let grouped = Dictionary(grouping: filteredStaples) { staple in
            staple.categoryEntity ?? findOrCreateCategory(for: staple)
        }
        
        return grouped.sorted { $0.key.sortOrder < $1.key.sortOrder }
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private func categoryHeader(category: Category, count: Int) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: category.displayColor))
                .frame(width: 20, height: 20)
                .overlay(
                    Text(categoryEmoji(for: category.displayName))
                        .font(.system(size: 12))
                )
            
            Text(category.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: category.displayColor))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func stapleRow(item: GroceryItem) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: item.categoryColor))
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Unknown Item")
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 6) {
                    if let lastPurchased = item.lastPurchased {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        Text("Last: \(lastPurchased, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("Never purchased")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text("📌")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func contextMenuButtons(for item: GroceryItem) -> some View {
        Button(action: { editStaple(item) }) {
            Label("Edit", systemImage: "pencil")
        }
        
        Button(action: { markAsPurchased(item) }) {
            Label("Mark as Purchased", systemImage: "cart.badge.plus")
        }
        
        if item.lastPurchased != nil {
            Button(action: { clearPurchaseHistory(item) }) {
                Label("Clear Purchase History", systemImage: "clock.arrow.circlepath")
            }
        }
        
        Button(role: .destructive, action: { deleteStaple(item) }) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: - Helper Methods
    private func cleanupDuplicateCategories() {
        let context = viewContext
        
        // Group categories by name to find duplicates
        let categoryNames = Set(categories.map { $0.displayName })
        
        for categoryName in categoryNames {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[c] %@", categoryName)
            
            do {
                let duplicateCategories = try context.fetch(request)
                if duplicateCategories.count > 1 {
                    print("🧹 Found \(duplicateCategories.count) categories named '\(categoryName)'")
                    
                    // Keep the first one (usually the one with the lowest sortOrder)
                    let categoryToKeep = duplicateCategories.sorted { $0.sortOrder < $1.sortOrder }.first!
                    
                    // Delete the rest
                    for category in duplicateCategories {
                        if category != categoryToKeep {
                            print("🗑️ Deleting duplicate category: \(category.displayName)")
                            context.delete(category)
                        }
                    }
                }
            } catch {
                print("❌ Error cleaning up categories: \(error)")
            }
        }
        
        // Save changes
        do {
            if context.hasChanges {
                try context.save()
                print("✅ Category cleanup completed")
            }
        } catch {
            print("❌ Failed to save category cleanup: \(error)")
        }
    }
    
    private func createUncategorizedCategory() -> Category {
        // First try to find existing uncategorized category
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] 'Uncategorized'")
        
        if let existing = try? viewContext.fetch(request).first {
            return existing
        }
        
        // Only create if one doesn't exist
        let category = Category(context: viewContext)
        category.name = "Uncategorized"
        category.color = "#757575"
        category.sortOrder = 999
        category.isDefault = false
        category.id = UUID()
        category.dateCreated = Date()
        
        // Save immediately to prevent duplicates
        try? viewContext.save()
        
        return category
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
    
    private func findOrCreateCategory(for item: GroceryItem) -> Category {
        if let categoryName = item.category {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[c] %@", categoryName)
            
            if let existingCategory = try? viewContext.fetch(request).first {
                return existingCategory
            }
        }
        
        return createUncategorizedCategory()
    }
    
    private func ensureItemsHaveCategoryRelationships() {
        let itemsNeedingMigration = staples.filter { $0.categoryEntity == nil }
        
        if !itemsNeedingMigration.isEmpty {
            for item in itemsNeedingMigration {
                item.migrateToCategory(in: viewContext)
            }
            
            try? viewContext.save()
        }
    }
    
    // MARK: - Action Methods
    private func editStaple(_ staple: GroceryItem) {
        stapleToEdit = staple
    }
    
    private func markAsPurchased(_ staple: GroceryItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        let stapleID = staple.objectID
        PersistenceController.shared.performWrite({ context in
            let stapleToUpdate = context.object(with: stapleID) as! GroceryItem
            stapleToUpdate.lastPurchased = Date()
        }, onError: { error in
            errorMessage = "Failed to update purchase date: \(error.localizedDescription)"
            showingError = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
    
    private func deleteStaple(_ staple: GroceryItem) {
        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
        }
        
        let objectID = staple.objectID
        PersistenceController.shared.performWrite({ context in
            let object = context.object(with: objectID)
            context.delete(object)
        }, onError: { error in
            errorMessage = "Failed to delete staple: \(error.localizedDescription)"
            showingError = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
    
    private func clearPurchaseHistory(_ staple: GroceryItem) {
        let stapleID = staple.objectID
        PersistenceController.shared.performWrite({ context in
            let stapleToUpdate = context.object(with: stapleID) as! GroceryItem
            stapleToUpdate.lastPurchased = nil
        }, onError: { error in
            errorMessage = "Failed to clear purchase history: \(error.localizedDescription)"
            showingError = true
        })
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    NavigationView {
        StaplesView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
