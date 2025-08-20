import SwiftUI
import CoreData

struct StaplesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Search and filter state
    @State private var searchText = ""
    @State private var selectedCategory = "All Categories"
    
    // Form presentation states
    @State private var showingAddForm = false
    @State private var stapleToEdit: GroceryItem?
    
    // Error handling
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Loading states for professional polish
    @State private var isLoading = false
    @State private var lastRefreshDate = Date()
    
    // Categories for filtering (matches your updated AddStaplesView categories)
    private let groceryCategories = [
        "All Categories",
        "Produce",
        "Deli & Meat",
        "Dairy & Fridge",
        "Bread & Frozen",
        "Boxed & Canned",
        "Snacks, Drinks, & Other"
    ]
    
    // Dynamic FetchRequest based on search and category filter
    @FetchRequest var staples: FetchedResults<GroceryItem>
    
    init() {
        // Initialize with basic staples predicate
        self._staples = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \GroceryItem.category, ascending: true),
                NSSortDescriptor(keyPath: \GroceryItem.name, ascending: true)
            ],
            predicate: NSPredicate(format: "isStaple == YES"),
            animation: .default
        )
    }
    
    // Computed filtered staples based on current search and category
    private var filteredStaples: [GroceryItem] {
        var filtered = Array(staples)
        
        // Apply search filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = filtered.filter { staple in
                let name = staple.name ?? ""
                let category = staple.category ?? ""
                return name.localizedCaseInsensitiveContains(searchText) ||
                       category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if selectedCategory != "All Categories" {
            filtered = filtered.filter { staple in
                staple.category == selectedCategory
            }
        }
        
        return filtered
    }
    
    // Group filtered staples by category
    private var groupedStaples: [(key: String, value: [GroceryItem])] {
        let grouped = Dictionary(grouping: filteredStaples) { staple in
            staple.category ?? "Uncategorized"
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    // Filter status text
    private var filtersActiveText: String {
        var activeFilters: [String] = []
        
        if !searchText.isEmpty {
            activeFilters.append("Search")
        }
        
        if selectedCategory != "All Categories" {
            activeFilters.append("Category")
        }
        
        if activeFilters.isEmpty {
            return ""
        } else if activeFilters.count == 1 {
            return "\(activeFilters[0]) active"
        } else {
            return "\(activeFilters.count) filters active"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category Filter - Compact Picker
            HStack {
                Text("Category:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Category Filter", selection: $selectedCategory) {
                    ForEach(groceryCategories, id: \.self) { category in
                        Text(category == "All Categories" ? "All" : category)
                            .tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                // Show active filters count
                if searchText.count > 0 || selectedCategory != "All Categories" {
                    Text(filtersActiveText)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Main Content with Loading Overlay
            ZStack {
                Group {
                    if filteredStaples.isEmpty {
                        EmptyStaplesView(
                            hasSearchText: !searchText.isEmpty,
                            hasCategory: selectedCategory != "All Categories",
                            onClearFilters: clearFilters,
                            onAddStaple: { showingAddForm = true }
                        )
                    } else {
                        List {
                            // Always group by category for grocery list feel
                            ForEach(groupedStaples, id: \.key) { category, items in
                                Section(header: CategoryHeaderView(category: category, count: items.count)) {
                                    ForEach(items, id: \.self) { item in
                                        StapleRowView(item: item)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                editStaple(item)
                                            }
                                            .contextMenu {
                                                contextMenuButtons(for: item)
                                            }
                                            .swipeActions(edge: .trailing) {
                                                trailingSwipeActions(for: item)
                                            }
                                            .swipeActions(edge: .leading) {
                                                leadingSwipeActions(for: item)
                                            }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            await refreshData()
                        }
                    }
                }
                
                // Loading overlay
                if isLoading {
                    LoadingOverlay()
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
    
    // MARK: - Action Methods
    
    private func editStaple(_ staple: GroceryItem) {
        print("🔧 Edit tapped for: \(staple.name ?? "Unknown")")
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
            print("✅ Marked \(stapleToUpdate.name ?? "Unknown") as purchased")
        }, onError: { error in
            errorMessage = "Failed to update purchase date: \(error.localizedDescription)"
            showingError = true
        })
        
        // Hide loading after brief delay
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
            print("✅ Deleted staple: \(staple.name ?? "Unknown")")
        }, onError: { error in
            errorMessage = "Failed to delete staple: \(error.localizedDescription)"
            showingError = true
        })
        
        // Hide loading after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
    
    private func clearFilters() {
        withAnimation(.easeInOut(duration: 0.3)) {
            searchText = ""
            selectedCategory = "All Categories"
        }
    }
    
    @MainActor
    private func refreshData() async {
        // Simulate refresh operation
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        lastRefreshDate = Date()
        
        // Trigger a Core Data refresh if needed
        viewContext.refreshAllObjects()
    }
    
    // MARK: - Context Menu & Swipe Action Builders
    
    @ViewBuilder
    private func contextMenuButtons(for item: GroceryItem) -> some View {
        Button(action: {
            editStaple(item)
        }) {
            Label("Edit", systemImage: "pencil")
        }
        
        Button(action: {
            markAsPurchased(item)
        }) {
            Label("Mark as Purchased", systemImage: "cart.badge.plus")
        }
        
        if let lastPurchased = item.lastPurchased {
            Button(action: {
                clearPurchaseHistory(item)
            }) {
                Label("Clear Purchase History", systemImage: "clock.arrow.circlepath")
            }
        }
        
        Button(role: .destructive, action: {
            deleteStaple(item)
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    @ViewBuilder
    private func trailingSwipeActions(for item: GroceryItem) -> some View {
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
    
    @ViewBuilder
    private func leadingSwipeActions(for item: GroceryItem) -> some View {
        Button {
            markAsPurchased(item)
        } label: {
            Label("Purchased", systemImage: "cart.badge.plus")
        }
        .tint(.green)
    }
    
    private func clearPurchaseHistory(_ staple: GroceryItem) {
        let stapleID = staple.objectID
        PersistenceController.shared.performWrite({ context in
            let stapleToUpdate = context.object(with: stapleID) as! GroceryItem
            stapleToUpdate.lastPurchased = nil
            print("🧹 Cleared purchase history for \(stapleToUpdate.name ?? "Unknown")")
        }, onError: { error in
            errorMessage = "Failed to clear purchase history: \(error.localizedDescription)"
            showingError = true
        })
    }
}

// Custom category header view for grocery list feel
struct CategoryHeaderView: View {
    let category: String
    let count: Int
    
    var body: some View {
        HStack {
            // Category icon based on category type
            Image(systemName: categoryIcon)
                .foregroundColor(categoryColor)
                .font(.system(size: 16, weight: .medium))
            
            Text(category)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Item count badge
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoryColor)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    // Category-specific icons for your store layout
    private var categoryIcon: String {
        switch category {
        case "Produce":
            return "leaf.fill"
        case "Deli & Meat":
            return "fork.knife"
        case "Dairy & Fridge":
            return "snowflake"
        case "Bread & Frozen":
            return "birthday.cake.fill"
        case "Boxed & Canned":
            return "archivebox.fill"
        case "Snacks, Drinks, & Other":
            return "cup.and.saucer.fill"
        default:
            return "square.grid.2x2.fill"
        }
    }
    
    // Category-specific colors for your store layout
    private var categoryColor: Color {
        switch category {
        case "Produce":
            return .green
        case "Deli & Meat":
            return .red
        case "Dairy & Fridge":
            return .blue
        case "Bread & Frozen":
            return .orange
        case "Boxed & Canned":
            return .brown
        case "Snacks, Drinks, & Other":
            return .purple
        default:
            return .gray
        }
    }
}

// Enhanced empty state view with context-aware messaging
struct EmptyStaplesView: View {
    let hasSearchText: Bool
    let hasCategory: Bool
    let onClearFilters: () -> Void
    let onAddStaple: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon based on context
            Image(systemName: emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Action buttons based on context
            VStack(spacing: 12) {
                if hasSearchText || hasCategory {
                    Button(action: onClearFilters) {
                        Label("Clear Filters", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                
                Button(action: onAddStaple) {
                    Label("Add Your First Staple", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(hasSearchText || hasCategory ? Color.green : Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateIcon: String {
        if hasSearchText {
            return "magnifyingglass"
        } else if hasCategory {
            return "line.3.horizontal.decrease.circle"
        } else {
            return "cart.badge.plus"
        }
    }
    
    private var emptyStateTitle: String {
        if hasSearchText {
            return "No Matching Staples"
        } else if hasCategory {
            return "No Staples in This Category"
        } else {
            return "No Staples Yet"
        }
    }
    
    private var emptyStateMessage: String {
        if hasSearchText {
            return "No staples match your search. Try different keywords or clear your search."
        } else if hasCategory {
            return "You don't have any staples in this category yet. Try a different category or add some staples."
        } else {
            return "Start building your staples list! Add items you buy regularly and they'll automatically appear in your grocery lists."
        }
    }
}

// Professional loading overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
                
                Text("Updating...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
        }
    }
}

struct StapleRowView: View {
    let item: GroceryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Staple indicator circle (like grocery list checkbox)
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 20, height: 20)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.blue)
                )
                .accessibilityLabel("Staple item")
            
            VStack(alignment: .leading, spacing: 4) {
                // Main item name
                Text(item.name ?? "Unknown Item")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Purchase history info with visual indicator
                HStack(spacing: 6) {
                    if let lastPurchased = item.lastPurchased {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                        
                        Text("Last purchased: \(lastPurchased, formatter: dateFormatter)")
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
            
            // Purchase status indicator
            VStack(alignment: .trailing, spacing: 4) {
                // Staple badge (smaller, more subtle)
                Text("📌")
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                
                // Days since purchase indicator
                if let daysSincePurchase = daysSinceLastPurchase {
                    Text(daysSincePurchaseText(daysSincePurchase))
                        .font(.caption2)
                        .foregroundColor(daysSincePurchase > 14 ? .orange : .secondary)
                        .fontWeight(daysSincePurchase > 14 ? .medium : .regular)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle()) // Makes entire row tappable
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name ?? "Unknown item"), staple")
        .accessibilityHint("Tap to edit")
        .accessibilityAction(named: "Mark as purchased") {
            // This would be handled by parent view
        }
    }
    
    private var daysSinceLastPurchase: Int? {
        guard let purchaseDate = item.lastPurchased else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 0
        return days
    }
    
    private func daysSincePurchaseText(_ days: Int) -> String {
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Yesterday"
        } else if days < 7 {
            return "\(days)d ago"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks)w ago"
        } else {
            return "30+ days"
        }
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
