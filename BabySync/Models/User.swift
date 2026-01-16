import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var photoURL: String?
    var sharedBabies: [String]
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case photoURL
        case sharedBabies
        case createdAt
        case updatedAt
    }

    init(
        id: String? = nil,
        email: String,
        displayName: String,
        photoURL: String? = nil,
        sharedBabies: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.sharedBabies = sharedBabies
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
