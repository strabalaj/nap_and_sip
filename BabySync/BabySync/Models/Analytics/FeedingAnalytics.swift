import Foundation

struct FeedingAnalytics: Codable {
    var babyId: String
    var dateRange: SleepAnalytics.DateRange
    var totalFeedings: Int
    var averageFeedingsPerDay: Double
    var totalVolume: Double
    var averageDailyVolume: Double
    var averageVolumePerFeed: Double
    var averageIntervalBetweenFeeds: TimeInterval
    var feedingsByMethod: [String: Int]
    var feedingsByDay: [DailyFeeding]

    struct DailyFeeding: Codable, Identifiable {
        var id: String { date.ISO8601Format() }
        var date: Date
        var count: Int
        var totalVolume: Double
        var averageInterval: TimeInterval

        var displayVolume: String {
            "\(Int(totalVolume)) oz"
        }
    }

    func targetVolume(for baby: Baby) -> ClosedRange<Double> {
        let months = baby.ageInMonths

        switch months {
        case 0...1:
            return 18.0...32.0
        case 2...3:
            return 24.0...36.0
        case 4...5:
            return 25.0...40.0
        case 6...8:
            return 24.0...32.0
        case 9...11:
            return 20.0...30.0
        default:
            return 16.0...24.0
        }
    }
}
