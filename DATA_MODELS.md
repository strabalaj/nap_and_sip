# BabySync - Data Models

## Overview
This document defines all data models used in the BabySync application. All models conform to `Codable` for Firebase Firestore serialization.

## Core Models

### User

```swift
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var photoURL: String?
    var sharedBabies: [String] // Baby IDs this user has access to
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case photoURL
        case sharedBabies
        case createdAt
        case updatedAt
    }
}
```

### Baby

```swift
import Foundation
import FirebaseFirestore

struct Baby: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var dateOfBirth: Date
    var gender: Gender?
    var photoURL: String?
    var owners: [String] // User IDs with access
    var createdBy: String // User ID who created this baby profile
    var createdAt: Date
    var updatedAt: Date

    enum Gender: String, Codable {
        case male
        case female
        case other
    }

    // Computed properties
    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: dateOfBirth, to: Date()).day ?? 0
    }

    var ageInWeeks: Int {
        ageInDays / 7
    }

    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }

    var ageDescription: String {
        if ageInDays < 14 {
            return "\(ageInDays) days old"
        } else if ageInMonths < 12 {
            return "\(ageInMonths) months old"
        } else {
            let years = ageInMonths / 12
            let months = ageInMonths % 12
            if months == 0 {
                return "\(years) year\(years > 1 ? "s" : "") old"
            }
            return "\(years)y \(months)m old"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dateOfBirth
        case gender
        case photoURL
        case owners
        case createdBy
        case createdAt
        case updatedAt
    }
}
```

## Event Models

### Base Event Protocol

```swift
import Foundation
import FirebaseFirestore

protocol BabyEvent: Codable, Identifiable {
    var id: String? { get set }
    var babyId: String { get }
    var type: EventType { get }
    var timestamp: Date { get }
    var createdBy: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var notes: String? { get }
    var photoURLs: [String]? { get }
}

enum EventType: String, Codable {
    case feed
    case sleep
    case diaper
    case milestone
}
```

### Feed Event

```swift
import Foundation
import FirebaseFirestore

struct FeedEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .feed
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    // Feed-specific fields
    var method: FeedMethod
    var volume: Double? // In ounces for bottle
    var unit: VolumeUnit = .oz
    var side: BreastSide? // For breastfeeding
    var duration: Int? // In minutes for breastfeeding
    var foodType: String? // For solids

    enum FeedMethod: String, Codable {
        case bottle = "bottle"
        case breast = "breast"
        case solids = "solids"
        case mixed = "mixed" // Bottle + breast
    }

    enum BreastSide: String, Codable {
        case left
        case right
        case both
    }

    enum VolumeUnit: String, Codable {
        case oz
        case ml
    }

    // Computed properties
    var volumeInML: Double? {
        guard let volume = volume else { return nil }
        switch unit {
        case .oz:
            return volume * 29.5735 // Convert oz to ml
        case .ml:
            return volume
        }
    }

    var displayVolume: String? {
        guard let volume = volume else { return nil }
        return "\(Int(volume)) \(unit.rawValue)"
    }

    var displayDuration: String? {
        guard let duration = duration else { return nil }
        return "\(duration) min"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case timestamp
        case createdBy
        case createdAt
        case updatedAt
        case notes
        case photoURLs
        case method
        case volume
        case unit
        case side
        case duration
        case foodType
    }
}
```

### Sleep Event

```swift
import Foundation
import FirebaseFirestore

struct SleepEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .sleep
    var timestamp: Date // Start time
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    // Sleep-specific fields
    var startTime: Date
    var endTime: Date? // Nil if sleep is ongoing
    var quality: SleepQuality?
    var isNightSleep: Bool
    var napNumber: Int? // 1st, 2nd, 3rd nap of the day

    enum SleepQuality: String, Codable {
        case excellent
        case good
        case fair
        case poor
    }

    // Computed properties
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    var durationInMinutes: Int? {
        guard let duration = duration else { return nil }
        return Int(duration / 60)
    }

    var durationInHours: Double? {
        guard let duration = duration else { return nil }
        return duration / 3600
    }

    var displayDuration: String {
        guard let minutes = durationInMinutes else { return "Ongoing" }

        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }

    var isOngoing: Bool {
        endTime == nil
    }

    var isNap: Bool {
        !isNightSleep
    }

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case timestamp
        case createdBy
        case createdAt
        case updatedAt
        case notes
        case photoURLs
        case startTime
        case endTime
        case quality
        case isNightSleep
        case napNumber
    }
}
```

### Diaper Event

```swift
import Foundation
import FirebaseFirestore

struct DiaperEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .diaper
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    // Diaper-specific fields
    var diaperType: DiaperType

    enum DiaperType: String, Codable {
        case wet
        case dirty
        case both
    }

    var displayType: String {
        switch diaperType {
        case .wet:
            return "Wet"
        case .dirty:
            return "Dirty"
        case .both:
            return "Wet & Dirty"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case timestamp
        case createdBy
        case createdAt
        case updatedAt
        case notes
        case photoURLs
        case diaperType
    }
}
```

### Milestone Event

```swift
import Foundation
import FirebaseFirestore

struct MilestoneEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .milestone
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    // Milestone-specific fields
    var title: String
    var description: String?
    var category: MilestoneCategory

    enum MilestoneCategory: String, Codable, CaseIterable {
        case physical = "Physical"
        case cognitive = "Cognitive"
        case social = "Social & Emotional"
        case language = "Language"
        case other = "Other"

        var icon: String {
            switch self {
            case .physical: return "figure.walk"
            case .cognitive: return "brain.head.profile"
            case .social: return "person.2"
            case .language: return "text.bubble"
            case .other: return "star"
            }
        }
    }

    // Common milestone presets
    static let commonMilestones = [
        "First smile",
        "First laugh",
        "Rolled over",
        "First solid food",
        "Sat up alone",
        "First tooth",
        "Crawled",
        "Stood up",
        "First steps",
        "First word",
        "First birthday"
    ]

    enum CodingKeys: String, CodingKey {
        case id
        case babyId
        case type
        case timestamp
        case createdBy
        case createdAt
        case updatedAt
        case notes
        case photoURLs
        case title
        case description
        case category
    }
}
```

