import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    
    var body: some View {
        TabView {
            // Home/Timeline Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Preparations Tab
            PreparationsView()
                .tabItem {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Preparations")
                }
            
            // Coffee Inventory Tab
            InventoryView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Inventory")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.brown)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 