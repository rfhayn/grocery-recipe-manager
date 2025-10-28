//
//  MealPlanView.swift
//  GroceryRecipeManager
//
//  Created for M4.2: Calendar-Based Meal Planning Core
//  Main calendar view showing planned meals for the active meal plan
//

import SwiftUI

// M4.2: Main meal planning calendar view
// Displays the active meal plan with recipe assignments by date
// Shows empty state when no active plan exists
struct MealPlanView: View {
    
    // MARK: - State Management
    
    // M4.2: Meal plan service for data access
    @StateObject private var mealPlanService = MealPlanService.shared
    
    // M4.2: User preferences for display options
    @StateObject private var preferences = UserPreferencesService.shared
    
    // M4.2: Track if showing create plan sheet
    @State private var showingCreatePlan = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if let plan = mealPlanService.activeMealPlan {
                    // Show calendar when active plan exists
                    calendarView(for: plan)
                } else {
                    // Show empty state when no active plan
                    EmptyMealPlanView(onCreatePlan: createNewMealPlan)
                }
            }
            .navigationTitle("Meal Planning")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if mealPlanService.activeMealPlan != nil {
                            Button {
                                archivePlan()
                            } label: {
                                Label("Archive Current Plan", systemImage: "archivebox")
                            }
                            
                            Button {
                                createNewMealPlan()
                            } label: {
                                Label("Start New Plan", systemImage: "plus.circle")
                            }
                        } else {
                            Button {
                                createNewMealPlan()
                            } label: {
                                Label("Create Meal Plan", systemImage: "plus.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePlan) {
            CreateMealPlanSheet()
        }
        .onAppear {
            // Ensure we have the latest data when view appears
            mealPlanService.loadActiveMealPlan()
        }
    }
    
    // MARK: - Calendar View
    
    // M4.2: Calendar grid showing all dates in the meal plan
    // Displays recipe assignments and allows removal
    @ViewBuilder
    private func calendarView(for plan: MealPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Plan header with name and date range
                planHeaderView(for: plan)
                
                // Calendar grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                    ForEach(mealPlanService.getDatesInMealPlan(), id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            plannedMeal: mealPlanService.getPlannedMeal(for: date),
                            showRecipeSource: preferences.showRecipeSourceInMealPlan,
                            onRemove: { meal in
                                mealPlanService.removePlannedMeal(meal)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Plan Header
    
    // M4.2: Header showing meal plan name and date range
    @ViewBuilder
    private func planHeaderView(for plan: MealPlan) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = plan.name {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if let startDate = plan.startDate {
                Text(formatDateRange(startDate: startDate, duration: Int(plan.duration)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            HStack(spacing: 16) {
                Label("\(mealPlanService.plannedMeals.count) meals", systemImage: "fork.knife")
                Label("\(Int(plan.duration)) days", systemImage: "calendar")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    // M4.2: Shows sheet for creating a new meal plan with custom dates
    private func createNewMealPlan() {
        showingCreatePlan = true
    }
    
    // M4.2: Archives the current active meal plan
    private func archivePlan() {
        mealPlanService.archiveActiveMealPlan()
    }
    
    // MARK: - Helpers
    
    // M4.2: Formats the date range for display
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

// M4.2: Individual calendar cell representing one day in the meal plan
// Shows the date and any assigned recipe
struct CalendarDayCell: View {
    let date: Date
    let plannedMeal: PlannedMeal?
    let showRecipeSource: Bool
    let onRemove: (PlannedMeal) -> Void
    
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
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date header
            VStack(alignment: .leading, spacing: 2) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Divider()
            
            // Recipe assignment or empty state
            if let meal = plannedMeal, let recipe = meal.recipe {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title ?? "Untitled Recipe")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    // Servings info
                    Text("\(meal.servings) servings")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Completed indicator
                    if meal.isCompleted {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                // Remove button
                Button(role: .destructive) {
                    onRemove(meal)
                } label: {
                    Label("Remove", systemImage: "xmark.circle.fill")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
            } else {
                Text("No meal planned")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .frame(minHeight: 140)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    // MARK: - Helpers
    
    // M4.2: Checks if this date is today
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Preview

#Preview {
    MealPlanView()
}
