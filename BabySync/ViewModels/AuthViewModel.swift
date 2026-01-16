import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?

    private let authService = AuthService.shared
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        authService.authStatePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                self?.isAuthenticated = firebaseUser != nil

                if let user = firebaseUser {
                    Task {
                        await self?.loadUserProfile(userId: user.uid)
                    }
                } else {
                    self?.currentUser = nil
                    self?.hasCompletedOnboarding = false
                }
            }
            .store(in: &cancellables)
    }

    private func loadUserProfile(userId: String) async {
        do {
            if let user = try await userService.fetchUser(id: userId) {
                currentUser = user
                hasCompletedOnboarding = !user.sharedBabies.isEmpty
            }
        } catch {
            Logger.error("Failed to load user profile", error: error, category: Logger.auth)
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Sign in failed", error: error, category: Logger.auth)
        }

        isLoading = false
    }

    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let firebaseUser = try await authService.signUp(email: email, password: password, displayName: displayName)

            try await userService.createUserIfNeeded(
                id: firebaseUser.uid,
                email: email,
                displayName: displayName
            )
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Sign up failed", error: error, category: Logger.auth)
        }

        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Sign out failed", error: error, category: Logger.auth)
        }
    }

    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
            Logger.error("Password reset failed", error: error, category: Logger.auth)
        }

        isLoading = false
    }

    func clearError() {
        errorMessage = nil
    }
}
