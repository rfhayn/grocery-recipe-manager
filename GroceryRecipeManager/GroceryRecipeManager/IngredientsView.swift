// IngredientsView.swift
// STEP 4 PHASE 2: Complete unified ingredient template and staple management system

import SwiftUI
import CoreData

struct IngredientsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Core Data Fetch
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \IngredientTemplate.isStaple, ascending: false),
            NSSortDescriptor(keyPath: \IngredientTemplate.category, ascending: true),
            NSSortDescriptor(keyPath: \IngredientTemplate.name, ascending: true)
        ],
        animation: .default
    ) private var ingredients: FetchedResults<IngredientTemplate>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    // MARK: - State Variables
    @State private var searchText = ""
    @State private var selectedCategory = "All Categories"
    @State private var showStaplesOnly = false
    @State private var sortOption: SortOption = .staplesFirst
    @State private var isEditMode = false
    @State private var selectedIngredients: Set<IngredientTemplate> = []
    @State private var showingAddForm = false
    @State private var showingCategoryAssignment = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var ingredientForCategoryAssignment: IngredientTemplate?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                searchAndFilterSection
                
                // Main Content
                if filteredIngredients.isEmpty {
                    emptyStateView
                } else {
                    ingredientsListView
                }
            }
            .navigationTitle("Ingredients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Ingredient", systemImage: "plus.circle") {
                            showingAddForm = true
                        }
                        
                        if isEditMode && !selectedIngredients.isEmpty {
                            Divider()
                            
                            Button("Mark as Staples", systemImage: "pin.fill") {
                                markSelectedAsStaples(true)
                            }
                            
                            Button("Remove Staple Status", systemImage: "pin.slash") {
                                markSelectedAsStaples(false)
                            }
                            
                            Divider()
                            
                            Button("Delete Selected", systemImage: "trash", role: .destructive) {
                                bulkDeleteSelected()
                            }
                        }
                    } label: {
                        Image(systemName: isEditMode && !selectedIngredients.isEmpty ? "ellipsis.circle.fill" : "plus")
                            .foregroundColor(isEditMode && !selectedIngredients.isEmpty ? .blue : .primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        if isEditMode {
                            Button("Done") {
                                withAnimation {
                                    isEditMode = false
                                    selectedIngredients.removeAll()
                                }
                            }
                        } else {
                            Button("Edit") {
                                withAnimation {
                                    isEditMode = true
                                }
                            }
                            .disabled(ingredients.isEmpty)
                        }
                        
                        if isEditMode {
                            Text("(\(ingredients.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddIngredientView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search ingredients...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter Controls
            HStack {
                // Category Filter
                Menu {
                    Button("All Categories") {
                        selectedCategory = "All Categories"
                    }
                    
                    ForEach(categories, id: \.self) { category in
                        Button(category.displayName) {
                            selectedCategory = category.displayName
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Staples Only Toggle
                Button(action: { showStaplesOnly.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: showStaplesOnly ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(showStaplesOnly ? .blue : .secondary)
                        Text("Staples Only")
                            .font(.subheadline)
                            .foregroundColor(showStaplesOnly ? .blue : .secondary)
                    }
                }
                
                Spacer()
                
                // Sort Options
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            HStack {
                                Text(option.displayName)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.displayName)
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 4)
            
            // Edit Mode Info
            if isEditMode && !selectedIngredients.isEmpty {
                Text("\(selectedIngredients.count) selected")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    private var filteredIngredients: [IngredientTemplate] {
        var filtered = Array(ingredients)
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { ingredient in
                ingredient.name?.lowercased().contains(searchText.lowercased()) == true
            }
        }
        
        // Apply category filter
        if selectedCategory != "All Categories" {
            filtered = filtered.filter { ingredient in
                ingredient.category == selectedCategory
            }
        }
        
        // Apply staples only filter
        if showStaplesOnly {
            filtered = filtered.filter { $0.isStaple }
        }
        
        // Apply sorting
        switch sortOption {
        case .alphabetical:
            filtered.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .category:
            filtered.sort {
                if ($0.category ?? "") == ($1.category ?? "") {
                    return ($0.name ?? "") < ($1.name ?? "")
                }
                return ($0.category ?? "") < ($1.category ?? "")
            }
        case .usage:
            filtered.sort {
                if $0.usageCount == $1.usageCount {
                    return ($0.name ?? "") < ($1.name ?? "")
                }
                return $0.usageCount > $1.usageCount
            }
        case .staplesFirst:
            filtered.sort {
                if $0.isStaple == $1.isStaple {
                    if ($0.category ?? "") == ($1.category ?? "") {
                        return ($0.name ?? "") < ($1.name ?? "")
                    }
                    return ($0.category ?? "") < ($1.category ?? "")
                }
                return $0.isStaple && !$1.isStaple
            }
        }
        
        return filtered
    }
    
    private var groupedIngredients: [(key: String, value: [IngredientTemplate])] {
        let grouped = Dictionary(grouping: filteredIngredients) { ingredient in
            ingredient.category ?? "Uncategorized"
        }
        
        return grouped.sorted { first, second in
            let firstCategory = categories.first { $0.displayName == first.key }
            let secondCategory = categories.first { $0.displayName == second.key }
            
            if let firstOrder = firstCategory?.sortOrder,
               let secondOrder = secondCategory?.sortOrder {
                return firstOrder < secondOrder
            } else if firstCategory != nil && secondCategory == nil {
                return true
            } else if firstCategory == nil && secondCategory != nil {
                return false
            } else {
                return first.key < second.key
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "leaf.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                if filteredIngredients.isEmpty && ingredients.isEmpty {
                    Text("No Ingredients Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add ingredients to build your catalog")
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
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Ingredients List View
    private var ingredientsListView: some View {
        List {
            ForEach(groupedIngredients, id: \.key) { categoryName, items in
                Section(header: categoryHeader(categoryName: categoryName, count: items.count)) {
                    ForEach(items, id: \.self) { ingredient in
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
                                ingredientForCategoryAssignment = ingredient
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
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Category Header
    private func categoryHeader(categoryName: String, count: Int) -> some View {
        HStack {
            Circle()
                .fill(categoryColor(for: categoryName))
                .frame(width: 16, height: 16)
                .overlay(
                    Text(categoryEmoji(for: categoryName))
                        .font(.system(size: 10))
                )
            
            Text(categoryName.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(6)
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
                ingredient.isStaple.toggle()
            }
        }
    }
    
    private func markSelectedAsStaples(_ isStaple: Bool) {
        withAnimation {
            for ingredient in selectedIngredients {
                ingredient.isStaple = isStaple
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
    
    private func bulkDeleteSelected() {
        guard !selectedIngredients.isEmpty else { return }
        
        withAnimation {
            for ingredient in selectedIngredients {
                viewContext.delete(ingredient)
            }
            
            do {
                try viewContext.save()
                selectedIngredients.removeAll()
                isEditMode = false
            } catch {
                errorMessage = "Failed to delete selected ingredients: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func deleteIngredients(from items: [IngredientTemplate], at indexSet: IndexSet) {
        withAnimation {
            for index in indexSet {
                let ingredient = items[index]
                selectedIngredients.remove(ingredient)
                viewContext.delete(ingredient)
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
    private func categoryColor(for categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "produce": return .green
        case "deli & meat": return .red
        case "dairy & fridge": return .blue
        case "bread & frozen": return .orange
        case "boxed & canned": return .brown
        case "snacks, drinks, & other": return .purple
        default: return .gray
        }
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

// MARK: - Add Ingredient View
struct AddIngredientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var ingredientName = ""
    @State private var selectedCategory = "Uncategorized"
    @State private var isStaple = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.sortOrder, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<Category>
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Ingredient Name", text: $ingredientName)
                        .autocapitalization(.words)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.displayName).tag(category.displayName)
                        }
                    }
                    
                    Toggle("Mark as Staple", isOn: $isStaple)
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIngredient()
                    }
                    .disabled(ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveIngredient() {
        let trimmedName = ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        let request: NSFetchRequest<IngredientTemplate> = IngredientTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", trimmedName)
        
        do {
            let existingIngredients = try viewContext.fetch(request)
            if !existingIngredients.isEmpty {
                errorMessage = "An ingredient with this name already exists"
                showingError = true
                return
            }
        } catch {
            errorMessage = "Failed to check for duplicates: \(error.localizedDescription)"
            showingError = true
            return
        }
        
        let newIngredient = IngredientTemplate(context: viewContext)
        newIngredient.id = UUID()
        newIngredient.name = trimmedName
        newIngredient.category = selectedCategory
        newIngredient.isStaple = isStaple
        newIngredient.usageCount = 0
        newIngredient.dateCreated = Date()
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Failed to save ingredient: \(error.localizedDescription)"
            showingError = true
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
