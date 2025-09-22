// IngredientsView.swift
// STEP 4 PHASE 2: Unified ingredient management consolidating staples and templates
// Replaces StaplesView with comprehensive IngredientTemplate-based system

import SwiftUI
import CoreData

struct IngredientsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Core Data
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \IngredientTemplate.isStaple, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.category, ascending: true),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ],
        animation: .default
    ) private var ingredients: FetchedResults<IngredientTemplate>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
    ) private var categories: FetchedResults<Category>
    
    // MARK: - State
    
    @State private var searchText = ""
    @State private var selectedCategory: Category? = nil
    @State private var showStaplesOnly = false
    @State private var sortOption: SortOption = .alphabetical
    @State private var showingAddForm = false
    @State private var showingCategoryAssignment = false
    @State private var selectedIngredients: Set<IngredientTemplate> = []
    @State private var isEditMode = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // MARK: - Computed Properties
    
    private var filteredIngredients: [IngredientTemplate] {
        var filtered = Array(ingredients)
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { ingredient in
                let name = ingredient.name ?? ""
                let category = ingredient.category ?? ""
                return name.localizedCaseInsensitiveContains(searchText) ||
                       category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { ingredient in
                ingredient.category == selectedCategory.displayName
            }
        }
        
        // Apply staples filter
        if showStaplesOnly {
            filtered = filtered.filter { $0.isStaple }
        }
        
        // Apply sorting
        switch sortOption {
        case .alphabetical:
            filtered.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .category:
            filtered.sort {
                let cat1 = $0.category ?? "Uncategorized"
                let cat2 = $1.category ?? "Uncategorized"
                if cat1 == cat2 {
                    return ($0.name ?? "") < ($1.name ?? "")
                }
                return cat1 < cat2
            }
        case .usage:
            filtered.sort { $0.usageCount > $1.usageCount }
        case .staplesFirst:
            filtered.sort { ingredient1, ingredient2 in
                if ingredient1.isStaple != ingredient2.isStaple {
                    return ingredient1.isStaple && !ingredient2.isStaple
                }
                return (ingredient1.name ?? "") < (ingredient2.name ?? "")
            }
        }
        
        return filtered
    }
    
    private var groupedIngredients: [(key: String, value: [IngredientTemplate])] {
        let grouped = Dictionary(grouping: filteredIngredients) { ingredient in
            ingredient.category ?? "Uncategorized"
        }
        
        return grouped.sorted { pair1, pair2 in
            // Staples first within each category
            let category1 = findCategory(named: pair1.key)
            let category2 = findCategory(named: pair2.key)
            
            if let cat1 = category1, let cat2 = category2 {
                return cat1.sortOrder < cat2.sortOrder
            }
            
            return pair1.key < pair2.key
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filters and search
            headerSection
            
            // Main content
            mainContentArea
        }
        .navigationTitle("Ingredients")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Done") {
                        isEditMode = false
                        selectedIngredients.removeAll()
                    }
                } else {
                    Button("Edit") {
                        isEditMode = true
                    }
                }
                
                Button(action: { showingAddForm = true }) {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if isEditMode && !selectedIngredients.isEmpty {
                    Menu {
                        Button("Assign Category") {
                            showingCategoryAssignment = true
                        }
                        
                        Button("Toggle Staple Status") {
                            toggleStapleStatusForSelected()
                        }
                        
                        Button("Delete Selected", role: .destructive) {
                            deleteSelectedIngredients()
                        }
                    } label: {
                        Text("Actions")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            AddIngredientView()
        }
        .sheet(isPresented: $showingCategoryAssignment) {
            if !selectedIngredients.isEmpty {
                CategoryAssignmentModal(
                    uncategorizedTemplates: Array(selectedIngredients),
                    onAssignmentsComplete: {
                        selectedIngredients.removeAll()
                        isEditMode = false
                    }
                )
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search ingredients...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Filter controls
            HStack {
                // Category filter
                Menu {
                    Button("All Categories") {
                        selectedCategory = nil
                    }
                    
                    ForEach(categories, id: \.self) { category in
                        Button(category.displayName) {
                            selectedCategory = category
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory?.displayName ?? "All Categories")
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Staples filter toggle
                Button(action: { showStaplesOnly.toggle() }) {
                    HStack {
                        Image(systemName: showStaplesOnly ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(showStaplesOnly ? .blue : .secondary)
                        Text("Staples Only")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Sort options
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.displayName) {
                            sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.secondary)
                        Text(sortOption.displayName)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Main Content
    
    private var mainContentArea: some View {
        ZStack {
            if filteredIngredients.isEmpty {
                emptyStateView
            } else {
                ingredientsListView
            }
            
            if isLoading {
                loadingOverlay
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                if showStaplesOnly {
                    Text("No Staples Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Mark ingredients as staples to see them here!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else if !searchText.isEmpty {
                    Text("No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Try adjusting your search or filters")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No Ingredients Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add ingredients to build your catalog")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: { showingAddForm = true }) {
                Label("Add Ingredient", systemImage: "plus.circle.fill")
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
    
    private var ingredientsListView: some View {
        List {
            ForEach(groupedIngredients, id: \.key) { categoryName, items in
                Section(header: categoryHeader(categoryName: categoryName, count: items.count)) {
                    ForEach(items, id: \.objectID) { ingredient in
                        IngredientRowView(
                            ingredient: ingredient,
                            isSelected: selectedIngredients.contains(ingredient),
                            isEditMode: isEditMode,
                            onSelectionChanged: { isSelected in
                                if isSelected {
                                    selectedIngredients.insert(ingredient)
                                } else {
                                    selectedIngredients.remove(ingredient)
                                }
                            },
                            onStapleToggle: {
                                toggleStapleStatus(for: ingredient)
                            },
                            onCategoryAssign: {
                                selectedIngredients = [ingredient]
                                showingCategoryAssignment = true
                            }
                        )
                    }
                    .onDelete { indexSet in
                        deleteIngredients(from: items, at: indexSet)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .overlay(
                ProgressView("Processing...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
            )
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func categoryHeader(categoryName: String, count: Int) -> some View {
        HStack {
            if let category = findCategory(named: categoryName) {
                Circle()
                    .fill(Color(hex: category.displayColor))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text(categoryEmoji(for: category.displayName))
                            .font(.system(size: 12))
                    )
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Text("📦")
                            .font(.system(size: 12))
                    )
            }
            
            Text(categoryName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Fixed the problematic line here:
            let backgroundColor: Color = {
                if let category = findCategory(named: categoryName) {
                    return Color(hex: category.displayColor)
                } else {
                    return Color.gray
                }
            }()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions
    
    private func toggleStapleStatus(for ingredient: IngredientTemplate) {
        withAnimation {
            ingredient.isStaple.toggle()
            
            do {
                try viewContext.save()
            } catch {
                errorMessage = "Failed to update staple status: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func toggleStapleStatusForSelected() {
        withAnimation {
            for ingredient in selectedIngredients {
                ingredient.isStaple.toggle()
            }
            
            do {
                try viewContext.save()
                selectedIngredients.removeAll()
                isEditMode = false
            } catch {
                errorMessage = "Failed to update staple status: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func deleteSelectedIngredients() {
        withAnimation {
            for ingredient in selectedIngredients {
                viewContext.delete(ingredient)
            }
            
            do {
                try viewContext.save()
                selectedIngredients.removeAll()
                isEditMode = false
            } catch {
                errorMessage = "Failed to delete ingredients: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func deleteIngredients(from items: [IngredientTemplate], at indexSet: IndexSet) {
        withAnimation {
            for index in indexSet {
                viewContext.delete(items[index])
            }
            
            do {
                try viewContext.save()
            } catch {
                errorMessage = "Failed to delete ingredient: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findCategory(named name: String) -> Category? {
        return categories.first { $0.displayName == name }
    }
    
    private func categoryEmoji(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "produce": return "🥬"
        case "deli & meat": return "🥩"
        case "dairy & fridge": return "🥛"
        case "bread & frozen": return "🍞"
        case "boxed & canned": return "📦"
        case "snacks, drinks, & other": return "🥤"
        default: return "📦"
        }
    }
}

// MARK: - Sort Options

enum SortOption: CaseIterable {
    case alphabetical, category, usage, staplesFirst
    
    var displayName: String {
        switch self {
        case .alphabetical: return "A-Z"
        case .category: return "Category"
        case .usage: return "Usage"
        case .staplesFirst: return "Staples First"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        IngredientsView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
