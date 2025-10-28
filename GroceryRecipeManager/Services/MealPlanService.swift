//
//  MealPlanService.swift
//  GroceryRecipeManager
//
//  Created for M4.2: Calendar-Based Meal Planning Core
//  Manages meal plans and recipe assignments to dates
//

import Foundation
import CoreData
import Combine

// M4.2: Meal plan management service
// Handles creation, retrieval, and management of meal plans
// Integrates with UserPreferencesService for user-configured defaults
@MainActor
class MealPlanService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = MealPlanService()
    
    // MARK: - Published Properties
    
    // M4.2: Current active meal plan
    // Published for real-time UI updates when plan changes
    @Published var activeMealPlan: MealPlan?
    
    // M4.2: All planned meals in the active plan
    // Used by calendar view for displaying recipe assignments
    @Published var plannedMeals: [PlannedMeal] = []
    
    // M4.2: Performance tracking for service operations
    // Monitors operation duration to ensure < 0.1s target
    @Published var lastOperationDuration: TimeInterval = 0
    
    // M4.2: Error state for UI display
    // Published to allow views to show error messages
    @Published var lastError: Error?
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    // M4.2: Private initializer for singleton pattern
    // Loads active meal plan on initialization
    private init() {
        self.context = PersistenceController.shared.container.viewContext
        loadActiveMealPlan()
    }
    
    // MARK: - Meal Plan Management
    
    // M4.2: Loads the currently active meal plan
    // Only one meal plan should be active at a time
    // Performance target: < 0.1s
    func loadActiveMealPlan() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let fetchRequest: NSFetchRequest<MealPlan> = MealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isActive == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let plans = try context.fetch(fetchRequest)
            activeMealPlan = plans.first
            
            // Load planned meals if we have an active plan
            if let plan = activeMealPlan {
                loadPlannedMeals(for: plan)
            } else {
                plannedMeals = []
            }
            
            lastOperationDuration = CFAbsoluteTimeGetCurrent() - startTime
        } catch {
            lastError = error
            print("Error loading active meal plan: \(error)")
        }
    }
    
    // M4.2: Creates a new meal plan using user preferences
    // Automatically sets as active and deactivates any existing active plans
    // Uses UserPreferencesService for duration and start day defaults
    func createMealPlan(startDate: Date? = nil) -> MealPlan? {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Deactivate any existing active plans
        deactivateAllPlans()
        
        let plan = MealPlan(context: context)
        plan.id = UUID()
        plan.createdDate = Date()
        plan.isActive = true
        
        // Use provided start date or calculate from user preferences
        let prefs = UserPreferencesService.shared
        let calculatedStartDate = startDate ?? calculateStartDate(using: prefs.mealPlanStartDay)
        plan.startDate = calculatedStartDate
        plan.duration = Int16(prefs.mealPlanDuration)
        
        // Auto-generate name if enabled in preferences
        if prefs.autoNameMealPlans {
            plan.name = generateMealPlanName(for: calculatedStartDate)
        }
        
        do {
            try context.save()
            activeMealPlan = plan
            plannedMeals = [] // New plan has no meals yet
            lastOperationDuration = CFAbsoluteTimeGetCurrent() - startTime
            return plan
        } catch {
            lastError = error
            print("Error creating meal plan: \(error)")
            context.rollback()
            return nil
        }
    }
    
    // M4.2: Archives the current active meal plan
    // Sets isActive to false and records completion date
    // Useful when starting a new planning period
    func archiveActiveMealPlan() {
        guard let plan = activeMealPlan else { return }
        
        plan.isActive = false
        plan.completedDate = Date()
        
        do {
            try context.save()
            activeMealPlan = nil
            plannedMeals = []
        } catch {
            lastError = error
            print("Error archiving meal plan: \(error)")
            context.rollback()
        }
    }
    
    // M4.2: Deletes a meal plan and all its planned meals
    // Cascade delete rule automatically removes associated PlannedMeal records
    func deleteMealPlan(_ plan: MealPlan) {
        context.delete(plan)
        
        do {
            try context.save()
            if plan == activeMealPlan {
                activeMealPlan = nil
                plannedMeals = []
            }
        } catch {
            lastError = error
            print("Error deleting meal plan: \(error)")
            context.rollback()
        }
    }
    
    // MARK: - Planned Meal Management
    
    // M4.2: Loads all planned meals for a specific meal plan
    // Sorted by date ascending for calendar display
    // Performance target: < 0.1s
    private func loadPlannedMeals(for plan: MealPlan) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let fetchRequest: NSFetchRequest<PlannedMeal> = PlannedMeal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mealPlan == %@", plan)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.relationshipKeyPathsForPrefetching = ["recipe"] // Optimize for calendar display
        
        do {
            plannedMeals = try context.fetch(fetchRequest)
            lastOperationDuration = CFAbsoluteTimeGetCurrent() - startTime
        } catch {
            lastError = error
            print("Error loading planned meals: \(error)")
        }
    }
    
    // M4.2: Adds a recipe to a specific date in the active meal plan
    // Enforces one-recipe-per-day constraint by checking for existing meals
    // Returns the created PlannedMeal or nil if date already has a meal
    func addRecipeToMealPlan(recipe: Recipe, date: Date, servings: Int16? = nil) -> PlannedMeal? {
        guard let plan = activeMealPlan else {
            print("No active meal plan to add recipe to")
            return nil
        }
        
        // Check if date already has a planned meal
        if hasPlannedMeal(on: date) {
            print("Date \(date) already has a planned meal")
            return nil
        }
        
        let plannedMeal = PlannedMeal(context: context)
        plannedMeal.id = UUID()
        plannedMeal.date = date
        plannedMeal.servings = servings ?? recipe.servings
        plannedMeal.scaleFactor = Double(plannedMeal.servings) / Double(recipe.servings)
        plannedMeal.isCompleted = false
        plannedMeal.createdDate = Date()
        plannedMeal.mealPlan = plan
        plannedMeal.recipe = recipe
        
        do {
            try context.save()
            loadPlannedMeals(for: plan) // Reload to update published array
            return plannedMeal
        } catch {
            lastError = error
            print("Error adding recipe to meal plan: \(error)")
            context.rollback()
            return nil
        }
    }
    
    // M4.2: Removes a planned meal from the meal plan
    // Updates plannedMeals array to reflect removal in UI
    func removePlannedMeal(_ meal: PlannedMeal) {
        guard let plan = activeMealPlan else { return }
        
        context.delete(meal)
        
        do {
            try context.save()
            loadPlannedMeals(for: plan) // Reload to update published array
        } catch {
            lastError = error
            print("Error removing planned meal: \(error)")
            context.rollback()
        }
    }
    
    // M4.2: Marks a planned meal as completed
    // Records completion date for tracking purposes
    func markMealAsCompleted(_ meal: PlannedMeal) {
        meal.isCompleted = true
        meal.completedDate = Date()
        
        do {
            try context.save()
        } catch {
            lastError = error
            print("Error marking meal as completed: \(error)")
            context.rollback()
        }
    }
    
    // M4.2: Updates the servings for a planned meal
    // Recalculates scale factor based on original recipe servings
    func updateServings(for meal: PlannedMeal, servings: Int16) {
        guard let recipe = meal.recipe else { return }
        
        meal.servings = servings
        meal.scaleFactor = Double(servings) / Double(recipe.servings)
        
        do {
            try context.save()
        } catch {
            lastError = error
            print("Error updating servings: \(error)")
            context.rollback()
        }
    }
    
    // MARK: - Query Helpers
    
    // M4.2: Checks if a specific date already has a planned meal
    // Used to enforce one-recipe-per-day constraint
    func hasPlannedMeal(on date: Date) -> Bool {
        // Compare dates by day, ignoring time
        let calendar = Calendar.current
        return plannedMeals.contains { meal in
            guard let mealDate = meal.date else { return false }
            return calendar.isDate(mealDate, inSameDayAs: date)
        }
    }
    
    // M4.2: Gets the planned meal for a specific date
    // Returns nil if no meal planned for that date
    func getPlannedMeal(for date: Date) -> PlannedMeal? {
        let calendar = Calendar.current
        return plannedMeals.first { meal in
            guard let mealDate = meal.date else { return false }
            return calendar.isDate(mealDate, inSameDayAs: date)
        }
    }
    
    // M4.2: Gets all dates that are within the current meal plan period
    // Used by calendar view to display the planning period
    func getDatesInMealPlan() -> [Date] {
        guard let plan = activeMealPlan,
              let startDate = plan.startDate else {
            return []
        }
        
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for day in 0..<Int(plan.duration) {
            if let date = calendar.date(byAdding: .day, value: day, to: startDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // MARK: - Private Helpers
    
    // M4.2: Deactivates all currently active meal plans
    // Ensures only one plan is active at a time
    private func deactivateAllPlans() {
        let fetchRequest: NSFetchRequest<MealPlan> = MealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            let plans = try context.fetch(fetchRequest)
            for plan in plans {
                plan.isActive = false
            }
            try context.save()
        } catch {
            print("Error deactivating plans: \(error)")
        }
    }
    
    // M4.2: Calculates the start date for a new meal plan
    // Uses the user's preferred start day (0=Sunday, 6=Saturday)
    // Finds the next occurrence of that day from today
    private func calculateStartDate(using preferredStartDay: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Get today's weekday (1=Sunday, 7=Saturday)
        let todayWeekday = calendar.component(.weekday, from: today)
        
        // Convert our 0-based index (0=Sunday) to Calendar's 1-based (1=Sunday)
        let targetWeekday = preferredStartDay + 1
        
        // Calculate days to add to reach the target weekday
        var daysToAdd = targetWeekday - todayWeekday
        if daysToAdd <= 0 {
            daysToAdd += 7 // Move to next week if target day has passed
        }
        
        // Return the calculated start date
        return calendar.date(byAdding: .day, value: daysToAdd, to: today) ?? today
    }
    
    // M4.2: Generates a user-friendly name for a meal plan
    // Format: "Week of Oct 27" or "Week of Oct 27 - Nov 2"
    private func generateMealPlanName(for startDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        
        // If plan is 7 days, show single week format
        // Otherwise show date range
        let prefs = UserPreferencesService.shared
        if prefs.mealPlanDuration == 7 {
            return "Week of \(formatter.string(from: startDate))"
        } else {
            if let endDate = calendar.date(byAdding: .day, value: prefs.mealPlanDuration - 1, to: startDate) {
                return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
            }
            return "Week of \(formatter.string(from: startDate))"
        }
    }
    
    // MARK: - Performance Validation
    
    // M4.2: Validates service performance meets targets
    // Target: < 0.1s for all operations
    func validatePerformance() -> Bool {
        return lastOperationDuration < 0.1
    }
}
