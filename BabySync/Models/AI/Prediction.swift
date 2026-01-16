import Foundation
import FirebaseFirestore

struct Prediction: Codable, Identifiable {
    var id: String { type.rawValue }
    var babyId: String
    var type: PredictionType
    var predictedTime: Date
    var predictedDuration: TimeInterval?
    var confidence: Double
    var basedOn: String
    var updatedAt: Date

    enum PredictionType: String, Codable {
        case nextNap = "next_nap"
        case nextFeed = "next_feed"
        case bedtime = "bedtime"

        var displayName: String {
            switch self {
            case .nextNap: return "Next Nap"
            case .nextFeed: return "Next Feed"
            case .bedtime: return "Bedtime"
            }
        }

        var icon: String {
            switch self {
            case .nextNap: return "moon.fill"
            case .nextFeed: return "drop.fill"
            case .bedtime: return "bed.double.fill"
            }
        }
    }

    var confidencePercentage: Int {
        Int(confidence * 100)
    }

    var displayConfidence: String {
        "\(confidencePercentage)% confident"
    }

    var timeUntil: TimeInterval {
        predictedTime.timeIntervalSinceNow
    }

    var displayTimeUntil: String {
        let minutes = Int(timeUntil / 60)

        if minutes < 0 {
            return "Overdue by \(abs(minutes)) min"
        } else if minutes < 60 {
            return "In \(minutes) min"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "In \(hours)h \(mins)m"
        }
    }

    var displayDuration: String? {
        guard let duration = predictedDuration else { return nil }
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins) min"
    }

    enum CodingKeys: String, CodingKey {
        case babyId
        case type
        case predictedTime
        case predictedDuration
        case confidence
        case basedOn
        case updatedAt
    }
}
