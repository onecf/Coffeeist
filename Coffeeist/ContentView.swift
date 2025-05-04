//
//  ContentView.swift
//  Coffeeist
//
//  Created by Juan Colmenares on 5/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingNewPreparationForm = false
    @EnvironmentObject private var dataManager: PreparationDataManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with date and greeting
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Good morning, Juan!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                
                // Timeline or empty state
                if dataManager.preparations.isEmpty {
                    ContentUnavailableView(
                        "No Coffee Preparations Yet",
                        systemImage: "cup.and.saucer",
                        description: Text("Tap the button below to log your first coffee preparation.")
                    )
                    .padding()
                    Spacer()
                } else {
                    TimelineView()
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
                    PreparationFormView(editMode: false)
                }
                .presentationDetents([.large])
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}

#Preview {
    ContentView()
        .environmentObject(PreparationDataManager())
}
