import Foundation

protocol AnalyticsServiceProtocol {
    func calculateSleepAnalytics(events: [SleepEvent], for baby: Baby, dateRange: SleepAnalytics.DateRange) -> SleepAnalytics
    func calculateFeedingAnalytics(events: [FeedEvent], for baby: Baby, dateRange: SleepAnalytics.DateRange) -> FeedingAnalytics
    func calculateWakeWindows(events: [SleepEvent], for baby: Baby) -> [WakeWindow]
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()

    private init() {}

    func calculateSleepAnalytics(events: [SleepEvent], for baby: Baby, dateRange: SleepAnalytics.DateRange) -> SleepAnalytics {
        let interval = dateRange.dateInterval()
        let filteredEvents = events.filter { event in
            event.startTime >= interval.start && event.startTime < interval.end
        }
        
        let completedSleeps = filteredEvents.filter { !$0.isOngoing }

        let totalSeconds = completedSleeps.compactMap { $0.duration }.reduce(0, +)
        let totalHours = totalSeconds / 3600

        let days = max(dateRange.days, 1)
        let averageDaily = totalHours / Double(days)

        let nightSleeps = completedSleeps.filter { $0.isNightSleep }
        let naps = completedSleeps.filter { $0.isNap }

        let nightSeconds = nightSleeps.compactMap { $0.duration }.reduce(0, +)
        let napSeconds = naps.compactMap { $0.duration }.reduce(0, +)

        let durations = completedSleeps.compactMap { $0.duration }

        return SleepAnalytics(
            babyId: baby.id ?? "",
            dateRange: dateRange,
            totalSleepHours: totalHours,
            averageDailySleep: averageDaily,
            nightSleepAverage: (nightSeconds / 3600) / Double(days),
            napAverage: (napSeconds / 3600) / Double(days),
            napCount: naps.count,
            averageNapsPerDay: Double(naps.count) / Double(days),
            longestSleep: durations.max() ?? 0,
            shortestSleep: durations.min() ?? 0,
            averageWakeups: 0,
            wakeWindows: calculateWakeWindows(events: events, for: baby),
            sleepByDay: []
        )
    }

    func calculateFeedingAnalytics(events: [FeedEvent], for baby: Baby, dateRange: SleepAnalytics.DateRange) -> FeedingAnalytics {
        let interval = dateRange.dateInterval()
        let filteredEvents = events.filter { event in
            event.timestamp >= interval.start && event.timestamp < interval.end
        }
        
        let days = max(dateRange.days, 1)

        let totalVolume = filteredEvents.compactMap { $0.volume }.reduce(0, +)
        let averageDaily = totalVolume / Double(days)
        let averagePerFeed = filteredEvents.isEmpty ? 0 : totalVolume / Double(filteredEvents.count)

        var methodCounts: [String: Int] = [:]
        for event in filteredEvents {
            methodCounts[event.method.rawValue, default: 0] += 1
        }

        var averageInterval: TimeInterval = 0
        if filteredEvents.count > 1 {
            let sortedEvents = filteredEvents.sorted { $0.timestamp < $1.timestamp }
            var totalInterval: TimeInterval = 0
            for i in 1..<sortedEvents.count {
                totalInterval += sortedEvents[i].timestamp.timeIntervalSince(sortedEvents[i-1].timestamp)
            }
            averageInterval = totalInterval / Double(sortedEvents.count - 1)
        }

        return FeedingAnalytics(
            babyId: baby.id ?? "",
            dateRange: dateRange,
            totalFeedings: filteredEvents.count,
            averageFeedingsPerDay: Double(filteredEvents.count) / Double(days),
            totalVolume: totalVolume,
            averageDailyVolume: averageDaily,
            averageVolumePerFeed: averagePerFeed,
            averageIntervalBetweenFeeds: averageInterval,
            feedingsByMethod: methodCounts,
            feedingsByDay: []
        )
    }

    func calculateWakeWindows(events: [SleepEvent], for baby: Baby) -> [WakeWindow] {
        let sortedSleeps = events
            .filter { $0.endTime != nil }
            .sorted { $0.endTime! < $1.endTime! }

        var wakeWindows: [WakeWindow] = []

        for i in 0..<(sortedSleeps.count - 1) {
            guard let wakeTime = sortedSleeps[i].endTime else { continue }
            let nextSleepStart = sortedSleeps[i + 1].startTime

            let duration = nextSleepStart.timeIntervalSince(wakeTime)

            if duration > 0 && duration < 12 * 3600 {
                var window = WakeWindow(
                    startTime: wakeTime,
                    endTime: nextSleepStart,
                    duration: duration,
                    windowNumber: wakeWindows.count + 1
                )
                window.quality = window.evaluateQuality(for: baby.ageInMonths)
                wakeWindows.append(window)
            }
        }

        return wakeWindows
    }
}
