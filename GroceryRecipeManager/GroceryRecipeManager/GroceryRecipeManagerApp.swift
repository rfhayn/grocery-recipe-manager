// GroceryRecipeManagerApp.swift
// Updated with Settings Tab - M3 Phase 3
// Updated with Meal Planning Tab - M4.2
// Updated with Tap-to-Pop-to-Root - Tab Bar UX Enhancement

import SwiftUI

@main
struct GroceryRecipeManagerApp: App {
    let persistenceController = PersistenceController.shared
    
    // Tab selection and pop-to-root state management
    // Enables standard iOS behavior: tapping active tab pops navigation to root
    @State private var selectedTab: Tab = .lists
    @State private var listsPopToRoot = false
    @State private var ingredientsPopToRoot = false
    @State private var recipesPopToRoot = false
    @State private var mealPlansPopToRoot = false
    @State private var categoriesPopToRoot = false

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationView {
                    WeeklyListsView(popToRoot: $listsPopToRoot)
                }
                .tabItem {
                    Label("Lists", systemImage: "list.clipboard")
                }
                .tag(Tab.lists)
                
                NavigationView {
                    IngredientsView(popToRoot: $ingredientsPopToRoot)
                }
                .tabItem {
                    Label("Ingredients", systemImage: "leaf.circle")
                }
                .tag(Tab.ingredients)
                
                RecipeListView(popToRoot: $recipesPopToRoot)
                .tabItem {
                    Label("Recipes", systemImage: "book.pages")
                }
                .tag(Tab.recipes)
                
                // M4.2.4 PHASE 7: Updated to use MealPlansListView for multi-plan support
                // Changed from single MealPlanView to list-based architecture
                // Enables multiple concurrent plans, historical tracking, and improved navigation
                NavigationView {
                    MealPlansListView(popToRoot: $mealPlansPopToRoot)
                }
                .tabItem {
                    Label("Meal Plans", systemImage: "calendar")
                }
                .tag(Tab.mealPlans)
                
                NavigationView {
                    ManageCategoriesView(popToRoot: $categoriesPopToRoot)
                }
                .tabItem {
                    Label("Categories", systemImage: "folder.badge.gearshape")
                }
                .tag(Tab.categories)
                
                // M3 Phase 3: Settings Tab (replaces DEBUG-only Migration tab)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(Tab.settings)
            }
            .onChange(of: selectedTab) { oldTab, newTab in
                // Pop to root when tapping the already-selected tab
                // This is standard iOS tab bar behavior
                if oldTab == newTab {
                    handlePopToRoot(for: newTab)
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    // MARK: - Tab Pop-to-Root Handler
    
    // Triggers pop-to-root for the specified tab
    // Each tab watches its respective @Binding and dismisses navigation when triggered
    private func handlePopToRoot(for tab: Tab) {
        switch tab {
        case .lists:
            listsPopToRoot.toggle()
        case .ingredients:
            ingredientsPopToRoot.toggle()
        case .recipes:
            recipesPopToRoot.toggle()
        case .mealPlans:
            mealPlansPopToRoot.toggle()
        case .categories:
            categoriesPopToRoot.toggle()
        case .settings:
            break // Settings has no navigation stack
        }
    }
}

// MARK: - Tab Enumeration

// Defines all tabs in the app for type-safe selection tracking
enum Tab {
    case lists
    case ingredients
    case recipes
    case mealPlans
    case categories
    case settings
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
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color.red.opacity(0.8) : Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .font(.headline)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
