import Foundation
import FirebaseFirestore

struct Insight: Codable, Identifiable {
    @DocumentID var id: String?
    var babyId: String
    var type: InsightType
    var title: String
    var insightDescription: String
    var confidence: Double
    var data: [String: String]
    var actionable: Bool
    var actionTitle: String?
    var actionRoute: String?
    var createdAt: Date
    var expiresAt: Date?
    var dismissed: Bool

    enum InsightType: String, Codable {
        case pattern = "pattern"
        case recommendation = "recommendation"
        case achievement = "achievement"
        case warning = "warning"

        var displayName: String {
            switch self {
            case .pattern: return "Pattern Detected"
            case .recommendation: return "Recommendation"
            case .achievement: return "Achievement Unlocked"
            case .warning: return "Heads Up"
            }
        }

        var icon: String {
            switch self {
            case .pattern: return "sparkles"
            case .recommendation: return "target"
            case .achievement: return "trophy.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }

    var confidencePercentage: Int {
        Int(confidence * 100)
    }

    var displayConfidence: String {
        "\(confidencePercentage)% confident"
    }

    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case title
        case insightDescription = "description"
        case confidence
        case data
        case actionable
        case actionTitle
        case actionRoute
        case createdAt
        case expiresAt
        case dismissed
    }
}
