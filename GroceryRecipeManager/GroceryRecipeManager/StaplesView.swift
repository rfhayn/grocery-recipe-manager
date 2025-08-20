// Complete StaplesView.swift with Duplicate Category Cleanup
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
    
    // Computed filtered staples
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
    
    // Group filtered staples by category (using custom sort order)
    private var groupedStaples: [(key: Category, value: [GroceryItem])] {
        // First, ensure all items have category relationships
        ensureItemsHaveCategoryRelationships()
        
        let grouped = Dictionary(grouping: filteredStaples) { staple in
            staple.categoryEntity ?? findOrCreateCategory(for: staple)
        }
        
        // Sort by category sort order
        return grouped.sorted { $0.key.sortOrder < $1.key.sortOrder }
    }

    var body: some View {
        let _ = debugCategoryData() // Debug logging
        
        VStack(spacing: 0) {
            // Category Filter Section
            HStack {
                Text("Category:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Menu {
                    Button("All Categories") {
                        selectedCategory = nil
                    }
                    
                    Divider()
                    
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
            
            // Main Content
            ZStack {
                if filteredStaples.isEmpty {
                    // Empty State
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
                } else {
                    List {
                        // Group by category using custom sort order
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
                
                // Loading overlay
                if isLoading {
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
            }
        }
        .searchable(text: $searchText, prompt: "Search staples...")
        .toolbar {
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
        .navigationTitle("Staples")
        .sheet(isPresented: $showingAddForm) {
            AddStapleView()
        }
        .sheet(item: $stapleToEdit) { staple in
            EditStapleView(staple: staple)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
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
    private func createUncategorizedCategory() -> Category {
        let category = Category(context: viewContext)
        category.name = "Uncategorized"
        category.color = "#757575"
        category.sortOrder = 999
        category.isDefault = false
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
    
    // Helper method to find or create category for an item
    private func findOrCreateCategory(for item: GroceryItem) -> Category {
        // Try to find existing category by name
        if let categoryName = item.category {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name ==[c] %@", categoryName)
            
            if let existingCategory = try? viewContext.fetch(request).first {
                return existingCategory
            }
        }
        
        // Fallback: create uncategorized
        return createUncategorizedCategory()
    }
    
    // Helper method to ensure items have category relationships
    private func ensureItemsHaveCategoryRelationships() {
        let itemsNeedingMigration = staples.filter { $0.categoryEntity == nil }
        
        if !itemsNeedingMigration.isEmpty {
            for item in itemsNeedingMigration {
                item.migrateToCategory(in: viewContext)
            }
            
            try? viewContext.save()
        }
    }
    
    // Clean up duplicate categories
    private func cleanupDuplicateCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true),
            NSSortDescriptor(keyPath: \Category.dateCreated, ascending: true)
        ]
        
        do {
            let allCategories = try viewContext.fetch(request)
            var categoryNames: Set<String> = []
            var categoriesToDelete: [Category] = []
            
            for category in allCategories {
                let name = category.displayName
                if categoryNames.contains(name) {
                    // This is a duplicate - mark for deletion
                    categoriesToDelete.append(category)
                    print("🗑️ Marking duplicate category for deletion: \(name)")
                } else {
                    categoryNames.insert(name)
                    print("✅ Keeping category: \(name)")
                }
            }
            
            // Delete duplicates
            for category in categoriesToDelete {
                viewContext.delete(category)
            }
            
            if !categoriesToDelete.isEmpty {
                try viewContext.save()
                print("🧹 Cleaned up \(categoriesToDelete.count) duplicate categories")
            }
            
        } catch {
            print("❌ Error cleaning up categories: \(error)")
        }
    }
    
    // Debug method to see what's happening
    private func debugCategoryData() {
        cleanupDuplicateCategories() // Clean up duplicates first
        
        print("=== CATEGORY DEBUG ===")
        print("Total categories: \(categories.count)")
        for category in categories {
            print("Category: \(category.displayName), sortOrder: \(category.sortOrder), items: \(category.groceryItemsArray.count)")
        }
        
        print("\nTotal staples: \(staples.count)")
        for staple in staples {
            print("Staple: \(staple.name ?? "nil"), category string: \(staple.category ?? "nil"), categoryEntity: \(staple.categoryEntity?.displayName ?? "nil")")
        }
        
        print("\nGrouped staples:")
        for (category, items) in groupedStaples {
            print("Group \(category.displayName): \(items.count) items")
            for item in items {
                print("  - \(item.name ?? "nil")")
            }
        }
        print("=== END DEBUG ===")
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

// MARK: - Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
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
