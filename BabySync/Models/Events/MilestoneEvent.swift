import Foundation
import FirebaseFirestore

struct MilestoneEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .milestone
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    var title: String
    var milestoneDescription: String?
    var category: MilestoneCategory

    enum MilestoneCategory: String, Codable, CaseIterable {
        case physical = "Physical"
        case cognitive = "Cognitive"
        case social = "Social & Emotional"
        case language = "Language"
        case other = "Other"

        var icon: String {
            switch self {
            case .physical: return "figure.walk"
            case .cognitive: return "brain.head.profile"
            case .social: return "person.2"
            case .language: return "text.bubble"
            case .other: return "star"
            }
        }
    }

    static let commonMilestones = [
        "First smile",
        "First laugh",
        "Rolled over",
        "First solid food",
        "Sat up alone",
        "First tooth",
        "Crawled",
        "Stood up",
        "First steps",
        "First word",
        "First birthday"
    ]

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
        case title
        case milestoneDescription = "description"
        case category
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
        title: String,
        milestoneDescription: String? = nil,
        category: MilestoneCategory
    ) {
        self.id = id
        self.babyId = babyId
        self.timestamp = timestamp
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.photoURLs = photoURLs
        self.title = title
        self.milestoneDescription = milestoneDescription
        self.category = category
    }
}
