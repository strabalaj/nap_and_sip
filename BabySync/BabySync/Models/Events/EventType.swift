import Foundation
import SwiftUI

enum EventType: String, Codable, CaseIterable {
    case feed
    case sleep
    case diaper
    case milestone

    var displayName: String {
        switch self {
        case .feed: return "Feeding"
        case .sleep: return "Sleep"
        case .diaper: return "Diaper"
        case .milestone: return "Milestone"
        }
    }

    var icon: String {
        switch self {
        case .feed: return "drop.fill"
        case .sleep: return "moon.fill"
        case .diaper: return "sparkles"
        case .milestone: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .feed: return .blue
        case .sleep: return .indigo
        case .diaper: return .orange
        case .milestone: return .yellow
        }
    }
}
