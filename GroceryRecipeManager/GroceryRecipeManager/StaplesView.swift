import SwiftUI
import CoreData

struct StaplesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GroceryItem.name, ascending: true)],
        animation: .default)
    private var allItems: FetchedResults<GroceryItem>

    // Filter staples in computed property
    private var staples: [GroceryItem] {
        allItems.filter { $0.isStaple }
    }

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
                Button(action: addStaple) {
                    Label("Add Staple", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Staples")
    }

    private func addStaple() {
        withAnimation {
            let newStaple = GroceryItem(context: viewContext)
            newStaple.id = UUID()
            newStaple.name = "New Staple \(Int(Date().timeIntervalSince1970))"
            newStaple.category = "Grocery"
            newStaple.dateCreated = Date()
            newStaple.isStaple = true

            do {
                try viewContext.save()
                print("✅ Added new staple: \(newStaple.name ?? "Unknown")")
            } catch {
                print("❌ Error adding staple: \(error)")
            }
        }
    }

    private func deleteStaples(offsets: IndexSet) {
        withAnimation {
            let staplesToDelete = offsets.map { staples[$0] }
            staplesToDelete.forEach(viewContext.delete)

            do {
                try viewContext.save()
                print("✅ Deleted \(staplesToDelete.count) staple(s)")
            } catch {
                print("❌ Error deleting staples: \(error)")
            }
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
