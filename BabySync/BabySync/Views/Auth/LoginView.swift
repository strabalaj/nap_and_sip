import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                Spacer()

                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Text("BabySync")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Track your baby's day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: Constants.Spacing.md) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, Constants.Spacing.lg)

                Spacer()

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.bottom, Constants.Spacing.lg)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
