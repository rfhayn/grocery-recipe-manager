import SwiftUI
import CoreData
import Combine  // NEW: Added for QuantityMergeService

struct GroceryListDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let weeklyList: WeeklyList
    
    // Fetch categories for custom sorting
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // Fetch list items directly to get real-time updates
    @FetchRequest private var listItems: FetchedResults<GroceryListItem>
    
    // State management
    @State private var showingAddItem = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // NEW: M3 Phase 5 - Consolidation state
    @State private var showingConsolidationSheet = false
    @State private var showingNoOpportunitiesAlert = false
    @State private var mergeAnalysis: MergeAnalysis?
    @StateObject private var mergeService: QuantityMergeService
    
    // Initialize with dynamic fetch request for the specific list
    init(weeklyList: WeeklyList) {
        self.weeklyList = weeklyList
        
        // Create a fetch request specifically for this list's items
        let request: NSFetchRequest<GroceryListItem> = GroceryListItem.fetchRequest()
        request.predicate = NSPredicate(format: "weeklyList == %@", weeklyList)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \GroceryListItem.categoryName, ascending: true),
            NSSortDescriptor(keyPath: \GroceryListItem.sortOrder, ascending: true)
        ]
        
        self._listItems = FetchRequest(fetchRequest: request, animation: .default)
        
        // NEW: Initialize merge service
        _mergeService = StateObject(wrappedValue: QuantityMergeService(
            context: PersistenceController.shared.container.viewContext
        ))
    }
    
    // Group items by category using custom sort order
    private var groupedItems: [(key: String, value: [GroceryListItem])] {
        let grouped = Dictionary(grouping: Array(listItems)) { item in
            return item.categoryName ?? "Unknown"
        }
        
        // Sort categories by custom sort order
        let categoryOrder = Dictionary(uniqueKeysWithValues: categories.enumerated().map { ($1.displayName, $0) })
        
        return grouped.sorted { first, second in
            let firstOrder = categoryOrder[first.key] ?? 999
            let secondOrder = categoryOrder[second.key] ?? 999
            return firstOrder < secondOrder
        }
    }
    
    private var completedItemsCount: Int {
        Array(listItems).filter { $0.isCompleted }.count
    }
    
    private var totalItemsCount: Int {
        listItems.count
    }
    
    private var completionPercentage: Double {
        guard totalItemsCount > 0 else { return 0 }
        return Double(completedItemsCount) / Double(totalItemsCount)
    }
    
    // NEW: M3 Phase 5 - Incomplete items for consolidation
    private var incompletedItems: [GroceryListItem] {
        Array(listItems).filter { !$0.isCompleted }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            if listItems.isEmpty {
                emptyStateView
            } else {
                shoppingListView
            }
        }
        .navigationTitle(weeklyList.name ?? "Grocery List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showingAddItem) {
            AddListItemView(weeklyList: weeklyList)
        }
        // NEW: M3 Phase 5 - Consolidation preview sheet
        .sheet(isPresented: $showingConsolidationSheet) {
            if let analysis = mergeAnalysis {
                ConsolidationPreviewView(
                    analysis: analysis,
                    mergeService: mergeService,
                    onComplete: handleConsolidationComplete
                )
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("No Items to Consolidate", isPresented: $showingNoOpportunitiesAlert) {
            Button("OK") { }
        } message: {
            Text("This list has no duplicate items that can be combined. Items can only be consolidated if they have the same ingredient name and compatible units (e.g., \"1 cup flour\" + \"2 cups flour\" = \"3 cups flour\", or \"1 tsp sugar\" + \"2 tbsp sugar\" with unit conversion).")
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Progress stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completedItemsCount) of \(totalItemsCount) items")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("\(Int(completionPercentage * 100))% complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Mark all complete button
                if !listItems.isEmpty && completedItemsCount < totalItemsCount {
                    Button("Complete All") {
                        markAllItemsComplete()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .foregroundColor(.gray.opacity(0.3))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * completionPercentage, height: 8)
                        .foregroundColor(completionPercentage >= 1.0 ? .green : .blue)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.3), value: completionPercentage)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("Empty List")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some items to get started shopping!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddItem = true }) {
                Label("Add Item", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var shoppingListView: some View {
        List {
            ForEach(groupedItems, id: \.key) { categoryName, items in
                Section(header: categoryHeader(for: categoryName, items: items)) {
                    ForEach(items, id: \.self) { item in
                        GroceryListItemRow(item: item) {
                            toggleItemCompletion(item)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleItemCompletion(item)
                            } label: {
                                Label(item.isCompleted ? "Undo" : "Complete",
                                      systemImage: item.isCompleted ? "arrow.uturn.left" : "checkmark")
                            }
                            .tint(item.isCompleted ? .orange : .green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // NEW: M3 Phase 5 - Consolidate button
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: analyzeConsolidation) {
                Label("Consolidate", systemImage: "arrow.triangle.merge")
            }
            .disabled(incompletedItems.count < 2)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddItem = true }) {
                Label("Add Item", systemImage: "plus")
            }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func categoryHeader(for categoryName: String, items: [GroceryListItem]) -> some View {
        HStack {
            // Category icon and name
            HStack {
                if let category = categories.first(where: { $0.displayName == categoryName }) {
                    Circle()
                        .fill(Color(hex: category.displayColor))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text(categoryEmoji(for: categoryName))
                                .font(.system(size: 10))
                        )
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text("📋")
                                .font(.system(size: 10))
                        )
                }
                
                Text(categoryName)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Category completion indicator
            let completedInCategory = items.filter { $0.isCompleted }.count
            Text("\(completedInCategory)/\(items.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
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
    
    // MARK: - Actions
    
    private func toggleItemCompletion(_ item: GroceryListItem) {
        let itemID = item.objectID
        let listID = weeklyList.objectID
        
        PersistenceController.shared.performWrite({ context in
            let itemToUpdate = context.object(with: itemID) as! GroceryListItem
            itemToUpdate.isCompleted.toggle()
            
            if itemToUpdate.isCompleted {
                itemToUpdate.dateCompleted = Date()
            } else {
                itemToUpdate.dateCompleted = nil
            }
            
            // Enhanced: Update parent list completion status
            let listToUpdate = context.object(with: listID) as! WeeklyList
            updateListCompletionStatus(listToUpdate, in: context)
            
            print("✅ Toggled item completion: \(itemToUpdate.name ?? "Unknown") - \(itemToUpdate.isCompleted ? "Complete" : "Incomplete")")
        }, onError: { error in
            errorMessage = "Failed to update item: \(error.localizedDescription)"
            showingError = true
        })
    }
    
    private func markAllItemsComplete() {
        let incompleteItems = Array(listItems).filter { !$0.isCompleted }
        let itemIDs = incompleteItems.map { $0.objectID }
        let listID = weeklyList.objectID
        
        PersistenceController.shared.performWrite({ context in
            for itemID in itemIDs {
                let item = context.object(with: itemID) as! GroceryListItem
                item.isCompleted = true
                item.dateCompleted = Date()
            }
            
            // Enhanced: Update parent list completion status
            let listToUpdate = context.object(with: listID) as! WeeklyList
            updateListCompletionStatus(listToUpdate, in: context)
            
            print("✅ Marked all \(itemIDs.count) items as complete")
        }, onError: { error in
            errorMessage = "Failed to complete all items: \(error.localizedDescription)"
            showingError = true
        })
    }
    
    private func deleteItem(_ item: GroceryListItem) {
        let itemID = item.objectID
        let listID = weeklyList.objectID
        
        PersistenceController.shared.performWrite({ context in
            let itemToDelete = context.object(with: itemID)
            context.delete(itemToDelete)
            
            // Enhanced: Update parent list completion status after deletion
            let listToUpdate = context.object(with: listID) as! WeeklyList
            updateListCompletionStatus(listToUpdate, in: context)
            
            print("✅ Deleted item: \(item.name ?? "Unknown")")
        }, onError: { error in
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
            showingError = true
        })
    }
    
    // MARK: - M3 Phase 5: Consolidation Actions
    
    /// Analyze list for consolidation opportunities
    private func analyzeConsolidation() {
        mergeAnalysis = mergeService.analyzeMergeOpportunities(for: weeklyList)
        
        if let analysis = mergeAnalysis, analysis.hasMergeOpportunities {
            showingConsolidationSheet = true
        } else {
            // Show informational alert (not an error)
            showingNoOpportunitiesAlert = true
        }
    }
    
    /// Handle consolidation completion
    private func handleConsolidationComplete() {
        // Refresh the view by accessing context
        viewContext.refreshAllObjects()
        
        // Clear analysis
        mergeAnalysis = nil
    }
    
    // MARK: - List Completion Status Management
    
    private func updateListCompletionStatus(_ weeklyList: WeeklyList, in context: NSManagedObjectContext) {
        guard let items = weeklyList.items as? Set<GroceryListItem> else {
            weeklyList.isCompleted = false
            return
        }
        
        let itemsArray = Array(items)
        let totalItems = itemsArray.count
        let completedItems = itemsArray.filter { $0.isCompleted }.count
        
        // List is complete if all items are completed (and there's at least one item)
        let wasCompleted = weeklyList.isCompleted
        weeklyList.isCompleted = totalItems > 0 && completedItems == totalItems
        
        // Log status change for debugging
        if wasCompleted != weeklyList.isCompleted {
            print("📋 List completion status changed: \(weeklyList.name ?? "Unknown") - \(weeklyList.isCompleted ? "COMPLETED" : "INCOMPLETE") (\(completedItems)/\(totalItems))")
        }
    }
}

// MARK: - Enhanced GroceryListItemRow Component

struct GroceryListItemRow: View {
    let item: GroceryListItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            // Enhanced Item details with improved typography hierarchy
            VStack(alignment: .leading, spacing: 4) {
                // Primary: Item name (prominent display) + Secondary: Quantity (smaller, muted)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.name ?? "Unknown Item")
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(item.isCompleted)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                        .lineLimit(2)
                    
                    // Use displayText for quantity (75% font size, muted color)
                    if let displayText = item.displayText, !displayText.isEmpty, displayText != "1" {
                        Text("(\(displayText))")
                            .font(.caption)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                            .strikethrough(item.isCompleted)
                    }
                    
                    Spacer()
                }
                
                // Tertiary: Source and completion info
                HStack {
                    // Source indicator
                    if let source = item.source {
                        Text(sourceDisplayText(source))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray6))
                            .cornerRadius(4)
                    }
                    
                    // Completion date
                    if item.isCompleted, let dateCompleted = item.dateCompleted {
                        Text("Completed \(dateCompleted, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
    
    private func sourceDisplayText(_ source: String) -> String {
        // NEW: Handle merged+converted source indicator
        if source.hasPrefix("merged+converted(") {
            let count = source.replacingOccurrences(of: "merged+converted(", with: "").replacingOccurrences(of: ")", with: "")
            return "🔀⚡ Merged (\(count))"
        }
        
        // Handle regular merged source indicator
        if source.hasPrefix("merged(") {
            let count = source.replacingOccurrences(of: "merged(", with: "").replacingOccurrences(of: ")", with: "")
            return "🔀 Merged (\(count))"
        }
        
        switch source {
        case "staples": return "📌 Staple"
        case "recipe": return "🍳 Recipe"
        case "manual": return "✏️ Added"
        default: return source.capitalized
        }
    }
}

// MARK: - Date Formatter

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let sampleList = WeeklyList(context: context)
    sampleList.id = UUID()
    sampleList.name = "Sample Grocery List"
    sampleList.dateCreated = Date()
    sampleList.isCompleted = false
    
    let item1 = GroceryListItem(context: context)
    item1.id = UUID()
    item1.name = "Bananas"
    item1.categoryName = "Produce"
    item1.displayText = "2 bunches"
    item1.numericValue = 2.0
    item1.standardUnit = "bunch"
    item1.isParseable = true
    item1.parseConfidence = 1.0
    item1.isCompleted = false
    item1.source = "staples"
    sampleList.addToItems(item1)
    
    let item2 = GroceryListItem(context: context)
    item2.id = UUID()
    item2.name = "Milk"
    item2.categoryName = "Dairy & Fridge"
    item2.displayText = "1 gallon"
    item2.numericValue = 1.0
    item2.standardUnit = "gallon"
    item2.isParseable = true
    item2.parseConfidence = 1.0
    item2.isCompleted = true
    item2.source = "staples"
    item2.dateCompleted = Date()
    sampleList.addToItems(item2)
    
    return NavigationView {
        GroceryListDetailView(weeklyList: sampleList)
    }
    .environment(\.managedObjectContext, context)
}
