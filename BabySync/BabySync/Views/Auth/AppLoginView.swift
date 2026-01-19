import SwiftUI

struct AppLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUpMode = false
    @State private var showResetPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo/Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.pink.gradient)
                    
                    Text("BabySync")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track, share, and cherish every moment")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Form
                VStack(spacing: 16) {
                    if isSignUpMode {
                        TextField("Full Name", text: $displayName)
                            .textContentType(.name)
                            .autocapitalization(.words)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .textContentType(isSignUpMode ? .newPassword : .password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Error Message
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        Task {
                            if isSignUpMode {
                                await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    displayName: displayName
                                )
                            } else {
                                await authViewModel.signIn(
                                    email: email,
                                    password: password
                                )
                            }
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(isSignUpMode ? "Create Account" : "Sign In")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(authViewModel.isLoading || !isFormValid)
                    
                    Button {
                        withAnimation {
                            isSignUpMode.toggle()
                            authViewModel.clearError()
                        }
                    } label: {
                        Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !isSignUpMode {
                        Button {
                            showResetPassword = true
                        } label: {
                            Text("Forgot Password?")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .alert("Reset Password", isPresented: $showResetPassword) {
                TextField("Email", text: $email)
                Button("Cancel", role: .cancel) {}
                Button("Send Reset Link") {
                    Task {
                        await authViewModel.resetPassword(email: email)
                    }
                }
            } message: {
                Text("Enter your email address to receive a password reset link.")
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !displayName.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
}

#Preview {
    AppLoginView()
        .environmentObject(AuthViewModel())
}
