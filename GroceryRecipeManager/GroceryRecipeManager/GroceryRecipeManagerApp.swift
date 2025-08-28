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
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
