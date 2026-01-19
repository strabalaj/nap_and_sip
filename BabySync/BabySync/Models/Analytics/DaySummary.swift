import Foundation

struct DaySummary: Codable, Identifiable {
    var id: Date { date }
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
    
    // MARK: - Sample Data
    static var sampleWeek: [DaySummary] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            return DaySummary(
                date: date,
                totalFeedings: Int.random(in: 6...10),
                totalVolume: Double.random(in: 20...32),
                napCount: Int.random(in: 3...5),
                daySleepHours: Double.random(in: 2.5...4.5),
                nightSleepHours: Double.random(in: 9...12),
                diaperCount: Int.random(in: 6...10),
                milestones: Int.random(in: 0...2)
            )
        }.reversed()
    }
    
    static var sample: DaySummary {
        DaySummary(
            date: Date(),
            totalFeedings: 8,
            totalVolume: 26.5,
            napCount: 4,
            daySleepHours: 3.5,
            nightSleepHours: 10.5,
            diaperCount: 8,
            milestones: 1
        )
    }
}
