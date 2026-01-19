import Foundation
import os.log

enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.babysync"

    static let general = os.Logger(subsystem: subsystem, category: "general")
    static let auth = os.Logger(subsystem: subsystem, category: "auth")
    static let firebase = os.Logger(subsystem: subsystem, category: "firebase")
    static let events = os.Logger(subsystem: subsystem, category: "events")
    static let analytics = os.Logger(subsystem: subsystem, category: "analytics")
    static let network = os.Logger(subsystem: subsystem, category: "network")

    static func debug(_ message: String, category: os.Logger = general) {
        #if DEBUG
        category.debug("\(message)")
        #endif
    }

    static func info(_ message: String, category: os.Logger = general) {
        category.info("\(message)")
    }

    static func warning(_ message: String, category: os.Logger = general) {
        category.warning("\(message)")
    }

    static func error(_ message: String, error: Error? = nil, category: os.Logger = general) {
        if let error = error {
            category.error("\(message): \(error.localizedDescription)")
        } else {
            category.error("\(message)")
        }
    }
}
