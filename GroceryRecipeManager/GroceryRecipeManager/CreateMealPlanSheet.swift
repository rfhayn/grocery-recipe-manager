//
//  CreateMealPlanSheet.swift
//  GroceryRecipeManager
//
//  Created for M4.2.4: Multiple Meal Plans List View
//  Quick plan creation with smart defaults from M4.1 user preferences
//  Can be used standalone or inline within SelectMealPlanSheet
//

import SwiftUI
import CoreData

// M4.2.4: Quick meal plan creation sheet
// Uses M4.1 user preferences for smart defaults
// Validates dates to prevent overlaps
// Supports both modal and inline modes
struct CreateMealPlanSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // M4.2.4: User preferences for smart defaults
    @StateObject private var prefs = UserPreferencesService.shared
    
    // M4.2.4: Inline mode support for use within other sheets
    var isInline: Bool = false
    var onCreated: ((MealPlan) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    // M4.2.4: Form fields with smart defaults
    @State private var name = ""
    @State private var startDate = Date()
    @State private var duration: Int
    
    // M4.2.4: Validation state
    @State private var validationError: String?
    @State private var isValidating = false
    
    // M4.2.4: Initialize with user preferences
    init(isInline: Bool = false, onCreated: ((MealPlan) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.isInline = isInline
        self.onCreated = onCreated
        self.onCancel = onCancel
        
        // Initialize duration from preferences
        let prefsDuration = UserPreferencesService.shared.mealPlanDuration
        _duration = State(initialValue: prefsDuration)
    }
    
    var body: some View {
        if isInline {
            // Inline mode - no NavigationView wrapper
            formContent
        } else {
            // Modal mode - wrapped in NavigationView
            NavigationView {
                formContent
                    .navigationTitle("Create Meal Plan")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                createMealPlan()
                            }
                            .disabled(isValidating)
                        }
                    }
            }
        }
    }
    
    // MARK: - Form Content
    
    // M4.2.4: Main form layout
    // Shows smart defaults with user customization options
    private var formContent: some View {
        Form {
            nameSection
            dateSection
            durationSection
            
            if let error = validationError {
                validationErrorSection(error)
            }
            
            if isInline {
                actionButtonsSection
            }
        }
    }
    
    // M4.2.4: Optional name field with auto-generation hint
    private var nameSection: some View {
        Section {
            TextField("Plan name (optional)", text: $name)
        } header: {
            Text("Name")
        } footer: {
            if name.isEmpty {
                Text("If left empty, a name will be auto-generated based on the date range")
                    .font(.caption)
            }
        }
    }
    
    // M4.2.4: Start date picker
    // Smart default: Next occurrence of user's preferred start day
    private var dateSection: some View {
        Section {
            DatePicker(
                "Start Date",
                selection: $startDate,
                displayedComponents: .date
            )
            .onChange(of: startDate) { oldValue, newValue in
                validateDates()
            }
        } header: {
            Text("Dates")
        } footer: {
            Text(dateRangeDescription)
                .font(.caption)
        }
    }
    
    // M4.2.4: Duration picker with user preference default
    private var durationSection: some View {
        Section {
            Stepper(value: $duration, in: 3...14) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(duration) days")
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: duration) { oldValue, newValue in
                validateDates()
            }
        } footer: {
            Text("Choose between 3 and 14 days. Your preference is \(prefs.mealPlanDuration) days.")
                .font(.caption)
        }
    }
    
    // M4.2.4: Display validation errors
    private func validationErrorSection(_ message: String) -> some View {
        Section {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .foregroundColor(.red)
        }
    }
    
    // M4.2.4: Inline action buttons (for use within other sheets)
    private var actionButtonsSection: some View {
        Section {
            Button(action: createMealPlan) {
                HStack {
                    Spacer()
                    if isValidating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Create Plan")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .disabled(isValidating)
            
            if let cancel = onCancel {
                Button("Cancel", role: .cancel, action: cancel)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // M4.2.4: Description of date range based on current inputs
    private var dateRangeDescription: String {
        guard let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Plan will run from \(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }
    
    // M4.2.4: Validate dates using MealPlanService
    // Checks for overlaps with existing plans
    private func validateDates() {
        isValidating = true
        
        // Use MealPlanService validation
        let service = MealPlanService.shared
        let result = service.validatePlanDates(
            startDate: startDate,
            duration: duration,
            excludingPlan: nil
        )
        
        if result.isValid {
            validationError = nil
        } else {
            validationError = result.errorMessage
        }
        
        isValidating = false
    }
    
    // M4.2.4: Generate auto-name if user didn't provide one
    // Uses "Week of [start date] - [end date]" format
    private func generateAutoName() -> String {
        guard let endDate = Calendar.current.date(byAdding: .day, value: duration - 1, to: startDate) else {
            return "Meal Plan"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Week of \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // M4.2.4: Create the meal plan with validation
    // Calls appropriate callback based on mode (inline vs modal)
    private func createMealPlan() {
        // Final validation check
        validateDates()
        
        if validationError != nil {
            return
        }
        
        // Create the plan
        let plan = MealPlan(context: viewContext)
        plan.id = UUID()
        plan.name = name.isEmpty ? generateAutoName() : name
        plan.startDate = Calendar.current.startOfDay(for: startDate)
        plan.duration = Int16(duration)
        plan.createdDate = Date()
        plan.isActive = false // Will be set by updateActivePlanStatus
        plan.isCompleted = false
        
        do {
            try viewContext.save()
            
            // Update active status
            MealPlanService.shared.updateActivePlanStatus()
            
            // Handle callbacks based on mode
            if isInline, let callback = onCreated {
                callback(plan)
            } else {
                dismiss()
            }
        } catch {
            print("Error creating meal plan: \(error)")
            validationError = "Failed to create meal plan. Please try again."
        }
    }
}

// MARK: - Preview

#Preview("Modal Mode") {
    let context = PersistenceController.preview.container.viewContext
    
    return CreateMealPlanSheet()
        .environment(\.managedObjectContext, context)
}

#Preview("Inline Mode") {
    let context = PersistenceController.preview.container.viewContext
    
    return NavigationView {
        Form {
            Section {
                Text("Parent Form Content")
            }
            
            CreateMealPlanSheet(
                isInline: true,
                onCreated: { plan in
                    print("Created plan: \(plan.name ?? "unnamed")")
                },
                onCancel: {
                    print("Cancelled")
                }
            )
        }
        .navigationTitle("Test Container")
    }
    .environment(\.managedObjectContext, context)
}

#Preview("With Existing Plans") {
    let context = PersistenceController.preview.container.viewContext
    
    // Create existing plan to test overlap validation
    let existingPlan = MealPlan(context: context)
    existingPlan.id = UUID()
    existingPlan.name = "Existing Plan"
    existingPlan.startDate = Date()
    existingPlan.duration = 7
    existingPlan.isActive = true
    
    try? context.save()
    
    return CreateMealPlanSheet()
        .environment(\.managedObjectContext, context)
}
