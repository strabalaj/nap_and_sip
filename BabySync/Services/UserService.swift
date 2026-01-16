import Foundation
import FirebaseFirestore

protocol UserServiceProtocol {
    func createUser(_ user: User) async throws -> String
    func fetchUser(id: String) async throws -> User?
    func updateUser(_ user: User) async throws
}

final class UserService: UserServiceProtocol {
    static let shared = UserService()

    private let firebase = FirebaseService.shared

    private init() {}

    func createUser(_ user: User) async throws -> String {
        if let userId = user.id {
            try firebase.usersCollection.document(userId).setData(from: user)
            return userId
        } else {
            return try await firebase.create(user, in: firebase.usersCollection)
        }
    }

    func fetchUser(id: String) async throws -> User? {
        try await firebase.read(User.self, documentId: id, from: firebase.usersCollection)
    }

    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw UserServiceError.missingUserId
        }
        try await firebase.update(user, documentId: userId, in: firebase.usersCollection)
    }

    func createUserIfNeeded(id: String, email: String, displayName: String) async throws {
        let existingUser = try await fetchUser(id: id)

        if existingUser == nil {
            let newUser = User(
                id: id,
                email: email,
                displayName: displayName,
                sharedBabies: []
            )
            _ = try await createUser(newUser)
        }
    }
}

enum UserServiceError: LocalizedError {
    case missingUserId

    var errorDescription: String? {
        switch self {
        case .missingUserId:
            return "User ID is required for this operation"
        }
    }
}
