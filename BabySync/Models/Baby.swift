import Foundation
import FirebaseFirestore

struct Baby: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var dateOfBirth: Date
    var gender: Gender?
    var photoURL: String?
    var owners: [String]
    var createdBy: String
    var createdAt: Date
    var updatedAt: Date

    enum Gender: String, Codable {
        case male
        case female
        case other
    }

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

    init(
        id: String? = nil,
        name: String,
        dateOfBirth: Date,
        gender: Gender? = nil,
        photoURL: String? = nil,
        owners: [String] = [],
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.photoURL = photoURL
        self.owners = owners
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
