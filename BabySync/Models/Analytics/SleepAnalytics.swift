import Foundation

struct SleepAnalytics: Codable {
    var babyId: String
    var dateRange: DateRange
    var totalSleepHours: Double
    var averageDailySleep: Double
    var nightSleepAverage: Double
    var napAverage: Double
    var napCount: Int
    var averageNapsPerDay: Double
    var longestSleep: TimeInterval
    var shortestSleep: TimeInterval
    var averageWakeups: Double
    var wakeWindows: [WakeWindow]
    var sleepByDay: [DailySleep]

    struct DateRange: Codable {
        var start: Date
        var end: Date

        var days: Int {
            Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        }
    }

    struct DailySleep: Codable, Identifiable {
        var id: String { date.ISO8601Format() }
        var date: Date
        var totalSleep: TimeInterval
        var napSleep: TimeInterval
        var nightSleep: TimeInterval
        var napCount: Int

        var totalHours: Double {
            totalSleep / 3600
        }

        var napHours: Double {
            napSleep / 3600
        }

        var nightHours: Double {
            nightSleep / 3600
        }
    }

    func targetSleep(for baby: Baby) -> ClosedRange<Double> {
        let months = baby.ageInMonths

        switch months {
        case 0...2:
            return 14.0...17.0
        case 3...5:
            return 12.0...15.0
        case 6...11:
            return 12.0...15.0
        case 12...23:
            return 11.0...14.0
        default:
            return 10.0...13.0
        }
    }

    var meetsTargetSleep: Bool? {
        nil
    }
}
