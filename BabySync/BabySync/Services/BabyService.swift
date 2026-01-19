import Foundation
import FirebaseFirestore
import Combine

protocol BabyServiceProtocol {
    func createBaby(_ baby: Baby) async throws -> String
    func fetchBaby(id: String) async throws -> Baby?
    func fetchBabies(for userId: String) async throws -> [Baby]
    func updateBaby(_ baby: Baby) async throws
    func deleteBaby(id: String) async throws
    func shareBaby(babyId: String, withUserId userId: String) async throws
}

final class BabyService: BabyServiceProtocol {
    static let shared = BabyService()

    private let firebase = FirebaseService.shared

    private init() {}

    func createBaby(_ baby: Baby) async throws -> String {
        try await firebase.create(baby, in: firebase.babiesCollection)
    }

    func fetchBaby(id: String) async throws -> Baby? {
        try await firebase.read(Baby.self, documentId: id, from: firebase.babiesCollection)
    }

    func fetchBabies(for userId: String) async throws -> [Baby] {
        let snapshot = try await firebase.babiesCollection
            .whereField("owners", arrayContains: userId)
            .getDocuments()

        return try snapshot.documents.compactMap { doc in
            try doc.data(as: Baby.self)
        }
    }

    func updateBaby(_ baby: Baby) async throws {
        guard let babyId = baby.id else {
            throw BabyServiceError.missingBabyId
        }
        try await firebase.update(baby, documentId: babyId, in: firebase.babiesCollection)
    }

    func deleteBaby(id: String) async throws {
        try await firebase.delete(documentId: id, from: firebase.babiesCollection)
    }

    func shareBaby(babyId: String, withUserId userId: String) async throws {
        let docRef = firebase.babiesCollection.document(babyId)
        try await docRef.updateData([
            "owners": FieldValue.arrayUnion([userId])
        ])
    }

    func observeBabies(for userId: String) -> AnyPublisher<[Baby], Error> {
        let subject = PassthroughSubject<[Baby], Error>()

        firebase.babiesCollection
            .whereField("owners", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let babies = (snapshot?.documents ?? []).compactMap { doc in
                    try? doc.data(as: Baby.self)
                }

                subject.send(babies)
            }

        return subject.eraseToAnyPublisher()
    }
}

enum BabyServiceError: LocalizedError {
    case missingBabyId

    var errorDescription: String? {
        switch self {
        case .missingBabyId:
            return "Baby ID is required for this operation"
        }
    }
}
