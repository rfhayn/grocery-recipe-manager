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
                
                NavigationView {
                    StaplesView()
                }
                .tabItem {
                    Label("Staples", systemImage: "cart.badge.plus")
                }
                
                NavigationView {
                    ManageCategoriesView()
                }
                .tabItem {
                    Label("Categories", systemImage: "folder.badge.gearshape")
                }
                
                // Phase 0 Step 2 Test Tab
                NavigationView {
                    Phase0TestView()
                }
                .tabItem {
                    Label("Test", systemImage: "wrench.and.screwdriver")
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Phase 0 Step 2 Test View
struct Phase0TestView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isTestRunning = false
    @State private var lastTestResult = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Phase 0 Step 2 Testing")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Test the new performance services and architecture optimizations")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if isTestRunning {
                ProgressView("Running tests...")
                    .scaleEffect(1.2)
            } else {
                Button("🧪 Test Phase 0 Services") {
                    runPhase0Test()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.headline)
            }
            
            if !lastTestResult.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Test Result:")
                        .font(.headline)
                    
                    Text(lastTestResult)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Phase 0 Testing")
    }
    
    private func runPhase0Test() {
        isTestRunning = true
        lastTestResult = ""
        
        print("🚀 Starting Phase 0 Step 2 Service Test...")
       
        Task {
            let recipeService = OptimizedRecipeDataService(context: viewContext)
            let templateService = IngredientTemplateService(context: viewContext)
            let validator = ArchitectureValidator(context: viewContext, recipeService: recipeService, templateService: templateService)
            
            // Run performance check
            let (isPassing, summary) = await validator.quickPerformanceCheck()
            
            // Run integration test
            let report = await validator.testServiceIntegration()
            
            DispatchQueue.main.async {
                self.isTestRunning = false
                self.lastTestResult = "✅ \(summary)\n\nCheck Xcode console for detailed report."
            }
            
            print("🎯 Phase 0 Step 2 Final Result: \(summary)")
            print("\n==================================================")
            print("📋 DETAILED INTEGRATION REPORT:")
            print("==================================================")
            print(report)
            print("==================================================")
        }

        
        // Temporary placeholder until services are implemented
        DispatchQueue.main.async {
            self.isTestRunning = false
            self.lastTestResult = "⏳ Services not yet implemented. Test will be functional after service creation."
        }
    }
}
