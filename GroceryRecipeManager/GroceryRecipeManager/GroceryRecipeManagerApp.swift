// GroceryRecipeManagerApp.swift
// Updated with Settings Tab - M3 Phase 3

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
                    IngredientsView()
                }
                .tabItem {
                    Label("Ingredients", systemImage: "leaf.circle")
                }
                
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
                
                // NEW: Settings Tab (replaces DEBUG-only Migration tab)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Custom Button Styles
// Note: These are now also defined in SettingsView.swift with "Migration" prefix
// Keeping these here for backward compatibility with any other views that might use them

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
