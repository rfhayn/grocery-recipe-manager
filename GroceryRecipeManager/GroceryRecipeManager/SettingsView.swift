import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            List {
                // Data Management Section
                Section {
                    NavigationLink(destination: ManageCategoriesView()) {
                        Label("Categories", systemImage: "folder.badge.gearshape")
                    }
                    
                    NavigationLink(destination: IngredientsView()) {
                        Label("Ingredients", systemImage: "leaf.circle")
                    }
                } header: {
                    Text("Data Management")
                }
                
                // Developer Tools Section
                Section {
                    NavigationLink(destination: QuantityMigrationView()) {
                        Label("Quantity Migration", systemImage: "arrow.triangle.2.circlepath")
                    }
                } header: {
                    Text("Developer Tools")
                } footer: {
                    Text("Migration tools for updating ingredient quantities to the new structured format")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/rfhayn/grocery-recipe-manager")!) {
                        HStack {
                            Text("GitHub Repository")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Quantity Migration View
struct QuantityMigrationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var migrationReport = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Quantity Migration")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Migrate ingredients to structured quantity format")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Migration Status Card
                migrationStatusCard
                    .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: checkMigrationStatus) {
                        Label("Check Status", systemImage: "doc.text.magnifyingglass")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SettingsPrimaryButtonStyle())
                    .disabled(isLoading)
                    
                    Button(action: validateMigration) {
                        Label("Validate Migration", systemImage: "checkmark.shield")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SettingsSecondaryButtonStyle())
                    .disabled(isLoading)
                    
                    #if DEBUG
                    Divider()
                        .padding(.vertical, 8)
                    
                    Text("Debug Actions")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Button(action: resetMigration) {
                        Label("Reset Migration", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SettingsDebugButtonStyle(color: .orange))
                    .disabled(isLoading)
                    
                    Button(action: forceMigration) {
                        Label("Force Execute", systemImage: "bolt.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SettingsDebugButtonStyle(color: .green))
                    .disabled(isLoading)
                    #endif
                }
                .padding(.horizontal)
                
                // Loading Indicator
                if isLoading {
                    ProgressView("Processing...")
                        .scaleEffect(1.2)
                        .padding()
                }
                
                // Migration Report
                if !migrationReport.isEmpty {
                    migrationReportView
                        .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Quantity Migration")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 12) {
            HStack {
                Image(systemName: IngredientTemplate.isMigrationCompleted ? "checkmark.circle.fill" : "clock.circle")
                    .foregroundColor(IngredientTemplate.isMigrationCompleted ? .green : .orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(IngredientTemplate.isMigrationCompleted ? "Migration Complete" : "Migration Pending")
                        .font(.headline)
                    
                    if let date = IngredientTemplate.migrationDate {
                        Text("Completed: \(date, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var migrationReportView: some View {
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
            .padding(.bottom, 4)
            
            Text(migrationReport)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
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
            let validation = IngredientTemplate.validateMigration(in: self.viewContext)
            
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
            PersistenceController.shared.resetMigrationForTesting()
            
            let container = PersistenceController.shared.container
            container.performBackgroundTask { backgroundContext in
                print("Force executing migration...")
                IngredientTemplate.migrateStaplesFromGroceryItems(in: backgroundContext)
                
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

// MARK: - Button Styles (with Settings prefix to avoid conflicts)

struct SettingsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SettingsSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color(.systemGray5) : Color(.systemGray6))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SettingsDebugButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(color)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? color.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
