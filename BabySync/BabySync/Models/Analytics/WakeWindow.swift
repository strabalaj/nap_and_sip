import Foundation

struct WakeWindow: Codable, Identifiable {
    var id: String { "\(startTime.ISO8601Format())-\(endTime.ISO8601Format())" }
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var windowNumber: Int
    var quality: WakeWindowQuality?

    enum WakeWindowQuality: String, Codable {
        case short = "Short"
        case optimal = "Good"
        case long = "Long"
        case tooLong = "Too Long"
    }

    var durationInMinutes: Int {
        Int(duration / 60)
    }

    var displayDuration: String {
        let hours = durationInMinutes / 60
        let mins = durationInMinutes % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }

    static func targetRange(for ageInMonths: Int, windowNumber: Int) -> ClosedRange<Int> {
        switch ageInMonths {
        case 0...1:
            return 30...90
        case 2...3:
            return 60...120
        case 4...5:
            return 90...150
        case 6...8:
            switch windowNumber {
            case 1: return 120...150
            case 2: return 150...180
            default: return 90...120
            }
        case 9...11:
            return 150...240
        case 12...18:
            return 240...360
        default:
            return 300...420
        }
    }

    func evaluateQuality(for ageInMonths: Int) -> WakeWindowQuality {
        let target = Self.targetRange(for: ageInMonths, windowNumber: windowNumber)
        let mins = durationInMinutes

        if mins < target.lowerBound {
            return .short
        } else if mins > target.upperBound + 30 {
            return .tooLong
        } else if mins > target.upperBound {
            return .long
        } else {
            return .optimal
        }
    }
}
