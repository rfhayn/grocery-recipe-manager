import SwiftUI
import CoreData

struct StaplesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Predicate-based FetchRequest for better performance with indexed queries
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GroceryItem.category, ascending: true),
            NSSortDescriptor(keyPath: \GroceryItem.name, ascending: true)
        ],
        predicate: NSPredicate(format: "isStaple == YES"),
        animation: .default
    ) private var staples: FetchedResults<GroceryItem>
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Add form presentation
    @State private var showingAddForm = false

    var body: some View {
        List {
            ForEach(staples, id: \.self) { item in
                StapleRowView(item: item)
            }
            .onDelete(perform: deleteStaples)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: {
                    showingAddForm = true
                }) {
                    Label("Add Staple", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Staples")
        .sheet(isPresented: $showingAddForm) {
            AddStapleView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private func deleteStaples(offsets: IndexSet) {
        withAnimation {
            // Get object IDs for background context operations
            let objectIDs = offsets.map { staples[$0].objectID }
            
            // Use background context for non-blocking operations
            PersistenceController.shared.performWrite({ context in
                for objectID in objectIDs {
                    let object = context.object(with: objectID)
                    context.delete(object)
                }
                print("✅ Deleted \(objectIDs.count) staple(s)")
            }, onError: { error in
                errorMessage = "Failed to delete staples: \(error.localizedDescription)"
                showingError = true
            })
        }
    }
}

struct StapleRowView: View {
    let item: GroceryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.name ?? "Unknown Item")
                    .fontWeight(.medium)
                Spacer()
                Text("📌 Staple")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if let category = item.category {
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let lastPurchased = item.lastPurchased {
                Text("Last purchased: \(lastPurchased, formatter: dateFormatter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    NavigationView {
        StaplesView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
