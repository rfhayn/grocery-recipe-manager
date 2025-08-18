//
//  GroceryRecipeManagerApp.swift
//  GroceryRecipeManager
//
//  Created by Rich Hayn on 8/18/25.
//

import SwiftUI

@main
struct GroceryRecipeManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
