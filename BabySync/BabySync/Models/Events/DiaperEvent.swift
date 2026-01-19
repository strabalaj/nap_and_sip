import Foundation
import FirebaseFirestore

struct DiaperEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .diaper
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    var diaperType: DiaperType

    enum DiaperType: String, Codable, CaseIterable {
        case wet
        case dirty
        case both

        var displayName: String {
            switch self {
            case .wet: return "Wet"
            case .dirty: return "Dirty"
            case .both: return "Wet & Dirty"
            }
        }

        var icon: String {
            switch self {
            case .wet: return "drop.fill"
            case .dirty: return "tornado"
            case .both: return "drop.triangle.fill"
            }
        }
    }

    var displayType: String {
        diaperType.displayName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case timestamp
        case createdBy
        case createdAt
        case updatedAt
        case notes
        case photoURLs
        case diaperType
    }

    init(
        id: String? = nil,
        babyId: String,
        timestamp: Date = Date(),
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        photoURLs: [String]? = nil,
        diaperType: DiaperType
    ) {
        self.id = id
        self.babyId = babyId
        self.timestamp = timestamp
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.photoURLs = photoURLs
        self.diaperType = diaperType
    }
}
