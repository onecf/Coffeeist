import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                Section {
                    HStack {
                        Circle()
                            .fill(Color.brown.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(authService.currentUser?.displayName.prefix(1).uppercased() ?? "U")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.brown)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.currentUser?.displayName ?? "Unknown User")
                                .font(.headline)
                            
                            Text("@\(authService.currentUser?.username ?? "coffee_lover")")
                                .font(.subheadline)
                                .foregroundColor(.brown)
                            
                            Text(authService.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let bio = authService.currentUser?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Stats Section
                Section("Stats") {
                    HStack {
                        VStack {
                            Text("\(authService.currentUser?.preparationsCount ?? 0)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Preparations")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(authService.currentUser?.followersCount ?? 0)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Followers")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(authService.currentUser?.followingCount ?? 0)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Following")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Settings Section
                Section("Settings") {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Label("Edit Profile", systemImage: "person.circle")
                    }
                    
                    Button(action: {
                        authService.signOut()
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Information") {
                    TextField("Display Name", text: $displayName)
                    
                    HStack {
                        Text("@")
                            .foregroundColor(.brown)
                        TextField("username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Location", text: $location)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        if let user = authService.currentUser {
            displayName = user.displayName
            username = user.username
            bio = user.bio ?? ""
            location = user.location ?? ""
        }
    }
    
    private func saveProfile() async {
        isSaving = true
        
        await authService.updateProfile(
            displayName: displayName.isEmpty ? nil : displayName,
            username: username.isEmpty ? nil : username,
            bio: bio.isEmpty ? nil : bio,
            location: location.isEmpty ? nil : location
        )
        
        isSaving = false
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
} 