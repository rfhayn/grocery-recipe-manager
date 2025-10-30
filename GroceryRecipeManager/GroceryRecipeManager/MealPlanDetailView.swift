//
//  MealPlanDetailView.swift
//  GroceryRecipeManager
//
//  TEMPORARY PLACEHOLDER for M4.2.4 Phase 3
//  Will be properly refactored in Phase 5 from MealPlanView
//

import SwiftUI
import CoreData

// M4.2.4: TEMPORARY placeholder for meal plan detail view
// This allows Phase 3 to build and link properly
// Phase 5 will refactor the existing MealPlanView to accept a meal plan parameter
struct MealPlanDetailView: View {
    @ObservedObject var mealPlan: MealPlan
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Meal Plan Detail")
                .font(.title)
            
            if let name = mealPlan.name {
                Text(name)
                    .font(.headline)
            }
            
            if let startDate = mealPlan.startDate {
                Text("Starts: \(startDate, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Duration: \(mealPlan.duration) days")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("⚠️ Phase 5 Coming Soon")
                .font(.caption)
                .foregroundColor(.orange)
                .padding()
            
            Text("This will be fully implemented when we refactor MealPlanView in Phase 5")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Meal Plan")
    }
}

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let plan = MealPlan(context: context)
    plan.id = UUID()
    plan.name = "This Week's Meals"
    plan.startDate = Date()
    plan.duration = 7
    
    return NavigationView {
        MealPlanDetailView(mealPlan: plan)
    }
    .environment(\.managedObjectContext, context)
}
