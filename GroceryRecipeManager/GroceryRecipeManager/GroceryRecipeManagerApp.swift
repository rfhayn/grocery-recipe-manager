import SwiftUI

@main
struct GroceryRecipeManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                StaplesView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
