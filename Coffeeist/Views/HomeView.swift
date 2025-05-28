import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @State private var preparations: [Preparation] = []
    @State private var isLoading = false
    @State private var showingNewPreparationForm = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header with date and greeting
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedDate)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Good morning, \(authService.currentUser?.displayName.components(separatedBy: " ").first ?? "Coffee Lover")!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    
                    // Timeline or empty state
                    if preparations.isEmpty && !isLoading {
                        ContentUnavailableView(
                            "No Coffee Preparations Yet",
                            systemImage: "cup.and.saucer",
                            description: Text("Tap the button below to log your first coffee preparation.")
                        )
                        .padding()
                        Spacer()
                    } else {
                        PreparationTimelineView(preparations: preparations)
                    }
                    
                    // Add prominent CTA button at the bottom
                    Button(action: {
                        showingNewPreparationForm = true
                    }) {
                        Label("Log New Preparation", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
                
                // Loading overlay
                if isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("Coffeeist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingNewPreparationForm = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewPreparationForm) {
                NavigationStack {
                    NewPreparationFormView()
                }
                .presentationDetents([.large])
            }
            .task {
                await loadPreparations()
            }
            .refreshable {
                await loadPreparations()
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
    private func loadPreparations() async {
        guard let userId = authService.currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            preparations = try await databaseService.getUserPreparations(userId: userId, limit: 10)
        } catch {
            errorMessage = "Failed to load preparations: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationService())
        .environmentObject(DatabaseService())
} 