//
//  MealPlanDetailView.swift
//  GroceryRecipeManager
//
//  Refactored for M4.2.4 Phase 5: Multiple Meal Plans List View
//  Adapted from MealPlanView to accept a passed meal plan parameter
//  Displays calendar view for a specific meal plan
//

import SwiftUI
import CoreData

// M4.2.4 PHASE 5: Meal plan detail view with calendar display
// Accepts a meal plan as a parameter (instead of fetching active plan)
// Shows calendar grid with recipe assignments for the specific plan
struct MealPlanDetailView: View {
    
    // MARK: - Properties
    
    // M4.2.4: The meal plan to display (passed from list view)
    @ObservedObject var mealPlan: MealPlan
    
    // M4.2.4: Core Data context for fetching planned meals
    @Environment(\.managedObjectContext) private var viewContext
    
    // M4.2.4: Fetch planned meals for THIS specific meal plan
    // Filtered by plan ID to show only meals in this plan
    @FetchRequest private var plannedMeals: FetchedResults<PlannedMeal>
    
    // M4.2.4: User preferences for display options
    @StateObject private var preferences = UserPreferencesService.shared
    
    // M4.2.4: Meal plan service for operations
    @StateObject private var mealPlanService = MealPlanService.shared
    
    // MARK: - Initialization
    
    // M4.2.4: Initialize with specific meal plan
    // Configures FetchRequest to filter planned meals by this plan's ID
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
                
                // Calendar grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                    ForEach(getDatesInMealPlan(), id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            plannedMeal: getPlannedMeal(for: date),
                            showRecipeSource: preferences.showRecipeSourceInMealPlan,
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
        .navigationTitle(mealPlan.name ?? "Meal Plan")
        .navigationBarTitleDisplayMode(.inline)
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
    
    // MARK: - Helper Functions
    
    // M4.2.4: Generate array of dates in this meal plan
    // Creates date for each day from start to start + duration
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
    // Searches fetched plannedMeals for matching date
    private func getPlannedMeal(for date: Date) -> PlannedMeal? {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        return plannedMeals.first { meal in
            guard let mealDate = meal.date else { return false }
            let mealStartOfDay = calendar.startOfDay(for: mealDate)
            return mealStartOfDay == targetDate
        }
    }
    
    // M4.2.4: Remove a planned meal from this plan
    // Deletes the meal and saves context
    private func removePlannedMeal(_ meal: PlannedMeal) {
        viewContext.delete(meal)
        
        do {
            try viewContext.save()
        } catch {
            print("Error removing planned meal: \(error)")
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
