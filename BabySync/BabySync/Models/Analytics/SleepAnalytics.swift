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

    enum DateRange: String, Codable, CaseIterable, Hashable {
        case today
        case week
        case month
        case custom
        
        var displayName: String {
            switch self {
            case .today: return "Today"
            case .week: return "Week"
            case .month: return "Month"
            case .custom: return "Custom"
            }
        }
        
        var days: Int {
            switch self {
            case .today: return 1
            case .week: return 7
            case .month: return 30
            case .custom: return 30
            }
        }
        
        func dateInterval(from referenceDate: Date = Date()) -> (start: Date, end: Date) {
            let calendar = Calendar.current
            
            switch self {
            case .today:
                let start = calendar.startOfDay(for: referenceDate)
                let end = calendar.date(byAdding: .day, value: 1, to: start) ?? referenceDate
                return (start, end)
                
            case .week:
                let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: referenceDate)) ?? referenceDate
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? referenceDate
                return (weekStart, weekEnd)
                
            case .month:
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate
                let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? referenceDate
                return (monthStart, monthEnd)
                
            case .custom:
                return (referenceDate, referenceDate)
            }
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
