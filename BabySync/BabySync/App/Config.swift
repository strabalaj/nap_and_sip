import Foundation

enum Config {
    enum Environment {
        case development
        case staging
        case production
    }

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    static var isDebug: Bool {
        current == .development
    }

    enum Firebase {
        static var projectId: String {
            switch Config.current {
            case .development, .staging:
                return "babysync-dev"
            case .production:
                return "babysync-prod"
            }
        }
    }

    enum App {
        static let minimumIOSVersion = "16.0"
        static let appName = "BabySync"
        static let bundleIdentifier = "com.yourname.babysync"
    }

    enum Defaults {
        static let eventPageSize = 50
        static let maxPhotoAttachments = 5
        static let insightExpirationDays = 7
    }
}