## Analytics Models

### Sleep Analytics

```swift
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

    // Age-appropriate sleep targets (in hours)
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
        // Compare with typical ranges
        // This would check against baby's age
        return nil // Implement based on baby age
    }
}
```

### Wake Window

```swift
import Foundation

struct WakeWindow: Codable, Identifiable {
    var id: String { "\(startTime.ISO8601Format())-\(endTime.ISO8601Format())" }
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var windowNumber: Int // 1st, 2nd, 3rd wake window of the day
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

    // Age-appropriate wake window targets (in minutes)
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
            default: return 90...120 // Last window before bed
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
```

### Feeding Analytics

```swift
import Foundation

struct FeedingAnalytics: Codable {
    var babyId: String
    var dateRange: SleepAnalytics.DateRange
    var totalFeedings: Int
    var averageFeedingsPerDay: Double
    var totalVolume: Double // In oz
    var averageDailyVolume: Double
    var averageVolumePerFeed: Double
    var averageIntervalBetweenFeeds: TimeInterval
    var feedingsByMethod: [FeedEvent.FeedMethod: Int]
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

    // Age-appropriate feeding targets
    func targetVolume(for baby: Baby) -> ClosedRange<Double> {
        let months = baby.ageInMonths

        switch months {
        case 0...1:
            return 18.0...32.0 // oz per day
        case 2...3:
            return 24.0...36.0
        case 4...5:
            return 25.0...40.0
        case 6...8:
            return 24.0...32.0 // Starting solids
        case 9...11:
            return 20.0...30.0
        default:
            return 16.0...24.0
        }
    }
}
```

## AI Models

### Insight

```swift
import Foundation
import FirebaseFirestore

struct Insight: Codable, Identifiable {
    @DocumentID var id: String?
    var babyId: String
    var type: InsightType
    var title: String
    var description: String
    var confidence: Double // 0.0 - 1.0
    var data: [String: String] // Supporting data
    var actionable: Bool
    var actionTitle: String?
    var actionRoute: String? // Deep link to relevant screen
    var createdAt: Date
    var expiresAt: Date?
    var dismissed: Bool

    enum InsightType: String, Codable {
        case pattern = "pattern"           // "Pattern Detected"
        case recommendation = "recommendation" // "Recommendation"
        case achievement = "achievement"   // "Achievement Unlocked"
        case warning = "warning"           // "Heads Up"
    }

    var icon: String {
        switch type {
        case .pattern: return "✨"
        case .recommendation: return "🎯"
        case .achievement: return "🏆"
        case .warning: return "⚠️"
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
        case description
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
```

### Prediction

```swift
import Foundation
import FirebaseFirestore

struct Prediction: Codable, Identifiable {
    var id: String { type.rawValue }
    var babyId: String
    var type: PredictionType
    var predictedTime: Date
    var predictedDuration: TimeInterval?
    var confidence: Double // 0.0 - 1.0
    var basedOn: String // Description of data used
    var updatedAt: Date

    enum PredictionType: String, Codable {
        case nextNap = "next_nap"
        case nextFeed = "next_feed"
        case bedtime = "bedtime"
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
```

## Utility Models

### TimelineSection

```swift
import Foundation

struct TimelineSection: Identifiable {
    var id: String { hourLabel }
    var hourLabel: String // "8:00 AM", "9:00 AM", etc.
    var hour: Int
    var events: [AnyBabyEvent]

    struct AnyBabyEvent: Identifiable {
        var id: String
        var event: any BabyEvent
        var eventType: EventType

        init<T: BabyEvent>(_ event: T) {
            self.id = event.id ?? UUID().uuidString
            self.event = event
            self.eventType = event.type
        }
    }
}
```

### DaySummary

```swift
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
```

## Validation Extensions

```swift
extension FeedEvent {
    func validate() -> [String] {
        var errors: [String] = []

        switch method {
        case .bottle:
            if volume == nil {
                errors.append("Volume is required for bottle feeding")
            } else if let vol = volume, vol <= 0 || vol > 12 {
                errors.append("Volume must be between 0 and 12 oz")
            }

        case .breast:
            if duration == nil {
                errors.append("Duration is required for breastfeeding")
            } else if let dur = duration, dur <= 0 || dur > 60 {
                errors.append("Duration must be between 0 and 60 minutes")
            }
            if side == nil {
                errors.append("Side is required for breastfeeding")
            }

        case .solids:
            if foodType == nil || foodType?.isEmpty == true {
                errors.append("Food type is required for solid feeding")
            }

        case .mixed:
            if volume == nil && duration == nil {
                errors.append("Either volume or duration is required for mixed feeding")
            }
        }

        return errors
    }
}

extension SleepEvent {
    func validate() -> [String] {
        var errors: [String] = []

        if let end = endTime, end < startTime {
            errors.append("End time must be after start time")
        }

        if let duration = durationInMinutes, duration > 720 { // 12 hours
            errors.append("Sleep duration seems too long")
        }

        return errors
    }
}
```

## Next Steps
These models should be implemented in the iOS project following the folder structure defined in ARCHITECTURE.md. Each model file should include:
- Import statements
- Main struct/class definition
- Computed properties
- Validation methods
- Helper extensions
