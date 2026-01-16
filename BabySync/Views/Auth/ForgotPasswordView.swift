import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                Text("Reset Password")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await authViewModel.resetPassword(email: email)
                        if authViewModel.errorMessage == nil {
                            showSuccess = true
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Reset Link")
                    }
                }
                .primaryButtonStyle()
                .disabled(!Validators.isValidEmail(email) || authViewModel.isLoading)

                Spacer()
            }
            .padding(Constants.Spacing.lg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Email Sent", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Check your email for a password reset link.")
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
}
