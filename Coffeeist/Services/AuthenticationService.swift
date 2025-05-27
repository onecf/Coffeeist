import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let databaseService = DatabaseService()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.loadCurrentUser(firebaseUser: user)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    private func loadCurrentUser(firebaseUser: FirebaseAuth.User) async {
        do {
            if let user = try await databaseService.getUser(uid: firebaseUser.uid) {
                self.currentUser = user
                self.isAuthenticated = true
                print("✅ Successfully loaded user profile for: \(user.displayName)")
            } else {
                // User exists in Firebase Auth but not in our database
                // This might happen during the migration period or for existing users
                print("⚠️ User exists in Firebase Auth but not in Firestore. Creating profile...")
                await createUserProfile(from: firebaseUser)
            }
        } catch {
            print("❌ Error loading user: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
        }
    }
    
    private func createUserProfile(from firebaseUser: FirebaseAuth.User) async {
        let user = User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? "Coffee Lover",
            profileImageURL: firebaseUser.photoURL?.absoluteString
        )
        
        print("🔄 Creating user profile for: \(user.displayName) (\(user.email))")
        
        do {
            try await databaseService.createUser(user)
            
            // Seed default data for existing users
            try await databaseService.seedDefaultBrewingMethods()
            try await databaseService.seedDefaultCoffeeBeans(createdBy: user.uid)
            
            self.currentUser = user
            self.isAuthenticated = true
            print("✅ Successfully created user profile for: \(user.displayName)")
        } catch {
            print("❌ Error creating user profile: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            self.errorMessage = "Failed to create user profile: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Create user profile in our database
            let user = User(
                uid: result.user.uid,
                email: email,
                displayName: displayName
            )
            
            try await databaseService.createUser(user)
            
            // Seed default data
            try await databaseService.seedDefaultBrewingMethods()
            try await databaseService.seedDefaultCoffeeBeans(createdBy: result.user.uid)
            
            self.currentUser = user
            self.isAuthenticated = true
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await loadCurrentUser(firebaseUser: result.user)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateProfile(displayName: String? = nil, bio: String? = nil, location: String? = nil, userTypes: [UserType]? = nil) async {
        guard var user = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Update Firebase Auth profile if display name changed
            if let displayName = displayName, displayName != user.displayName {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = displayName
                try await changeRequest?.commitChanges()
                user.displayName = displayName
            }
            
            // Update other profile fields
            if let bio = bio { user.bio = bio }
            if let location = location { user.location = location }
            if let userTypes = userTypes { user.userTypes = userTypes }
            
            // Update in database
            try await databaseService.updateUser(user)
            self.currentUser = user
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteAccount() async {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // TODO: In production, you'd want to delete all user data from Firestore
            // This would require a cloud function or careful client-side cleanup
            
            try await firebaseUser.delete()
            self.currentUser = nil
            self.isAuthenticated = false
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Utility Methods
    
    func refreshCurrentUser() async {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        await loadCurrentUser(firebaseUser: firebaseUser)
    }
    
    var isEmailVerified: Bool {
        return Auth.auth().currentUser?.isEmailVerified ?? false
    }
    
    func sendEmailVerification() async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            try await user.sendEmailVerification()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 