//
//  CreateMealPlanSheet.swift
//  GroceryRecipeManager
//
//  Created for M4.2.4: Multiple Meal Plans List View
//  Sheet for creating new meal plans with smart defaults from M4.1 preferences
//  Includes date overlap validation to maintain data integrity
//

import SwiftUI
import CoreData

// M4.2.4: Sheet for creating new meal plans
// Uses M4.1 UserPreferencesService for smart defaults
// Validates dates to prevent overlaps with existing plans
struct CreateMealPlanSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // M4.2.4: Meal plan service for creation and validation
    @StateObject private var mealPlanService = MealPlanService.shared
    
    // M4.2.4: User preferences for smart defaults (from M4.1)
    @StateObject private var preferences = UserPreferencesService.shared
    
    // M4.2.4: Form state
    @State private var name = ""
    @State private var startDate = Date()
    @State private var duration = 7  // Default, will be set from preferences
    
    // M4.2.4: Validation state
    @State private var validationResult: ValidationResult = .valid
    @State private var showingError = false
    @State private var isCreating = false
    
    // M4.2.4: Initialize with smart defaults from preferences
    init() {
        // Duration will be set in onAppear from preferences
    }
    
    var body: some View {
        NavigationView {
            Form {
                // M4.2.4: Name section (optional, auto-generates if empty)
                Section {
                    TextField("Plan Name (optional)", text: $name)
                        .autocapitalization(.words)
                } header: {
                    Text("Plan Name")
                } footer: {
                    if preferences.autoNameMealPlans {
                        Text("Leave empty to auto-generate from dates")
                            .font(.caption)
                    }
                }
                
                // M4.2.4: Date and duration section
                Section {
                    // Start date picker
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: [.date]
                    )
                    .onChange(of: startDate) { _ in
                        validateDates()
                    }
                    
                    // Duration stepper (3-14 days, from M4.1 preferences)
                    Stepper(
                        value: $duration,
                        in: 3...14,
                        step: 1
                    ) {
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(duration) days")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: duration) { _ in
                        validateDates()
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    Text(dateRangeText)
                        .font(.caption)
                }
                
                // M4.2.4: Validation error section
                if !validationResult.isValid {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date Conflict")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                if let errorMessage = validationResult.errorMessage {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // M4.2.4: Helpful tips section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("One plan at a time", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("Plan must not overlap with existing plans", systemImage: "calendar.badge.exclamationmark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("Add recipes from Recipe tab", systemImage: "book.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Tips")
                }
            }
            .navigationTitle("New Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreating)
                }
                
                // Create button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isCreating ? "Creating..." : "Create") {
                        createMealPlan()
                    }
                    .disabled(!validationResult.isValid || isCreating)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                // M4.2.4: Set smart defaults from M4.1 preferences
                setupSmartDefaults()
                validateDates()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    // M4.2.4: Date range text showing calculated end date
    private var dateRangeText: String {
        let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Plan will run from \(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }
    
    // MARK: - Actions
    
    // M4.2.4: Setup smart defaults from M4.1 UserPreferencesService
    // Uses user's preferred duration and calculates optimal start date
    private func setupSmartDefaults() {
        // Set duration from preferences
        duration = preferences.mealPlanDuration
        
        // Calculate next preferred start day
        // If user prefers Sunday starts, find next Sunday
        let preferredStartDay = preferences.mealPlanStartDay
        let calendar = Calendar.current
        let today = Date()
        
        // Find next occurrence of preferred day
        if let nextStartDay = calendar.nextDate(
            after: today,
            matching: DateComponents(weekday: preferredStartDay + 1), // +1 because weekday is 1-7
            matchingPolicy: .nextTime
        ) {
            startDate = nextStartDay
        } else {
            // Fallback to today if calculation fails
            startDate = today
        }
    }
    
    // M4.2.4: Validate dates against existing plans
    // Prevents overlapping meal plans to maintain data integrity
    private func validateDates() {
        validationResult = mealPlanService.validatePlanDates(
            startDate: startDate,
            duration: duration,
            excludingPlan: nil
        )
    }
    
    // M4.2.4: Create new meal plan
    // Uses M4.1 auto-naming preference if name is empty
    // Navigates to detail view on success
    private func createMealPlan() {
        guard validationResult.isValid else { return }
        
        isCreating = true
        
        // Create plan with service
        let plan = MealPlan(context: viewContext)
        plan.id = UUID()
        plan.createdDate = Date()
        plan.startDate = startDate
        plan.duration = Int16(duration)
        
        // M4.2.4: Use auto-naming from M4.1 preferences
        if preferences.autoNameMealPlans {
            if name.isEmpty {
                // Auto-generate name
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) ?? startDate
                plan.name = "Week of \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
            } else {
                // Use custom name
                plan.name = name
            }
        } else {
            // Always require name if auto-naming disabled
            plan.name = name.isEmpty ? "Unnamed Plan" : name
        }
        
        // Determine if this plan should be active
        let today = Calendar.current.startOfDay(for: Date())
        let startDay = Calendar.current.startOfDay(for: startDate)
        let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDay) ?? startDay
        plan.isActive = (startDay <= today) && (today <= endDate)
        plan.isCompleted = false
        
        do {
            try viewContext.save()
            
            // M4.2.4: Update active plan status to ensure only one active
            mealPlanService.updateActivePlanStatus()
            
            // Success - dismiss sheet
            dismiss()
        } catch {
            print("Error creating meal plan: \(error)")
            showingError = true
            isCreating = false
        }
    }
}

// MARK: - Preview

#Preview {
    CreateMealPlanSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
