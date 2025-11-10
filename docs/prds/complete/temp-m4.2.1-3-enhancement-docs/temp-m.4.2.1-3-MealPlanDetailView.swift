//
//  MealPlanDetailView.swift
//  GroceryRecipeManager
//
//  Enhanced for M4.2.1-3: Calendar Recipe Assignment with Tap-to-Add
//  Displays calendar view for a specific meal plan with recipe assignment
//  Users can tap any day to add a recipe
//

import SwiftUI
import CoreData

// M4.2.1-3: Meal plan detail view with calendar display and tap-to-add
// Shows calendar grid with recipe assignments for the specific plan
// Allows tapping on any day to add or change recipes
struct MealPlanDetailView: View {
    
    // MARK: - Properties
    
    // M4.2.4: The meal plan to display (passed from list view)
    @ObservedObject var mealPlan: MealPlan
    
    // M4.2.4: Core Data context for fetching planned meals
    @Environment(\.managedObjectContext) private var viewContext
    
    // M4.2.4: Fetch planned meals for THIS specific meal plan
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    // M4.2.4: User preferences for display options
    @StateObject private var preferences = UserPreferencesService.shared
    
    // M4.2.1-3 ENHANCEMENT: State for showing recipe picker
    // FIXED: Use item-based sheet to prevent blank-first-render bug
    @State private var recipePickerPayload: RecipePickerPayload?
    
    // M4.2.1-3 ENHANCEMENT: State for showing replace confirmation
    @State private var showingReplaceAlert = false
    @State private var recipeToReplace: PlannedMeal?
    
    // MARK: - Initialization
    
    // M4.2.4: Initialize with specific meal plan
    init(mealPlan: MealPlan) {
        self.mealPlan = mealPlan
        
        // Configure FetchRequest to fetch only meals for this plan
        let planID = mealPlan.id ?? UUID()
        let predicate = NSPredicate(format: "mealPlan.id == %@", planID as CVarArg)
        
        _plannedMeals = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \PlannedMeal.date, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Plan header with name and date range
                planHeaderView
                
                // Help text for tap-to-add
                helpTextView
                
                // Calendar grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                    ForEach(getDatesInMealPlan(), id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            plannedMeal: getPlannedMeal(for: date),
                            showRecipeSource: preferences.showRecipeSourceInMealPlan,
                            onTap: {
                                handleDayTap(date: date)
                            },
                            onRemove: { meal in
                                removePlannedMeal(meal)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(mealPlan.name ?? formatDateRange(startDate: mealPlan.startDate ?? Date(), duration: Int(mealPlan.duration)))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $recipePickerPayload) { payload in
            RecipePickerSheet(
                date: payload.date,
                mealPlan: payload.mealPlan,
                onRecipeSelected: { _ in
                    // Recipe was added successfully
                    recipePickerPayload = nil
                }
            )
            .environment(\.managedObjectContext, viewContext)
        }
        .alert("Replace Recipe?", isPresented: $showingReplaceAlert) {
            Button("Cancel", role: .cancel) {
                recipeToReplace = nil
            }
            
            Button("Replace", role: .destructive) {
                if let meal = recipeToReplace, let date = meal.date {
                    removePlannedMeal(meal)
                    // FIXED: Create payload after removal
                    recipePickerPayload = RecipePickerPayload(date: date, mealPlan: mealPlan)
                }
            }
        } message: {
            if let meal = recipeToReplace,
               let recipe = meal.recipe {
                Text("This will remove '\(recipe.title ?? "Untitled")' from this day and let you select a new recipe.")
            }
        }
    }
    
    // MARK: - Plan Header
    
