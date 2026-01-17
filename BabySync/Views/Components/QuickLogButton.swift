import SwiftUI

struct QuickLogButton: View {
    let eventType: EventType
    let action: () -> Void
    var isActive: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isActive ? eventType.color : eventType.color.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: eventType.icon)
                        .font(.title2)
                        .foregroundColor(isActive ? .white : eventType.color)

                    if isActive {
                        Circle()
                            .stroke(eventType.color, lineWidth: 3)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Circle()
                                    .trim(from: 0, to: 0.25)
                                    .stroke(eventType.color, lineWidth: 3)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isActive)
                            }
                    }
                }

                Text(eventType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isActive ? eventType.color : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct QuickLogButtonRow: View {
    let onFeedTap: () -> Void
    let onSleepTap: () -> Void
    let onDiaperTap: () -> Void
    let onMilestoneTap: () -> Void
    var ongoingSleep: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            QuickLogButton(eventType: .feed, action: onFeedTap)
            QuickLogButton(eventType: .sleep, action: onSleepTap, isActive: ongoingSleep)
            QuickLogButton(eventType: .diaper, action: onDiaperTap)
            QuickLogButton(eventType: .milestone, action: onMilestoneTap)
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 32) {
        QuickLogButtonRow(
            onFeedTap: {},
            onSleepTap: {},
            onDiaperTap: {},
            onMilestoneTap: {}
        )

        QuickLogButtonRow(
            onFeedTap: {},
            onSleepTap: {},
            onDiaperTap: {},
            onMilestoneTap: {},
            ongoingSleep: true
        )
    }
}
