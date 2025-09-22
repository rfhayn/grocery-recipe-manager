// GroceryRecipeManagerApp.swift
// Updated to replace StaplesView with IngredientsView for Step 4 implementation

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
                
                // UPDATED: StaplesView replaced with IngredientsView
                NavigationView {
                    IngredientsView()
                }
                .tabItem {
                    Label("Ingredients", systemImage: "leaf.circle")
                }
                
                // Recipes tab (from Step 1)
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
                
                // Migration Test Tab (for Step 4 testing - can be removed after validation)
                NavigationView {
                    MigrationTestView()
                }
                .tabItem {
                    Label("Migration", systemImage: "arrow.triangle.2.circlepath")
                }
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
            
            VStack(spacing: 12) {
                Button("Check Migration Status") {
                    checkMigrationStatus()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                
                #if DEBUG
                Button("Reset Migration (Debug)") {
                    resetMigration()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                
                Button("Force Migration") {
                    forceMigration()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
                #endif
            }
            
            if isLoading {
                ProgressView("Processing...")
                    .scaleEffect(1.2)
                    .padding()
            }
            
            if !migrationReport.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Migration Report")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        Text(migrationReport)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Migration Test")
        .onAppear {
            checkMigrationStatus()
        }
    }
    
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
    
    #if DEBUG
    private func resetMigration() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            PersistenceController.shared.resetMigrationForTesting()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.migrationReport = "Migration status reset. Restart app to trigger migration."
            }
        }
    }
    
    private func forceMigration() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Reset and then execute migration
            PersistenceController.shared.resetMigrationForTesting()
            PersistenceController.shared.executeMigrationIfNeeded()
            
            // Get updated status
            let report = PersistenceController.shared.getMigrationStatusReport()
            
            DispatchQueue.main.async {
                self.migrationReport = report
                self.isLoading = false
            }
        }
    }
    #endif
}
