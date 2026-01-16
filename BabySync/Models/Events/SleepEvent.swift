import Foundation
import FirebaseFirestore

struct SleepEvent: BabyEvent {
    @DocumentID var id: String?
    var babyId: String
    var type: EventType = .sleep
    var timestamp: Date
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date
    var notes: String?
    var photoURLs: [String]?

    var startTime: Date
    var endTime: Date?
    var quality: SleepQuality?
    var isNightSleep: Bool
    var napNumber: Int?

    enum SleepQuality: String, Codable, CaseIterable {
        case excellent
        case good
        case fair
        case poor

        var displayName: String {
            rawValue.capitalized
        }
    }

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

    init(
        id: String? = nil,
        babyId: String,
        timestamp: Date = Date(),
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        photoURLs: [String]? = nil,
        startTime: Date,
        endTime: Date? = nil,
        quality: SleepQuality? = nil,
        isNightSleep: Bool = false,
        napNumber: Int? = nil
    ) {
        self.id = id
        self.babyId = babyId
        self.timestamp = timestamp
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.photoURLs = photoURLs
        self.startTime = startTime
        self.endTime = endTime
        self.quality = quality
        self.isNightSleep = isNightSleep
        self.napNumber = napNumber
    }

    func validate() -> [String] {
        var errors: [String] = []

        if let end = endTime, end < startTime {
            errors.append("End time must be after start time")
        }

        if let duration = durationInMinutes, duration > 720 {
            errors.append("Sleep duration seems too long")
        }

        return errors
    }
}