    // M4.2.4: Header showing meal plan name and date range
    private var planHeaderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = mealPlan.name {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if let startDate = mealPlan.startDate {
                Text(formatDateRange(startDate: startDate, duration: Int(mealPlan.duration)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            HStack(spacing: 16) {
                Label("\(plannedMeals.count) meals", systemImage: "fork.knife")
                Label("\(Int(mealPlan.duration)) days", systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Help Text
    
    // M4.2.1-3 ENHANCEMENT: Help text explaining tap-to-add functionality
    private var helpTextView: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            
            Text("Tap any day to add or change recipes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    // MARK: - Actions
    
    // M4.2.1-3 ENHANCEMENT: Handle tap on calendar day cell
    // Opens recipe picker for empty days or shows replace alert for occupied days
    // FIXED: Create payload for item-based sheet presentation
    private func handleDayTap(date: Date) {
        // Check if this date already has a meal
        if let existingMeal = getPlannedMeal(for: date) {
            // Show replace confirmation
            recipeToReplace = existingMeal
            showingReplaceAlert = true
        } else {
            // No meal on this date - show recipe picker with payload
            recipePickerPayload = RecipePickerPayload(date: date, mealPlan: mealPlan)
        }
    }
    
    // M4.2.4: Remove a planned meal from this plan
    private func removePlannedMeal(_ meal: PlannedMeal) {
        viewContext.delete(meal)
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing planned meal: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    
    // M4.2.4: Generate array of dates in this meal plan
    private func getDatesInMealPlan() -> [Date] {
        guard let startDate = mealPlan.startDate else { return [] }
        
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for dayOffset in 0..<Int(mealPlan.duration) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        
        return dates
    }
    
    // M4.2.4: Get planned meal for a specific date in this plan
    private func getPlannedMeal(for date: Date) -> PlannedMeal? {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        return plannedMeals.first { meal in
            guard let mealDate = meal.date else { return false }
            let mealStartOfDay = calendar.startOfDay(for: mealDate)
            return mealStartOfDay == targetDate
        }
    }
    
    // M4.2.4: Format date range for display
    private func formatDateRange(startDate: Date, duration: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let calendar = Calendar.current
        if let endDate = calendar.date(byAdding: .day, value: duration - 1, to: startDate) {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
        
        return formatter.string(from: startDate)
    }
}

// MARK: - Calendar Day Cell

// M4.2.1-3 ENHANCED: Individual calendar cell with tap-to-add functionality
// Shows the date and any assigned recipe, tappable to add/change recipe
struct CalendarDayCell: View {
    let date: Date
    let plannedMeal: PlannedMeal?
    let showRecipeSource: Bool
    let onTap: () -> Void  // M4.2.1-3 ENHANCEMENT: Tap handler
    let onRemove: (PlannedMeal) -> Void
    
    // MARK: - State
    
    @State private var showingRemoveConfirmation = false
    
    // MARK: - Date Formatting
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, etc.
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // Oct 27
        return formatter
    }
    
    // MARK: - Computed Properties
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date header
            VStack(alignment: .leading, spacing: 2) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isToday ? .blue : .secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Recipe content or empty state
            if let meal = plannedMeal,
               let recipe = meal.recipe {
                recipeContentView(meal: meal, recipe: recipe)
            } else {
                emptyDayView
            }
        }
        .padding(12)
        .frame(minHeight: 120)
        .background(cellBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())  // M4.2.1-3: Makes entire cell tappable
        .onTapGesture {  // M4.2.1-3 ENHANCEMENT: Tap to add/change recipe
            onTap()
        }
        .alert("Remove Recipe?", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let meal = plannedMeal {
                    onRemove(meal)
                }
            }
        } message: {
            if let recipe = plannedMeal?.recipe {
                Text("Remove '\(recipe.title ?? "Untitled")' from \(dateFormatter.string(from: date))?")
            }
        }
    }
    
    // MARK: - Recipe Content View
    
    // M4.2: Shows assigned recipe with details
    @ViewBuilder
    private func recipeContentView(meal: PlannedMeal, recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "fork.knife.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Spacer()
                
                // Remove button (long press or context menu alternative)
                Button {
                    showingRemoveConfirmation = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            Text(recipe.title ?? "Untitled Recipe")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            // Servings info
            if meal.servings > 0 {
                Text("\(Int(meal.servings)) servings")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Recipe source (if enabled in preferences)
            if showRecipeSource,
               let sourceURL = recipe.sourceURL,
               !sourceURL.isEmpty {
                Text(sourceURL)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Empty Day View
    
    // M4.2.1-3 ENHANCED: Shows "Tap to add" prompt for empty days
    private var emptyDayView: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .font(.title2)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Tap to add")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Cell Background Color
    
    private var cellBackgroundColor: Color {
        if plannedMeal != nil {
            return Color(UIColor.systemBackground)
        } else {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
}

// MARK: - Preview

#Preview("With Meals") {
    let context = PersistenceController.preview.container.viewContext
    
    // Create sample meal plan
    let plan = MealPlan(context: context)
    plan.id = UUID()
    plan.name = "This Week's Meals"
    plan.startDate = Date()
    plan.duration = 7
    plan.isActive = true
    
    // Create sample recipes
    let recipe1 = Recipe(context: context)
    recipe1.id = UUID()
    recipe1.title = "Spaghetti Carbonara"
    recipe1.servings = 4
    
    let recipe2 = Recipe(context: context)
    recipe2.id = UUID()
    recipe2.title = "Chicken Stir Fry"
    recipe2.servings = 4
    
    // Create planned meals
    let meal1 = PlannedMeal(context: context)
    meal1.id = UUID()
    meal1.date = Date()
    meal1.servings = 4
    meal1.recipe = recipe1
    meal1.mealPlan = plan
    
    let meal2 = PlannedMeal(context: context)
    meal2.id = UUID()
    meal2.date = Calendar.current.date(byAdding: .day, value: 2, to: Date())
    meal2.servings = 4
    meal2.recipe = recipe2
    meal2.mealPlan = plan
    
    try? context.save()
    
    return NavigationView {
        MealPlanDetailView(mealPlan: plan)
    }
    .environment(\.managedObjectContext, context)
}

#Preview("Empty Plan") {
    let context = PersistenceController.preview.container.viewContext
    
    let plan = MealPlan(context: context)
    plan.id = UUID()
    plan.name = nil  // Auto-generated name
    plan.startDate = Date()
    plan.duration = 7
    plan.isActive = false
    
    return NavigationView {
        MealPlanDetailView(mealPlan: plan)
    }
    .environment(\.managedObjectContext, context)
}