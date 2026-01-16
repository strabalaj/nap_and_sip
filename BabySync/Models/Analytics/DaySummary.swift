import Foundation

struct DaySummary: Codable {
    var date: Date
    var totalFeedings: Int
    var totalVolume: Double
    var napCount: Int
    var daySleepHours: Double
    var nightSleepHours: Double
    var diaperCount: Int
    var milestones: Int

    var totalSleepHours: Double {
        daySleepHours + nightSleepHours
    }

    var displayVolume: String {
        "\(Int(totalVolume)) oz"
    }

    var displayDaySleep: String {
        let hours = Int(daySleepHours)
        let minutes = Int((daySleepHours - Double(hours)) * 60)
        return "\(hours).\(minutes) hrs"
    }

    var displayNightSleep: String {
        let hours = Int(nightSleepHours)
        let minutes = Int((nightSleepHours - Double(hours)) * 60)
        return "\(hours).\(minutes) hrs"
    }
}
