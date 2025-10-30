//
//  SelectMealPlanSheet.swift
//  GroceryRecipeManager
//
//  Created for M4.2.4: Multiple Meal Plans List View
//  Sheet for selecting which meal plan and date to assign a recipe to
//  Used when "Add to Meal Plan" is tapped from recipe views
//

import SwiftUI
import CoreData

// M4.2.4: Sheet for selecting meal plan and date for recipe assignment
// Pre-selects active plan for convenience
// Allows creating new plan if needed
struct SelectMealPlanSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // M4.2.4: Recipe being added to meal plan
    let recipe: Recipe
    
    // M4.2.4: Callback when plan and date selected
    let onSelect: (MealPlan, Date) -> Void
    
    // M4.2.4: Fetch all non-completed meal plans
    // Only show active and upcoming plans as assignment targets
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MealPlan.startDate, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == NO"),
        animation: .default
    ) private var availablePlans: FetchedResults<MealPlan>
    
    // M4.2.4: Sheet state
    @State private var selectedPlan: MealPlan?
    @State private var selectedDate = Date()
    @State private var showingCreatePlan = false
    @State private var existingRecipeOnDate: PlannedMeal?
    @State private var showingReplaceConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                // M4.2.4: Recipe info section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title ?? "Unnamed Recipe")
                                .font(.headline)
                            
                            Text("\(recipe.servings) servings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Recipe")
                }
                
                // M4.2.4: Meal plan selection
                Section {
                    if availablePlans.isEmpty {
                        // No plans available - prompt to create
                        VStack(spacing: 12) {
                            Text("No meal plans available")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showingCreatePlan = true }) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Create Meal Plan")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    } else {
                        // Show available plans
                        Picker("Meal Plan", selection: $selectedPlan) {
                            Text("Select a plan").tag(nil as MealPlan?)
                            
                            ForEach(availablePlans, id: \.self) { plan in
                                Label {
                                    Text(planDisplayName(for: plan))
                                } icon: {
                                    if plan.isActive {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .tag(plan as MealPlan?)
                            }
                        }
                        .onChange(of: selectedPlan) { newPlan in
                            // M4.2.4: When plan changes, update selected date
                            if let plan = newPlan {
                                updateSelectedDate(for: plan)
                            }
                        }
                        
                        // M4.2.4: Option to create new plan
                        Button(action: { showingCreatePlan = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Create New Plan")
                            }
                        }
                    }
                } header: {
                    Text("Select Meal Plan")
                } footer: {
                    // M4.2.4: Footer must always return a view in ViewBuilder
                    if selectedPlan != nil {
                        Text("Active plan pre-selected for convenience")
                            .font(.caption)
                    } else {
                        Text("Choose a meal plan to continue")
                            .font(.caption)
                    }
                }
                
                // M4.2.4: Date selection (only show if plan selected)
                if let plan = selectedPlan {
                    Section {
                        DatePicker(
                            "Date",
                            selection: $selectedDate,
                            in: dateRange(for: plan),
                            displayedComponents: [.date]
                        )
                        .onChange(of: selectedDate) { _ in
                            checkForExistingRecipe()
                        }
                        
                        // M4.2.4: Warning if date already has a recipe
                        if let existing = existingRecipeOnDate {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Date Already Planned")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                    
                                    // M4.2.4: Must return a view in both branches
                                    if let existingRecipe = existing.recipe {
                                        Text("\(existingRecipe.title ?? "Unknown") is already assigned to this date")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("A recipe is already assigned to this date")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Select Date")
                    } footer: {
                        Text("Choose a date within the meal plan period")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add to Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // Add button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addRecipeToMealPlan()
                    }
                    .disabled(selectedPlan == nil)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingCreatePlan) {
                CreateMealPlanSheet()
            }
            .confirmationDialog(
                "Replace Existing Recipe?",
                isPresented: $showingReplaceConfirmation,
                titleVisibility: .visible
            ) {
                Button("Replace", role: .destructive) {
                    performAddRecipe(replacing: existingRecipeOnDate)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                // M4.2.4: Message must always return a view in ViewBuilder context
                if let existing = existingRecipeOnDate, let existingRecipe = existing.recipe {
                    Text("This will replace '\(existingRecipe.title ?? "Unknown")' on \(dateFormatter.string(from: selectedDate))")
                } else {
                    Text("This will replace the existing recipe")
                }
            }
            .onAppear {
                // M4.2.4: Pre-select active plan for convenience
                selectedPlan = availablePlans.first { $0.isActive }
                
                if let plan = selectedPlan {
                    updateSelectedDate(for: plan)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // M4.2.4: Date formatter for display
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // MARK: - Helper Methods
    
    // M4.2.4: Display name for meal plan
    private func planDisplayName(for plan: MealPlan) -> String {
        if let name = plan.name, !name.isEmpty {
            return name
        }
        
        // Auto-generate from dates
        guard let startDate = plan.startDate else { return "Unnamed Plan" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Week of \(formatter.string(from: startDate))"
    }
    
    // M4.2.4: Valid date range for selected plan
    // Only allows dates within the plan's duration
    private func dateRange(for plan: MealPlan) -> ClosedRange<Date> {
        guard let startDate = plan.startDate else {
            return Date()...Date()
        }
        
        let endDate = Calendar.current.date(
            byAdding: .day,
            value: Int(plan.duration) - 1,
            to: startDate
        ) ?? startDate
        
        return startDate...endDate
    }
    
    // M4.2.4: Update selected date when plan changes
    // Sets to today if within plan, otherwise first day of plan
    private func updateSelectedDate(for plan: MealPlan) {
        guard let startDate = plan.startDate else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let planStart = Calendar.current.startOfDay(for: startDate)
        let planEnd = Calendar.current.date(byAdding: .day, value: Int(plan.duration) - 1, to: planStart) ?? planStart
        
        // If today is within plan, use today
        if today >= planStart && today <= planEnd {
            selectedDate = today
        } else {
            // Otherwise use first day of plan
            selectedDate = startDate
        }
        
        checkForExistingRecipe()
    }
    
    // M4.2.4: Check if selected date already has a recipe assigned
    // Used to show warning and prompt for replacement
    private func checkForExistingRecipe() {
        guard let plan = selectedPlan else {
            existingRecipeOnDate = nil
            return
        }
        
        let selectedDay = Calendar.current.startOfDay(for: selectedDate)
        
        // Fetch planned meals for this plan and date
        let fetchRequest: NSFetchRequest<PlannedMeal> = PlannedMeal.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "mealPlan.id == %@ AND date >= %@ AND date < %@",
            plan.id! as CVarArg,
            selectedDay as NSDate,
            Calendar.current.date(byAdding: .day, value: 1, to: selectedDay)! as NSDate
        )
        
        do {
            let existingMeals = try viewContext.fetch(fetchRequest)
            existingRecipeOnDate = existingMeals.first
        } catch {
            print("Error checking for existing recipe: \(error)")
            existingRecipeOnDate = nil
        }
    }
    
    // MARK: - Actions
    
    // M4.2.4: Add recipe to selected plan and date
    // Prompts for confirmation if date already has recipe (one recipe per day rule)
    private func addRecipeToMealPlan() {
        guard let plan = selectedPlan else { return }
        
        // Check if date already has a recipe
        if existingRecipeOnDate != nil {
            // Show confirmation dialog
            showingReplaceConfirmation = true
        } else {
            // No conflict, add directly
            performAddRecipe(replacing: nil)
        }
    }
    
    // M4.2.4: Perform the actual recipe assignment
    // Optionally replaces existing recipe if confirmed by user
    private func performAddRecipe(replacing existing: PlannedMeal?) {
        guard let plan = selectedPlan else { return }
        
        // Remove existing recipe if replacing
        if let existing = existing {
            viewContext.delete(existing)
        }
        
        // Create new planned meal
        let plannedMeal = PlannedMeal(context: viewContext)
        plannedMeal.id = UUID()
        plannedMeal.date = selectedDate
        plannedMeal.mealPlan = plan
        plannedMeal.recipe = recipe
        
        // M4.2.4: Update recipe tracking (NEW behavior)
        // Track when added to meal plan (not grocery list)
        recipe.usageCount += 1
        recipe.lastUsed = selectedDate  // Planned date, not today!
        
        do {
            try viewContext.save()
            
            // Call completion callback
            onSelect(plan, selectedDate)
            
            // Dismiss sheet
            dismiss()
        } catch {
            print("Error adding recipe to meal plan: \(error)")
            viewContext.rollback()
        }
    }
}

// MARK: - Preview

#Preview {
    {
        let context = PersistenceController.preview.container.viewContext
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.title = "Tacos"
        recipe.servings = 4
        
        return SelectMealPlanSheet(recipe: recipe) { plan, date in
            print("Selected plan: \(plan.name ?? "Unnamed"), date: \(date)")
        }
        .environment(\.managedObjectContext, context)
    }()
}
