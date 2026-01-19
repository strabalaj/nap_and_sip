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
    
    // MARK: - Sample Data
    static var sample: Insight {
        Insight(
            id: nil,
            babyId: "baby123",
            type: .pattern,
            title: "Consistent Sleep Pattern",
            insightDescription: "Your baby has been sleeping consistently for 10-12 hours at night for the past week.",
            confidence: 0.89,
            data: ["avgNightSleep": "11.2", "nights": "7"],
            actionable: false,
            actionTitle: nil,
            actionRoute: nil,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            dismissed: false
        )
    }
    
    static var sampleRecommendation: Insight {
        Insight(
            id: nil,
            babyId: "baby123",
            type: .recommendation,
            title: "Optimize Wake Windows",
            insightDescription: "Consider shortening the last wake window by 15 minutes to help baby fall asleep easier.",
            confidence: 0.75,
            data: ["currentWindow": "2.5", "suggested": "2.25"],
            actionable: true,
            actionTitle: "View Sleep Schedule",
            actionRoute: "/analytics",
            createdAt: Date(),
            expiresAt: nil,
            dismissed: false
        )
    }
    
    static var sampleAchievement: Insight {
        Insight(
            id: nil,
            babyId: "baby123",
            type: .achievement,
            title: "Sleep Through the Night!",
            insightDescription: "Amazing! Your baby slept 12 hours straight last night without waking up.",
            confidence: 1.0,
            data: ["duration": "12.0"],
            actionable: false,
            actionTitle: nil,
            actionRoute: nil,
            createdAt: Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            dismissed: false
        )
    }
    
    static var samples: [Insight] {
        [sample, sampleRecommendation, sampleAchievement]
    }
}
