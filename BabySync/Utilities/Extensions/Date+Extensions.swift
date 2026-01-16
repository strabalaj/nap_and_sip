import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }

    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func timeAgo() -> String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 {
            return "Just now"
        } else if minutes < 60 {
            return "\(minutes) min ago"
        } else if hours < 24 {
            return "\(hours) hr ago"
        } else if days == 1 {
            return "Yesterday"
        } else if days < 7 {
            return "\(days) days ago"
        } else {
            return formatted(Constants.DateFormats.dateOnly)
        }
    }

    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }

    func isYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    var relativeTimeString: String {
        if isToday() {
            return "Today, \(formatted(Constants.DateFormats.timeOnly))"
        } else if isYesterday() {
            return "Yesterday, \(formatted(Constants.DateFormats.timeOnly))"
        } else {
            return formatted(Constants.DateFormats.dateTime)
        }
    }
}
