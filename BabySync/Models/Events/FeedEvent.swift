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

    var method: FeedMethod
    var volume: Double?
    var unit: VolumeUnit = .oz
    var side: BreastSide?
    var duration: Int?
    var foodType: String?

    enum FeedMethod: String, Codable, CaseIterable {
        case bottle = "bottle"
        case breast = "breast"
        case solids = "solids"
        case mixed = "mixed"

        var displayName: String {
            switch self {
            case .bottle: return "Bottle"
            case .breast: return "Breast"
            case .solids: return "Solids"
            case .mixed: return "Mixed"
            }
        }
    }

    enum BreastSide: String, Codable, CaseIterable {
        case left
        case right
        case both

        var displayName: String {
            rawValue.capitalized
        }
    }

    enum VolumeUnit: String, Codable, CaseIterable {
        case oz
        case ml

        var displayName: String {
            rawValue
        }
    }

    var volumeInML: Double? {
        guard let volume = volume else { return nil }
        switch unit {
        case .oz:
            return volume * 29.5735
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

    init(
        id: String? = nil,
        babyId: String,
        timestamp: Date = Date(),
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        notes: String? = nil,
        photoURLs: [String]? = nil,
        method: FeedMethod,
        volume: Double? = nil,
        unit: VolumeUnit = .oz,
        side: BreastSide? = nil,
        duration: Int? = nil,
        foodType: String? = nil
    ) {
        self.id = id
        self.babyId = babyId
        self.timestamp = timestamp
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.notes = notes
        self.photoURLs = photoURLs
        self.method = method
        self.volume = volume
        self.unit = unit
        self.side = side
        self.duration = duration
        self.foodType = foodType
    }

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
