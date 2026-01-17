import SwiftUI

struct EventCard: View {
    let event: any BabyEvent

    var body: some View {
        HStack(spacing: 12) {
            // Event icon
            Image(systemName: event.type.icon)
                .font(.title3)
                .foregroundColor(event.type.color)
                .frame(width: 40, height: 40)
                .background(event.type.color.opacity(0.15))
                .clipShape(Circle())

            // Event details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.type.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(eventSummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private var eventSummary: String {
        if let feed = event as? FeedEvent {
            return feedSummary(feed)
        } else if let sleep = event as? SleepEvent {
            return sleepSummary(sleep)
        } else if let diaper = event as? DiaperEvent {
            return diaperSummary(diaper)
        } else if let milestone = event as? MilestoneEvent {
            return milestoneSummary(milestone)
        }
        return ""
    }

    private func feedSummary(_ feed: FeedEvent) -> String {
        var parts: [String] = [feed.method.displayName]

        if let volume = feed.volume {
            parts.append("\(volume, specifier: "%.1f") oz")
        }
        if let duration = feed.duration {
            parts.append("\(duration) min")
        }
        if let side = feed.side {
            parts.append(side.displayName)
        }

        return parts.joined(separator: " · ")
    }

    private func sleepSummary(_ sleep: SleepEvent) -> String {
        var parts: [String] = []

        if sleep.isNightSleep {
            parts.append("Night sleep")
        } else {
            parts.append("Nap")
        }

        if let duration = sleep.durationFormatted {
            parts.append(duration)
        } else if sleep.isOngoing {
            parts.append("In progress")
        }

        if let quality = sleep.quality {
            parts.append(quality.displayName)
        }

        return parts.joined(separator: " · ")
    }

    private func diaperSummary(_ diaper: DiaperEvent) -> String {
        diaper.diaperType.displayName
    }

    private func milestoneSummary(_ milestone: MilestoneEvent) -> String {
        "\(milestone.title) · \(milestone.category.rawValue)"
    }
}

struct EventCardCompact: View {
    let event: any BabyEvent

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: event.type.icon)
                .font(.caption)
                .foregroundColor(event.type.color)
                .frame(width: 24, height: 24)
                .background(event.type.color.opacity(0.15))
                .clipShape(Circle())

            Text(event.type.displayName)
                .font(.caption)
                .fontWeight(.medium)

            Spacer()

            Text(event.timestamp.timeAgoDisplay)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    List {
        EventCard(event: FeedEvent(
            babyId: "1",
            createdBy: "user1",
            method: .bottle,
            volume: 4.5
        ))

        EventCard(event: SleepEvent(
            babyId: "1",
            createdBy: "user1",
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date(),
            quality: .good,
            isNightSleep: false
        ))

        EventCard(event: DiaperEvent(
            babyId: "1",
            createdBy: "user1",
            diaperType: .both
        ))

        EventCard(event: MilestoneEvent(
            babyId: "1",
            createdBy: "user1",
            title: "First smile",
            category: .social
        ))
    }
}
