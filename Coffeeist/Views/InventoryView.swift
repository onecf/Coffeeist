import SwiftUI

struct InventoryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coffee Inventory",
                systemImage: "bag.fill",
                description: Text("Track your coffee beans and equipment here. Coming soon!")
            )
            .navigationTitle("Inventory")
        }
    }
}

#Preview {
    InventoryView()
} 