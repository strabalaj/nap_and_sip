import Foundation
import FirebaseFirestore

final class FirebaseService {
    static let shared = FirebaseService()

    let db = Firestore.firestore()

    private init() {
        configureFirestore()
    }

    private func configureFirestore() {
        let settings = db.settings
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        db.settings = settings
    }

    // MARK: - Collections

    var usersCollection: CollectionReference {
        db.collection("users")
    }

    var babiesCollection: CollectionReference {
        db.collection("babies")
    }

    func eventsCollection(for babyId: String) -> CollectionReference {
        db.collection("events").document(babyId).collection("events")
    }

    func insightsCollection(for babyId: String) -> CollectionReference {
        db.collection("insights").document(babyId).collection("insights")
    }

    func predictionsCollection(for babyId: String) -> CollectionReference {
        db.collection("predictions").document(babyId).collection("predictions")
    }

    // MARK: - Generic Operations

    func create<T: Codable>(_ document: T, in collection: CollectionReference) async throws -> String {
        let docRef = try collection.addDocument(from: document)
        return docRef.documentID
    }

    func read<T: Codable>(_ type: T.Type, documentId: String, from collection: CollectionReference) async throws -> T? {
        let snapshot = try await collection.document(documentId).getDocument()
        return try snapshot.data(as: T.self)
    }

    func update<T: Codable>(_ document: T, documentId: String, in collection: CollectionReference) async throws {
        try collection.document(documentId).setData(from: document, merge: true)
    }

    func delete(documentId: String, from collection: CollectionReference) async throws {
        try await collection.document(documentId).delete()
    }
}
