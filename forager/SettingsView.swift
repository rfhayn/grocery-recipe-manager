//
//  SettingsView.swift
//  forager
//
//  Enhanced for M4.1: Added Meal Planning Preferences Section
//  Enhanced for M4.3.1: Added Display Options Section
//  Enhanced for M7.0.2: Added Privacy Policy Link with SafariServices
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    // M4.1: User preferences service for meal planning settings
    @StateObject private var preferencesService = UserPreferencesService.shared
    
    // Access to Core Data context for migration service
    @Environment(\.managedObjectContext) private var viewContext
    
    // M7.0.2: Privacy policy URL presentation state
    @State private var showingPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            Form {
                // M4.1: Meal Planning Preferences
                mealPlanningSection
                
                // M4.3.1: Display Options
                displayOptionsSection
                
                // M7.1.2: Developer Tools
                developerToolsSection
                
                // M7.0.2: About & Privacy
                aboutSection
                
                // M3: Data Management with Migration - Hidden after migration complete
                // migrationSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                SafariView(url: URL(string: "https://rfhayn.github.io/forager/privacy.html")!)
                    .ignoresSafeArea()
            }
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
            
        } header: {
            Text("Meal Planning")
        } footer: {
            Text("Configure how meal plans are created and displayed. Meal plans will default to \(preferencesService.mealPlanDuration) days starting on \(preferencesService.startDayName).")
                .font(.caption)
        }
    }
    
    // MARK: - M4.3.1: Display Options Section
    
    // Display preferences for recipe source visibility
    // Controls whether recipe sources appear throughout the app
    private var displayOptionsSection: some View {
        Section {
            // Show recipe sources toggle
            // When enabled, shows recipe tags like "[Tacos] [Spaghetti]"
            Toggle("Show Recipe Sources", isOn: $preferencesService.showRecipeSources)
            
        } header: {
            Text("Display Options")
        } footer: {
            Text("When enabled, grocery list items will show which recipes they came from (e.g., \"Ground beef [Tacos]\").")
                .font(.caption)
        }
    }
    
    // MARK: - M7.1.2: Developer Tools Section
    
    // Developer tools for CloudKit sync testing and debugging
    // Provides access to sync status monitoring and validation
    private var developerToolsSection: some View {
        Section {
            // CloudKit Sync Status link
            // Opens test interface for monitoring CloudKit sync events
            NavigationLink {
                CloudKitSyncTestView()
            } label: {
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("CloudKit Sync Status")
                            .font(.headline)
                        Text("Monitor sync events and test CloudKit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        } header: {
            Text("Developer Tools")
        } footer: {
            Text("Tools for testing and debugging CloudKit synchronization.")
                .font(.caption)
        }
    }
    
    // MARK: - M7.0.2: About Section
    
    // About section with app information and legal links
    // Provides access to privacy policy and app version
    private var aboutSection: some View {
        Section {
            // Privacy Policy link
            // Opens privacy policy in in-app Safari browser
            Button {
                showingPrivacyPolicy = true
            } label: {
                HStack {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.green)
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
        } header: {
            Text("About")
        } footer: {
            Text("forager stores all data locally on your device. We do not collect, transmit, or share any personal information.")
                .font(.caption)
        }
    }
    
    // MARK: - M3: Legacy Sections (Hidden)
    
    // Migration section for quantity data management
    // Hidden after M3 migration complete - preserved for reference
    /*
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
    */
    
    // MARK: - Helper Methods
    
    // M4.1: Converts day number (0-6) to weekday name
    // Used by Picker to display "Sunday", "Monday", etc.
    private func dayName(for day: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[day]
    }
}

// MARK: - M7.0.2: SafariView Wrapper

// UIViewControllerRepresentable wrapper for SFSafariViewController
// Enables in-app Safari browser for displaying web content
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
