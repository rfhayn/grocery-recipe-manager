//
//  ContentView.swift
//  GroceryRecipeManager
//
//  Working version with Phase 0 Step 2 test button
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            WeeklyListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
            
            StaplesView()
                .tabItem {
                    Label("Staples", systemImage: "cart")
                }
            
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "tag")
                }
            
            // Test tab for Phase 0 Step 2
            NavigationView {
                VStack(spacing: 30) {
                    Text("Phase 0 Testing")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Test the new performance services from Phase 0 Step 2")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("🧪 Test Phase 0 Services") {
                        testServices()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Testing")
            }
            .tabItem {
                Label("Test", systemImage: "wrench.and.screwdriver")
            }
        }
    }
    

    private func testServices() {
        print("🚀 Starting Phase 0 Step 2 Service Test...")

        Task {
            let recipeService = OptimizedRecipeDataService(context: viewContext)
            let templateService = IngredientTemplateService(context: viewContext)
            let validator = ArchitectureValidator(context: viewContext, recipeService: recipeService, templateService: templateService)
            
            let (isPassing, summary) = await validator.quickPerformanceCheck()
            print("🎯 Phase 0 Step 2 Result: \(summary)")
            
            // Also run the integration test
            let report = await validator.testServiceIntegration()
            print(report)
        }

    }
}

// MARK: - Temporary Categories View (if it doesn't exist)
struct CategoriesView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Categories Coming Soon")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Category management will be enhanced in future updates")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Categories")
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
