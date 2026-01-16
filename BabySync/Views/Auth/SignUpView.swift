import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var isFormValid: Bool {
        !displayName.isEmpty &&
        Validators.isValidEmail(email) &&
        Validators.isValidPassword(password) &&
        password == confirmPassword
    }

    var body: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: Constants.Spacing.md) {
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                if !password.isEmpty {
                    HStack {
                        Text("Password strength:")
                        Text(Validators.passwordStrength(password).description)
                            .fontWeight(.medium)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                if password != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await authViewModel.signUp(email: email, password: password, displayName: displayName)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account")
                    }
                }
                .primaryButtonStyle()
                .disabled(!isFormValid || authViewModel.isLoading)
            }
            .padding(.horizontal, Constants.Spacing.lg)

            Spacer()
        }
        .padding(.top, Constants.Spacing.xl)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
