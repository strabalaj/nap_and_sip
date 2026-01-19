import SwiftUI

enum Constants {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title3: CGFloat = 20
        static let title2: CGFloat = 24
        static let title: CGFloat = 28
        static let largeTitle: CGFloat = 34
    }

    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }

    enum Icons {
        static let feed = "drop.fill"
        static let sleep = "moon.fill"
        static let diaper = "sparkles"
        static let milestone = "star.fill"
        static let home = "house.fill"
        static let timeline = "clock.fill"
        static let analytics = "chart.line.uptrend.xyaxis"
        static let profile = "person.fill"
        static let add = "plus"
        static let edit = "pencil"
        static let delete = "trash"
        static let settings = "gear"
        static let notification = "bell.fill"
        static let share = "square.and.arrow.up"
    }

    enum DateFormats {
        static let timeOnly = "h:mm a"
        static let dateOnly = "MMM d"
        static let dateTime = "MMM d, h:mm a"
        static let fullDate = "MMMM d, yyyy"
        static let dayOfWeek = "EEEE"
        static let monthYear = "MMMM yyyy"
    }

    enum Firebase {
        static let usersCollection = "users"
        static let babiesCollection = "babies"
        static let eventsCollection = "events"
        static let insightsCollection = "insights"
        static let predictionsCollection = "predictions"
    }
}
