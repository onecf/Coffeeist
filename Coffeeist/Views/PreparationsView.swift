import SwiftUI

struct PreparationsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @State private var preparations: [Preparation] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List(preparations) { preparation in
                PreparationTimelineCard(preparation: preparation)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .navigationTitle("My Preparations")
            .task {
                await loadPreparations()
            }
            .refreshable {
                await loadPreparations()
            }
        }
    }
    
    private func loadPreparations() async {
        guard let userId = authService.currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            preparations = try await databaseService.getUserPreparations(userId: userId, limit: 100)
        } catch {
            print("Error loading preparations: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    PreparationsView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 