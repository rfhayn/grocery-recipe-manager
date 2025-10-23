//
//  SettingsView.swift
//  GroceryRecipeManager
//
//  Enhanced for M4.1: Added Meal Planning Preferences Section
//

import SwiftUI

struct SettingsView: View {
    // M4.1: User preferences service for meal planning settings
    @StateObject private var preferencesService = UserPreferencesService.shared
    
    // Access to Core Data context for migration service
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            Form {
                // M4.1: NEW SECTION - Meal Planning Preferences
                mealPlanningSection
                
                // Existing section - Data Management with Migration
                migrationSection
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - M4.1: Meal Planning Section
    
    // Meal planning preferences for user configuration
    // Controls meal plan duration, start day, and display options
    private var mealPlanningSection: some View {
        Section {
            // Duration stepper (3-14 days)
            // Controls how many days appear in meal plan calendar
            Stepper(
                "Plan Duration: \(preferencesService.mealPlanDuration) days",
                value: $preferencesService.mealPlanDuration,
                in: 3...14
            )
            
            // Start day picker (Sunday-Saturday)
            // Determines which day meal plan calendar begins on
            Picker("Start Day", selection: $preferencesService.mealPlanStartDay) {
                ForEach(0..<7) { day in
                    Text(dayName(for: day)).tag(day)
                }
            }
            
            // Auto-name toggle
            // When enabled, generates names like "Week of Oct 23"
            Toggle("Auto-name Meal Plans", isOn: $preferencesService.autoNameMealPlans)
            
            // Show source toggle
            // Controls whether recipe source appears in meal plan displays
            Toggle("Show Recipe Sources", isOn: $preferencesService.showRecipeSourceInMealPlan)
            
        } header: {
            Text("Meal Planning")
        } footer: {
            Text("Meal plans will default to \(preferencesService.mealPlanDuration) days starting on \(preferencesService.startDayName).")
                .font(.caption)
        }
    }
    
    // MARK: - Existing Sections
    
    // Migration section for quantity data management
    // Allows users to migrate unparsed quantities to structured format
    private var migrationSection: some View {
        Section {
            NavigationLink(destination: MigrationDebugView(context: viewContext)) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Quantity Migration")
                            .font(.headline)
                        Text("Convert ingredients to structured format")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Data Management")
        }
    }
    
    // MARK: - Helper Methods
    
    // M4.1: Converts day number (0-6) to weekday name
    // Used by Picker to display "Sunday", "Monday", etc.
    private func dayName(for day: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[day]
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
