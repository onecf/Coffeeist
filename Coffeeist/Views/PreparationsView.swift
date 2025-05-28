import SwiftUI

struct PreparationsView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @EnvironmentObject private var databaseService: DatabaseService
    @State private var preparations: [Preparation] = []
    @State private var isLoading = false
    @State private var showingNewPreparationForm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    if preparations.isEmpty && !isLoading {
                        ContentUnavailableView(
                            "No Preparations Yet",
                            systemImage: "cup.and.saucer",
                            description: Text("Start logging your coffee preparations to track your brewing journey.")
                        )
                        .padding()
                        Spacer()
                    } else {
                        List(preparations) { preparation in
                            PreparationTimelineCard(preparation: preparation)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .listStyle(.plain)
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
                    ProgressView("Loading preparations...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
            .navigationTitle("My Preparations")
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