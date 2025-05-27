import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App Logo/Header
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.brown)
                    
                    Text("Coffeeist")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your perfect coffee journey")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Form
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(isSignUp ? .newPassword : .password)
                    
                    if isSignUp {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                    }
                    
                    // Error message
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Main action button
                    Button(action: handleMainAction) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.brown : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isFormValid || authService.isLoading)
                    
                    // Toggle between sign in/up
                    Button(action: {
                        isSignUp.toggle()
                        clearForm()
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.brown)
                    }
                    
                    // Forgot password
                    if !isSignUp {
                        Button("Forgot Password?") {
                            showingForgotPassword = true
                        }
                        .font(.footnote)
                        .foregroundColor(.brown)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .alert("Reset Password", isPresented: $showingForgotPassword) {
                TextField("Email", text: $email)
                Button("Send Reset Email") {
                    Task {
                        await authService.resetPassword(email: email)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your email address to receive a password reset link.")
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !displayName.isEmpty && 
                   password == confirmPassword &&
                   password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleMainAction() {
        Task {
            if isSignUp {
                await authService.signUp(email: email, password: password, displayName: displayName)
            } else {
                await authService.signIn(email: email, password: password)
            }
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        authService.errorMessage = nil
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationService())
} 