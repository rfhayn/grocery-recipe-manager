//
//  WeeklyListsView.swift
//  GroceryRecipeManager
//
//  PHASE 1 UPDATE: Generate from IngredientTemplate.isStaple instead of GroceryItem.isStaple
//

import SwiftUI
import CoreData

struct WeeklyListsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WeeklyList.dateCreated, ascending: false)],
        animation: .default
    ) private var weeklyLists: FetchedResults<WeeklyList>
    
    // State management
    @State private var isGeneratingList = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var refreshID = UUID()
    
    var body: some View {
        contentView
            .navigationTitle("Grocery Lists")
            .toolbar {
                toolbarContent
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
    }
    
    private var contentView: some View {
        ZStack {
            if weeklyLists.isEmpty && !isGeneratingList {
                emptyStateView
            } else {
                listsView
            }
            
            if isGeneratingList {
                loadingOverlay
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                Text("No Grocery Lists")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Generate your first list from staples to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: generateListFromStaples) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Generate from Staples")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(isGeneratingList)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var listsView: some View {
        List {
            Section {
                ForEach(weeklyLists, id: \.self) { list in
                    NavigationLink(destination: GroceryListDetailView(weeklyList: list)) {
                        WeeklyListRowView(weeklyList: list)
                    }
                }
                .onDelete(perform: deleteWeeklyLists)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .refreshable {
            viewContext.refreshAllObjects()
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                
                VStack(spacing: 8) {
                    Text("Generating List...")
                        .font(.headline)
                    Text("Organizing by your custom categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: generateListFromStaples) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Generate")
                }
            }
            .disabled(isGeneratingList)
        }
    }
    
    // MARK: - Actions
    
    private func generateListFromStaples() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isGeneratingList = true
        }
        
        PersistenceController.shared.performWrite({ context in
            // 1. Create new WeeklyList
            let newList = WeeklyList(context: context)
            newList.id = UUID()
            newList.name = "Weekly Shopping - \(DateFormatter.shortDate.string(from: Date()))"
            newList.dateCreated = Date()
            newList.isCompleted = false
            newList.notes = "Auto-generated from ingredient staples"
            
            // 2. UPDATED: Fetch staples from IngredientTemplate instead of GroceryItem
            let stapleRequest: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
            stapleRequest.predicate = NSPredicate(format: "isStaple == YES")
            
            // Sort by category first, then by name within category
            stapleRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \IngredientTemplate.category, ascending: true),
                NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
            ]
            
            do {
                let stapleTemplates = try context.fetch(stapleRequest)
                
                print("📋 Generating list from \(stapleTemplates.count) staple templates")
                
                // 3. Create GroceryListItems from staple templates
                for (index, template) in stapleTemplates.enumerated() {
                    let listItem = GroceryListItem(context: context)
                    listItem.id = UUID()
                    listItem.name = template.name
                    
                    // Use structured quantity fields with default values
                    listItem.displayText = "1"
                    listItem.numericValue = 1.0
                    listItem.standardUnit = nil
                    listItem.isParseable = true
                    listItem.parseConfidence = 1.0
                    
                    listItem.isCompleted = false
                    listItem.source = "staples"
                    listItem.sortOrder = Int16(index)
                    
                    // UPDATED: Copy category from template
                    if let category = template.category, !category.isEmpty {
                        listItem.categoryName = category
                    } else {
                        listItem.categoryName = "Uncategorized"
                    }
                    
                    // Link to the weekly list
                    newList.addToItems(listItem)
                    
                    print("  ✓ Added '\(template.name ?? "Unknown")' in category '\(listItem.categoryName ?? "None")'")
                }
                
                print("✅ Generated grocery list with \(stapleTemplates.count) items from ingredient templates")
                
            } catch {
                print("❌ Error fetching staple templates: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch staples: \(error.localizedDescription)"
                    self.showingError = true
                    self.isGeneratingList = false
                }
                return
            }
            
        }, onError: { error in
            DispatchQueue.main.async {
                errorMessage = "Failed to generate list: \(error.localizedDescription)"
                showingError = true
                isGeneratingList = false
            }
        })
        
        // Hide loading after a brief delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isGeneratingList = false
            }
        }
    }
    
    private func deleteWeeklyLists(offsets: IndexSet) {
        let listsToDelete = offsets.map { weeklyLists[$0] }
        
        for list in listsToDelete {
            let listID = list.objectID
            PersistenceController.shared.performWrite({ context in
                let listToDelete = context.object(with: listID)
                context.delete(listToDelete) // Cascade delete will handle items
                print("✅ Deleted weekly list: \(list.name ?? "Unnamed")")
            }, onError: { error in
                errorMessage = "Failed to delete list: \(error.localizedDescription)"
                showingError = true
            })
        }
    }
}

// MARK: - Enhanced WeeklyListRowView Component

struct WeeklyListRowView: View {
    @ObservedObject var weeklyList: WeeklyList
    
    // Calculate real-time data from the relationship
    private var itemsArray: [GroceryListItem] {
        return (weeklyList.items as? Set<GroceryListItem>)?.sorted {
            $0.sortOrder < $1.sortOrder
        } ?? []
    }
    
    private var completedItemsCount: Int {
        itemsArray.filter { $0.isCompleted }.count
    }
    
    private var totalItemsCount: Int {
        itemsArray.count
    }
    
    private var completionPercentage: Double {
        guard totalItemsCount > 0 else { return 0 }
        return Double(completedItemsCount) / Double(totalItemsCount)
    }
    
    // Use calculated completion status for accuracy
    private var isListCompleted: Bool {
        return totalItemsCount > 0 && completedItemsCount == totalItemsCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weeklyList.name ?? "Unnamed List")
                        .font(.headline)
                        .foregroundColor(isListCompleted ? .secondary : .primary)
                    
                    if let date = weeklyList.dateCreated {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isListCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            // Progress bar
            if totalItemsCount > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(completedItemsCount) of \(totalItemsCount) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: completionPercentage)
                        .tint(completionPercentage == 1.0 ? .green : .blue)
                }
            } else {
                Text("Empty list")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        WeeklyListsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
