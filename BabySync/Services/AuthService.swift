import Foundation
import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    var currentUser: FirebaseAuth.User? { get }
    var isAuthenticated: Bool { get }
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User
    func signUp(email: String, password: String, displayName: String) async throws -> FirebaseAuth.User
    func signOut() throws
    func resetPassword(email: String) async throws
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private let auth = Auth.auth()

    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }

    var isAuthenticated: Bool {
        currentUser != nil
    }

    var currentUserId: String? {
        currentUser?.uid
    }

    private init() {}

    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }

    func signUp(email: String, password: String, displayName: String) async throws -> FirebaseAuth.User {
        let result = try await auth.createUser(withEmail: email, password: password)

        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        return result.user
    }

    func signOut() throws {
        try auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func authStatePublisher() -> AnyPublisher<FirebaseAuth.User?, Never> {
        let subject = PassthroughSubject<FirebaseAuth.User?, Never>()

        auth.addStateDidChangeListener { _, user in
            subject.send(user)
        }

        return subject.eraseToAnyPublisher()
    }
}
