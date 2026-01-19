import Foundation
import FirebaseFirestore

protocol BabyEvent: Codable, Identifiable {
    var id: String? { get set }
    var babyId: String { get }
    var type: EventType { get }
    var timestamp: Date { get }
    var createdBy: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var notes: String? { get }
    var photoURLs: [String]? { get }
}
