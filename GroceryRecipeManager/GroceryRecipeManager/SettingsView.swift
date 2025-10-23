import SwiftUI
import CoreData

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
                    NavigationLink(destination: M3DataDebugView()) {
                        Label("Debug: Check Data", systemImage: "ant.circle")
                    }
                    
                    NavigationLink(destination: MigrationDebugView(context: viewContext)) {
                        Label("M3 Quantity Migration", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    Button(action: {
                        runIngredientTemplateValidation(context: viewContext)
                    }) {
                        Label("M3.5 Template Validation", systemImage: "checkmark.shield")
                    }
                    
                    // M3.5 TASK 4: Computed Properties Test
                    Button(action: {
                        runComputedPropertiesTests(context: viewContext)
                    }) {
                        Label("M3.5 Computed Properties", systemImage: "function")
                    }
                    
                    Button(action: {
                        runM3ValidationTests(context: viewContext)
                    }) {
                        Label("M3.5 Final Validation", systemImage: "checkmark.circle.badge.xmark")
                    }
                } header: {
                    Text("Developer Tools")
                } footer: {
                    Text("Debug tools for data validation, migration, and testing. Check console output for results.")
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

// MARK: - M3 Data Debug View (separate struct to avoid conflicts)
struct M3DataDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var debugOutput: String = "Loading..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Data Debug Report")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                Text(debugOutput)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: checkData) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Data Check")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Copy button
                Button(action: copyToClipboard) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Report")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Data Debug")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkData()
        }
    }
    
    private func checkData() {
        var output = "🔍 ACTUAL DATA CHECK\n"
        output += String(repeating: "=", count: 50) + "\n\n"
        
        // Check Ingredients
        let ingredientRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        ingredientRequest.fetchLimit = 5
        
        do {
            let ingredients = try viewContext.fetch(ingredientRequest)
            let totalCount = try viewContext.count(for: Ingredient.fetchRequest())
            output += "📊 INGREDIENTS (showing 5 of \(totalCount))\n"
            output += String(repeating: "-", count: 50) + "\n\n"
            
            if ingredients.isEmpty {
                output += "⚠️ No ingredients found!\n\n"
            }
            
            for (index, ingredient) in ingredients.enumerated() {
                output += "[\(index + 1)] Ingredient:\n"
                output += "  ID: \(ingredient.id?.uuidString.prefix(8) ?? "nil")\n"
                output += "  name: '\(ingredient.name ?? "nil")'\n"
                output += "  displayText: '\(ingredient.displayText ?? "nil")'\n"
                output += "  numericValue: \(ingredient.numericValue)\n"
                output += "  standardUnit: '\(ingredient.standardUnit ?? "nil")'\n"
                output += "  isParseable: \(ingredient.isParseable)\n"
                output += "  parseConfidence: \(ingredient.parseConfidence)\n"
                
                if let recipe = ingredient.recipe {
                    output += "  recipe: '\(recipe.title ?? "nil")'\n"
                }
                
                output += "\n"
            }
        } catch {
            output += "❌ Error fetching ingredients: \(error)\n\n"
        }
        
        // Check GroceryListItems
        let itemRequest: NSFetchRequest<GroceryListItem> = GroceryListItem.fetchRequest()
        itemRequest.fetchLimit = 5
        
        do {
            let items = try viewContext.fetch(itemRequest)
            let totalCount = try viewContext.count(for: GroceryListItem.fetchRequest())
            output += "📊 GROCERY LIST ITEMS (showing 5 of \(totalCount))\n"
            output += String(repeating: "-", count: 50) + "\n\n"
            
            if items.isEmpty {
                output += "⚠️ No grocery items found!\n\n"
            }
            
            for (index, item) in items.enumerated() {
                output += "[\(index + 1)] GroceryListItem:\n"
                output += "  ID: \(item.id?.uuidString.prefix(8) ?? "nil")\n"
                output += "  name: '\(item.name ?? "nil")'\n"
                output += "  displayText: '\(item.displayText ?? "nil")'\n"
                output += "  numericValue: \(item.numericValue)\n"
                output += "  standardUnit: '\(item.standardUnit ?? "nil")'\n"
                output += "  isParseable: \(item.isParseable)\n"
                output += "  parseConfidence: \(item.parseConfidence)\n"
                output += "  isCompleted: \(item.isCompleted)\n"
                output += "\n"
            }
        } catch {
            output += "❌ Error fetching items: \(error)\n\n"
        }
        
        // Summary
        output += String(repeating: "=", count: 50) + "\n"
        output += "🎯 WHAT TO LOOK FOR:\n"
        output += String(repeating: "-", count: 50) + "\n"
        output += "✅ name should have quantity text\n"
        output += "   e.g., '2 cups flour'\n"
        output += "✅ displayText can be nil (will be populated)\n"
        output += "✅ numericValue should be 0.0 before migration\n"
        output += "✅ isParseable should be false before migration\n"
        
        debugOutput = output
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = debugOutput
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
