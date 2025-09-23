// GroceryRecipeManagerApp.swift
// Updated for Step 4 Phase 2.1 - IngredientsView Structure Creation

import SwiftUI

@main
struct GroceryRecipeManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    WeeklyListsView()
                }
                .tabItem {
                    Label("Lists", systemImage: "list.clipboard")
                }
                
                // STEP 4 PHASE 2.1: StaplesView replaced with IngredientsView
                NavigationView {
                    IngredientsView()
                }
                .tabItem {
                    Label("Ingredients", systemImage: "leaf.circle")
                }
                
                // Recipes tab (from Step 1-3a)
                RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.pages")
                }
                
                NavigationView {
                    ManageCategoriesView()
                }
                .tabItem {
                    Label("Categories", systemImage: "folder.badge.gearshape")
                }
                
                #if DEBUG
                // Migration Test Tab (for Step 4 testing - can be removed after validation)
                NavigationView {
                    MigrationTestView()
                }
                .tabItem {
                    Label("Migration", systemImage: "arrow.triangle.2.circlepath")
                }
                #endif
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Migration Test View (Development/Testing)
struct MigrationTestView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var migrationReport = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Step 4 Migration Testing")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Test and validate the staples migration from GroceryItem to IngredientTemplate")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Migration Status Summary
            migrationStatusCard
            
            VStack(spacing: 12) {
                Button("Check Migration Status") {
                    checkMigrationStatus()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Validate Migration") {
                    validateMigration()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                #if DEBUG
                Divider()
                    .padding(.vertical, 8)
                
                Text("Debug Actions")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                Button("Reset Migration Status") {
                    resetMigration()
                }
                .buttonStyle(DebugButtonStyle(color: .orange))
                
                Button("Force Migration Execute") {
                    forceMigration()
                }
                .buttonStyle(DebugButtonStyle(color: .green))
                #endif
            }
            
            if isLoading {
                ProgressView("Processing...")
                    .scaleEffect(1.2)
                    .padding()
            }
            
            if !migrationReport.isEmpty {
                migrationReportView
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Migration Test")
        .alert("Migration Action", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkMigrationStatus()
        }
    }
    
    // MARK: - UI Components
    
    private var migrationStatusCard: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: IngredientTemplate.isMigrationCompleted ? "checkmark.circle.fill" : "clock.circle")
                    .foregroundColor(IngredientTemplate.isMigrationCompleted ? .green : .orange)
                
                Text(IngredientTemplate.isMigrationCompleted ? "Migration Completed" : "Migration Pending")
                    .font(.headline)
                
                Spacer()
            }
            
            if let migrationDate = IngredientTemplate.migrationDate {
                HStack {
                    Text("Completed:")
                        .foregroundColor(.secondary)
                    Text(migrationDate, style: .date)
                        .font(.caption)
                    Text(migrationDate, style: .time)
                        .font(.caption)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var migrationReportView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Migration Report")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        UIPasteboard.general.string = migrationReport
                        alertMessage = "Report copied to clipboard"
                        showingAlert = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .padding(.bottom, 8)
                
                Text(migrationReport)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(maxHeight: 400)
    }
    
    // MARK: - Actions
    
    private func checkMigrationStatus() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            #if DEBUG
            let report = PersistenceController.shared.getMigrationStatusReport()
            #else
            let validation = IngredientTemplate.validateMigration(in: viewContext)
            let report = validation.report
            #endif
            
            DispatchQueue.main.async {
                self.migrationReport = report
                self.isLoading = false
            }
        }
    }
    
    private func validateMigration() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let validation = IngredientTemplate.validateMigration(in: viewContext)
            
            DispatchQueue.main.async {
                self.migrationReport = validation.report
                self.isLoading = false
                
                self.alertMessage = validation.success ?
                    "Migration validation passed successfully!" :
                    "Migration validation failed. Check the report for details."
                self.showingAlert = true
            }
        }
    }
    
    #if DEBUG
    private func resetMigration() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            PersistenceController.shared.resetMigrationForTesting()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.migrationReport = "Migration status reset successfully.\n\nRestart the app to trigger fresh migration."
                self.alertMessage = "Migration status reset. Restart app to see effects."
                self.showingAlert = true
            }
        }
    }
    
    private func forceMigration() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Reset migration status first
            PersistenceController.shared.resetMigrationForTesting()
            
            // Force execute migration in background context
            let container = PersistenceController.shared.container
            container.performBackgroundTask { backgroundContext in
                print("Force executing Step 4 migration...")
                IngredientTemplate.migrateStaplesFromGroceryItems(in: backgroundContext)
                
                // Validate the forced migration
                let validation = IngredientTemplate.validateMigration(in: backgroundContext)
                
                DispatchQueue.main.async {
                    self.migrationReport = validation.report
                    self.isLoading = false
                    
                    self.alertMessage = validation.success ?
                        "Forced migration completed successfully!" :
                        "Forced migration failed. Check the report."
                    self.showingAlert = true
                }
            }
        }
    }
    #endif
}

// MARK: - Custom Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color(.systemGray4) : Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
struct DebugButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? color.opacity(0.8) : color)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.subheadline.weight(.medium))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
#endif
